import 'dart:async';

import 'package:angry_arrows/constants.dart';
import 'package:angry_arrows/data/firebase_adapter.dart';
import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/objects/level.dart';
import 'package:angry_arrows/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:async_loader/async_loader.dart';

typedef void OnPress();

class HomeScreen extends StatefulWidget {
  final Levels levels;

  HomeScreen(this.levels);

  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

//    firebase.login();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        alignment: FractionalOffset.center,
        decoration: const BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.fill,
            image: const AssetImage("assets/images/landscape.png"),
          ),
        ),
        child: new Container(
          margin: const EdgeInsets.fromLTRB(64.0, 0.0, 64.0, 16.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 40.0),
                decoration: const BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.4)),
                child: new Text(
                  "Angry Arrows >:(",
                  // Todo - figure out why fonts aren't displaying
                  style: const TextStyle(
                    inherit: false,
                    fontSize: 64.0,
                    color: Colors.white,
                    package: "angry_arrows",
                    fontFamily: "yatra",
                  ),
                ),
              ),
              _buildButton('Start', _handleStartOnPress),
              _buildButton('Levels', _handleLevelsOnPress),
              _buildButton('Settings', _handleSettingsOnPress),
              _buildButton('Log Out', _handleLogOutOnPress),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStartOnPress() => loadGameScene(widget.levels, 1);

  void _handleLevelsOnPress() {
    firebase.writeScore(
      level: 999,
      score: 555,
    );
    Navigator.of(context).push(
      new MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new LevelsScreen(widget.levels);
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

  void _handleLogOutOnPress() => firebase.logout();

  Widget _buildButton(String text, OnPress onPress) {
    return new Container(
      child: new FlatButton(
        onPressed: onPress,
        child: new Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            new Opacity(
              opacity: 0.69,
              child: new Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(25.0),
                  ),
                ),
                child: new ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 800.0, minHeight: 50.0),
                  child: new Container(),
                ),
              ),
            ),
            new Positioned(
              top: -7.0,
              child: new Container(
                constraints: new BoxConstraints(
                  maxHeight: 64.0,
                  maxWidth: 80.0,
                ),
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: const AssetImage("assets/images/crate.png"),
                  ),
                ),
              ),
            ),
            new Positioned(
              top: 17.0,
              bottom: 25.0,
              left: 100.0,
              child: new Text(
                text.toUpperCase(),
                // Todo - figure out why fonts aren't displaying
                style: const TextStyle(
                  color: Colors.white,
                  package: "angry_arrows",
                  fontFamily: "Marker",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LevelsScreen extends StatefulWidget {
  final Levels levels;

  LevelsScreen(this.levels);

  @override
  State<StatefulWidget> createState() => new _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  SharedPreferences prefs;

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  Widget _renderLevelSelect(BuildContext c) {
    var levelPreviews = <Widget>[
      new BoxItem(
          text: "Main Menu",
          fontSize: 20.0,
          isEnabled: true,
          isValid: true,
          onPressed: () {
            Navigator.pop(context);
          },
          scaffoldContext: c)
    ];

    for (var i = 1; i <= 30; i++) {
      var isValid = i - 1 < widget.levels.levels.length;
      var isEnabled = i <= (prefs?.getInt("CURRENT_LEVEL_INT") ?? 2);

      levelPreviews.add(
        new BoxItem(
            text: "$i",
            isEnabled: isEnabled,
            isValid: isValid,
            onPressed: () {
              if (isEnabled && !isValid) {
                Scaffold.of(c).showSnackBar(const SnackBar(
                    content: const Text(
                        "This level doesn't actually exist.  This is not an error.")));
              } else if (isEnabled) {
                Navigator.pop(context);
                loadGameScene(widget.levels, i);
              }
            },
            scaffoldContext: c),
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
        alignment: FractionalOffset.center,
        decoration: const BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.fill,
            image: const AssetImage("assets/images/landscape.png"),
          ),
        ),
        child: new Builder(builder: (BuildContext c) {
          return new Container(
            child: new AsyncLoader(
                key: _asyncLoaderState,
                initState: (() async =>
                    prefs ??= await SharedPreferences.getInstance()),
                renderLoad: () =>
                    new Center(child: new CircularProgressIndicator()),
                renderError: ([error]) => new Center(
                      child: new Text('Unable to load the level select.'),
                    ),
                renderSuccess: ({data}) => _renderLevelSelect(c)),
          );
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
                  value: prefs.getBool(AppSharedPrefs.showGuides) ?? true,
                  onChanged: (nextValue) => setState(
                        () =>
                            prefs.setBool(AppSharedPrefs.showGuides, nextValue),
                      ),
                ),
              ],
            ),
          ),
          new Container(
            child: new Row(
              children: <Widget>[
                new Text("Override current level"),
                new Slider(
                  // casting int to double because of SharedPrefs flutter implementation issue
                  value: prefs.getInt(AppSharedPrefs.levelOverride)?.toDouble() ?? 2.0,
                  min: 1.0,
                  max: 30.0,
                  divisions: 30,
                  label: prefs.getInt(AppSharedPrefs.levelOverride).toString(),
                  thumbOpenAtMin: true,
                  onChanged: (nextValue) => setState(() =>
                      prefs.setInt(AppSharedPrefs.levelOverride, nextValue.toInt())),
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
