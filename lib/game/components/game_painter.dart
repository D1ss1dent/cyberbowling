import 'dart:ui' as ui;

import 'package:cyberbowling/game/components/game_state.dart';
import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final GameState gameState;
  final double time;
  final ui.Image pinImage;

  GamePainter(
      {required this.gameState, required this.time, required this.pinImage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = Colors.brown;
    for (var pin in gameState.pins) {
      pin.draw(canvas, pinImage);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
