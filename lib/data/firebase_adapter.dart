import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAdapter firebase = new FirebaseAdapter();

class FirebaseAdapter {
  // Google-specific
  final GoogleSignIn _google = new GoogleSignIn();

  // Firebase-specific
  FirebaseAnalytics _analytics = new FirebaseAnalytics();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Call this before invoking operations on [FirebaseAdapter].
  Future<Null> initialize() async {
    await _database.setPersistenceEnabled(true);
  }

  // //////////////////////////////
  // Data storage
  // //////////////////////////////

  /// Writes that the user has completed [level] with the given [score].
  void writeScore({int level, int score}) {
    _database.reference().child('database').push().set({
      'level': '$level',
      'score': '$score',
    });
    _analytics.logEvent(name: 'write_score');
  }

  /// Fetches the current score for the level.
  int getScore(int level) {
    return 0; // todo
  }

  /// Fetches the completed levels.
  List<int> getCompletedLevels() {
    return []; // todo
  }

  // //////////////////////////////
  // Logging
  // //////////////////////////////

  void log(String tag) => _analytics.logEvent(name: tag.replaceAll(' ', '_'));

  // //////////////////////////////
  // Log in / out
  // //////////////////////////////

  void login() => _googleSignIn();

  void logout() => _googleSignOut();

  Future _googleSignIn() async {
    var user = _google.currentUser;
    if (user == null) {
      user = await _google.signInSilently();
    }
    if (user == null) {
      await _google.signIn();
      _analytics.logLogin();
    }
//    if (await _auth.currentUser() == null) {
//      var credentials = await _google.currentUser.authentication;
//      await _auth.signInWithGoogle(
//        idToken: credentials.idToken,
//        accessToken: credentials.accessToken,
//      );
//    }
  }

  Future _googleSignOut() async {
    var user = _google.currentUser;
    if (user != null) {
      await _google.signOut();
    }
  }
}
