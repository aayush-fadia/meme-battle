import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:provider/provider.dart';

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PlayerList playersList = Provider.of<PlayerList>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xff5b86e5),
          title: Text(
            "Game Over",
            textAlign: TextAlign.center,
          )),
      body: ListView(
          shrinkWrap: true,
          children: playersList.playersList
              .map(
                (e) => ListTile(
                  leading: Icon(
                      e.state == PlayerState.READY ? Icons.done : Icons.timer),
                  title: Text(e.name),
                  trailing: Text(e.score.toString()),
                ),
              )
              .toList()),
    );
  }
}
