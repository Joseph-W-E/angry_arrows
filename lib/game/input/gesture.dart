import 'package:angry_arrows/game/physics/formulas.dart';

/// Interprets arrays of [Points] to determine what the user was trying to do.
/// Keeps a local history of the gestures, allowing smart gesture detection.
class GestureInterpreter {
  List<Gesture> _history = [];

  // location of the point the arrow is centered around
  Point originPoint;

  // location of the point the arrow is currently at
  Point arrowPoint;

  // location of the point the back button is located
  // note that this point is not affected by scrolling
  Point backButtonPoint;

  // the current state of the arrow
  State _state = State.none;

  GestureInterpreter({this.arrowPoint, this.backButtonPoint});

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
  void updateArrowLocation({Point point}) {
    arrowPoint = point ?? arrowPoint;
  }

  /// Determines what gesture to send back.
  Gesture _analyzeHistory() {
    // Having more than 2 elements acts as a threshold (ignores very subtle inputs)
    if (_history.length <= 2) return null;

    Gesture gesture = _isGoBackGesture() ?? _isControlArrowGesture() ?? _isLaunchArrowGesture() ?? _isScrollGesture();
    _history.clear();
    return gesture;
  }

  /// Determines if [_history] can be converted to a [GoBack] gesture.
  GoBack _isGoBackGesture() {
    var start = _history.first.point;
    return Formulas.distanceBetween(start, backButtonPoint) < 400.0 ? new GoBack(false) : null;
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

  double _distanceToArrow(Point p) => Formulas.distanceBetween(p, arrowPoint);

  double _angleToArrow(Point p) => Formulas.angleBetween(p, arrowPoint);

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

enum State {
  none, holdingArrow, launchingArrow
}
