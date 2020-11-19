import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/synced_models_new/stock_round.dart';
import 'package:meme_battle/utils.dart';
import 'package:meme_battle/views/player_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../univ.dart';

class Lobby extends StatefulWidget {
  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  TextEditingController stockNumCtrl = TextEditingController(text: "0");
  TextEditingController memeTimeoutController =
      TextEditingController(text: "60");
  final _formKey = GlobalKey<FormState>();
  Game game;

  bool checkAllReady(List<Player> players) {
    return !players.any((element) => !element.ready);
  }

  bool amIReady(List<Player> players, String myName) {
    return players.firstWhere((element) => element.name == myName).ready;
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

  // Future<String> makeRound(
  //     BuildContext context, String gameCode, String roundCode) async {
  //   File image = await pickImage();
  //   final cloud = FirebaseStorage.instance;
  //   BuildContext dialogContext;
  //   Dialog d = Dialog(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Row(
  //         children: <Widget>[
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: CircularProgressIndicator(),
  //           ),
  //           Expanded(
  //             child: Text("Uploading Image to Server, pls wait."),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         dialogContext = context;
  //         return d;
  //       },
  //       barrierDismissible: false);
  //   await cloud
  //       .ref()
  //       .child("games/$gameCode/$roundCode/template.png")
  //       .putFile(image)
  //       .onComplete;
  //   String url = await cloud
  //       .ref()
  //       .child("games/$gameCode/$roundCode/template.png")
  //       .getDownloadURL();
  //   Navigator.pop(dialogContext);
  //   return url;
  // }

  @override
  void initState() {
    stockNumCtrl.value = TextEditingValue(text: game?.stockNum?.toString()??'0');
    memeTimeoutController.value =
        TextEditingValue(text: game?.memeTimeout?.toString()??'45');
    stockNumCtrl.addListener(() {
      if (game != null) {
        game.stockNum = int.parse(stockNumCtrl.text);
      }
    });
    memeTimeoutController.addListener(() {
      if (game != null) {
        game.memeTimeout = int.parse(memeTimeoutController.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GameUser user = Provider.of<GameUser>(context);
    game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    List<StockRound> stockRounds = Provider.of<List<StockRound>>(context);
    if (!user.host) {
      stockNumCtrl.text = game?.stockNum?.toString() ?? '0';
      memeTimeoutController.text = game?.memeTimeout?.toString() ?? '45';
    }
    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                //   child: Text("GAME CODE",
                //       style: Theme
                //           .of(context)
                //           .textTheme
                //           .headline5),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: FittedBox(
                      child: Text(
                    game.code.toUpperCase(),
                    style: Theme.of(context).textTheme.headline1,
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      print("Share Invoked");
                    },
                    label: Text("Share Game Code"),
                    icon: Icon(Icons.share),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Text(
                    "${rounds.length} Rounds Added",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      String roundCode = getRoundCode();
                      String url = await pickAndUploadImage(context,
                          "games/${game.code}/$roundCode/template.png");
                      game.addRound(roundCode, url, user.name);
                    },
                    label: Text("Upload a round!"),
                    icon: Icon(Icons.add_photo_alternate),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  children: players.map((e) {
                    return Center(
                        child: PlayerCard(
                      player: e,
                    ));
                  }).toList(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Game Config",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                controller: stockNumCtrl,
                                enabled: user.host,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Enter a Number from 0 to ${stockRounds.length}";
                                  }
                                  int val = int.parse(value);
                                  if (val > stockRounds.length || val < 0) {
                                    return "Enter a Number from 0 to ${stockRounds.length}";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration:
                                    InputDecoration(labelText: "Stock Rounds"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                controller: memeTimeoutController,
                                enabled: user.host,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Enter a Number from 30 to 300";
                                  }
                                  int val = int.parse(value);
                                  if (val > 300 || val < 0) {
                                    return "Enter a Number from 0 to ${stockRounds.length}";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: "Meme Making Timeout"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              game.setReady(user.name, !amIReady(players, user.name));
            },
            label: Text(amIReady(players, user.name) ? "Not Ready" : "Ready"),
            icon: Icon(amIReady(players, user.name) ? Icons.close : Icons.done),
            backgroundColor:
                amIReady(players, user.name) ? Colors.red : Colors.greenAccent,
          ),
          if (user.host)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.extended(
                onPressed: checkAllReady(players)
                    ? () {
                        if (_formKey.currentState.validate()) {
                          load_begin(context);
                          final random = new Random();
                          for (int i = 0; i < game.stockNum; i++) {
                            game.addRound(
                                getRoundCode(),
                                stockRounds[random.nextInt(stockRounds.length)]
                                    .url,
                                'stock');
                          }
                          Navigator.pop(context);
                          game.state = GameState.PLAYING;
                        }
                      }
                    : null,
                label: Text(checkAllReady(players)
                    ? "Start Game!"
                    : "Waiting for everyone to get ready..."),
                backgroundColor:
                    checkAllReady(players) ? Colors.greenAccent : Colors.red,
              ),
            )
        ],
      ),
    );
  }
}
