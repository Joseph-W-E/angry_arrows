import 'dart:math' as math;

import 'package:angry_arrows/common/common.dart';

/// Interprets arrays of [Points] to determine what the user was trying to do.
/// Keeps a local history of the gestures, allowing smart gesture detection.
class GestureInterpreter {
  List<Gesture> _history = [];

  Point arrowPoint;
  double arrowWidth;
  double arrowHeight;
  double arrowRadians;

  State _state = State.none;

  GestureInterpreter({this.arrowPoint, this.arrowWidth, this.arrowHeight, this.arrowRadians});

  /// Generates a [Gesture] from the given [points].
  Gesture interpret(List<Point> points) {
    if (points == null || points.isEmpty) {
      if (_state == State.holdingArrow) {
        // they let go of the arrow
        // below doesn't work
        //return new LaunchArrow(false);
      }
      _history.clear();
      return null;
    }

    points.forEach((point) => _history.add(new Gesture(true, point: point)));

    return _analyzeHistory();
  }

  /// Should be called if the arrow changes location or size.
  void updateArrowInformation({Point point, double width, double height, double radians}) {
    arrowPoint = point ?? arrowPoint;
    arrowWidth = width ?? arrowWidth;
    arrowHeight = height ?? arrowHeight;
    arrowRadians = radians ?? arrowRadians;
  }

  /// Determines what gesture to send back.
  Gesture _analyzeHistory() {
    // Having more than 2 elements acts as a threshold (ignores very subtle inputs)
    if (_history.length <= 2) return null;

    Gesture gesture = _isGoBackGesture() ?? _isControlArrowGesture() ?? _isLaunchArrowGesture() ?? _isScrollGesture();
    _history.clear();
    return gesture;
  }

  GoBack _isGoBackGesture() {
    var start = _history.first.point;
    return start.x < 500.0 ? new GoBack(false) : null;
  }

  /// Determines if [_history] can be converted to a [ControlArrow] gesture.
  ControlArrow _isControlArrowGesture() {
    if (_state == State.launchingArrow) return null;

    var start = _history.first.point;
    var distanceToArrow = _distanceToArrow(start);

    if (distanceToArrow > 128.0) return null; // [start] is too far away

    var radians = _angleToArrow(start);

    _state = State.holdingArrow;

    return new ControlArrow(
      false,
      distance: distanceToArrow,
      radians: radians,
    );
  }

  double _distanceToArrow(Point p) => distanceBetween(p, arrowPoint);

  double _angleToArrow(Point p) => angleBetween(p, arrowPoint);

  /// Determines if [_history] can be converted to a [LaunchArrow] gesture.
  LaunchArrow _isLaunchArrowGesture() {
    if (_state != State.holdingArrow) return null;
    _state = State.launchingArrow;

    return new LaunchArrow(false);
  }

  /// Determines if [_history] can be converted to a [Scroll] gesture.
  /// This should never return null. It's the last resort in the chain of commands.
  Scroll _isScrollGesture() {
    var start = _history.first.point.x;
    var end = _history.last.point.x;
    var distance = end - start;
    return new Scroll(false, distance: distance);
  }
}

// //////////////////////////////
// Types of gestures
// //////////////////////////////

class Gesture {
  final bool isNaive;
  final Point point;
  Gesture(this.isNaive, {this.point});
}

class GoBack extends Gesture {
  GoBack(bool isNaive) : super(isNaive);
}

class ControlArrow extends Gesture {
  final double distance;
  final double radians;
  ControlArrow(bool naive, {this.distance, this.radians}) : super(naive);
}

class LaunchArrow extends Gesture {
  LaunchArrow(bool naive) : super(naive);
}

class Scroll extends Gesture {
  final double distance;
  Scroll(bool naive, {this.distance}) : super(naive);
}

// //////////////////////////////
// Other
// //////////////////////////////

class Point {
  final double x, y;
  Point({this.x, this.y}) : assert(x != null), assert(y != null);

  @override
  String toString() => '(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) {
    return other is Point && (other.x == this.x && other.y == this.y);
  }

  @override
  int get hashCode => "$x,$y".hashCode;
}

enum State {
  none, holdingArrow, launchingArrow
}
