/// Interprets arrays of [Points] to determine what the user was trying to do.
/// Keeps a local history of the gestures, allowing smart gesture detection.
class GestureInterpreter {
  List<Gesture> _history;

  GestureInterpreter();

  /// Converts a list of points to a gesture.
  /// If [_history] is empty or no smart gesture could be built,
  /// a naive gesture is returned.
  Gesture interpret(List<Point> points) {
    return null; // todo
  }
}

/// Interpretation for a user's action.
class Gesture {
  /// A naive gesture could be ignored, depending on the situation.
  bool get isNaive => false;
}

/// The user is intending to scroll in the given [direction].
class Scroll extends Gesture {}

/// The user is trying move the arrow (change [angle] and [position]).
class ControlArrow extends Gesture {}

/// The user is intending to launch the arrow.
class LaunchArrow extends Gesture {}

class Point {
  final double x, y;
  Point({this.x, this.y}) : assert(x != null), assert(y != null);
}
