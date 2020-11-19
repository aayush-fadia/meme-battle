import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/univ.dart';

enum GameState { OUTSIDE, LOBBY, PLAYING, ENDED }

GameState toGameState(String enumString) {
  return GameState.values.firstWhere((e) => e.toString() == enumString);
}

class Game {
  String code;
  String _currentRound;
  int _stockNum;

  int get stockNum => _stockNum;

  set stockNum(int stockNum) {
    _stockNum = stockNum;
    gameRoot.setData({"stock_num": _stockNum}, merge: true);
  }

  String get currentRound => _currentRound;

  set currentRound(String currentRound) {
    _currentRound = currentRound;
    gameRoot.updateData({"current_round": _currentRound});
  }

  GameState _state;

  GameState get state => _state;

  set state(GameState state) {
    _state = state;
    gameRoot.updateData({"state": _state.toString()});
  }

  static final db = Firestore.instance;
  DocumentReference gameRoot;
  CollectionReference playersRoot;
  CollectionReference roundsRoot;

  Game(this.code, this._currentRound, this._state, this._stockNum) {
    print("Making Game with currentRound=$_currentRound");
    gameRoot = db.document("games/$code");
    playersRoot = gameRoot.collection("players");
    roundsRoot = gameRoot.collection("rounds");
  }

  factory Game.fromSnapshot(DocumentSnapshot snapShot) {
    return Game(snapShot.documentID, snapShot.data["current_round"] ?? "null",
        toGameState(snapShot.data["state"]), snapShot.data["stock_num"] ?? 0);
  }

  static String makeNewGame() {
    String newGameCode = getGameCode();
    Map<String, String> gameData = {
      "current_round": "null",
      "state": GameState.LOBBY.toString()
    };
    db.document("games/$newGameCode").setData(gameData);
    return newGameCode;
  }

  void setReady(String myName, bool ready) {
    playersRoot.document(myName).setData({"ready": ready}, merge: true);
  }

  static Stream<Game> streamGame(String code) {
    return db
        .document("games/$code")
        .snapshots()
        .map((snapShot) => Game.fromSnapshot(snapShot));
  }

  static Stream<List<Player>> streamPlayersOf(String code) {
    return db.document("games/$code").collection("players").snapshots().map(
        (event) => event.documents.map((e) => Player.fromSnapshot(e)).toList());
  }

  static Stream<List<Round>> streamRoundsOf(String code) {
    return db.document("games/$code").collection("rounds").snapshots().map(
        (event) => event.documents.map((e) => Round.fromSnapshot(e)).toList());
  }

  static void enterGame(String code, String myName, String url) async {
    db
        .document("games/$code")
        .collection("players")
        .document(myName)
        .setData({"score": 0, "ready": false, "url": url}, merge: true);
  }

  void loadRound() {
    roundsRoot.getDocuments().then((value) => {
          value.documents.forEach((element) {
            if (!Round.fromSnapshot(element).played) {
              gameRoot.setData(
                  {"current_round": Round.fromSnapshot(element).id},
                  merge: true);
            }
          })
        });
  }

  void addRound(String id, String url, String myName) {
    roundsRoot.document(id).setData({
      "uploader": myName,
      "url": url,
      "played": false,
      "state": RoundState.THINKING.toString()
    });
  }
}
