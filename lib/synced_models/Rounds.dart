import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' show get;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../image_editor/image_editor.dart';

enum RoundState { THINKING, VOTING, ENDING }

RoundState toRoundState(String enumString) {
  return RoundState.values.firstWhere((e) => e.toString() == enumString);
}

class Response {
  String imageUrl;
  String player;

  Response(this.player, this.imageUrl);
}

class RoundSync extends ChangeNotifier {
  final db = Firestore.instance;
  final cloud = FirebaseStorage.instance;
  String round;
  String imageUrl;
  bool host;
  RoundState state;
  String gameCode;
  int numPlayers;
  List<Response> responses;
  bool iVoted = false;
  Map<String, List<String>> votes;
  String roundWinner;
  bool iResponded = false;
  bool iStartedNew = false;

  RoundSync(String gameCode, bool host_, int numPlayers_, String round_id) {
    numPlayers = numPlayers_;
    this.gameCode = gameCode;
    this.round = round_id;
    db.document("games/$gameCode/rounds/$round").snapshots().listen((event) {
      state = toRoundState(event.data["state"]);
      if (state == RoundState.THINKING) {
        cloud
            .ref()
            .child("games/$gameCode/$round/template.png")
            .getDownloadURL()
            .then((value) {
          imageUrl = value;
          notifyListeners();
        });
      } else if (state == RoundState.VOTING) {
        responses = new List();
        db
            .collection("games/$gameCode/rounds/$round/responses")
            .getDocuments()
            .then((value) {
          value.documents.forEach((element) async {
            String imageUrl = await cloud
                .ref()
                .child("games/$gameCode/$round/${element.documentID}.png")
                .getDownloadURL();
            responses.add(Response(element.documentID, imageUrl));
            print("Added Response!");
            notifyListeners();
          });
        });
      } else if (state == RoundState.ENDING) {
        db
            .collection("games/$gameCode/rounds/$round/votes/")
            .getDocuments()
            .then((event) {
          votes = Map();
          event.documents.forEach((element) {
            votes[element.documentID] = element.data.keys.toList();
          });
          notifyListeners();
        });
      }
    });
    host = host_;
  }

  Future<File> pickImage(BuildContext context, String imgUrl) async {
    var response = await get(imgUrl);
    File file = new File(
        join((await getApplicationDocumentsDirectory()).path, 'imagetest.png'));
    file.writeAsBytesSync(
        response.bodyBytes); // This is a sync operation on a real
    // app you'd probably prefer to use writeAsByte and handle its Future
    File image =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditorPro(
          appBarColor: Colors.blue, bottomBarColor: Colors.blue, image: file);
    }));
    return image;
  }

  void respond(BuildContext context, String myName, String imageURL) async {
    String roundCode = round;
    File image = await pickImage(context, imageURL);
    BuildContext dialogContext;
    iResponded = true;
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
        .child("games/$gameCode/$roundCode/$myName.png")
        .putFile(image)
        .onComplete;
    await db
        .document("games/$gameCode/rounds/$round/responses/$myName")
        .setData({"uploaded": "1"});
    if (host) {
      print("NUMPLAYERS: " + numPlayers.toString());
      db
          .collection("games/$gameCode/rounds/$round/responses")
          .snapshots()
          .listen((event) {
        if (event.documents.length == numPlayers) {
          db
              .document("games/$gameCode/rounds/$round")
              .setData({"state": RoundState.VOTING.toString()});
        }
      });
    }
    Navigator.pop(dialogContext);
    notifyListeners();
  }

  void vote(String forPlayer, String myName) {
    db
        .document("games/$gameCode/rounds/$round/votes/$forPlayer")
        .setData({myName: "1"}, merge: true);
    iVoted = true;
    if (host) {
      db
          .collection("games/$gameCode/rounds/$round/votes/")
          .snapshots()
          .listen((event) {
        int numVotes = 0;
        event.documents.forEach((element) {
          numVotes += element.data.keys.length;
        });
        if (numVotes == numPlayers) {
          db
              .document("games/$gameCode/rounds/$round")
              .updateData({"state": RoundState.ENDING.toString()});
        }
      });
    }
    notifyListeners();
  }
}
