import 'package:cloud_firestore/cloud_firestore.dart';

class StockRound {
  String url;

  StockRound(this.url);

  factory StockRound.fromSnapshot(DocumentSnapshot snapShot) {
    return StockRound(snapShot.data["url"]);
  }
}
