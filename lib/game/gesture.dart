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
        // they let go, launch the arrow
        // return new LaunchArrow gesture
      }
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
    if (_history.length <= 2) return null;

    Gesture gesture = _isControlArrowGesture() ?? _isLaunchArrowGesture() ?? _isScrollGesture();
    _history.clear();
    return gesture;
  }

  /// Determines if [_history] can be converted to a [ControlArrow] gesture.
  ControlArrow _isControlArrowGesture() {
    if (_state == State.launchingArrow) return null;

    var start = _history.first.point;
    // if start is inside the arrow's hitbox, then we should calculate
    // how far and to what angle's we've dragged the arrow.

    // update the state to State.holdingArrow

    // return a new ControlArrow

    return null;//new ControlArrow(false, distance: 0.0, radians: 0.0);
  }

  /// Determines if [_history] can be converted to a [LaunchArrow] gesture.
  LaunchArrow _isLaunchArrowGesture() {
    if (_state != State.holdingArrow) return null;
    _state = State.launchingArrow;

    return new LaunchArrow(false);
  }

  /// Determines if [_history] can be converted to a [Scroll] gesture.
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
}

enum State {
  none, holdingArrow, launchingArrow
}
