import 'dart:math' as math;
import 'package:angry_arrows/game/objects.dart';
import 'package:flame/component.dart';

/// [PhysicsHandler] is responsible primarily for launching the arrow.
class PhysicsHandler {
  static const double _gravity = 100.0;

  // elapsed time
  double _t = 0.0;

  // initial horizontal position
  double _x0 = 0.0;

  // initial vertical position
  double _y0 = 0.0;

  // initial horizontal velocity
  double _vx0 = 0.0;

  // initial vertical velocity
  double _vy0 = 0.0;

  bool _hasLaunched = false;

  PhysicsHandler();

  /// Begins the launch on the arrow
  void launch({double distance, double radians, double x0, double y0}) {
    if (distance == null || radians == null) return;

    // set the starting position
    _x0 = x0;
    _y0 = y0;

    // calculate initial velocity
    _vx0 = 2 * distance * math.cos(radians);
    _vy0 = -2 * distance * math.sin(radians);

    _hasLaunched = true;
  }

  bool get hasLaunched => _hasLaunched;

  void update(double tickTime, OnUpdateCallback onUpdate) {
    _t += tickTime;

    onUpdate(new PhysicsUpdatePayload(_x0 + _x, _y0 - _y, math.atan(_yp)));
  }

  // horizontal distance since the start
  double get _x => _vx0 * _t;

  // vertical distance since the start
  double get _y => _vy0 * _t - 0.5 * _gravity * math.pow(_t, 2);

  // derivative of [_y]
  double get _yp => _vy0 - _gravity * _t;

  /// Resets this object's state.
  void reset() {
    _t = 0.0;
    _x0 = 0.0;
    _y0 = 0.0;
    _vx0 = 0.0;
    _vy0 = 0.0;
    _hasLaunched = false;
  }
}

typedef void OnUpdateCallback(PhysicsUpdatePayload payload);

class PhysicsUpdatePayload {
  final double x;
  final double y;
  final double radians;

  PhysicsUpdatePayload(this.x, this.y, this.radians);
}
