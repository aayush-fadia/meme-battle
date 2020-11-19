import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:provider/provider.dart';

class InGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    if (game.currentRound == "null") {
      return Text("Loading Round!");
    } else {
      return StreamProvider(
          create: (context) => game.roundsRoot
              .document(game.currentRound)
              .snapshots()
              .map((event) => Round.fromSnapshot(event)));
    }
  }
}
