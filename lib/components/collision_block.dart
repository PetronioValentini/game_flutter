import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  CollisionBlock({required Vector2 position, required Vector2 size, this.isPlatform = false})
      : super(position: position, size: size) {
    debugMode = true;
  }

  bool isPlatform;
}
