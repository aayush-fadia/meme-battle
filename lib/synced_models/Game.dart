import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_battle/univ.dart';
import 'package:path_provider/path_provider.dart';

import 'PlayerList.dart';

enum GameState { FIRST_TIME, OUTSIDE, LOBBY }

class Game extends ChangeNotifier {
  GameState state = GameState.OUTSIDE;
  String code = "-1";
  String myName = "-1";
  PlayerState myState = PlayerState.WAITING;
  bool host = false;
  final db = Firestore.instance;
  final cloud = FirebaseStorage.instance;

  Game() {
    loadNameFromDisk();
  }

  void listenToSnap(DocumentSnapshot snap) {
    Map data = snap.data;
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
    db.document("games/$code/rounds/$roundCode").setData({"uploader": myName});
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
              child: Text(
                  "Uploading Product Data and Images to Server, please wait."),
            )
          ],
        ),
      ),
    );
    final result = showDialog(
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
