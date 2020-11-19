import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/app_user.dart';
import 'package:meme_battle/synced_models_new/game.dart';
import 'package:meme_battle/utils.dart';
import 'package:meme_battle/views/game.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController codeCtrl = TextEditingController();
  String code = '';

  String getButtonLabel() {
    if (code.isEmpty) {
      return "Create New Game!";
    } else {
      return "Join Game!";
    }
  }

  IconData getIcon() {
    if (code.isEmpty) {
      return Icons.add;
    } else {
      return Icons.group_add;
    }
  }

  Function() getOnPressed(BuildContext context, AppUser user) {
    if (code.isEmpty) {
      return () async {
        String gameId = Game.makeNewGame();
        load_begin(context);
        String url = await uploadFaceAndGetURL(gameId, user.name);
        Game.enterGame(gameId, user.name, url);
        Navigator.pop(context);
        Navigator.popUntil(context, (route) => true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GameParent(gameId, user.name, true)));
      };
    } else {
      return () async {
        load_begin(context);
        String url = await uploadFaceAndGetURL(code, user.name);
        Game.enterGame(code, user.name, url);
        Navigator.pop(context);
        Navigator.popUntil(context, (route) => true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GameParent(code, user.name, false)));
      };
    }
  }

  @override
  void initState() {
    codeCtrl.addListener(() {
      setState(() {
        code = codeCtrl.text;
        print(code);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/welcome.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      "Welcome to",
                      textAlign: TextAlign.center,
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
                      "Welcome to",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Card(
                    child: Column(
                      children: [
                        FutureBuilder(
                            future: getFaceImage(),
                            builder: (context, fileAsync) {
                              if (fileAsync.hasData) {
                                return Image.file(fileAsync.data);
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            user.name,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      "MemeBattle",
                      textAlign: TextAlign.center,
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
                      "MemeBattle",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Game Code",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: codeCtrl,
                      decoration: InputDecoration(
                          hintText:
                              "Enter Game Code to join, leave blank to create"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton.extended(
                      onPressed: getOnPressed(context, user),
                      label: Text(getButtonLabel()),
                      icon: Icon(getIcon()),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
