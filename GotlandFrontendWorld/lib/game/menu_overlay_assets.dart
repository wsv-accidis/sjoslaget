import 'package:bonfire/bonfire.dart';

class MenuOverlayAssets {
  static late final Image frame;

  static Future load() async {
    frame = await Flame.images.load("ui/frame_32.png");
  }
}
