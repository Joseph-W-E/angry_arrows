import 'dart:async';
import 'dart:ui';

import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/level.dart';
import 'package:angry_arrows/home/home.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';

Future<Null> main() async {
  final googleSignIn = new GoogleSignIn();

  // attempt a google sign in
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    await googleSignIn.signIn();
  }

  loadHomeScreen();
}

void loadHomeScreen() => runApp(new MaterialApp(home: new Scaffold(body: new HomeScreen(loadLevel))));

Future<Null> loadLevel() async {
  // unload the home screen

  // setup Flame
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  // setup the levels
  var dimensions = await Flame.util.initialDimensions();
  var levels = new Levels(dimensions);

  // start the game
  var game = new Level(
    dimensions: dimensions,
    config: levels.level2,
    goHome: loadHomeScreen,
  )..start();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);

  // start handling user input
  window.onPointerDataPacket = (PointerDataPacket packet) {
    var pointer = packet.data.first;
    // todo investigate what [packet.data] looks like
    // todo (and maybe see if we can improve touch inputs)
    game.input(pointer.physicalX, pointer.physicalY);
  };
}
