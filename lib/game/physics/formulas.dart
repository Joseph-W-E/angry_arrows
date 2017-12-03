import 'dart:math' as math;

import 'dart:ui';

class Formulas {
  static const double gravity = 100.0;

  /// calculates the horizontal distance traveled
  ///   [vx0] is the initial x velocity (in points per second)
  ///   [t] is the current time (in seconds)
  static double horizontalProjectileMotion(double vx0, double t) {
    return vx0 * t;
  }

  /// calculates the vertical distance traveled
  ///   [vy0] is the initial y velocity (in points per second)
  ///   [t] is the current time (in seconds)
  static double verticalProjectileMotion(double vy0, double t) {
    return (vy0 * t) - (0.5 * gravity * math.pow(t, 2));
  }

  /// calculates the angle between two [Points], in radians.
  static double angleBetween(Point a, Point b) {
    return (math.atan2(a.x - b.x, b.y - a.y) - math.PI / 2) % (2 * math.PI);
  }

  /// calculates the distance between two [Points], in points.
  static double distanceBetween(Point a, Point b) {
    return math.sqrt(math.pow(b.y - a.y, 2) + math.pow(b.x - a.x, 2));
  }
}

class Point {
  final double x, y;

  Point({this.x, this.y}) : assert(x != null), assert(y != null);

  Point.fromPointerData(PointerData data) : x = data.physicalX, y = data.physicalY;

  @override
  String toString() => '(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) {
    return other is Point && (other.x == this.x && other.y == this.y);
  }

  @override
  int get hashCode => "$x,$y".hashCode;
}
