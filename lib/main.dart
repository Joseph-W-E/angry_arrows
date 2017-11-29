import 'dart:async';
import 'dart:ui';

import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/level.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  )..start();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);

  // start handling user input
  window.onPointerDataPacket = (PointerDataPacket packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}
