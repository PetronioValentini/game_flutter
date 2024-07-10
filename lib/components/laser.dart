import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Laser extends SpriteComponent {
  Laser({Vector2? position, Vector2? direction})
      : super(
          position: position,
          size: Vector2(1000, 10), // Tamanho do raio laser
        );

  final double _speed = 500; // Velocidade do raio laser
  final Paint _paint = Paint()..color = Colors.red; // Cor do raio laser

  @override
  Future<void> onLoad() async {
    // Carregar o sprite de forma assíncrona
    final spriteImage = await Sprite.load(
        'background/backgroundimage.png'); // Substitua 'empty.png' pelo caminho da sua imagem

    // Atribuir o sprite carregado à variável sprite
    sprite = spriteImage;

    // Chamar super.onLoad() depois de carregar o sprite
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += Vector2(2, 0) * _speed * dt; // Movimento do raio laser
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y), _paint); // Desenha o raio laser
  }
}
