/// Interprets arrays of [Points] to determine what the user was trying to do.
/// Keeps a local history of the gestures, allowing smart gesture detection.
class GestureInterpreter {
  /// Used to determine more complicated [Gesture]s.
  /// If the history is used to determine a [Gesture],
  /// then [_history] should be cleared.
  List<Gesture> _history = [];

  // information used to determine if we tapped inside the arrow
  Point arrowPoint;
  double arrowWidth;
  double arrowHeight;
  double arrowRadians;

  /// Used to help determine how to interpret some points in [interpret]
  State _state = State.none;

  GestureInterpreter({this.arrowPoint, this.arrowWidth, this.arrowHeight, this.arrowRadians});

  /// Converts a list of points to a gesture.
  /// If [_history] is empty or no smart gesture could be built,
  /// a naive gesture is returned.
  Gesture interpret(List<Point> points) {
    if (points == null || points.isEmpty) return null;

    if (_history.isEmpty && _pointCollidesWithArrow(points.first)) {
      return new ControlArrow(true);
    }

    points.forEach((point) => _history.add(new Gesture(true, point: point)));

    return _analyzeHistory();
  }

  Gesture _analyzeHistory() {
    Point start = _history.first.point; // todo
    return new Scroll(false, distance: _history.map((gesture) => gesture.point).fold(0.0, (prev, point) => prev += start.x - point.x));
  }

  bool _pointCollidesWithArrow(Point point) {
    return false; // todo
  }
}

/// Interpretation for a user's action.
class Gesture {
  final bool isNaive;
  final Point point;
  Gesture(this.isNaive, {this.point});
}

/// The user is intending to scroll at the [angle] the [distance].
class Scroll extends Gesture {
  final double distance;
  Scroll(bool naive, {this.distance}) : super(naive);
}

/// The user is trying move the arrow (change [angle] and [position]).
class ControlArrow extends Gesture { // todo figure out what we need to make this work
  ControlArrow(bool naive) : super(naive);
}

/// The user is intending to launch the arrow.
class LaunchArrow extends Gesture {
  LaunchArrow(bool naive) : super(naive);
}

class Point {
  final double x, y;
  Point({this.x, this.y}) : assert(x != null), assert(y != null);
}

enum State {
  none, holdingArrow, launchingArrow
}
