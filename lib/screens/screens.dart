import 'package:angry_arrows/game/game.dart';
import 'package:flutter/material.dart';

typedef void OnPress();

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
      )
    );
  }

  void _handleStartOnPress() => loadGameScene(1);

  // todo route to new screen (level select)
  void _handleLevelsOnPress() => print('levels on press');

  // todo route to new screen (settings)
  void _handleSettingsOnPress() => print('settings on press');

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

// todo
class SettingsScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return new Text('todo');
  }
}
