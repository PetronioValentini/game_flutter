import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  Player({super.position, this.character = 'cat'});

  String character;

  late final SpriteAnimation idleAnimation,
      runningAnimation,
      jumpingAnimation,
      fallingAnimation;

  final double stepTime = 0.1; // 0.1

  // Escala dos personagens de 4.0x
  //final Vector2 characterScale = Vector2(4.0, 4.0);

  double horizontalMoviment = 0;
  double moveSpeed = 150;
  Vector2 velocity = Vector2.zero();
  final double _gravity = 9.8;
  final double _jumpForce = 700; // 460
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  List<CollisionBlock> collisionBlocks = [];

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 45,
    offsetY: 70,
    width: 50,
    height: 60,
    /*offsetX: 10,
    offsetY: 17,
    width: 15,
    height: 15,
    */
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    //scale = characterScale; // Definir a escala do personagem
    debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMoviment(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMoviment = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    // se e verdadeiro -1 se e falso 0
    horizontalMoviment += isLeftKeyPressed ? -1 : 0;
    horizontalMoviment += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(8, 0);

    runningAnimation = _spriteAnimation(8, 512);

    jumpingAnimation = _spriteAnimationSingleFrame(3, 2432); // 19 608

    fallingAnimation = _spriteAnimationSingleFrame(2, 2560); // 20 640

    // Lista de todas animações
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    // Define a animação atual
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(int amount, double vectorY) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('character/$character/animation.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(128),
        texturePosition: Vector2(0, vectorY),
      ),
    );
  }

  // SPRITE UNICO PARA PULO E QUEDA
  SpriteAnimation _spriteAnimationSingleFrame(int frameIndex, double vectorY) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('character/$character/animation.png'),
      SpriteAnimationData.sequenced(
        amount: 1, // Apenas um quadro
        stepTime: stepTime, // Ajuste conforme necessário
        textureSize: Vector2.all(128),
        texturePosition: Vector2(128, vectorY),
      ),
    );
  }

  void _updatePlayerMoviment(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    if (velocity.y > _gravity) {
      isOnGround = false;
    }

    velocity.x = horizontalMoviment * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    if (velocity.y > 0) {
      playerState = PlayerState.falling;
    }

    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        } else {
          if (checkCollision(this, block)) {
            if (velocity.y > 0) {
              velocity.y = 0;
              position.y = block.y - hitbox.height - hitbox.offsetY;
              isOnGround = true;
              break;
            }
            if (velocity.y < 0) {
              velocity.y = 0;
              position.y = block.y + block.height - hitbox.offsetY;
            }
          }
        }
      }
    }
  }
}