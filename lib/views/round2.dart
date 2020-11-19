import 'package:flutter/cupertino.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/meme.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:meme_battle/views/round_thinking.dart';
import 'package:meme_battle/views/voting.dart';
import 'package:provider/provider.dart';

class RoundScreen2 extends StatelessWidget {
  bool checkIMemed(List<Meme> memes, String userName) {
    return memes.any((element) => element.author == userName);
  }

  bool checkAllMemed(List<Meme> memes, List<Player> players) {
    return memes.length == players.length;
  }

  @override
  Widget build(BuildContext context) {
    print("Building RoundScreen2");
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    List<Meme> memes = Provider.of<List<Meme>>(context);
    Round round = Provider.of<Round>(context);
    print("ROUND ID IN RoundScreen2: ${round.id}");
    if (round == null) {
      return Text("Loading Round");
    } else if (round.state == RoundState.THINKING) {
      if (checkAllMemed(memes, players)) {
        return VotingScreen();
      } else if (checkIMemed(memes, user.name)) {
        return Text("I have Memed");
      } else {
        return RoundThinking();
      }
    }
  }
}
