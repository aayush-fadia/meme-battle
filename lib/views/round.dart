import 'package:flutter/cupertino.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/meme.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/views/round2.dart';
import 'package:provider/provider.dart';

class RoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Building RoundScreen");
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    Round round = Provider.of<Round>(context);
    if (round == null) {
      return Text("Loading Round");
    } else if (round.state == RoundState.THINKING) {
      print("ROUND ID: ${round.id}");
      return StreamProvider<List<Meme>>(
        create: (context) => round.streamMemes(game.code),
        initialData: [],
        child: RoundScreen2(),
      );
    }
  }
}
