import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:provider/provider.dart';

class RoundSetWait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    if (user.host) {
      final random = new Random();
      List<Round> roundsNotPlayed =
          rounds.where((element) => !element.played).toList();
      if (roundsNotPlayed.isNotEmpty) {
        var i = random.nextInt(roundsNotPlayed.length);
        game.currentRound = roundsNotPlayed[i].id;
      } else {
        game.state = GameState.ENDED;
      }
    }
    return Text("Waiting for Round!");
  }
}
