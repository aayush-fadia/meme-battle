import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PlayerState { WAITING, READY }

PlayerState toPlayerState(String enumString) {
  return PlayerState.values.firstWhere((e) => e.toString() == enumString);
}

class Player {
  String name;
  int score;
  PlayerState state;

  Player.fromSnapshot(DocumentSnapshot snap) {
    Map data = snap.data;
    this.name = snap.documentID;
    this.score = data['score'];
    this.state = toPlayerState(data['status']);
  }
}

class PlayerList extends ChangeNotifier {
  final db = Firestore.instance;
  final playersList = new List<Player>();

  PlayerList(String gameCode) {
    db
        .collection("games/$gameCode/players")
        .snapshots()
        .listen((querySnapshot) {
      playersList.clear();
      querySnapshot.documents.forEach((element) {
        playersList.add(Player.fromSnapshot(element));
      });
      notifyListeners();
    });
  }
}
