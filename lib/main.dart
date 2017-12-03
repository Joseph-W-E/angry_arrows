import 'dart:async';

import 'package:angry_arrows/game/objects/level.dart';
import 'package:angry_arrows/screens/screens.dart';
import 'package:flame/flame.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<Null> main() async {
  // setup Flame
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  // setup the levels
  var dimensions = await Flame.util.initialDimensions();
  var levels = new Levels(dimensions);

  // boot up the home screen
  loadHomeScreen(levels);
}

void loadHomeScreen(Levels levels) => runApp(new MaterialApp(
    home: new Scaffold(
      body: new HomeScreen(levels),
    ),
  ));
