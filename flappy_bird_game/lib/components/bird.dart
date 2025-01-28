import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flappy_bird_game/game/bird_movement.dart';
import 'package:flappy_bird_game/game/assets.dart';
import 'package:flappy_bird_game/game/configuration.dart';
import 'package:flappy_bird_game/game/flappy_bird_game.dart';
import 'package:flutter/material.dart';

class Bird extends SpriteGroupComponent<BirdMovement>
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  Bird();

  int score = 0;
  int record = 0;

  @override
  Future<void> onLoad() async {
    final birdMidFlap = await gameRef.loadSprite(Assets.birdMidFlap);
    final birdUpFlap = await gameRef.loadSprite(Assets.birdUpFlap);
    final birdDownFlap = await gameRef.loadSprite(Assets.birdDownFlap);

    sprites = {
      BirdMovement.middle: birdMidFlap,
      BirdMovement.up: birdUpFlap,
      BirdMovement.down: birdDownFlap,
    };

    current = BirdMovement.middle;

    size = Vector2(60, 50);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.birdVelocity * dt;

    if (position.y < 1) {
      gameOver();
    }
  }

  void fly() {
    if (gameRef.isHit) return;

    add(
      MoveByEffect(
        Vector2(0, Config.gravity),
        EffectController(duration: 0.3, curve: Curves.decelerate),
        onComplete: () => current = BirdMovement.down,
      ),
    );

    FlameAudio.play(Assets.flying);
    current = BirdMovement.up;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    gameOver();
  }

  void reset() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    score = 0;
    current = BirdMovement.middle;
    if (score > record) {
      record = score;
    }
  }

  void gameOver() {
    if (gameRef.isHit) return;

    FlameAudio.play(Assets.collision);
    gameRef.isHit = true;
    gameRef.overlays.add('gameOver');
    gameRef.pauseEngine();
  }
}
