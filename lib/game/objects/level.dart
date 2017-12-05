import 'dart:ui';

import 'package:angry_arrows/game/objects/objects.dart';

/// [Levels] is a resource for levels in the game.
class Levels {
  Size _dimensions;

  Levels(this._dimensions);

  LevelConfiguration getLevel(int level) {
    if (level > 0 && level < levels.length + 1) {
      return levels[level - 1];
    }
    return null;
  }

  List<LevelConfiguration> get levels => [
        level1,
        level2,
        level3,
      ];

  LevelConfiguration get level1 =>
      new LevelConfiguration(dimensions: _dimensions)
        ..level = 1
        ..landscape = new LandscapeConfig(
          width: _dimensions.width,
          height: _dimensions.height,
          x: _dimensions.width / 2,
          y: _dimensions.height / 2,
        )
        ..arrow = _defaultArrowConfig
        ..crates = [
          new CrateConfig()
            ..x = 500.0
            ..y = _height - 198,
        ]
        ..platforms = [
          new PlatformConfig()
            ..x = 500.0
            ..y = _height - 110,
        ];

  LevelConfiguration get level2 =>
      new LevelConfiguration(dimensions: _dimensions)
        ..level = 2
        ..landscape = new LandscapeConfig(
          width: _dimensions.width,
          height: _dimensions.height,
          x: _dimensions.width / 2,
          y: _dimensions.height / 2,
        )
        ..arrow = _defaultArrowConfig
        ..crates = [
          new CrateConfig()
            ..x = 2000.0
            ..y = _height - 198,
          new CrateConfig()
            ..x = 1600.0
            ..y = _height - 198,
          new CrateConfig()
            ..x = 700.0
            ..y = _height - 198,
        ]
        ..platforms = [
          new PlatformConfig()
            ..x = 2000.0
            ..y = _height - 110,
          new PlatformConfig()
            ..x = 1600.0
            ..y = _height - 110,
          new PlatformConfig()
            ..x = 700.0
            ..y = _height - 110,
        ];

  LevelConfiguration get level3 =>
      new LevelConfiguration(dimensions: _dimensions)
        ..level = 3
        ..landscape = new LandscapeConfig(
          width: _dimensions.width,
          height: _dimensions.height,
          x: _dimensions.width / 2,
          y: _dimensions.height / 2,
        )
        ..arrow = _defaultArrowConfig
        ..crates = [
          new CrateConfig()
            ..x = 1600.0
            ..y = _height - 198,
          new CrateConfig()
            ..x = 700.0
            ..y = _height - 198,
          new CrateConfig()
            ..x = 1000.0
            ..y = _height - 500,
          new CrateConfig()
            ..x = 1150.0
            ..y = _height - 500,
          new CrateConfig()
            ..x = 1300.0
            ..y = _height - 500,

        ]
        ..platforms = [
          new PlatformConfig()
            ..x = 1600.0
            ..y = _height - 110,
          new PlatformConfig()
            ..x = 700.0
            ..y = _height - 110,
          new PlatformConfig()
            ..x = 1134.0
            ..y = _height - 420
        ];

  ArrowConfig get _defaultArrowConfig => new ArrowConfig()
    ..x = 300.0
    ..y = _height - 400.0;

  double get _height => _dimensions.height;
}

class LevelConfiguration {
  int level;
  LandscapeConfig landscape;
  ArrowConfig arrow;
  List<CrateConfig> crates;
  List<PlatformConfig> platforms;

  final Size dimensions;

  LevelConfiguration({this.dimensions}) : assert(dimensions != null);
}
