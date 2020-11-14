import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:meme_battle/synced_models/Rounds.dart';
import 'package:provider/provider.dart';

class RoundsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    RoundSync round = Provider.of<RoundSync>(context);
    PlayerList playersList = Provider.of<PlayerList>(context);
    return Scaffold(
        body: Column(
          children: [
            round.imageUrl != null
                ? Image.network(round.imageUrl)
                : Container(),
            FloatingActionButton(onPressed: () {
              round.respond(context, game.myName);
              game.ready();
            })
          ],
        ),
        drawer: Drawer(
          child: Column(children: [
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListView(
                shrinkWrap: true,
                children: playersList.playersList
                    .map(
                      (e) => ListTile(
                        leading: Icon(e.state == PlayerState.READY
                            ? Icons.done
                            : Icons.timer),
                        title: Text(e.name),
                        trailing: Text(e.score.toString()),
                      ),
                    )
                    .toList()),
          ]),
        ));
  }
}
