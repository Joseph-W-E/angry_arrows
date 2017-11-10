import 'dart:ui';

import 'package:angry_arrows/game/gesture.dart';
import 'package:angry_arrows/game/hud.dart';
import 'package:angry_arrows/game/objects.dart';
import 'package:flame/component.dart';
import 'package:flame/game.dart';

class Level extends Game {
  final Size dimensions;
  final LevelConfiguration config;

  // Sprites
  Arrow _arrow;
  List<Crate> _crates;
  //List<Platform> _platforms;

  // User input
  List<Point> _points;
  GestureInterpreter _interpreter = new GestureInterpreter();

  Level({this.dimensions, this.config}) : assert(dimensions != null), assert(config != null) {
    _setupSprites();
  }

  void _setupSprites() {
    _arrow = new Arrow(config.arrow);
    _crates = config.crates.map((config) => new Crate(config)).toList();
    //_platforms = config.platforms.map((config) => new Platform(config)).toList();
  }

  @override
  void render(Canvas canvas) {
    // render the hud
    // todo

    // render the arrow
    _internalRender(canvas, _arrow);

    // render the crates
    _crates.forEach((crate) => _internalRender(canvas, crate));

    // render the platforms
    // todo
  }

  void _internalRender(Canvas canvas, SpriteComponent sprite) {
    canvas.save();
    sprite.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @override
  void update(double t) {
    // we have all of the user input, so we can interpret their gesture

    // if the input resides on the arrow, we should be in an "arrow firing" phase

    // if the input is a noticeable drag and we weren't in the "arrow firing" phase,
    // then we should be moving the viewport

    // if the input is a noticeable drag and we were in the "arrow firing" phase,
    // then we should be prepping the arrow for launch (adjusting angle, drawback)

    // if the input was in the "arrow firing" phase and came to a hard stop, we should
    // fire the arrow and move to the "arrow fired" phase

    // if we are in the "arrow fired" phase, then we should ignore user input
    // and we should be moving objects around based off the viewport

    // defer to clearing points so each [update] has a fresh read of user input
    _interpreter.interpret(_points);
    _points.clear();
  }

  /// Accepts user input (typically a touch).
  /// [x] and [y] are the coordinates of the input.
  void input(double x, double y) {
    _points.add(new Point(x: x, y: y));
  }

  /// Stops rendering the level.
  /// This should be called when the user navigates away from the level.
  void stop() {
    // todo figure out how to destroy the game and return to normal flutter
  }

  void _handleGesture(Gesture gesture) {
    // sometimes we may want to ignore potentially bad gestures
    if (gesture.isNaive) return;

    // do something with the gesture
  }
}

/// Configuration for the level.
/// This includes:
///   The hud
///   All sprites
class LevelConfiguration {
  ArrowConfig arrow;
  List<CrateConfig> crates;
  List<PlatformItemConfig> platforms;

  final Size dimensions;

  LevelConfiguration({this.dimensions}) : assert(dimensions != null);
}
