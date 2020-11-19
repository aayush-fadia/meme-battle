import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/views/game_home.dart';
import 'package:provider/provider.dart';

class GameParent extends StatelessWidget {
  final String gameCode;
  final String userName;
  final bool host;

  GameParent(this.gameCode, this.userName, this.host);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Game>(
          create: (context) => Game.streamGame(gameCode),
          initialData: Game("Loading", "Loading", null, 0),
        ),
        Provider<GameUser>(
          create: (context) => GameUser(userName, host),
        ),
        StreamProvider<List<Player>>(
          create: (context) => Game.streamPlayersOf(gameCode),
          initialData: [],
        ),
        StreamProvider<List<Round>>(
          create: (context) => Game.streamRoundsOf(gameCode),
          initialData: [],
        )
      ],
      child: GameScreen(),
    );
  }
}
