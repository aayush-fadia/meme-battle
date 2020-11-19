import 'package:flutter/material.dart';
import 'package:meme_battle/utils.dart';

enum UserState { LOADING, UNSET, SET }

class AppUser extends ChangeNotifier {
  UserState state;
  String _name;

  String get name => _name;

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  bool host;

  AppUser() {
    state = UserState.LOADING;
    getName().then((value) {
      if (value == null) {
        state = UserState.UNSET;
      } else {
        name = value;
        state = UserState.SET;
      }
      notifyListeners();
    });
  }

  void nameSet() async {
    String value = await getName();
    if (value != null) {
      name = value;
      state = UserState.SET;
      notifyListeners();
    }
  }

  Future<String> readFromDisk() async {
    return getName();
  }
}
