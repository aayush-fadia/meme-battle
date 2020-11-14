import 'package:flutter/cupertino.dart';

enum RoundState {
  THINKING,
  VOTING,
  ENDING,
  ENDED
}

class RoundList extends ChangeNotifier {
  final roundsList = new List<String>();
  String round;

}
