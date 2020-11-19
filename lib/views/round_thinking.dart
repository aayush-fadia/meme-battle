import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/utils.dart';
import 'package:meme_battle/views/FaceEdit.dart';
import 'package:meme_battle/views/caption_editor.dart';
import 'package:meme_battle/views/meme_text.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class MemeCaptionProp {
  String caption = "Click Me!";
  int style = 0;

  MemeCaptionProp(this.caption, this.style);
}

class FaceProp {
  String user;
  String url;

  FaceProp(this.user, this.url);
}

class RoundThinking extends StatefulWidget {
  @override
  _RoundThinkingState createState() => _RoundThinkingState();
}

class _RoundThinkingState extends State<RoundThinking> {
  ScreenshotController screenshotController = ScreenshotController();
  List<dynamic> props = [];
  List<ValueNotifier<Matrix4>> notifiers = [];
  bool requestedFile = false;
  File templateImage;
  double heightToWidth = 1;

  Future<String> uploadMeme(BuildContext context, String gameCode,
      String roundCode, File image, String userName) async {
    load_begin(context);
    String url = await uploadAndGetURL(
        image, "games/$gameCode/$roundCode/$userName.png");
    Navigator.pop(context);
    return url;
  }

  @override
  void initState() {
    requestedFile = false;
    templateImage = null;
    super.initState();
  }

  void editComponent(int faceToEdit, List<Player> players) async {
    if (props[faceToEdit] is FaceProp) {
      FaceProp newFace = await showModalBottomSheet<FaceProp>(
          isDismissible: false,
          context: context,
          builder: (context) {
            return FaceEdit(props[faceToEdit], players);
          });
      if (newFace == null) {
        props.removeAt(faceToEdit);
        notifiers.removeAt(faceToEdit);
      } else {
        props[faceToEdit] = newFace;
      }
    } else if (props[faceToEdit] is MemeCaptionProp) {
      MemeCaptionProp newFace = await showModalBottomSheet<MemeCaptionProp>(
          isDismissible: false,
          context: context,
          builder: (context) {
            return CaptionEdit(props[faceToEdit]);
          });
      if (newFace == null) {
        props.removeAt(faceToEdit);
        props.removeAt(faceToEdit);
      } else {
        props[faceToEdit] = newFace;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("Building RoundThinking");
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    Round round = Provider.of<Round>(context);
    if (!requestedFile) {
      downloadImageGetAspectRatioAndFile(round.downloadUrl).then((value) {
        setState(() {
          templateImage = value.item1;
          heightToWidth = value.item2;
        });
      });
    }
    requestedFile = true;
    List<Widget> stackChildren = [
      if (templateImage == null)
        CircularProgressIndicator()
      else
        Image.file(templateImage)
    ];
    for (int i = 0; i < props.length; i++) {
      if (props[i] is FaceProp) {
        stackChildren.add(MatrixGestureDetector(
            onMatrixUpdate: (m, tm, sm, rm) {
              notifiers[i].value = m;
            },
            child: AnimatedBuilder(
                animation: notifiers[i],
                builder: (ctx, child) {
                  return Transform(
                    transform: notifiers[i].value,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            width: heightToWidth *
                                MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: InkWell(
                                onTap: () {
                                  editComponent(i, players);
                                },
                                child:
                                    CachedNetworkImage(imageUrl: props[i].url)))
                      ],
                    ),
                  );
                })));
      } else if (props[i] is MemeCaptionProp) {
        stackChildren.add(MatrixGestureDetector(
            onMatrixUpdate: (m, tm, sm, rm) {
              notifiers[i].value = m;
            },
            child: AnimatedBuilder(
                animation: notifiers[i],
                builder: (ctx, child) {
                  return Transform(
                    transform: notifiers[i].value,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            width: heightToWidth *
                                MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: InkWell(
                                onTap: () {
                                  editComponent(i, players);
                                },
                                child:
                                    MemeText(props[i].caption, props[i].style)))
                      ],
                    ),
                  );
                })));
      }
    }
    return Column(
      children: [
        Screenshot(
          child: Stack(
            children: stackChildren,
          ),
          controller: screenshotController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  onPressed: () async {
                    props.add(MemeCaptionProp("Edit Me!", 0));
                    notifiers.add(ValueNotifier(Matrix4.identity()));
                    int faceToEdit = props.length - 1;
                    editComponent(faceToEdit, players);
                  },
                  child: Icon(Icons.text_fields)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  onPressed: () async {
                    props.add(FaceProp(players[0].name, players[0].url));
                    notifiers.add(ValueNotifier(Matrix4.identity()));
                    int faceToEdit = props.length - 1;
                    editComponent(faceToEdit, players);
                  },
                  child: Icon(Icons.face)),
            ),
          ],
        ),
        FloatingActionButton.extended(
            onPressed: () async {
              File image = await screenshotController.capture();
              String url = await uploadMeme(
                  context, game.code, round.id, image, user.name);
              round.addMeme(game.code, user.name, url);
            },
            label: Text("Submit!")),
        Text("Round ID:${round.id}"),
        Text("Image URL:${round.downloadUrl}"),
      ],
    );
  }
}
