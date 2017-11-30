import 'dart:ui';

import 'package:angry_arrows/game/objects.dart';

/// [Levels] is a resource for levels in the game.
class Levels {
  Size _dimensions;

  Levels(this._dimensions);

  LevelConfiguration getLevel(int level) {
    return levels[level - 1];
  }

  List<LevelConfiguration> get levels => [
    level1,
    level2,
  ];

  LevelConfiguration get level1 => new LevelConfiguration(dimensions: _dimensions)
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

  LevelConfiguration get level2 => new LevelConfiguration(dimensions: _dimensions)
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

  ArrowConfig get _defaultArrowConfig => new ArrowConfig()
    ..x = 300.0
    ..y = _height - 400.0;

  double get _height => _dimensions.height;
}

class LevelConfiguration {
  LandscapeConfig landscape;
  ArrowConfig arrow;
  List<CrateConfig> crates;
  List<PlatformConfig> platforms;

  final Size dimensions;

  LevelConfiguration({this.dimensions}) : assert(dimensions != null);
}