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

class RoundSync extends ChangeNotifier {
  final db = Firestore.instance;
  final cloud = FirebaseStorage.instance;
  String round;
  String imageUrl;
  bool host;
  RoundState state;
  String gameCode;

  RoundSync(String gameCode, bool host_) {
    db.document("games/$gameCode").snapshots().listen((event) {
      round = event.data["round"];
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
        }
      });
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
    db
        .document("games/$gameCode/rounds/$roundCode")
        .setData({"uploader": myName});
    File image = await pickImage(context, imageURL);
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
        .child("games/$gameCode/$roundCode/$myName.png")
        .putFile(image)
        .onComplete;
    Navigator.pop(dialogContext);
  }
}
