import 'dart:ui';

import 'package:angry_arrows/game/physics/formulas.dart';
import 'package:meta/meta.dart';

typedef Point OnRequestPoint();

/// Interprets arrays of [Points] to determine what the user was trying to do.
/// Keeps a local history of the gestures, allowing smart gesture detection.
class GestureInterpreter {
  // logical location of the point the arrow is centered around
  final OnRequestPoint originPoint;
  Point get _originPoint => originPoint();

  // logical location of the point the arrow is currently at
  final OnRequestPoint arrowPoint;
  Point get _arrowPoint => arrowPoint();

  // logical location of the point the back button is located
  // this point's position should not change
  final OnRequestPoint backButtonPoint;
  Point get _backButtonPoint => backButtonPoint();

  final OnRequestPoint restartButtonPoint;
  Point get _restartButtonPoint => restartButtonPoint();

  // callbacks that [GestureInterpreter] invokes when the events happen
  final GestureHandler gestureHandler;
  final GoBackHandler goBackHandler;
  final RestartHandler restartHandler;
  final ControlArrowHandler controlArrowHandler;
  final LaunchArrowHandler launchArrowHandler;
  final ScrollHandler scrollHandler;

  // the latest pointer data
  PointerData _data;
  // the previously known data (used for scrolling)
  PointerData _previousData;

  // the pointer state
  State _state = State.none;

  GestureInterpreter({
    @required this.originPoint,
    @required this.arrowPoint,
    @required this.backButtonPoint,
    @required this.restartButtonPoint,
    this.gestureHandler,
    this.goBackHandler,
    this.restartHandler,
    this.controlArrowHandler,
    this.launchArrowHandler,
    this.scrollHandler
  });

  /// Generates a [Gesture] from the given [points].
  void interpret(PointerData data) {
    _previousData = data.change == PointerChange.move ? _data : null;
    _data = data;
    var gesture = _analyzePointerData();
    if (gesture is GoBack && goBackHandler != null) {
      goBackHandler(gesture);
    } else if (gesture is Restart && restartHandler != null) {
      restartHandler(gesture);
    } else if (gesture is ControlArrow && controlArrowHandler != null) {
      controlArrowHandler(gesture);
    } else if (gesture is LaunchArrow && launchArrowHandler != null) {
      launchArrowHandler(gesture);
    } else if (gesture is Scroll && scrollHandler != null) {
      scrollHandler(gesture);
    } else if (gesture != null && gestureHandler != null) {
      gestureHandler(gesture);
    }
  }

  /// Determines what gesture to send back.
  Gesture _analyzePointerData() {
    return _isGoBackGesture()
        ?? _isRestartGesture()
        ?? _isControlArrowGesture()
        ?? _isLaunchArrowGesture()
        ?? _isScrollGesture();
  }

  /// Determines if [_history] can be converted to a [GoBack] gesture.
  GoBack _isGoBackGesture() {
    // only let the user go back if they weren't doing anything
    if (_state != State.none) return null;
    if (_data.change != PointerChange.up) return null;

    var distance = Formulas.distanceBetween(new Point.fromPointerData(_data), _backButtonPoint);
    return distance < 200.0 ? new GoBack() : null;
  }

  Restart _isRestartGesture() {
    // only let the user restart if they weren't holding the arrow or scrolling
    if (_state == State.holdingArrow || _state == State.scrolling) return null;
    if (_data.change != PointerChange.up) return null;

    var distance = Formulas.distanceBetween(new Point.fromPointerData(_data), _restartButtonPoint);
    return distance < 300.0 ? new Restart() : null;
  }

  /// Determines if [_history] can be converted to a [ControlArrow] gesture.
  ControlArrow _isControlArrowGesture() {
    // we are scrolling or launching the arrow, so don't grab the arrow
    if (_state == State.scrolling || _state == State.launchingArrow) return null;
    // down change is to pick up the arrow, move is to move arrow
    if (_data.change != PointerChange.down && _data.change != PointerChange.move) return null;

    var dataPoint = new Point.fromPointerData(_data);
    if (Formulas.distanceBetween(dataPoint, _arrowPoint) > 128.0) {
      // we are no longer near the arrow, so we should return null
      return null;
    }

    _state = State.holdingArrow;

    return new ControlArrow(
      distance: Formulas.distanceBetween(dataPoint, _originPoint),
      radians: Formulas.angleBetween(_arrowPoint, _originPoint),
    );
  }

  /// Determines if [_history] can be converted to a [LaunchArrow] gesture.
  LaunchArrow _isLaunchArrowGesture() {
    // they aren't holding the arrow, so this gesture cannot happen
    if (_state != State.holdingArrow) return null;
    // they didn't let go, so we can't launch yet
    if (_data.change != PointerChange.up) return null;

    return new LaunchArrow();
  }

  /// Determines if [_history] can be converted to a [Scroll] gesture.
  /// This should never return null. It's the last resort in the chain of commands.
  Scroll _isScrollGesture() {
    if (_data.change == PointerChange.up) {
      _state = State.none;
      return null;
    }

    // if there is no previous data, then we just started scrolling
    if (_previousData == null) return null;

    _state = State.scrolling;

    var start = _previousData.physicalX;
    var end = _data.physicalX;
    var distance = end - start;
    return new Scroll(distance: distance);
  }
}

// //////////////////////////////
// Types of gestures
// //////////////////////////////

typedef void GestureHandler(Gesture gesture);

class Gesture {
  final PointerData data;
  Gesture({this.data});

  @override
  String toString() => '$data';
}

typedef void GoBackHandler(GoBack gesture);

class GoBack extends Gesture {}

typedef void RestartHandler(Restart gesture);

class Restart extends Gesture {}

typedef void ControlArrowHandler(ControlArrow gesture);

class ControlArrow extends Gesture {
  final double distance;
  final double radians;
  ControlArrow({this.distance, this.radians});

  @override
  String toString() => '${super.toString()}, ${distance.toStringAsPrecision(2)}, ${radians.toStringAsPrecision(2)}';
}

typedef void LaunchArrowHandler(LaunchArrow gesture);

class LaunchArrow extends Gesture {}

typedef void ScrollHandler(Scroll gesture);

class Scroll extends Gesture {
  final double distance;
  Scroll({this.distance});

  @override
  String toString() => '${super.toString()}, ${distance.toStringAsPrecision(2)}';
}

// //////////////////////////////
// Other
// //////////////////////////////

enum State {
  none, holdingArrow, launchingArrow, scrolling
}
