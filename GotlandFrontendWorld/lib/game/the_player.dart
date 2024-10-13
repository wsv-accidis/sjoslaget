import 'package:bonfire/bonfire.dart';

class ThePlayer extends SimplePlayer with BlockMovementCollision, PathFinding, TapGesture, TileRecognizer {
  ThePlayer(Vector2 position) : super(position: position, size: Vector2.all(64), speed: 160.0, animation: _PlayerSpriteSheet.animation);

  // Player sprite hitbox
  static final _playerHitbox = RectangleHitbox(size: Vector2(32, 50), position: Vector2(16, 13));

  // State for pathfinding
  var _pathFindingLastPos = Vector2.zero();
  var _pathFindingLastTime = 0;

  @override
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
    // moveToPositionWithPathFinding tends to get stuck on things, stop moving to reset the walking animation
    stopMove();
    super.onBlockedMovement(other, collisionData);
  }

  @override
  Future<void> onLoad() {
    add(_playerHitbox);
    setupPathFinding(linePathEnabled: true, showBarriersCalculated: false);
    return super.onLoad();
  }

  @override
  void onMove(double speed, Vector2 displacement, Direction direction, double angle) {
    if (_isInHomeArea()) print("In area!");
    super.onMove(speed, displacement, direction, angle);
  }

  @override
  void onTap() {}

  @override
  void onTapDownScreen(GestureEvent event) {
    var moveToPosition = Vector2(event.worldPosition.x.roundToDouble(), event.worldPosition.y.roundToDouble());
    var now = DateTime.now().millisecondsSinceEpoch;

    // Suppress repeated taps on same position since this creates jank
    if (moveToPosition != _pathFindingLastPos || now - _pathFindingLastTime > 1000) {
      _pathFindingLastPos = moveToPosition;
      _pathFindingLastTime = now;

      // Works ok but sometimes gets stuck, change settings in onLoad to debug
      moveToPositionWithPathFinding(moveToPosition);
    }
    super.onTapDownScreen(event);
  }

  bool _isInHomeArea() {
    // This property is set on the Area layer of the map
    var tileProps = tilePropertiesBelow();
    return tileProps != null && (tileProps["isArea"] ?? false);
  }
}

class _PlayerSpriteSheet {
  static const double runStepTime = 0.08;

  static Future<SpriteAnimation> get idleRight =>
      SpriteAnimation.load('sprites/player_idle_right.png', SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get idleDown =>
      SpriteAnimation.load('sprites/player_idle_down.png', SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get idleLeft =>
      SpriteAnimation.load('sprites/player_idle_left.png', SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get idleUp =>
      SpriteAnimation.load('sprites/player_idle_up.png', SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get runRight =>
      SpriteAnimation.load('sprites/player_walk_right.png', SpriteAnimationData.sequenced(amount: 9, stepTime: runStepTime, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get runDown =>
      SpriteAnimation.load('sprites/player_walk_down.png', SpriteAnimationData.sequenced(amount: 9, stepTime: runStepTime, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get runLeft =>
      SpriteAnimation.load('sprites/player_walk_left.png', SpriteAnimationData.sequenced(amount: 9, stepTime: runStepTime, textureSize: Vector2.all(64)));

  static Future<SpriteAnimation> get runUp =>
      SpriteAnimation.load('sprites/player_walk_up.png', SpriteAnimationData.sequenced(amount: 9, stepTime: runStepTime, textureSize: Vector2.all(64)));

  static SimpleDirectionAnimation get animation => SimpleDirectionAnimation(
      idleRight: idleRight,
      idleDown: idleDown,
      idleLeft: idleLeft,
      idleUp: idleUp,
      runRight: runRight,
      runDown: runDown,
      runLeft: runLeft,
      runUp: runUp,
      enabledFlipX: false,
      enabledFlipY: false);
}
