import 'dart:math' as math;
import 'package:angry_arrows/game/objects.dart';

/// [PhysicsHandler] is responsible primarily for launching the arrow.
class PhysicsHandler {
  static const double _gravity = 100.0;

  Arrow _arrow;

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

  PhysicsHandler(this._arrow);

  /// Begins the launch on the arrow
  void launch({double distance, double radians}) {
    if (distance == null || radians == null) return;

    // set the starting position
    _x0 = _arrow.x;
    _y0 = _arrow.y;

    // calculate initial velocity
    _vx0 = 2 * distance * math.cos(radians);
    _vy0 = -2 * distance * math.sin(radians);

    _hasLaunched = true;
  }

  bool get hasLaunched => _hasLaunched;

  void update(double tickTime) {
    _t += tickTime;

    _arrow.x = _x0 + _x;
    _arrow.y = _y0 - _y;
    //print('_yp $_yp'); TODO figure out how the hell to get the angle right
    print('radians ${_yp * math.PI / 180}');
    _arrow.angle = _yp * math.PI / 180;
  }

  // horizontal distance since the start
  double get _x => _vx0 * _t;

  // vertical distance since the start
  double get _y => _vy0 * _t - 0.5 * _gravity * math.pow(_t, 2);

  // derivative of [_y]
  double get _yp => _vy0 - _gravity * _t;

  /// Resets this object's state.
  void reset() {
    // todo
  }
}