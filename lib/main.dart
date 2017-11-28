import 'dart:async';
import 'dart:ui';

import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/level.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

Future<Null> main() async {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  var dimensions = await Flame.util.initialDimensions();
  var levels = new Levels(dimensions);

  var game = new Level(
    dimensions: dimensions,
    config: levels.level2,
  )..start();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);

  window.onPointerDataPacket = (PointerDataPacket packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}
