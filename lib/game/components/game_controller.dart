import 'dart:math';

import 'package:cyberbowling/game/components/bowling_pin.dart';
import 'package:cyberbowling/game/components/game_state.dart';
import 'package:cyberbowling/game/game%20file/bowling_game.dart';

class GameController {
  GameState gameState;
  UserObject userObject;
  double lastPinTime = 0;
  double pinSpawnInterval = 1.0;
  final void Function() playCollisionSound;
  bool isSoundOn2;

  GameController(
      {required this.gameState,
      required this.userObject,
      required this.playCollisionSound,
      required this.isSoundOn2});

  void updatePins(double time, double screenWidth, double screenHeight) {
    List<BowlingPin> pinsToRemove = [];

    for (var pin in gameState.pins) {
      pin.update(time, screenWidth, screenHeight);

      if (!pin.isActive || pin.yPos < 0) {
        pinsToRemove.add(pin);
      } else if (pin.isActive && userObject.isColliding(pin)) {
        pin.isActive = false;
        pinsToRemove.add(pin);
        if (userObject != null) {
          userObject.incrementPoints();
        }
        print('isSoundOn is ${isSoundOn2}');
        if (isSoundOn2) {
          playCollisionSound();
        }
      }
    }

    gameState.pins.removeWhere((pin) => pinsToRemove.contains(pin));

    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    if (currentTime - lastPinTime > pinSpawnInterval) {
      double randomXPos = Random().nextDouble() * screenWidth;
      double pinSize = 20.0;
      double pinSpeed = 150.0;

      bool canAddPin = !gameState.pins
          .any((pin) => (pin.xPos - randomXPos).abs() < pinSize * 2);

      if (canAddPin) {
        gameState.pins.add(BowlingPin(
          xPos: randomXPos,
          yPos: 0,
          size: pinSize,
          speed: pinSpeed,
          direction: pi / 2,
          isActive: true,
        ));

        lastPinTime = currentTime;
      }
    }
  }
}
