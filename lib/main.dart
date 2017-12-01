import 'dart:async';

import 'package:angry_arrows/game/level.dart';
import 'package:angry_arrows/screens/screens.dart';
import 'package:flame/flame.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<Null> main() async {
  final googleSignIn = new GoogleSignIn();

//  signIn(googleSignIn);

  // setup preferred landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

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

Future signIn(GoogleSignIn googleSignIn) async {
  // attempt a google sign in
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    await googleSignIn.signIn();
  }
}

// todo figure out how to invoke this via [HomeScreen]
Future signOut(GoogleSignIn googleSignIn) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user != null) {
    await googleSignIn.signOut();
  }
}
