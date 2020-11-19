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
  String caption = '';
  double size = 40.0;

  @override
  void initState() {
    size = widget.props.size;
    captionCtrl.addListener(() {
      setState(() {
        caption = captionCtrl.text;
      });
    });
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
              TextField(
                controller: captionCtrl,
                decoration: InputDecoration(hintText: "Caption"),
              ),
              Slider(
                value: size,
                onChanged: (newSize) {
                  setState(() {
                    size = newSize;
                  });
                },
                min: 20.0,
                max: 100.0,
                label: "Text Size",
              ),
              RaisedButton(onPressed: () {
                Navigator.pop(context, MemeCaptionProp(caption, size));
              })
            ],
          ),
        )
      ],
    );
  }
}
