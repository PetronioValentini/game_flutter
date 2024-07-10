import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents {
  // background
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  // adiciona cameraComponent
  late CameraComponent cam;
  Player player = Player(character: 'cat');

  @override
  FutureOr<void> onLoad() async {
    // cache das imagens
    await images.loadAllImages();

    // adiciona o level
    final world = Level(player: player, levelName: 'FrozenMap-01');

    // definicoes para camera
    cam = CameraComponent.withFixedResolution(
        world: world, width: 1440, height: 960);
    cam.viewfinder.anchor = Anchor.topLeft;

    //adiciona camera e mundo
    addAll([cam, world]);

    return super.onLoad();
  }
}
