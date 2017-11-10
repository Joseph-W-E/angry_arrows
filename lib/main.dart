import 'dart:async';
import 'dart:ui';

import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/objects.dart';
import 'package:flame/flame.dart';

Future<Null> main() async {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  var dimensions = await Flame.util.initialDimensions();

  var levelConfig = new LevelConfiguration(dimensions: dimensions);
  levelConfig..arrow = (new ArrowConfig()
      ..x = 100.0
      ..y = levelConfig.dimensions.height - 128)
    ..crates = [
      new CrateConfig()
        ..x = levelConfig.dimensions.width - 128
        ..y = levelConfig.dimensions.height - 128,
      new CrateConfig()
        ..x = levelConfig.dimensions.width - 500
        ..y = levelConfig.dimensions.height - 128,
      new CrateConfig()
        ..x = levelConfig.dimensions.width - 350
        ..y = levelConfig.dimensions.height - 128,
    ]
    ..platforms = [
      new PlatformItemConfig()
        ..x = 50.0
        ..y = 110.0,
      new PlatformItemConfig()
        ..x = 100.0
        ..y = 110.0,
      new PlatformItemConfig()
        ..x = 100.0
        ..y = 110.0,
    ];

  var game = new Level(
    dimensions: dimensions,
    config: levelConfig,
  )..start();

  window.onPointerDataPacket = (PointerDataPacket packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}
