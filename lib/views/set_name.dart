import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models/Game.dart';
import 'package:nice_button/nice_button.dart';
import 'package:provider/provider.dart';

class SetNameView extends StatefulWidget {
  @override
  _SetNameViewState createState() => _SetNameViewState();
}

class _SetNameViewState extends State<SetNameView> {
  TextEditingController nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Game game = Provider.of<Game>(context);

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
                      'Meme Battle',
                      style: new TextStyle(
                          color: hexToColor("#F2A03D"), fontSize: 25.0),
                    ),
                    new Padding(padding: EdgeInsets.only(top: 50.0)),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: new InputDecoration(
                                labelText: "Nickname",
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide: new BorderSide(),
                                ),
                                //fillColor: Colors.green
                              ),
                              controller: nameCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a nickname';
                                }
                                return null;
                              },
                              style: new TextStyle(fontFamily: "Poppins"),
                            ),
                            new Padding(padding: EdgeInsets.only(top: 50.0)),
                            NiceButton(
                              // width: 515,
                              elevation: 8.0,
                              radius: 52.0,
                              text: "Enter",
                              background: Color(0xff5b86e5),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  game.setName(nameCtrl.text);
                                }
                              },
                            ),
                          ],
                        )),
                  ])),
                ))));
  }
}
