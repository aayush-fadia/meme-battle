import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_battle/bottom_sheets/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void load_begin(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                children: [Text("Loading!"), CircularProgressIndicator()],
              ),
            )
          ],
        );
      });
}

void saveName(String name) async {
  SharedPreferences sprefs = await SharedPreferences.getInstance();
  sprefs.setString("name", name);
}

Future<String> getName() async {
  SharedPreferences sprefs = await SharedPreferences.getInstance();
  return sprefs.getString("name");
}

Future<String> uploadAndGetURL(File _image, String destination) async {
  final cloudFile = FirebaseStorage.instance.ref().child(destination);
  await cloudFile.putFile(_image).onComplete;
  String url = await cloudFile.getDownloadURL();
  return url;
}

Future<void> saveFaceImage(File _image) async {
  Directory appDir = await getApplicationDocumentsDirectory();
  await _image.copy("${appDir.path}/face.png");
}

Future<File> getFaceImage() async {
  return File((await getApplicationDocumentsDirectory()).path + "/face.png");
}

Future<String> uploadFaceAndGetURL(String gameCode, String myName) async {
  return uploadAndGetURL(
      await getFaceImage(), "games/$gameCode/players/$myName.png");
}

Future<File> getCroppedImage(ImageSource imgSrc) async {
  final picker = ImagePicker();
  var pickedFile =
      await picker.getImage(source: imgSrc, maxWidth: 720, maxHeight: 720);
  final imgpath = pickedFile.path;
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

Future<File> getCroppedImageBottomSheet(BuildContext context) async {
  return await showModalBottomSheet(
      context: context, builder: (ctx) => ImagePickerBottomSheet());
}
