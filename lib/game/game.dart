import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:angry_arrows/game/input/gesture.dart';
import 'package:angry_arrows/game/objects/hud.dart';
import 'package:angry_arrows/game/objects/level.dart';
import 'package:angry_arrows/game/objects/objects.dart';
import 'package:angry_arrows/game/physics/formulas.dart';
import 'package:angry_arrows/game/physics/physics.dart';
import 'package:angry_arrows/screens/constants.dart';
import 'package:flame/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void CanvasStroker(Canvas c);

typedef void OnGameComplete(int level, int score);

GameScene activeGameScene;
SharedPreferences _prefs;

Future<Null> loadGameScene(
    Levels levels, int levelToStart, OnGameComplete onGameComplete) async {
  // setup the dimensions
  var dimensions = await Flame.util.initialDimensions();

  _prefs = await SharedPreferences.getInstance();

  // start the game
  activeGameScene = new GameScene(
    dimensions: dimensions,
    config: levels.getLevel(levelToStart),
    onGameComplete: onGameComplete,
  )..start(onInput: _onInput);
}

void _onInput(PointerDataPacket packet) {
  if (packet.data.isEmpty) return;
  activeGameScene?.input(packet.data.first);
}

void unloadGameScene() {
  activeGameScene?.stop();
}

class GameScene extends Game {
  final Size dimensions;
  final LevelConfiguration config;
  final OnGameComplete onGameComplete;

  Landscape _landscape;
  Arrow _arrow;
  List<Crate> _crates;
  List<Platform> _platforms;

  GestureInterpreter _interpreter;

  Point _arrowStartPoint;
  ArrowPhysics _physics = new ArrowPhysics();

  int _totalAmountOfCrates = 0;
  int _timesLaunched = 0;

  GameScene(
      {@required this.dimensions, @required this.config, this.onGameComplete}) {
    _setupSprites();
  }

  void _setupSprites() {
    _landscape = new Landscape(config.landscape);

    _arrow = new Arrow(config.arrow);

    _arrowStartPoint = new Point(x: config.arrow.x, y: config.arrow.y);

    _interpreter = new GestureInterpreter(
      originPoint: () => _arrowStartPoint,
      arrowPoint: () => _currentArrowPoint,
      backButtonPoint: () => new Point(
            x: _backButtonPoint.x + 200.0,
            y: _backButtonPoint.y,
          ),
      restartButtonPoint: () => new Point(
            x: _restartButtonPoint.x + 250.0,
            y: _restartButtonPoint.y,
          ),
      gestureHandler: _handleGesture,
      goBackHandler: _handleGoBack,
      restartHandler: _handleRestart,
      controlArrowHandler: _handleControlArrow,
      launchArrowHandler: _handleLaunchArrow,
      scrollHandler: _handleScroll,
    );

    _crates = config.crates.map((config) => new Crate(config)).toList();
    _totalAmountOfCrates = _crates.length;

    _platforms =
        config.platforms.map((config) => new Platform(config)).toList();
  }

  @override
  void render(Canvas canvas) {
    // render the landscape
    _internalRenderSprite(canvas, _landscape);

    // render the current level info
    _internalRenderHudText(
        new HudInfo(
          text: '${config.level}',
          canvas: canvas,
          x: dimensions.width - 200.0,
          y: dimensions.height - 200.0,
          width: 200.0,
        ),
        Hud.drawText);

    // render the back button
    _internalRenderHudText(
        new HudInfo(
          text: 'Menu',
          canvas: canvas,
          x: _backButtonPoint.x,
          y: _backButtonPoint.y,
          width: 400.0,
        ),
        Hud.drawText);

    // render the restart button
    _internalRenderHudText(
        new HudInfo(
          text: 'Restart',
          canvas: canvas,
          x: _restartButtonPoint.x,
          y: _restartButtonPoint.y,
          width: 600.0,
        ),
        Hud.drawText);

    // render the arrow
    _internalRenderSprite(canvas, _arrow);

    _internalRenderGuides(canvas);

    // render the crates
    _crates.forEach((crate) => _internalRenderSprite(canvas, crate));

    // render the platforms
    _platforms.forEach((platform) => _internalRenderSprite(canvas, platform));
  }

  @override
  void update(double t) {
    if (_physics.hasLaunched) {
      _handlePhysicsUpdate(_physics.update(t));
      _checkCollisions();
    }
  }

  void _handlePhysicsUpdate(PhysicsUpdatePayload payload) {
    if (payload == null) return;

    _arrow.x = payload.point.x;
    _arrow.y = payload.point.y;
    _arrow.angle = payload.radians;

    // todo improve this
    if (_arrow.x < 0.0 - 3000.0 || _arrow.x > dimensions.width + 3000.0) {
      _resetArrow();
    }
    if (_arrow.y < 0.0 - 1000.0 || _arrow.y > dimensions.height + 1000.0) {
      _resetArrow();
    }
  }

