import 'dart:ui';

import 'package:angry_arrows/game/objects.dart';
import 'package:flame/game.dart';

class Level extends Game {
  final Size dimensions;

  final LevelConfiguration config;

  Level({this.dimensions, this.config}) : assert(dimensions != null);

  @override
  void render(Canvas canvas) {
    // todo
  }

  @override
  void update(double t) {
    // todo
  }

  /// Accepts user input (typically a touch).
  /// [x] and [y] are the coordinates of the input.
  void input(double x, double y) {
    print('x: $x     y: $y');
  }

  /// Stops rendering the level.
  /// This should be called when the user navigates away from the level.
  void stop() {}
}

/// Configuration for the level.
/// This includes:
///   The hud
///   All sprites
class LevelConfiguration {

}
