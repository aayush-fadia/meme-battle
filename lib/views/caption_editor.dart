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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Column(
            children: [
              DropdownButton(
                  items: [0, 1]
                      .map((val) => DropdownMenuItem(
                          value: val, child: Text(val.toString())))
                      .toList(),
                  onChanged: (newVal) {
                    style = newVal;
                  }),
              TextField(
                controller: captionCtrl,
                decoration: InputDecoration(hintText: "Caption"),
              ),
              RaisedButton(onPressed: () {
                Navigator.pop(
                    context, MemeCaptionProp(captionCtrl.text, style));
              })
            ],
          ),
        )
      ],
    );
  }
}
