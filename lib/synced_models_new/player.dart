import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  String name;
  int score;
  bool ready;
  String url;

  Player(this.name, this.score, this.ready, this.url);

  factory Player.fromSnapshot(DocumentSnapshot snapShot) {
    return Player(
        snapShot.documentID,
        snapShot.data["score"] ?? null,
        snapShot.data["ready"] ?? false,
        snapShot.data["url"] ??
            "https://i.pinimg.com/236x/c4/34/d8/c434d8c366517ca20425bdc9ad8a32de.jpg");
  }
}
