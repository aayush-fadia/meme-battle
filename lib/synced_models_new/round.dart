import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meme_battle/synced_models_new/meme.dart';

enum RoundState { THINKING, VOTING, ENDING }

RoundState toRoundState(String enumString) {
  return RoundState.values.firstWhere((e) => e.toString() == enumString);
}

class Round {
  String id;
  String downloadUrl;
  String uploader;
  bool played;
  RoundState state;

  Round(this.id, this.downloadUrl, this.uploader, this.played, this.state);

  factory Round.fromSnapshot(DocumentSnapshot snapShot) {
    return Round(
        snapShot.documentID,
        snapShot.data["url"],
        snapShot.data["uploader"],
        snapShot.data["played"],
        toRoundState(snapShot.data['state']));
  }

  void addMeme(String gameCode, String userName, String downloadUrl) {
    Firestore.instance
        .document("games/$gameCode/rounds/$id/memes/$userName")
        .setData({"url": downloadUrl, "votes": List<String>()});
  }

  Stream<List<Meme>> streamMemes(String gameCode) {
    return Firestore.instance
        .collection("games/$gameCode/rounds/$id/memes/")
        .snapshots()
        .map((event) =>
            event.documents.map((e) => Meme.fromSnapshot(e)).toList());
  }

  void setPlayed(String gameCode) {
    Firestore.instance
        .document("games/$gameCode/rounds/$id")
        .updateData({"played": true});
  }
}
