import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:provider/provider.dart';

class OutSideScreen extends StatefulWidget {
  @override
  _OutSideScreenState createState() => _OutSideScreenState();
}

class _OutSideScreenState extends State<OutSideScreen> {
  TextEditingController codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text("OutsideScreen"),
        ),
        body: Column(
          children: [
            Text("Hi, ${game.myName}"),
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(hintText: "Enter Game Code Here!"),
            ),
            FloatingActionButton.extended(
                onPressed: () {
                  if (codeCtrl.text.isEmpty) {
                    game.createGame();
                  } else {
                    game.joinGame(codeCtrl.text);
                  }
                },
                label: Text("Create/Join Game!"))
          ],
        ),
      ),
    );
  }
}
