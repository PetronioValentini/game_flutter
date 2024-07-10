import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World {
  Level({required this.levelName, required this.player});

  final Player player;
  final String levelName;
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    // Carrega o mapa Tiled
    _scrollingBackGround();
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(4));
    add(level);

    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  Future<void> _scrollingBackGround() async {
    // Carrega a imagem de fundo
    final backgroundImage = await Sprite.load('background/backgroundimage.png');

    // Cria um componente de Sprite para a imagem de fundo
    final background = SpriteComponent(
      sprite: backgroundImage,
      size: Vector2(1440, 960),
    );

    // Adiciona o componente de fundo ao mundo
    add(background);
  }

  void _spawningObjects() {
    // Obtém a camada de pontos de spawn
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      // Adiciona os objetos de acordo com os pontos de spawn
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;

          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
