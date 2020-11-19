import 'package:flutter/material.dart';
import 'package:meme_battle/deciders/game_decider.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    print("Building GameHome with currentRound=${game.currentRound}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Game ${game.code}"),
      ),
      body: SingleChildScrollView(
          physics: ClampingScrollPhysics(), child: GameDecider()),
    );
  }
}
