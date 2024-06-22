import 'dart:ui' as ui;
import 'dart:math';
import 'package:cyberbowling/game/components/red_line.dart';
import 'package:flutter/material.dart';

class BowlingPin {
  double xPos;
  double yPos;
  double size;
  double speed;
  double direction;
  bool isActive;

  BowlingPin({
    required this.xPos,
    required this.yPos,
    required this.size,
    required this.speed,
    required this.direction,
    this.isActive = true,
  });

  void update(double time, double screenWidth, double screenHeight) {
    if (isActive) {
      xPos += cos(direction) * speed * time;
      yPos += sin(direction) * speed * time;

      if (xPos < 0) xPos = screenWidth;
      if (xPos > screenWidth) xPos = 0;
      if (yPos < 0) yPos = screenHeight;
      if (yPos > screenHeight) yPos = 0;
    }
  }

  void draw(Canvas canvas, ui.Image pinImage) {
    if (isActive) {
      final imageSize = Size(40, 100);
      final imageRect = Rect.fromCenter(
          center: Offset(xPos, yPos),
          width: imageSize.width,
          height: imageSize.height);
      canvas.drawImageRect(
        pinImage,
        Rect.fromLTRB(
            0, 0, pinImage.width.toDouble(), pinImage.height.toDouble()),
        imageRect,
        Paint(),
      );
    }
  }

  bool isCollidingWithRedLine(RedLine redLine) {
    return yPos + size / 2 >= redLine.yPos;
  }
}
