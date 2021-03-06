import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:meme_battle/synced_models/PlayerList.dart';
import 'package:meme_battle/synced_models/Rounds.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundsScreen extends StatelessWidget {
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _requestPermission();
    Game game = Provider.of<Game>(context);
    RoundSync round = Provider.of<RoundSync>(context);
    PlayerList playersList = Provider.of<PlayerList>(context);
    if (round.state == RoundState.THINKING) {
      print("IRESPONDED: " + round.iResponded.toString());
      if (!round.iResponded) {
        round.respond(context, game.myName, round.imageUrl);
      }
      return Scaffold(
          backgroundColor: Colors.orangeAccent,
          body: Center(
            child: Text(
              "Waiting for others",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                  color: Color(0xff5b86e5)),
            ),
          ),
          drawer: Drawer(
            child: Column(children: [
              DrawerHeader(
                child: Text('Players Ranking'),
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
          ));
    } else if (round.state == RoundState.VOTING) {
      List cardList = [];
      List urlList = [];
      round.responses.forEach((element) {
        print(element.imageUrl);
        print(element.player);
      });
      round.responses.forEach((element) {
        if (element.player != game.myName) {
          cardList.add(Item1(element.imageUrl));
          urlList.add(element.player);
        }
      });
      var _currentIndex = 0;
      return Scaffold(
        appBar: AppBar(
          title: Text("Time to VOTE!"),
          backgroundColor: Color(0xff5b86e5),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                height: 425.0,
                enableInfiniteScroll: false,
                aspectRatio: 2.0,
                initialPage: 0,
                onPageChanged: (index, reason) {
                  _currentIndex = index;
                  print("change in page");
                  print(reason);
                  print(_currentIndex);
                },
              ),
              items: cardList.map((card) {
                return Builder(builder: (BuildContext context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.white,
                      child: card,
                    ),
                  );
                });
              }).toList(),
            ),
            new Padding(padding: EdgeInsets.only(top: 20.0)),
            NiceButton(
              // width: 515,
              elevation: 8.0,
              radius: 52.0,
              text: "Vote",
              background: round.iVoted ? Colors.lightGreen : Color(0xff5b86e5),
              onPressed: round.iVoted
                  ? null
                  : () {
                      print(_currentIndex);
                      round.vote(urlList[_currentIndex], game.myName);
                    },
            ),
            new Padding(padding: EdgeInsets.only(top: 20.0)),
            NiceButton(
              // width: 515,
              elevation: 8.0,
              radius: 52.0,
              text: "Save Meme",
              background: Color(0xff5b86e5),
              onPressed: () {
                String img = round.imageUrl;
                _save(img);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(cardList, (index, url) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Color(0xff5b86e5)
                        : Colors.grey,
                  ),
                );
              }),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            DrawerHeader(
              child: Text(
                'Player Rankings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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
      );
    } else if (round.state == RoundState.ENDING) {
      if (!round.iStartedNew) {
        round.iStartedNew = true;
        Future.delayed(Duration(milliseconds: 10000), () {
          if (game.host) {
            game.start();
          } else {
            game.inform();
          }
        });
      }
      List<String> winner = [];

      int max_votes = 0;
      round.votes.forEach((key, value) {
        print(key + " Voted for:");
        if (value.length > max_votes) max_votes = value.length;
        value.forEach((element) {
          print(element);
        });
        print(" ");
      });
      round.votes.forEach((key, value) {
        winner.add(key + ": " + (value.length * 5).toString());
      });
      round.iVoted = false;
      round.iResponded = false;
      round.iStartedNew = false;
      print("Winners:");
      print(winner);
      if (winner.length > 0) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Round-wise Winners"),
              backgroundColor: Color(0xff5b86e5),
            ),
            body: Column(
              children: <Widget>[
                new Padding(padding: EdgeInsets.only(top: 50.0)),
                Expanded(
                    child: SizedBox(
                        height: 200.0,
                        child: ListView.builder(
                          itemCount: winner.length,
                          itemBuilder: (context, i) {
                            return Container(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                  Text(
                                    winner[i].toUpperCase(),
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 2.0,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.blue,
                                          letterSpacing: .5),
                                    ),
                                  ),
                                  Divider(
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                ]));
                          },
                        )))
              ],
            ));
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  _save(String img) async {
    var response = await Dio()
        .get(img, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "hello");
    print(result);
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }
}

class Item1 extends StatelessWidget {
  String image_url;

  //Item1({Key key}) : super(key: key);
  Item1(String url) {
    image_url = url;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.network(image_url),
        ],
      ),
    );
  }
}
