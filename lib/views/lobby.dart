import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:provider/provider.dart';

class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    PlayerList playersList = Provider.of<PlayerList>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Lobby of game ${game.code}"),
        ),
        body: Column(children: [
          Text(
              "This is your Lobby! Pull from the left to see players in the lobby!")
        ]),
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
