import 'dart:math' as math;

import 'package:angry_arrows/game/physics/formulas.dart';
import 'package:meta/meta.dart';

/// [ArrowPhysics] is responsible primarily for launching the arrow.
class ArrowPhysics {
  // elapsed time
  double _t = 0.0;

  // initial horizontal position
  double _x0 = 0.0;

  // initial vertical position
  double _y0 = 0.0;

  // initial angle
  double _r0 = 0.0;

  // initial horizontal velocity
  double _vx0 = 0.0;

  // initial vertical velocity
  double _vy0 = 0.0;

  // the last known point calculated from [update]
  Point _previousPoint;

  // if [launch] has been called
  bool _hasLaunched = false;
  bool get hasLaunched => _hasLaunched;

  /// Calculates initial values used for [update].
  void launch({double distance, double radians, double x0, double y0}) {
    if (distance == null || radians == null) return;

    // set the starting position
    _x0 = x0;
    _y0 = y0;
    _r0 = radians;

    // calculate initial velocity
    _vx0 = Formulas.initialHorizontalVelocity(distance, radians);
    _vy0 = Formulas.initialVerticalVelocity(distance, radians);

    _hasLaunched = true;
  }

  /// Returns a new point based off the time since launch.
  PhysicsUpdatePayload update(double tickTime) {
    if (!_hasLaunched) return null;

    _t += 2 * tickTime;

    // calculate a the current point
    var currentPoint = new Point(
      x: _x0 + Formulas.horizontalProjectileMotion(_vx0, _t),
      y: _y0 - Formulas.verticalProjectileMotion(_vy0, _t),
    );

    var radians = _previousPoint != null ? Formulas.angleBetween(
      currentPoint,
      _previousPoint,
    ) : _r0;

    _previousPoint = currentPoint;

    return new PhysicsUpdatePayload(
      point: currentPoint,
      radians: radians,
    );
  }

  List<Point> simulateProjection({
    double distance,
    double radians,
    double x0,
    double y0,
    double step: 0.001,
    double max: 5.0,
  }) {
    ArrowPhysics simulator = new ArrowPhysics()..launch(
      distance: distance,
      radians: radians,
      x0: x0,
      y0: y0,
    );

    var points = <Point>[];
    for (double i = 0.0; i < max; i += step) {
      var payload = simulator.update(i);

      var adjustedPoint = new Point(
        x: payload.point.x,
        y: payload.point.y,
      );

      points.add(adjustedPoint);
    }

    return points;
  }

  /// Resets this object's state.
  void reset() {
    _t = 0.0;
    _x0 = 0.0;
    _y0 = 0.0;
    _r0 = 0.0;
    _vx0 = 0.0;
    _vy0 = 0.0;
    _previousPoint = null;
    _hasLaunched = false;
  }
}

typedef void OnUpdateCallback(PhysicsUpdatePayload payload);

class PhysicsUpdatePayload {
  final Point point;
  final double radians;

  PhysicsUpdatePayload({@required this.point, @required this.radians});
}
