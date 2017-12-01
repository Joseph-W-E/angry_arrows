import 'dart:async';

import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/level.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async_loader/async_loader.dart';

typedef void OnPress();

class HomeScreen extends StatefulWidget {
  Levels levels;
  HomeScreen(this.levels);

  @override
  State<StatefulWidget> createState() => new _HomeScreenState(levels);
}

class _HomeScreenState extends State<HomeScreen> {
  Levels levels;

  _HomeScreenState(this.levels);

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

  void _handleStartOnPress() => loadGameScene(levels, 1);

  void _handleLevelsOnPress() {
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new LevelsScreen(levels);
      }),
    );
  }

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

class LevelsScreen extends StatefulWidget {
  Levels levels;
  LevelsScreen(this.levels);

  @override
  State<StatefulWidget> createState() => new _LevelsScreenState(levels);
}

class _LevelsScreenState extends State<LevelsScreen> {
  Levels levels;
  _LevelsScreenState(this.levels);

  SharedPreferences prefs;

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  Widget _renderLevelSelect(BuildContext c) {
    var levelPreviews = <Widget>[];

    for (var i = 1; i <= 30; i++) {
      var isValid = i - 1 < levels.levels.length;
      var isEnabled = i <= prefs?.getInt("CURRENT_LEVEL_INT") ?? 2;

      levelPreviews.add(
        new GestureDetector(
          onTapUp: ((_) {
            if (isEnabled && !isValid) {
              Scaffold.of(c).showSnackBar(const SnackBar(
                  content: const Text(
                      "This level doesn't actually exist.  This is not an error.")));
            } else if (isEnabled) {
              Navigator.pop(context);
              loadGameScene(levels, i);
            }
          }),
          child: new Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: new DecoratedBox(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/images/crate.png"),
                  fit: BoxFit.fill,
                ),
              ),
              key: new Key("$i"),
              child: new Center(
                child: new Text(
                  "$i",
                  style: new TextStyle(
                    fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                    fontSize: 48.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return new GridView.count(
        primary: false,
        padding: const EdgeInsets.all(25.0),
        childAspectRatio: 1.0,
        mainAxisSpacing: 25.0,
        crossAxisSpacing: 25.0,
        crossAxisCount: 4,
        children: levelPreviews);
  }

  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();

    return new Scaffold(
      key: key,
      body: new Container(
        margin: const EdgeInsets.all(10.0),
        child: new Builder(builder: (BuildContext c) {
          return new AsyncLoader(
              key: _asyncLoaderState,
              initState: (() async =>
                  prefs ??= await SharedPreferences.getInstance()),
              renderLoad: () =>
                  new Center(child: new CircularProgressIndicator()),
              renderError: ([error]) => new Center(
                    child: new Text(
                        'Unable to load the level select.  Good luck with that'),
                  ),
              renderSuccess: ({data}) => _renderLevelSelect(c));
        }),
      ),
    );
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
                new Text("Show launch guides"),
                new Checkbox(
                  value: prefs.getBool("SHOW_GUIDES") ?? false,
                  onChanged: (nextValue) =>
                      setState(() => prefs.setBool("SHOW_GUIDES", nextValue)),
                ),
              ],
            ),
          ),
          new Container(
            child: new Row(
              children: <Widget>[
                new Text("Override current level"),
                new Slider(
                  value: prefs.getInt("CURRENT_LEVEL_INT")?.toDouble() ?? 2.0,
                  min: 1.0,
                  max: 30.0,
                  divisions: 30,
                  label: prefs.getInt("CURRENT_LEVEL_INT").toString(),
                  thumbOpenAtMin: true,
                  onChanged: (nextValue) => setState(() =>
                      prefs.setInt("CURRENT_LEVEL_INT", nextValue.toInt())),
                ),
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
