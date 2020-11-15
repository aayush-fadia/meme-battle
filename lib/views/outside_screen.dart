import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:provider/provider.dart';
import 'package:nice_button/nice_button.dart';

class OutSideScreen extends StatefulWidget {
  @override
  _OutSideScreenState createState() => _OutSideScreenState();
}

class _OutSideScreenState extends State<OutSideScreen> {
  TextEditingController codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);
    final _formKeyOutside = GlobalKey<FormState>();

    Color hexToColor(String code) {
      return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Meme Battle",
        home: new Material(
            child: new Container(
                padding: const EdgeInsets.all(30.0),
                color: Colors.white,
                child: new Container(
                  child: new Center(
                      child: new Column(children: [
                    new Padding(padding: EdgeInsets.only(top: 140.0)),
                    new Text(
                      "Hi, ${game.myName}",
                      style: new TextStyle(
                          color: hexToColor("#F2A03D"), fontSize: 20.0),
                    ),
                    new Padding(padding: EdgeInsets.only(top: 50.0)),
                    Form(
                        key: _formKeyOutside,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: new InputDecoration(
                                labelText: "Joining Code",
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  borderSide: new BorderSide(),
                                ),
                                //fillColor: Colors.green
                              ),
                              controller: codeCtrl,
                              validator: null,
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 25,
                              ),
                            ),
                            new Padding(padding: EdgeInsets.only(top: 50.0)),
                            NiceButton(
                              // width: 515,
                              elevation: 8.0,
                              radius: 52.0,
                              text: "Create/Join Game",
                              background: Color(0xff5b86e5),
                              onPressed: () {
                                if (codeCtrl.text.isEmpty) {
                                  game.createGame();
                                } else {
                                  game.joinGame(codeCtrl.text);
                                }
                              },
                            ),
                          ],
                        )),
                  ])),
                ))));
  }

// @override
// Widget build(BuildContext context) {
//   Game game = Provider.of<Game>(context);
//   return Center(
//     child: Scaffold(
//       appBar: AppBar(
//         title: Text("OutsideScreen"),
//       ),
//       body: Column(
//         children: [
//           Text("Hi, ${game.myName}"),
//           TextField(
//             controller: codeCtrl,
//             decoration: InputDecoration(hintText: "Enter Game Code Here!"),
//           ),
//           FloatingActionButton.extended(
//               onPressed: () {
//                 if (codeCtrl.text.isEmpty) {
//                   game.createGame();
//                 } else {
//                   game.joinGame(codeCtrl.text);
//                 }
//               },
//               label: Text("Create/Join Game!"))
//         ],
//       ),
//     ),
//   );
// }
}
