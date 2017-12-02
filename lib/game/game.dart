import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:angry_arrows/common/common.dart';
import 'package:angry_arrows/game/gesture.dart';
import 'package:angry_arrows/game/hud.dart';
import 'package:angry_arrows/game/level.dart';
import 'package:angry_arrows/game/objects.dart';
import 'package:angry_arrows/game/physics.dart';
import 'package:flame/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

typedef void CanvasStroker(Canvas c);

GameScene activeGameScene;

Future<Null> loadGameScene(Levels levels, int levelToStart) async {
  // todo this is causing a shit load of errors to print in the stack trace
  // todo figure out how to stop these errors

  // setup Flame
  Flame.audio.disableLog();

  // setup the dimensions
  var dimensions = await Flame.util.initialDimensions();

  // start the game
  activeGameScene = new GameScene(
    dimensions: dimensions,
    config: levels.getLevel(levelToStart),
  )..start();

  // start handling user input
  window.onPointerDataPacket = (PointerDataPacket packet) {
    var pointer = packet.data.first;
    // todo investigate what [packet.data] looks like
    // todo (and maybe see if we can improve touch inputs)
    activeGameScene?.input(pointer.physicalX, pointer.physicalY);
  };
}

// todo consume this (and make sure it works)
void unloadGameScene() {
  activeGameScene?.stop();
}

class GameScene extends Game {
  final Size dimensions;
  final LevelConfiguration config;

  Landscape _landscape;
  Arrow _arrow;
  List<Crate> _crates;
  List<Platform> _platforms;

  List<Point> _points = [];
  GestureInterpreter _interpreter;

  PhysicsHandler _physics = new PhysicsHandler();

  GameScene({this.dimensions, this.config}) : assert(dimensions != null), assert(config != null) {
    _setupSprites();
  }

  void _setupSprites() {
    _landscape = new Landscape(config.landscape);

    _arrow = new Arrow(config.arrow);

    _interpreter = new GestureInterpreter(
      arrowPoint: _arrowStartPoint,
      backButtonPoint: _backButtonPoint,
    );

    _crates = config.crates.map((config) => new Crate(config)).toList();

    _platforms = config.platforms.map((config) => new Platform(config)).toList();
  }

  @override
  void render(Canvas canvas) {
    // render the landscape
    _internalRenderSprite(canvas, _landscape);

    // render the current level info
    _internalRenderHudText(new HudInfo(
      text: '${config.level}',
      canvas: canvas,
      point: new Point(x: dimensions.width - 200.0, y: dimensions.height - 200.0),
      width: 200.0,
    ), Hud.drawText);

    // render the back button
    _internalRenderHudText(new HudInfo(
      text: 'Menu',
      canvas: canvas,
      point: new Point(x: dimensions.width - 400.0, y: 100.0),
      width: 400.0,
    ), Hud.drawText);

    // render the arrow
    _internalRenderSprite(canvas, _arrow);

    // render launch info todo move this to it's own function, maybe in physics.dart?
    if (_currentArrowPoint != _arrowStartPoint && !_physics.hasLaunched) {
      var d = distanceBetween(_currentArrowPoint, _arrowStartPoint);

      var lineCreator = (Canvas c) {
        var thickness = (math.max(1.0, d) / 64.0).clamp(1.0, 20.0);
        c.drawLine(new Offset(_currentArrowPoint.x, _currentArrowPoint.y),
            new Offset(_arrowStartPoint.x, _arrowStartPoint.y),
            new Paint()
              ..color = new Color.fromRGBO(255, 0, 0, 1.0)
              ..strokeWidth = thickness
        );
      };

      var arcCreator = (Canvas c) {
        var points = _physics.getArchProjection(
          distance: distanceBetween(_arrowStartPoint, _currentArrowPoint),
          radians: angleBetween(_arrowStartPoint, _currentArrowPoint),
          x0: _arrowStartPoint.x,
          y0: _arrowStartPoint.y,
        );

        for (var point in points) {
          canvas.drawCircle(new Offset(point.x, point.y), 3.0,
              new Paint()
                ..color = new Color.fromRGBO(255, 0, 0, 1.0)
                ..strokeWidth = 2.0
          );
        }
      };

      _internalRenderStroke(canvas, lineCreator);
      _internalRenderStroke(canvas, arcCreator);
    }

    // render the crates
    _crates.forEach((crate) => _internalRenderSprite(canvas, crate));

    // render the platforms
    _platforms.forEach((platform) => _internalRenderSprite(canvas, platform));
  }

  @override
  void update(double t) {
    _handleGesture(t, _interpreter.interpret(_points));
    _interpreter.updateArrowLocation(point: _currentArrowPoint);

    if (_physics.hasLaunched) {
      _physics.update(t, (PhysicsUpdatePayload payload) {
        _arrow.x = payload.x;
        _arrow.y = payload.y;
        _arrow.angle = payload.radians;
      });

      // check for collision with crates or platforms
      for (Crate crate in _crates) {
        Point arrowPoint = new Point(x: _arrow.x, y: _arrow.y);
        Point cratePoint = new Point(x: crate.x, y: crate.y);
        if (distanceBetween(arrowPoint, cratePoint) < 100) {
          // todo correctly update the ui
          _crates.remove(_crates);
          _physics.reset();

          // todo if there are no more crates, move to the next level
          break;
        }
      }
    }

    _points.clear();
  }

  /// Accepts user input (typically a touch).
  /// [x] and [y] are the coordinates of the input.
  void input(double x, double y) {
    _points.add(new Point(x: x, y: y));
  }

  // Determines how to manipulate the objects based off the received [gesture]
  void _handleGesture(double t, Gesture gesture) {
    // we should ignore potentially bad gestures
    // unless they're trying to grab the arrow
    if (gesture == null || (gesture.isNaive && gesture is! ControlArrow)) return;

    if (gesture is GoBack) {
      unloadGameScene();

    } else if (gesture is Scroll) {
      if (_physics.hasLaunched) return;
      _arrow.x += gesture.distance;
      _crates.forEach((crate) => crate.x += gesture.distance);
      _platforms.forEach((platform) => platform.x += gesture.distance);

    } else if (gesture is ControlArrow) {
      _arrow.x += gesture.distance * math.cos(gesture.radians);
      _arrow.y += gesture.distance * math.sin(gesture.radians);
      _arrow.angle = angleBetween(_arrowStartPoint, _currentArrowPoint);

    } else if (gesture is LaunchArrow) {
      _physics.launch(
        distance: distanceBetween(_arrowStartPoint, _currentArrowPoint),
        radians: angleBetween(_arrowStartPoint, _currentArrowPoint),
        x0: config.arrow.x,
        y0: config.arrow.y,
      );

    } else {
      print("Error: Unknown gesture $gesture");
    }
  }

  Point get _arrowStartPoint => new Point(x: config.arrow.x, y: config.arrow.y);
  Point get _currentArrowPoint => new Point(x: _arrow.x, y: _arrow.y);
  Point get _backButtonPoint => new Point(x: dimensions.width - 400.0, y: 100.0);

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

  void _internalRenderHudText(HudInfo info, DrawText func) {
    info.canvas.save();
    func(info);
    info.canvas.restore();
    info.canvas.save();
  }
}
