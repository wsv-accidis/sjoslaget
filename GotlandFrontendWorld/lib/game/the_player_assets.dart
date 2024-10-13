import 'package:bonfire/bonfire.dart';

class ThePlayerAssets {
  static const double _runStepTime = 0.08;

  static late final Image _idleRightImage;
  static late final Image _idleDownImage;
  static late final Image _idleLeftImage;
  static late final Image _idleUpImage;
  static late final Image _runRightImage;
  static late final Image _runDownImage;
  static late final Image _runLeftImage;
  static late final Image _runUpImage;

  static SpriteAnimation get _idleRight =>
      SpriteAnimation.fromFrameData(_idleRightImage, SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static SpriteAnimation get _idleDown =>
      SpriteAnimation.fromFrameData(_idleDownImage, SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static SpriteAnimation get _idleLeft =>
      SpriteAnimation.fromFrameData(_idleLeftImage, SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static SpriteAnimation get _idleUp =>
      SpriteAnimation.fromFrameData(_idleUpImage, SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: Vector2.all(64)));

  static SpriteAnimation get _runRight =>
      SpriteAnimation.fromFrameData(_runRightImage, SpriteAnimationData.sequenced(amount: 9, stepTime: _runStepTime, textureSize: Vector2.all(64)));

  static SpriteAnimation get _runDown =>
      SpriteAnimation.fromFrameData(_runDownImage, SpriteAnimationData.sequenced(amount: 9, stepTime: _runStepTime, textureSize: Vector2.all(64)));

  static SpriteAnimation get _runLeft =>
      SpriteAnimation.fromFrameData(_runLeftImage, SpriteAnimationData.sequenced(amount: 9, stepTime: _runStepTime, textureSize: Vector2.all(64)));

  static SpriteAnimation get _runUp =>
      SpriteAnimation.fromFrameData(_runUpImage, SpriteAnimationData.sequenced(amount: 9, stepTime: _runStepTime, textureSize: Vector2.all(64)));

  static SimpleDirectionAnimation get animation => SimpleDirectionAnimation(
      idleRight: _idleRight,
      idleDown: _idleDown,
      idleLeft: _idleLeft,
      idleUp: _idleUp,
      runRight: _runRight,
      runDown: _runDown,
      runLeft: _runLeft,
      runUp: _runUp,
      enabledFlipX: false,
      enabledFlipY: false);

  static Future load() async {
    _idleRightImage = await Flame.images.load('sprites/player_idle_right.png');
    _idleDownImage = await Flame.images.load('sprites/player_idle_down.png');
    _idleLeftImage = await Flame.images.load('sprites/player_idle_left.png');
    _idleUpImage = await Flame.images.load('sprites/player_idle_up.png');
    _runRightImage = await Flame.images.load('sprites/player_run_right.png');
    _runDownImage = await Flame.images.load('sprites/player_run_down.png');
    _runLeftImage = await Flame.images.load('sprites/player_run_left.png');
    _runUpImage = await Flame.images.load('sprites/player_run_up.png');
  }
}
