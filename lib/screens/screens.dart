import 'dart:async';

import 'package:angry_arrows/data/firebase_adapter.dart';
import 'package:angry_arrows/game/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async_loader/async_loader.dart';

typedef void OnPress();

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    firebase.login();
  }

  @override
  Widget build(BuildContext context) {
    // todo theme things (maybe add background?)
    return new Container(
        alignment: FractionalOffset.center,
        margin: const EdgeInsets.all(64.0),
        child: new Column(
          children: <Widget>[
            _buildButton('Start', _handleStartOnPress),
            _buildButton('Levels', _handleLevelsOnPress),
            _buildButton('Settings', _handleSettingsOnPress),
            _buildButton('Log Out', _handleLogOutOnPress),
          ],
        ));
  }

  void _handleStartOnPress() => loadGameScene(1);

  // todo route to new screen (level select)
  void _handleLevelsOnPress() => firebase.writeScore(level: 999, score: 555);

  // todo route to new screen (settings)
  _handleSettingsOnPress() async {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new SettingsScreen();
      }),
    );
  }

  // todo log out of google account
  void _handleLogOutOnPress() => print('log out on press');

  // todo style containers for game theme
  Widget _buildButton(String text, OnPress onPress) {
    return new Container(
      child: new FlatButton(
        onPressed: onPress,
        child: new Text(
          text,
          style: const TextStyle(),
        ),
      ),
    );
  }
}

// todo
class LevelsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LevelsScreenState();
}

class _LevelsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return new Text('todo');
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();
  SharedPreferences prefs;

  Widget _renderPreferences() {
    return new Container(
      margin: const EdgeInsets.all(20.0),
      child: new Column(
        children: <Widget>[
          new Container(
            child: new Row(
              children: <Widget>[
                new Checkbox(
                  value: prefs.getBool("SHOW_GUIDES") ?? false,
                  onChanged: (nextValue) =>
                      setState(() => prefs.setBool("SHOW_GUIDES", nextValue)),
                ),
                new Text("Show launch guides"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var asyncLoader = new AsyncLoader(
      key: _asyncLoaderState,
      initState: (() async => prefs ??= await (() async {
            await new Future.delayed(new Duration(milliseconds: 500));
            return await SharedPreferences.getInstance();
          }())),
      renderLoad: () => new Center(child: new CircularProgressIndicator()),
      renderError: ([error]) => new Center(
            child: new Text(
                'Unable to load shared preferences.  Good luck with that'),
          ),
      renderSuccess: ({data}) => _renderPreferences(),
    );

    return new Scaffold(
        appBar: new AppBar(title: new Text("Settings")), body: asyncLoader);
  }
}
