import 'package:cloud_firestore/cloud_firestore.dart';

class Meme {
  String author;
  String url;
  List<String> votes;

  Meme(this.author, this.url, this.votes);

  factory Meme.fromSnapshot(DocumentSnapshot snapShot) {
    return Meme(snapShot.documentID, snapShot.data['url'],
        List<String>.from(snapShot.data['votes'] ?? []));
  }

  void vote(String gameCode, String myName, String roundID) {
    Firestore.instance
        .document("games/$gameCode/rounds/$roundID/memes/$author/")
        .updateData({
      "votes": FieldValue.arrayUnion([myName])
    });
  }
}
