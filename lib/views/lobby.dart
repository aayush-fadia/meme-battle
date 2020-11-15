import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:provider/provider.dart';

class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color hexToColor(String code) {
      return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    }

    Game game = Provider.of<Game>(context);
    PlayerList playersList = Provider.of<PlayerList>(context);
    return MaterialApp(
        title: "Lobby",
        home: Scaffold(
            appBar: AppBar(title: Text("Lobby", textAlign: TextAlign.center,),
              backgroundColor: Color(0xff5b86e5),),
            body: Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.white,
                child: Container(
                    child: Center(
                        child: Column(children: [
                  Padding(padding: EdgeInsets.only(top: 140.0)),
                  Text(
                    "Welcome to the Lobby!\nPull from left to see who's joined\n\ncode: ${game.code}",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        color: hexToColor("#F2A03D"), fontSize: 25.0),
                  ),
                  new Padding(padding: EdgeInsets.only(top: 50.0)),
                  Card(
                    elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      color: Color(0xff5b86e5),
                          child: ListTile(
                          leading: Icon(Icons.upload_file,
                          color: Colors.white,),
                          title: Text('Upload Your Own Template',
                            style: TextStyle(
                              color: Colors.white,
                            ),),
                          onTap: () {game.makeRoundCustom(context);},
                          )),
                  Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      color: (game.myState==PlayerState.READY)?Colors.lightGreen:Color(0xff5b86e5),
                      child: ListTile(
                          title: Text('READY', textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),),
                          leading: (game.myState==PlayerState.READY)?Icon(Icons.done):null,
                          trailing: (game.myState==PlayerState.READY)?Icon(Icons.done):null,
                          onTap: (){game.ready();},
                      )),
                  if (game.host) Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    color: game.allReady?Colors.lightGreen:Color(0xff5b86e5),
                    child: ListTile(
                      title: Text('START', textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),),
                      enabled: game.allReady,
                      onTap: (){game.allReady?game.start():null;},
                    ),
                  ) else Container(),

                ])))),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
                children: <Widget>[
              DrawerHeader(
                child: Text('Leaderboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),),
                decoration: BoxDecoration(
                  color: Color(0xff5b86e5),
                ),
              ),
              ListView(
                  shrinkWrap: true,
                  children: playersList.playersList
                      .map(
                        (e) => ListTile(
                      leading: Icon(e.state == PlayerState.READY
                          ? Icons.done
                          : Icons.timer),
                      title: Text(e.name),
                      trailing: Text(e.score.toString()),
                    ),
                  )
                      .toList()),
            ]),
          ),
        ),

    );
  }
}
