import 'package:flutter/material.dart';

class MemeText extends StatefulWidget {
  final double left;
  final double top;
  final Function ontap;
  final Function(DragUpdateDetails) onpanupdate;
  final double size;
  final String caption;
  final TextAlign align;

  const MemeText(
      {Key key,
      this.left,
      this.top,
      this.ontap,
      this.onpanupdate,
      this.size,
      this.caption,
      this.align})
      : super(key: key);

  @override
  _MemeTextState createState() => _MemeTextState();
}

class _MemeTextState extends State<MemeText> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
          onTap: widget.ontap,
          onPanUpdate: widget.onpanupdate,
          child: Stack(
            children: <Widget>[
              // Stroked text as border.
              Text(
                widget.caption,
                style: TextStyle(
                  fontSize: widget.size,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = Colors.black,
                ),
              ),
              // Solid text as fill.
              Text(
                widget.caption,
                style: TextStyle(
                  fontSize: widget.size,
                  color: Colors.white,
                ),
              ),
            ],
          )),
    );
  }
}
