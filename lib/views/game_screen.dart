import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:meme_battle/synced_models/Rounds.dart';
import 'package:meme_battle/views/game_end_screen.dart';
import 'package:meme_battle/views/lobby.dart';
import 'package:meme_battle/views/outside_screen.dart';
import 'package:meme_battle/views/rounds_screen.dart';
import 'package:meme_battle/views/set_name.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    if (game.state == GameState.FIRST_TIME) {
      return SetNameView();
    } else if (game.state == GameState.OUTSIDE) {
      return OutSideScreen();
    } else if (game.state == GameState.LOBBY) {
      return ChangeNotifierProvider(
          create: (context) => PlayerList(game.code), child: Lobby());
    } else if (game.state == GameState.PLAYING) {
      print(game.numPlayers);
      print("IS THE NUMBER OF GAME PLAYERS");
      return MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => PlayerList(game.code)),
        ChangeNotifierProvider(
            create: (context) => RoundSync(
                game.code, game.host, game.numPlayers, game.currentRound))
      ], child: RoundsScreen());
    } else if (game.state == GameState.ENDED) {
      return ChangeNotifierProvider(
        create: (context) => PlayerList(game.code),
        child: EndScreen(),
      );
    }
  }
}
