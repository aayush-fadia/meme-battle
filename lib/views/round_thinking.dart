import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/views/FaceEdit.dart';
import 'package:meme_battle/views/caption_editor.dart';
import 'package:meme_battle/views/meme_text.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class MemeCaptionProp {
  String caption = "Click Me!";
  double size = 24;
  Offset offset = Offset.zero;

  MemeCaptionProp(this.caption, this.size);
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
  List<MemeCaptionProp> captions = [];
  List<FaceProp> faceProps = [];
  List<ValueNotifier<Matrix4>> faceNotifiers = [];

  void addCaption(BuildContext context) async {
    MemeCaptionProp newCaption = await showModalBottomSheet<MemeCaptionProp>(
        context: context,
        builder: (context) {
          return CaptionEdit(MemeCaptionProp("Enter Caption", 40));
        });
    captions.add(newCaption);
    setState(() {});
  }

  Future<String> uploadMeme(BuildContext context, String gameCode,
      String roundCode, File image, String userName) async {
    final cloud = FirebaseStorage.instance;
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
        .child("games/$gameCode/$roundCode/$userName.png")
        .putFile(image)
        .onComplete;
    String url = await cloud
        .ref()
        .child("games/$gameCode/$roundCode/$userName.png")
        .getDownloadURL();
    Navigator.pop(dialogContext);
    return url;
  }

  void showCaptionBottomSheet(int key) {}

  @override
  Widget build(BuildContext context) {
    print("Building RoundThinking");
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    Round round = Provider.of<Round>(context);
    List<Widget> stackChildren = [
      CachedNetworkImage(
        imageUrl: round.downloadUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    ];
    for (var key = 0; key < captions.length; key++) {
      stackChildren.add(MemeText(
        left: captions[key].offset.dx,
        top: captions[key].offset.dy,
        // ontap: () {
        //   scaf.currentState
        //       .showBottomSheet((context) {
        //     return Sliders(
        //       size: f.key,
        //       sizevalue:
        //       fontsize[f.key].toDouble(),
        //     );
        //   });
        // },
        onpanupdate: (details) {
          setState(() {
            captions[key].offset = Offset(
                captions[key].offset.dx + details.delta.dx,
                captions[key].offset.dy + details.delta.dy);
          });
        },
        caption: captions[key].caption,
        size: captions[key].size,
        align: TextAlign.center,
      ));
    }

    for (int i = 0; i < faceProps.length; i++) {
      stackChildren.add(MatrixGestureDetector(
          onMatrixUpdate: (m, tm, sm, rm) {
            faceNotifiers[i].value = m;
          },
          child: AnimatedBuilder(
              animation: faceNotifiers[i],
              builder: (ctx, child) {
                return Transform(
                  transform: faceNotifiers[i].value,
                  child: Stack(
                    children: <Widget>[
                      CachedNetworkImage(imageUrl: faceProps[i].url)
                    ],
                  ),
                );
              })));
    }
    return Scaffold(
      appBar: AppBar(title: Text("Make Your Meme!")),
      body: Column(
        children: [
          Screenshot(
            child: Stack(
              children: stackChildren,
            ),
            controller: screenshotController,
          ),
          FloatingActionButton.extended(
              onPressed: () async {
                MemeCaptionProp newCaption =
                    await showModalBottomSheet<MemeCaptionProp>(
                        context: context,
                        builder: (context) {
                          return CaptionEdit(
                              MemeCaptionProp("Enter Caption", 40));
                        });
                captions.add(newCaption);
                setState(() {});
              },
              label: Text("Add Caption!")),
          FloatingActionButton.extended(
              onPressed: () async {
                FaceProp newFace = await showModalBottomSheet<FaceProp>(
                    context: context,
                    builder: (context) {
                      return FaceEdit(
                          FaceProp(players[0].name, players[0].url), players);
                    });
                faceProps.add(newFace);
                faceNotifiers.add(ValueNotifier(Matrix4.identity()));
                setState(() {});
              },
              label: Text("Add Face")),
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
      ),
    );
  }
}
