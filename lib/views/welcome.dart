import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/app_user.dart';
import 'package:meme_battle/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  File _image;
  final TextEditingController nameCtrl = TextEditingController();
  bool namePut = false;

  @override
  void initState() {
    nameCtrl.addListener(() {
      if (namePut && nameCtrl.text.isEmpty) {
        setState(() {
          namePut = false;
        });
      } else if (!namePut && nameCtrl.text.isNotEmpty) {
        setState(() {
          namePut = true;
        });
      }
    });
    super.initState();
  }

  Color getFABColor(BuildContext context) {
    if (!namePut) {
      return Colors.red;
    }
    if (_image == null) {
      return Colors.red;
    }
    return Theme.of(context).accentColor;
  }

  String getFABLabel(BuildContext context) {
    if (!namePut) {
      return "Enter a Nickname!";
    } else if (_image == null) {
      return "Choose Face Image";
    } else {
      return "Onward!";
    }
  }

  @override
  Widget build(BuildContext context) {
    print(namePut);
    AppUser user = Provider.of<AppUser>(context);
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4.0,
              child: Column(
                children: [
                  _image == null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Click/Pick and Crop a Wacky Image of Your Face",
                            style: Theme.of(context).textTheme.headline3,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Image.file(_image),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton.extended(
                        heroTag: 'btn1',
                        onPressed: () async {
                          File croppedFile =
                              await getCroppedImageBottomSheet(context);
                          setState(() {
                            if (croppedFile != null) {
                              _image = File(croppedFile.path);
                            } else {
                              print('No image selected.');
                            }
                          });
                        },
                        label: Text("Pick Image")),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "What are you called?",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    TextField(
                      decoration:
                          InputDecoration(hintText: "Enter your Nickname"),
                      controller: nameCtrl,
                    ),
                  ],
                ),
              ),
            ),
          ),
          FloatingActionButton.extended(
              backgroundColor: getFABColor(context),
              heroTag: 'btn2',
              onPressed: () async {
                if (_image != null && nameCtrl.text.isNotEmpty) {
                  saveName(nameCtrl.text);
                  Directory appDir = await getApplicationDocumentsDirectory();
                  await _image.copy("${appDir.path}/face.png");
                  user.nameSet();
                }
              },
              label: Text(getFABLabel(context)))
        ],
      ),
    );
  }
}
