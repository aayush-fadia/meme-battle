import 'package:flutter/material.dart';
import 'package:meme_battle/screens/app_home.dart';
import 'package:meme_battle/synced_models_new/app_user.dart';
import 'package:provider/provider.dart';

class MemeBattleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemeBattle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.greenAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider<AppUser>(
        create: (context) => AppUser(),
        child: AppHomeScreen(),
      ),
    );
  }
}

// class MainPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (context) => Game(), child: GameScreen());
//   }
// }
