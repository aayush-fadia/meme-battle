import 'package:flutter/material.dart';
import 'package:meme_battle/deciders/user_decider.dart';

class AppHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MemeBattle!"),
      ),
      body: SingleChildScrollView(
          physics: ClampingScrollPhysics(), child: UserDecider()),
    );
  }
}
