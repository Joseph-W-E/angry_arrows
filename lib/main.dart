import 'dart:async';

import 'package:angry_arrows/screens/screens.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<Null> main() async {
  // setup preferred landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  // boot up the home screen
  loadHomeScreen();
}

void loadHomeScreen() => runApp(new MaterialApp(
    home: new Scaffold(
      body: new HomeScreen(),
    ),
  ));