  void _checkCollisions() {
    for (Crate crate in _crates) {
      Point cratePoint = new Point(x: crate.x, y: crate.y);
      if (Formulas.distanceBetween(_currentArrowPoint, cratePoint) < 100) {
        _resetArrow();
        _crates.remove(crate);

        if (_crates.isEmpty) {
          unloadGameScene();
          if (onGameComplete != null) {
            onGameComplete(
                config.level, 2 * _totalAmountOfCrates - _timesLaunched);
          }
        }
        break;
      }
    }

    for (Platform platform in _platforms) {
      Point platformPoint = new Point(x: platform.x, y: platform.y);
      if (Formulas.distanceBetween(_currentArrowPoint, platformPoint) < 100) {
        _resetArrow();
        break;
      }
    }
  }

  void _resetArrow() {
    _arrow.x = _arrowStartPoint.x;
    _arrow.y = _arrowStartPoint.y;
    _physics.reset();
  }

  /// Handles user input.
  void input(PointerData data) {
    _interpreter.interpret(data);
  }

  void _handleGesture(Gesture gesture) =>
      print('received generic gesture $gesture');

  void _handleGoBack(_) => unloadGameScene();

  // todo fix this
  void _handleRestart(_) {
    _physics.reset();
    _setupSprites();
  }

  void _handleControlArrow(ControlArrow gesture) {
    _arrow.x =
        _arrowStartPoint.x + gesture.distance * math.cos(gesture.radians);
    _arrow.y =
        _arrowStartPoint.y + gesture.distance * math.sin(gesture.radians);
    _arrow.angle = Formulas.angleBetween(_arrowStartPoint, _currentArrowPoint);
  }

  // requests the physics handler to launch
  void _handleLaunchArrow(LaunchArrow gesture) {
    _physics.launch(
      distance: Formulas.distanceBetween(_arrowStartPoint, _currentArrowPoint),
      radians: Formulas.angleBetween(_arrowStartPoint, _currentArrowPoint),
      x0: _currentArrowPoint.x,
      y0: _currentArrowPoint.y,
    );
    _timesLaunched++;
  }

  // when scrolling, move all visible items (and arrow launch point)
  void _handleScroll(Scroll gesture) {
    if (_physics.hasLaunched) return;
    _arrow.x += gesture.distance;
    _arrowStartPoint = new Point(
      x: _arrowStartPoint.x + gesture.distance,
      y: _arrowStartPoint.y,
    );
    _crates.forEach((crate) => crate.x += gesture.distance);
    _platforms.forEach((platform) => platform.x += gesture.distance);
  }

  // the arrow's current point
  Point get _currentArrowPoint => new Point(x: _arrow.x, y: _arrow.y);

  // the back button's point (unchanging)
  Point get _backButtonPoint =>
      new Point(x: dimensions.width - 400.0, y: 100.0);

  // the restart button's point (unchanging)
  Point get _restartButtonPoint =>
      new Point(x: _backButtonPoint.x - 600.0, y: 100.0);

  // Renders the [sprite] on the [canvas].
  void _internalRenderStroke(Canvas canvas, CanvasStroker updater) {
    canvas.save();
    updater?.call(canvas);
    canvas.restore();
    canvas.save();
  }

  // Renders the [sprite] on the [canvas].
  void _internalRenderSprite(Canvas canvas, SpriteComponent sprite) {
    canvas.save();
    sprite.render(canvas);
    canvas.restore();
    canvas.save();
  }

  // Renders [info.text] on the [info.canvas].
  void _internalRenderHudText(HudInfo info, DrawText func) {
    info.canvas.save();
    func(info);
    info.canvas.restore();
    info.canvas.save();
  }

  void _renderLaunchVector(Canvas c) {
    var d = Formulas.distanceBetween(_currentArrowPoint, _arrowStartPoint);

    var thickness = (math.max(1.0, d) / 64.0).clamp(1.0, 20.0);
    c.drawLine(
        new Offset(_currentArrowPoint.x, _currentArrowPoint.y),
        new Offset(_arrowStartPoint.x, _arrowStartPoint.y),
        new Paint()
          ..color = new Color.fromRGBO(255, 0, 0, 1.0)
          ..strokeWidth = thickness);
  }

  void _renderLaunchPreview(Canvas c) {
    var points = _physics.simulateProjection(
      distance: Formulas.distanceBetween(_arrowStartPoint, _currentArrowPoint),
      radians: Formulas.angleBetween(_arrowStartPoint, _currentArrowPoint),
      x0: _currentArrowPoint.x,
      y0: _currentArrowPoint.y,
    );

    for (var point in points) {
      c.drawCircle(
          new Offset(point.x, point.y),
          3.0,
          new Paint()
            ..color = new Color.fromRGBO(255, 0, 0, 1.0)
            ..strokeWidth = 2.0);
    }
  }

  // Renders launch info]
  void _internalRenderGuides(Canvas canvas) {
    var showGuides = _prefs.getBool(AppSharedPrefs.showGuides) ?? true;
    if (showGuides &&
        _currentArrowPoint != _arrowStartPoint &&
        !_physics.hasLaunched) {
      _internalRenderStroke(canvas, _renderLaunchVector);
      _internalRenderStroke(canvas, _renderLaunchPreview);
    }
  }
}
