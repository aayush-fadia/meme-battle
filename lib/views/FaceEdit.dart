import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/player.dart';
import 'package:meme_battle/views/round_thinking.dart';

class FaceEdit extends StatefulWidget {
  final FaceProp props;
  final players;
  FaceEdit(this.props, this.players);

  @override
  _FaceEditState createState() => _FaceEditState();
}

class _FaceEditState extends State<FaceEdit> {
  Player player;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            children: [
              DropdownButton(
                  items: widget.players
                      .map<DropdownMenuItem<Player>>((e) =>
                      DropdownMenuItem<Player>(
                          value: e, child: Text(e.name)))
                      .toList()
                      .toList(),
                  onChanged: (value) {
                    player = value;
                  }),
              RaisedButton(onPressed: () {
                Navigator.pop(
                    context, FaceProp(player.name, player.url)
                );
              })
            ],
          ),
        )
      ],
    );
  }
}
