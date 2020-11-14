import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meme_battle/univ.dart';

import 'PlayerList.dart';

enum GameState { FIRST_TIME, OUTSIDE, LOBBY }

class Game extends ChangeNotifier {
  GameState state = GameState.OUTSIDE;
  String code = "-1";
  String myName = "-1";
  PlayerState myState = PlayerState.WAITING;
  bool host = false;
  final db = Firestore.instance;

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
}
