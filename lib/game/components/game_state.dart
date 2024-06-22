import 'package:cyberbowling/game/components/bowling_pin.dart';

class GameState {
  List<BowlingPin> pins;

  GameState({required this.pins});

  factory GameState.standard() => GameState(pins: []);
}
