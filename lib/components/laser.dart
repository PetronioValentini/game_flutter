import 'package:flame/components.dart';

class Laser extends SpriteAnimationComponent {
  final Future<Sprite> Function(String) loadSpriteFunction;
  final Vector2 direction; // Armazena a direção do disparo
  final Vector2 startPosition; // Nova propriedade para a posição inicial

  Laser(
      {super.position,
      required this.startPosition, // Parâmetro adicionado para a posição inicial
      required this.direction,
      required this.loadSpriteFunction})
      : super(
          size: Vector2(1000, 150), // Tamanho do raio laser
        );

  final double _speed = 500; // Velocidade do raio laser

  @override
  Future<void> onLoad() async {
    // Carregar o sprite de forma assíncrona
    final List<Sprite> sprites = await Future.wait([
      loadSpriteFunction('powers/laser/pulse1.png'),
      loadSpriteFunction('powers/laser/pulse2.png'),
      loadSpriteFunction('powers/laser/pulse3.png'),
      loadSpriteFunction('powers/laser/pulse4.png'),
    ]);

    // Criar animação
    final spriteAnimation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.15, // Tempo de exibição de cada quadro (em segundos)
    );

    // Atribuir a animação ao componente
    animation = spriteAnimation;
    position.setFrom(startPosition); // Define a posição inicial do laser como a posição fornecida
    // Chamar super.onLoad() depois de carregar a animacao
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * _speed * dt; // Movimento do raio laser
  }
}
  /*
  @override
  void render(Canvas canvas) {
    super.render(canvas);
     LASER DESENHADO
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y), _paint); // Desenha o raio laser
    
  }
  */

