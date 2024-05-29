import 'dart:math';

import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/endless_jungle.dart';
import '/models/enemy_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class EnemyManager extends Component with HasGameReference<EndlessJungle> {
  // A list to hold data for all the enemies.
  final List<EnemyData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(2, repeat: true);

  EnemyManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    final randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = Enemy(enemyData);

    // Help in setting all enemies on ground.
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(
      game.virtualSize.x + 32,
      game.virtualSize.y - 24,
    );

    // If this enemy can fly, set its y position randomly.
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    enemy.size = enemyData.textureSize;
    game.world.add(enemy);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      _data.addAll([
        EnemyData(
          image: game.images.fromCache('Bunny/Run (34x44).png'),
          nFrames: 12,
          stepTime: 0.1,
          textureSize: Vector2(34, 44),
          speedX: 80,
          canFly: false,
        ),
        EnemyData(
          image: game.images.fromCache('BlueBird/Flying (32x32).png'),
          nFrames: 9,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
          speedX: 105,
          canFly: true,
        ),
        EnemyData(
          image: game.images.fromCache('Chicken/Run (32x34).png'),
          nFrames: 14,
          stepTime: 0.09,
          textureSize: Vector2(32, 34),
          speedX: 150,
          canFly: false,
        ),
      ]);
    }
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}

//_AssertionError ('package:flame/src/cache/images.dart': Failed assertion: line 104 pos 7: 'asset != null': Tried to access an image "Bunny/Run (34x44).png" that does not exist in the cache. Make sure to load() an image before accessing it)