import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_battle/utils.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: new Wrap(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Pick Image", style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
            ),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("From Camera"),
            onTap: () async {
              File image = await getCroppedImage(ImageSource.camera);
              Navigator.pop(context, image);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text("From Gallery"),
            onTap: () async {
              File image = await getCroppedImage(ImageSource.gallery);
              Navigator.pop(context, image);
            },
          )
        ],
      ),
    );
  }
}
