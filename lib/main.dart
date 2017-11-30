import 'dart:async';

import 'package:angry_arrows/screens/screens.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<Null> main() async {
  final googleSignIn = new GoogleSignIn();

  signIn(googleSignIn);

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
