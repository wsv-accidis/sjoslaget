import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart' show GlobalKey;
import 'package:world/game/menu_overlay.dart';
import 'package:world/game/the_player_assets.dart';
import 'package:world/util/global_key_extension.dart';

class ThePlayer extends SimplePlayer with BlockMovementCollision, PathFinding, TapGesture, TileRecognizer {
  ThePlayer(Vector2 position, this.menuKey) : super(position: position, size: Vector2.all(64), speed: 160.0, animation: ThePlayerAssets.animation);

  final GlobalKey<MenuOverlayState> menuKey;

  // Player sprite hitbox
  static final _playerHitbox = RectangleHitbox(size: Vector2(32, 50), position: Vector2(16, 13));

  // State for pathfinding
  var _pathFindingLastPos = Vector2.zero();
  var _pathFindingLastTime = 0;
  static const _pathFindingMinDelay = 1000;

  @override
  void onBlockedMovement(PositionComponent other, CollisionData collisionData) {
    // moveToPositionWithPathFinding tends to get stuck on things, stop moving to reset the walking animation
    stopMove();
    super.onBlockedMovement(other, collisionData);
  }

  @override
  Future<void> onLoad() {
    add(_playerHitbox);
    setupPathFinding(linePathEnabled: false, showBarriersCalculated: false);
    return super.onLoad();
  }

  @override
  void onMove(double speed, Vector2 displacement, Direction direction, double angle) {
    // Show the full menu only when player is inside home area
    final isInHomeArea = _isInHomeArea();
    menuKey.currentState?.mode = isInHomeArea ? MenuMode.collapsed : MenuMode.homeOnly;

    super.onMove(speed, displacement, direction, angle);
  }

  @override
  void onTap() {}

  @override
  void onTapDownScreen(GestureEvent event) {
    // Supress taps that hit the menu
    if (menuKey.globalPaintBounds?.containsPoint(event.screenPosition) ?? false) {
      return;
    }

    // Suppress repeated taps on same position since this creates jank
    var moveToPosition = Vector2(event.worldPosition.x.roundToDouble(), event.worldPosition.y.roundToDouble());
    var now = DateTime.now().millisecondsSinceEpoch;
    if (moveToPosition != _pathFindingLastPos || now - _pathFindingLastTime > _pathFindingMinDelay) {
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
