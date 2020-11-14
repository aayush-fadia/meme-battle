import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  void respond(BuildContext context, String myName) async {
    String roundCode = round;
    db
        .document("games/$gameCode/rounds/$roundCode")
        .setData({"uploader": myName});
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
        .child("games/$gameCode/$roundCode/$myName.png")
        .putFile(image)
        .onComplete;
    Navigator.pop(dialogContext);
  }
}
