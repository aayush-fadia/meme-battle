import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:provider/provider.dart';

class SetNameView extends StatefulWidget {
  @override
  _SetNameViewState createState() => _SetNameViewState();
}

class _SetNameViewState extends State<SetNameView> {
  TextEditingController nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("MemeBattle"),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: "Enter Your Nickname!"),
              controller: nameCtrl,
            ),
            FloatingActionButton.extended(
                onPressed: () {
                  game.setName(nameCtrl.text);
                },
                label: Text("Confirm Name!"))
          ],
        ),
      ),
    );
  }
}
