import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_battle/synced_models/Rounds.dart';
import 'package:meme_battle/univ.dart';
import 'package:path_provider/path_provider.dart';

import 'PlayerList.dart';

enum GameState { FIRST_TIME, OUTSIDE, LOBBY, PLAYING, ENDED }

GameState toGameState(String enumString) {
  return GameState.values.firstWhere((e) => e.toString() == enumString);
}

class Game extends ChangeNotifier {
  GameState state = GameState.OUTSIDE;
  String code = "-1";
  String myName = "-1";
  PlayerState myState = PlayerState.WAITING;
  bool host = false;
  bool allReady = false;
  String currentRound = "-1";
  List<String> rounds;
  List<String> newRounds;
  int numPlayers;
  final db = Firestore.instance;
  final cloud = FirebaseStorage.instance;

  Game() {
    loadNameFromDisk();
    print("Constructed");
  }

  void listenToSnap(DocumentSnapshot snap) {
    db.document("games/$code").snapshots().listen((event) {
      GameState _state = toGameState(event.data["state"]);
      String currentRound_ = event.data["round"];
      if (_state != state) {
        state = _state;
        notifyListeners();
      }
      if (currentRound != currentRound_) {
        currentRound = currentRound_;
        notifyListeners();
      }
    });
  }

  void ready() {
    myState = PlayerState.READY;
    db
        .document("games/$code/players/$myName")
        .updateData({"status": myState.toString()});
    notifyListeners();
  }

  void toLobby() {
    db
        .document("games/$code")
        .updateData({"state": GameState.LOBBY.toString()});
  }

  bool start() {
    if (newRounds == null) {
      newRounds = new List();
      newRounds.addAll(rounds);
      print(newRounds.length);
      if (newRounds.length > 0) {
        int roundIndex = Random().nextInt(newRounds.length);
        String round_ = newRounds[roundIndex];
        newRounds.removeAt(roundIndex);
        state = GameState.PLAYING;
        db
            .document("games/$code")
            .updateData({"state": state.toString(), "round": round_});
        db
            .document("games/$code/rounds/$round_")
            .updateData({"state": RoundState.THINKING.toString()});
        print("LENGTH OF ROUNDS: " + newRounds.length.toString());
      } else {
        state = GameState.ENDED;
        db.document("games/$code").updateData({"state": state.toString()});
      }
    } else {
      toLobby();
      Future.delayed(Duration(milliseconds: 3000), () {
        if (newRounds.length > 0) {
          int roundIndex = Random().nextInt(newRounds.length);
          String round_ = newRounds[roundIndex];
          newRounds.removeAt(roundIndex);
          state = GameState.PLAYING;
          db
              .document("games/$code")
              .updateData({"state": state.toString(), "round": round_});
          db
              .document("games/$code/rounds/$round_")
              .updateData({"state": RoundState.THINKING.toString()});
          print("LENGTH OF ROUNDS: " + newRounds.length.toString());
        } else {
          state = GameState.ENDED;
          db.document("games/$code").updateData({"state": state.toString()});
          notifyListeners();
        }
      });
    }
  }

  Future<void> loadNameFromDisk() async {
    String name = await getStringFromPrefs("myName");
    if (name == null) {
      state = GameState.FIRST_TIME;
    } else {
      myName = name;
    }
    notifyListeners();
  }

  void setName(String name) {
    saveString("myName", name);
    myName = name;
    state = GameState.OUTSIDE;
    notifyListeners();
  }

  void createGame() {
    code = getGameCode();
    state = GameState.LOBBY;
    db.document("games/$code").setData({"state": state.toString()});
    host = true;
    enterGame();
    notifyListeners();
  }

  void inform() {
    notifyListeners();
  }

  void joinGame(String gameCode) {
    code = gameCode;
    host = false;
    state = GameState.LOBBY;
    enterGame();
    notifyListeners();
  }

  void enterGame() {
    db
        .document("games/$code/players/$myName")
        .setData({"score": 0, "status": myState.toString()});
    db.document("games/$code").snapshots().listen((snap) {
      listenToSnap(snap);
    });
    //Host Listens to all player states, and sets all ready accordingly!
    //Host starts logging round additions!
    if (host) {
      db.collection("games/$code/rounds").snapshots().listen((event) {
        rounds = event.documents.map((e) => e.documentID).toList();
        print("No. of elements in roundList is:" + rounds.length.toString());
      });
      print("Listening to Plauyers!");
      db.collection("games/$code/players").snapshots().listen((event) {
        bool _allReady = true;
        int numPlayers_ = 0;
        event.documents.forEach((element) {
          print("CHECK READY!!!!!!");
          print(_allReady);
          print(Player.fromSnapshot(element).state == PlayerState.READY);
          print(" ");
          numPlayers_ = numPlayers_ + 1;
          numPlayers = numPlayers_;
          print("ADDED SET NUM_PLAYERS TO " + numPlayers_.toString());
          _allReady = _allReady &&
              Player.fromSnapshot(element).state == PlayerState.READY;
          if (allReady != _allReady) {
            allReady = _allReady;
            print("ALL READY CHANGED!");
            print("SET NUM_PLAYERS TO " + numPlayers.toString());
            notifyListeners();
          }
        });
      });
    }
  }

  Future<File> pickImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 720, maxHeight: 720);
    final directory = await getTemporaryDirectory();
    final imgpath = "${directory.path}/cimg.png";
    image.copy(imgpath);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imgpath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    return croppedFile;
  }

  void makeRoundCustom(BuildContext context) async {
    String roundCode = getRoundCode();
    db
        .document("games/$code/rounds/$roundCode")
        .setData({"uploader": myName, "state": RoundState.THINKING.toString()});
    File image = await pickImage();
    BuildContext dialogContext;
    Dialog d = Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            Expanded(
              child: Text("Uploading Image to Server, pls wait."),
            )
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (context) {
          dialogContext = context;
          return d;
        },
        barrierDismissible: false);
    await cloud
        .ref()
        .child("games/$code/$roundCode/template.png")
        .putFile(image)
        .onComplete;
    Navigator.pop(dialogContext);
  }
}
