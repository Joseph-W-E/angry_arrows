// The home screen

// todo Add a widget for the home screen

// todo Include Google sign in

// todo Config Firebase


import 'package:flutter/material.dart';

typedef void StartCallback();

class HomeScreen extends StatefulWidget {
  final StartCallback onStartPressed;

  HomeScreen(this.onStartPressed);

  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {

    return new Container(
      margin: const EdgeInsets.all(16.0),
      child: new FlatButton(
        onPressed: widget.onStartPressed,
        child: new Text('Start'),
      )
    );
  }
}
