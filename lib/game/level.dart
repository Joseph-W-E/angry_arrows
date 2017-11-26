import 'dart:ui';

import 'package:angry_arrows/game/game.dart';
import 'package:angry_arrows/game/objects.dart';

/// [Levels] is a resource for levels in the game.
///
/// [_dimensions] should ONLY be used for determining height of objects.
class Levels {
  Size _dimensions;

  Levels(this._dimensions);

  LevelConfiguration getLevel(int level) {
    return levels[level - 1];
  }

  List<LevelConfiguration> get levels => [
    level1,
  ];

  LevelConfiguration get level1 => new LevelConfiguration(dimensions: _dimensions)
      ..arrow = (_defaultArrowConfig)
      ..crates = [
        new CrateConfig()
          ..x = _dimensions.width - 128
          ..y = _dimensions.height - 128,
        new CrateConfig()
          ..x = _dimensions.width - 500
          ..y = _dimensions.height - 128,
        new CrateConfig()
          ..x = _dimensions.width - 350
          ..y = _dimensions.height - 128,
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

  LevelConfiguration get level2 => new LevelConfiguration(dimensions: _dimensions)
      ..arrow = (_defaultArrowConfig)
      ..crates = [
        new CrateConfig()
          ..x = 2000.0
          ..y = _height - 128,
        new CrateConfig()
          ..x = 1600.0
          ..y = _height - 128,
        new CrateConfig()
          ..x = 700.0
          ..y = _height - 128,
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

  ArrowConfig get _defaultArrowConfig => new ArrowConfig()
    ..x = 300.0
    ..y = _height - 400.0;

  double get _height => _dimensions.height;
}

class LevelConfiguration {
  ArrowConfig arrow;
  List<CrateConfig> crates;
  List<PlatformItemConfig> platforms;

  final Size dimensions;

  LevelConfiguration({this.dimensions}) : assert(dimensions != null);
}