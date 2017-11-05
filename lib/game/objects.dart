import 'dart:math' as math;

import 'package:flame/component.dart';

abstract class Config {
  final num width;
  final num height;
  final num angle;

  Config({this.width, this.height, this.angle});

  String get asset;
}

// //////////////////////////////
// Arrows
// //////////////////////////////

class Arrow extends SpriteComponent {
  Arrow(ArrowConfig config) : super.rectangle(
    config.width,
    config.height,
    config.asset,
  );
}

class ArrowConfig extends Config {
  ArrowConfig({num length: 128.0}) : super(
    width: length / 10,
    height: length,
    angle: 0.0,
  );

  @override
  String get asset => 'Arrow.png';
}


// //////////////////////////////
// Crates
// //////////////////////////////

class Crate extends SpriteComponent {
  Crate(CrateConfig config) : super.rectangle(
    config.width,
    config.height,
    config.asset,
  );
}

class CrateConfig extends Config {
  CrateConfig({num size: 128.0}) : super(
    width: 128.0,
    height: 128.0,
    angle: 0.0,
  );

  @override
  String get asset => 'crate.png';
}

// //////////////////////////////
// Platforms todo This doesn't actually work, was just messing around
// todo - What we should do is create a builder for platforms, so we end up with
// todo - one component that can be rendered inside the game.
// //////////////////////////////

class Platform extends SpriteComponent {
  final List<PlatformItem> items;

  Platform(this.items) : super.rectangle(
    items.map((item) => item.width).fold(0.0, (prev, curr) => prev + curr),
    items.map((item) => item.height).fold(0.0, (prev, curr) => math.max(prev, curr)),
    'platform.png', // todo obv not correct, but renders
  );
}

class PlatformItem extends SpriteComponent {
  final PlatformItemConfig config;

  PlatformItem(this.config) : super.rectangle(
    config.width,
    config.height,
    'standaloneTile.png',
  );
}

class PlatformItemConfig extends Config {
  final PlatformPosition position;

  PlatformItemConfig({num size: 128.0, this.position}) : super(
    width: 128.0,
    height: 128.0,
    angle: 0.0,
  );

  @override
  String get asset {
    switch(position) {
      case PlatformPosition.left:
        return 'leftTile.png';
      case PlatformPosition.middle:
        return 'midTile.png';
      case PlatformPosition.right:
        return 'rightTile.png';
      case PlatformPosition.standalone:
        return 'standaloneTile.png';
      default:
        return 'platform.png';
    }
  }
}

enum PlatformPosition {
  left, middle, right, standalone
}
