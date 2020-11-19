import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/synced_models_new/stock_round.dart';
import 'package:meme_battle/views/lobby_new.dart';
import 'package:meme_battle/views/round.dart';
import 'package:meme_battle/views/round_wait.dart';
import 'package:provider/provider.dart';

class GameDecider extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    if (game.state == GameState.LOBBY) {
      return FutureProvider<List<StockRound>>(
        create: (context) => Firestore.instance
            .collection("stock_memes")
            .getDocuments()
            .then((value) => value.documents
            .map((e) => StockRound.fromSnapshot(e))
            .toList()),
        child: Lobby(),
      );
    } else if (game.state == GameState.PLAYING) {
      if (game.currentRound == "null") {
        return RoundSetWait();
      } else {
        return StreamProvider<Round>(
          create: (context) => game.roundsRoot
              .document(game.currentRound)
              .snapshots()
              .map((event) => Round.fromSnapshot(event)),
          child: RoundScreen(),
        );
      }
    } else if (game.state == GameState.ENDED) {
      return Text("Game Has Ended!!");
    } else {
      return Text("Loading!!!!");
    }
  }

}