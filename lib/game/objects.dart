import 'dart:math' as math;

import 'package:flame/component.dart';

abstract class Config {
  final double width;
  final double height;
  final double angle;

  double x;
  double y;

  Config({this.width, this.height, this.angle});

  String get asset;
}

class Landscape extends SpriteComponent {
  Landscape(LandscapeConfig config) : super.rectangle(
    config.width,
    config.height,
    config.asset,
  ) {
    x = config.x;
    y = config.y;
    angle = config.angle;
  }
}

class LandscapeConfig extends Config {
  LandscapeConfig({double width, double height, double x, double y}) : super(
    width: width,
    height: height,
    angle: 3 / 2 * math.PI,
  ) {
    this.x = x;
    this.y = y;
  }

  @override
  String get asset => 'landscape.png';
}

// //////////////////////////////
// Arrows
// //////////////////////////////

class Arrow extends SpriteComponent {
  Arrow(ArrowConfig config) : super.rectangle(
    config.width,
    config.height,
    config.asset,
  ) {
    x = config.x;
    y = config.y;
    angle = config.angle;
  }
}

class ArrowConfig extends Config {
  ArrowConfig({double length: 128.0, double radians: -1.0}) : super(
    width: length / 10,
    height: length,
    angle: radians,
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
  ) {
    x = config.x;
    y = config.y;
    angle = config.angle;
  }
}

class CrateConfig extends Config {
  CrateConfig({double size: 128.0}) : super(
    width: size,
    height: size,
    angle: 0.0,
  );

  @override
  String get asset => 'crate.png';
}

// //////////////////////////////
// Platforms
// //////////////////////////////

class Platform extends SpriteComponent {
  Platform(PlatformConfig config) : super.rectangle(
    config.width,
    config.height,
    config.asset,
  ) {
    x = config.x;
    y = config.y;
    angle = config.angle;
  }
}

class PlatformConfig extends Config {
  PlatformConfig({double size: 500.0}) : super(
    width: size,
    height: size / 10,
    angle: 3 / 2 * math.PI,
  );

  @override
  String get asset => 'platform.png';
}
