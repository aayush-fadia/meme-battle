import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:meme_battle/synced_models/Rounds.dart';
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
      return MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => PlayerList(game.code)),
        ChangeNotifierProvider(
            create: (context) => RoundSync(game.code, game.host))
      ], child: RoundsScreen());
    }
  }
}
