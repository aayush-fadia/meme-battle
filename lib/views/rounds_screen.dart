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
      return Scaffold(
          body: Column(
            children: [
              round.imageUrl != null
                  ? Image.network(round.imageUrl)
                  : Container(),
              FloatingActionButton(onPressed: () {
                round.respond(context, game.myName, round.imageUrl);
                game.ready();
              })
            ],
          ),
          drawer: Drawer(
            child: Column(children: [
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
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
        if(element.player != game.myName){
          cardList.add(Item1(element.imageUrl));
          urlList.add(element.player);
        }
      });
      var _currentIndex = 0;
      return Scaffold(
          appBar: AppBar(title: Text("Flutter Card Carousel")),
          body: Column(
            children: <Widget>[
              CarouselSlider(
                options: CarouselOptions(
                  height: 500.0,
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
                        color: Colors.blueAccent,
                        child: card,
                      ),
                    );
                  });
                }).toList(),
              ),
              new Padding(padding: EdgeInsets.only(top: 50.0)),
              NiceButton(
                // width: 515,
                elevation: 8.0,
                radius: 52.0,
                text: "Vote This",
                background: Color(0xff5b86e5),
                onPressed: round.iVoted
                    ? null
                    : () {
                        print(_currentIndex);
                        round.vote(
                            urlList[_currentIndex], game.myName);
                      },
              ),
              NiceButton(
                // width: 515,
                elevation: 8.0,
                radius: 52.0,
                text: "Save This",
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
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ));
    } else if (round.state == RoundState.ENDING) {
      Future.delayed(Duration(milliseconds: 15000), () {
        game.start();
      });
      round.votes.forEach((key, value) {
        print(key + " Voted for:");
        value.forEach((element) {
          print(element);
        });
        print(" ");
      });
      return Container();
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
