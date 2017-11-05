import 'dart:async';
import 'dart:ui';

import 'package:angry_arrows/game/game.dart';
import 'package:flame/flame.dart';

Future<Null> main() async {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  var game = new Level(
    dimensions: await Flame.util.initialDimensions(),
    config: null,
  )..start();

  window.onPointerDataPacket = (PointerDataPacket packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}
