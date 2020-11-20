import 'package:flutter/material.dart';
import 'package:meme_battle/views/round_thinking.dart';

class FaceEdit extends StatefulWidget {
  final FaceProp faceProp;
  final players;

  FaceEdit(this.faceProp, this.players);

  @override
  _FaceEditState createState() => _FaceEditState();
}

class _FaceEditState extends State<FaceEdit> {
  FaceProp faceProp;

  @override
  void initState() {
    faceProp = widget.faceProp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Face of "),
                    DropdownButton(
                        value: faceProp.user,
                        items: List<DropdownMenuItem<String>>.from(widget
                            .players
                            .map((val) => DropdownMenuItem<String>(
                                value: val.name, child: Text(val.name)))
                            .toList()),
                        onChanged: (value) {
                          faceProp = FaceProp(value.name, value.url);
                        }),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.pop(context, faceProp);
                          },
                          label: Text("Confirm"),
                          icon: Icon(Icons.done),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          label: Text("Delete"),
                          icon: Icon(Icons.delete_forever),
                          backgroundColor: Colors.red,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
