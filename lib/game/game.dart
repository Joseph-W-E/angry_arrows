import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:angry_arrows/game/input/gesture.dart';
import 'package:angry_arrows/game/objects/hud.dart';
import 'package:angry_arrows/game/objects/level.dart';
import 'package:angry_arrows/game/objects/objects.dart';
import 'package:angry_arrows/game/physics/formulas.dart';
import 'package:angry_arrows/game/physics/physics.dart';
import 'package:flame/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

typedef void CanvasStroker(Canvas c);

GameScene activeGameScene;

Future<Null> loadGameScene(Levels levels, int levelToStart) async {
  // setup the dimensions
  var dimensions = await Flame.util.initialDimensions();

  // start the game
  activeGameScene = new GameScene(
    dimensions: dimensions,
    config: levels.getLevel(levelToStart),
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

  Landscape _landscape;
  Arrow _arrow;
  List<Crate> _crates;
  List<Platform> _platforms;

  GestureInterpreter _interpreter;

  Point _arrowStartPoint;
  PhysicsHandler _physics = new PhysicsHandler();

  GameScene({this.dimensions, this.config}) : assert(dimensions != null), assert(config != null) {
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
      controlArrowHandler: _handleControlArrow,
      launchArrowHandler: _handleLaunchArrow,
      scrollHandler: _handleScroll,
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
      x: dimensions.width - 200.0,
      y: dimensions.height - 200.0,
      width: 200.0,
    ), Hud.drawText);

    // render the back button
    _internalRenderHudText(new HudInfo(
      text: 'Menu',
      canvas: canvas,
      x: _backButtonPoint.x,
      y: _backButtonPoint.y,
      width: 400.0,
    ), Hud.drawText);

    // render the restart button
    _internalRenderHudText(new HudInfo(
      text: 'Restart',
      canvas: canvas,
      x: _restartButtonPoint.x,
      y: _restartButtonPoint.y,
      width: 600.0,
    ), Hud.drawText);

    // render the arrow
    _internalRenderSprite(canvas, _arrow);

    // render launch info todo move this to it's own function, maybe in physics.dart?
    if (_currentArrowPoint != _arrowStartPoint && !_physics.hasLaunched) {
      var d = Formulas.distanceBetween(_currentArrowPoint, _arrowStartPoint);

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
          distance: Formulas.distanceBetween(_arrowStartPoint, _currentArrowPoint),
          radians: Formulas.angleBetween(_arrowStartPoint, _currentArrowPoint),
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
        if (Formulas.distanceBetween(arrowPoint, cratePoint) < 100) {
          // todo correctly update the ui
          _crates.remove(_crates);
          _physics.reset();

          // todo if there are no more crates, move to the next level
          break;
        }
      }
    }
  }

  /// Handles user input.
  void input(PointerData data) {
    _interpreter.interpret(data);
  }

  void _handleGesture(Gesture gesture) => print('received generic gesture $gesture');

  void _handleGoBack(_) => unloadGameScene();

  void _handleRestart(_) => print('todo restart');

  void _handleControlArrow(ControlArrow gesture) {
    _arrow.x += gesture.distance * math.cos(gesture.radians);
    _arrow.y += gesture.distance * math.sin(gesture.radians);
    _arrow.angle = Formulas.angleBetween(_arrowStartPoint, _currentArrowPoint);
  }

  void _handleLaunchArrow(LaunchArrow gesture) {
    _physics.launch(
      distance: Formulas.distanceBetween(_arrowStartPoint, _currentArrowPoint),
      radians: Formulas.angleBetween(_arrowStartPoint, _currentArrowPoint),
      x0: config.arrow.x,
      y0: config.arrow.y,
    );
  }

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
  Point get _backButtonPoint => new Point(x: dimensions.width - 400.0, y: 100.0);

  // the restart button's point (unchanging)
  Point get _restartButtonPoint => new Point(x: _backButtonPoint.x - 600.0, y: 100.0);

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
}
