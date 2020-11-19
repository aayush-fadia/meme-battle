import 'package:flutter/material.dart';

class MemeText extends StatelessWidget {
  final String text;
  final int style;

  MemeText(this.text, this.style);

  @override
  Widget build(BuildContext context) {
    if (style == 0) {
      return Stack(
        children: <Widget>[
          // Stroked text as border.
          Text(
            text,
            style: TextStyle(
              fontSize: 60,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.black,
            ),
          ),
          // Solid text as fill.
          Text(
            text,
            style: TextStyle(
              fontSize: 60,
              color: Colors.white,
            ),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyText2,
      );
    }
  }
}
