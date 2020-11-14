import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

const chars = "abcdefghijklmnopqrstuvwxyz";

void saveString(String key, String s) async {
  SharedPreferences sprefs = await SharedPreferences.getInstance();
  sprefs.setString(key, s);
}

Future<String> getStringFromPrefs(String key) async {
  SharedPreferences sprefs = await SharedPreferences.getInstance();
  return sprefs.getString(key);
}

String getGameCode() {
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < 5; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}

String getRoundCode() {
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < 8; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}
