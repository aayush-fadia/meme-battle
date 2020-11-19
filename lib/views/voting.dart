import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/synced_models_new/game_user.dart';
import 'package:meme_battle/synced_models_new/meme.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/synced_models_new/round.dart';
import 'package:provider/provider.dart';

class VotingScreen extends StatelessWidget {
  bool checkVoted(List<Meme> memes, String myName) {
    return memes.any((element) => didIVoteForThis(element, myName));
  }

  bool didIVoteForThis(Meme meme, String myName) {
    return meme.votes.contains(myName);
  }

  bool didEveryoneVote(List<Player> players, List<Meme> memes) {
    int voteCount = 0;
    memes.forEach((element) {
      voteCount += element.votes.length;
    });
    return voteCount == players.length;
  }

  Function() getOnClick(String gameCode, String roundID, List<Meme> memes,
      Meme meme, String myName) {
    if (!checkVoted(memes, myName)) {
      return () {
        meme.vote(gameCode, myName, roundID);
      };
    } else {
      return null;
    }
  }

  String getLabel(String gameCode, String roundID, List<Meme> memes, Meme meme,
      String myName) {
    if (!checkVoted(memes, myName)) {
      return "Vote for This!";
    } else {
      if (didIVoteForThis(meme, myName)) {
        return "Already Voted for this!";
      } else {
        return "Already Voted for Something Else";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building Voting");
    GameUser user = Provider.of<GameUser>(context);
    Game game = Provider.of<Game>(context);
    List<Player> players = Provider.of<List<Player>>(context);
    List<Round> rounds = Provider.of<List<Round>>(context);
    List<Meme> memes = Provider.of<List<Meme>>(context);
    Round round = Provider.of<Round>(context);
    if (!didEveryoneVote(players, memes)) {
      return Scaffold(
        body: ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.from(memes.map((e) {
              return Card(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: e.url,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    FloatingActionButton.extended(
                        onPressed: getOnClick(
                            game.code, round.id, memes, e, user.name),
                        label: Text(
                            getLabel(game.code, round.id, memes, e, user.name)))
                  ],
                ),
              );
            }))),
      );
    } else {
      if (user.host) {
        round.setPlayed(game.code);
        Future.delayed(Duration(milliseconds: 10000), () {
          game.currentRound = "null";
        });
      }
      return Scaffold(
        body: ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.from(memes.map((e) {
              return Card(
                child: Column(
                  children: [
                    Text(e.author),
                    CachedNetworkImage(
                      imageUrl: e.url,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Text(e.votes.toString())
                  ],
                ),
              );
            }))),
      );
    }
  }
}
