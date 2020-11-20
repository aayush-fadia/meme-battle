import 'package:flutter/material.dart';
import 'package:meme_battle/views/round_thinking.dart';

class CaptionEdit extends StatefulWidget {
  final MemeCaptionProp props;

  CaptionEdit(this.props);

  @override
  _CaptionEditState createState() => _CaptionEditState();
}

class _CaptionEditState extends State<CaptionEdit> {
  TextEditingController captionCtrl = TextEditingController();
  int style = 0;
  MemeCaptionProp captionProp;

  @override
  void initState() {
    captionProp = widget.props;
    captionCtrl.value = TextEditingValue(text: captionProp.caption);
    captionCtrl.addListener(() {
      captionProp.caption = captionCtrl.text;
    });
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: captionCtrl,
                    decoration: InputDecoration(labelText: "Caption"),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Face of "),
                    DropdownButton(
                        value: captionProp.style,
                        items: List<DropdownMenuItem<String>>.from([
                          "Memey",
                          "Normal"
                        ]
                            .map((val) =>
                            DropdownMenuItem<String>(
                                value: val, child: Text(val)))
                            .toList()),
                        onChanged: (value) {
                          captionProp =
                              MemeCaptionProp(captionCtrl.text, value);
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
                            Navigator.pop(context, captionProp);
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
