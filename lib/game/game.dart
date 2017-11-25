import 'dart:math' as math;
import 'dart:ui';

import 'package:angry_arrows/game/gesture.dart';
import 'package:angry_arrows/game/level.dart';
import 'package:angry_arrows/game/objects.dart';
import 'package:flame/component.dart';
import 'package:flame/game.dart';

class Level extends Game {
  final Size dimensions;
  final LevelConfiguration config;

  Arrow _arrow;
  List<Crate> _crates;

  List<Point> _points = [];
  GestureInterpreter _interpreter;

  Level({this.dimensions, this.config}) : assert(dimensions != null), assert(config != null) {
    _setupSprites();
  }

  void _setupSprites() {
    _arrow = new Arrow(config.arrow);

    _interpreter = new GestureInterpreter(
      arrowPoint: new Point(x: config.arrow.x, y: config.arrow.y),
      arrowWidth: config.arrow.width,
      arrowHeight: config.arrow.height,
      arrowRadians: config.arrow.angle,
    );

    _crates = config.crates.map((config) => new Crate(config)).toList();

    // todo setup platforms
  }

  @override
  void render(Canvas canvas) {
    // render the arrow
    _internalRender(canvas, _arrow);

    // render the crates
    _crates.forEach((crate) => _internalRender(canvas, crate));

    // render the platforms
    // todo render the platforms
  }

  @override
  void update(double t) {
    _handleGesture(t, _interpreter.interpret(_points));
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

  // Determines how to manipulate the objects based off the received [gesture]
  void _handleGesture(double t, Gesture gesture) {
    // we should ignore potentially bad gestures
    // unless they're trying to grab the arrow
    if (gesture == null || (gesture.isNaive && gesture is! ControlArrow)) return;

    if (gesture is Scroll) {
      // move all the objects using the [Scroll]'s info
      _arrow.x += gesture.distance;
      _crates.forEach((crate) => crate.x += gesture.distance);
    } else if (gesture is ControlArrow) {
      // move the arrow using the [ControlArrow]'s info

    } else if (gesture is LaunchArrow) {
      // move the objects and disable user input
    } else {
      print("Error: Unknown gesture $gesture");
    }
  }

  // Renders the [sprite] on the [canvas].
  void _internalRender(Canvas canvas, SpriteComponent sprite) {
    canvas.save();
    sprite.render(canvas);
    canvas.restore();
    canvas.save();
  }
}
