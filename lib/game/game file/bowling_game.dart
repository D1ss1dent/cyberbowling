import 'dart:async';
import 'dart:ui' as ui;
import 'package:cyberbowling/game/components/background.dart';
import 'package:cyberbowling/game/components/bowling_pin.dart';
import 'package:cyberbowling/game/components/game_controller.dart';
import 'package:cyberbowling/game/components/game_painter.dart';
import 'package:cyberbowling/game/components/game_state.dart';
import 'package:cyberbowling/game/components/load_image.dart';
import 'package:cyberbowling/game/components/red_line.dart';
import 'package:cyberbowling/game/components/shared_preferences.dart';
import 'package:cyberbowling/game/components/transparent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class UserObject {
  double xPos;
  double yPos;
  double size;
  double screenWidth;
  _GameScreenState state;
  int points;
  bool isGamePaused;

  double interactionRadiusRight = 20.0;
  double interactionRadiusLeft = 70.0;
  double interactionRadiusUp = 130.0;
  double interactionRadiusDown = 10.0;

  final SharedPreferencesService sharedPreferencesService;

  UserObject(
    this.xPos,
    this.yPos,
    this.size,
    this.state,
    this.screenWidth,
    this.isGamePaused,
    this.sharedPreferencesService,
  ) : points = 0;

  bool isColliding(BowlingPin pin) {
    double xDistance = xPos - pin.xPos;
    double yDistance = yPos - pin.yPos;

    bool isWithinHorizontalRange = (xDistance <= interactionRadiusRight &&
        xDistance >= -interactionRadiusLeft);
    bool isWithinVerticalRange = (yDistance <= interactionRadiusUp &&
        yDistance >= -interactionRadiusDown);

    return isWithinHorizontalRange && isWithinVerticalRange;
  }

  void incrementPoints() async {
    state.setState(() {
      points++;
    });

    int bestScore = await sharedPreferencesService.getBestScore();
    if (points > bestScore) {
      await sharedPreferencesService.setBestScore(points);
    }
  }

  Widget buildUserWidget() {
    double interactionWidth = interactionRadiusRight + interactionRadiusLeft;
    double interactionHeight = interactionRadiusUp + interactionRadiusDown;

    return Positioned(
      left: xPos - interactionWidth / 2,
      top: yPos - interactionHeight / 2 - 100,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          final newX = xPos + details.delta.dx;
          final halfWidth = interactionWidth / 2;
          if (newX >= halfWidth && newX <= screenWidth - halfWidth) {
            state.setState(() {
              xPos = newX;
            });
          }
        },
        // child: Image.asset(
        //   isGamePaused ? 'assets/animation_paused.gif' : 'assets/animation.gif',
        //   width: interactionWidth,
        //   height: interactionHeight,
        // ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool isSoundOn2;

  GameScreen({required this.isSoundOn2});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController gameController;
  late Timer timer;
  UserObject? userObject;
  ui.Image? pinImage;
  bool firstTime = true;
  final List<Back> _Backs = <Back>[];

  bool isGamePaused = false;
  bool isGameInitialized = false;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      userObject ??= await UserObject(
        screenWidth / 2,
        screenHeight * 0.9,
        40,
        this,
        screenWidth,
        isGamePaused,
        SharedPreferencesService(),
      );

      gameController = GameController(
        gameState: GameState.standard(),
        userObject: userObject!,
        playCollisionSound: _playCollisionSound,
        isSoundOn2: widget.isSoundOn2,
      );

      if (pinImage == null) {
        pinImage = await loadImage('assets/pin.png');
        setState(() {});
      }

      startGame();
      isGameInitialized = true;
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (userObject == null) {
      return CircularProgressIndicator();
    }

    List<Widget> getBacks() {
      if (firstTime) {
        firstTime = false;
        _Backs.add(Back(top: -3));
        _Backs.add(Back(top: screenHeight / 3 - 4));
        _Backs.add(Back(top: screenHeight / 3 * 2 - 5));
      }
      List<Widget> list = <Widget>[];
      for (Back back in _Backs) {
        list.add(
          Positioned(
            top: back.top,
            left: 0,
            child: Image.asset(
              "assets/background.png",
              width: screenWidth,
              height: screenHeight / 2,
              fit: BoxFit.fill,
            ),
          ),
        );
      }
      return list;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              iconSize: 30,
              icon: isGamePaused
                  ? const Icon(Icons.play_arrow, size: 30, color: Colors.white)
                  : const Icon(Icons.pause, size: 30, color: Colors.white),
              onPressed: () {
                setState(() {
                  isGamePaused = !isGamePaused;
                  if (isGamePaused) {
                    timer.cancel();
                    _pauseGame();
                  } else {
                    startGame();
                  }
                });
              },
            ),
          ],
          title: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Knocked down pins: ${userObject!.points}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            ...getBacks(),
            CustomPaint(
              size: Size(screenWidth, screenHeight),
              painter: pinImage != null
                  ? GamePainter(
                      gameState: gameController.gameState,
                      time: 0.02,
                      pinImage: pinImage!,
                    )
                  : null,
            ),
            Positioned(
              left: userObject!.xPos ?? 0,
              top: (userObject!.yPos ?? 0) - (userObject!.size ?? 0) / 2 - 120,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (userObject != null) {
                    setState(() {
                      userObject!.xPos += details.delta.dx;
                    });
                  }
                },
                child: Image.asset(
                  isGamePaused
                      ? 'assets/animation_paused.gif'
                      : 'assets/animation.gif',
                  width: (userObject!.size ?? 0) + 75,
                  height: (userObject!.size ?? 0) + 75,
                ),
              ),
            ),
            RedLine(screenHeight - 1),
          ],
        ),
      ),
    );
  }

  @override
  void _playCollisionSound() async {
    await audioPlayer.play(AssetSource('interaction.wav'));
    audioPlayer.setReleaseMode(ReleaseMode.release);
  }

  @override
  void startGame() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    userObject ??= UserObject(
      screenWidth / 2,
      screenHeight * 0.9,
      40,
      this,
      screenWidth,
      isGamePaused,
      SharedPreferencesService(),
    );

    final redLine = RedLine(screenHeight - 1);

    timer = Timer.periodic(Duration(milliseconds: 20), (_) {
      if (!isGamePaused) {
        gameController.updatePins(0.02, screenWidth, screenHeight);

        if (gameController.gameState.pins
            .any((pin) => pin.isCollidingWithRedLine(redLine))) {
          _endGame();
        }

        bool backToAdd = false;
        Back? backToDelete;
        setState(() {
          for (Back back in _Backs) {
            if (back.top! < -1 && back.top! >= -4) {
              backToAdd = true;
            }
            if (back.top! <= screenHeight + 0 &&
                back.top! >= screenHeight - 3) {
              backToDelete = back;
            }
            back.top = back.top! + 3;
          }
        });
        if (backToAdd) {
          _Backs.add(Back(top: -screenHeight / 3 + 1));
        }
        if (backToDelete != null) {
          _Backs.remove(backToDelete);
        }
      }
    });
  }

  @override
  void _pauseGame() {
    setState(() {
      isGamePaused = true;
      timer.cancel();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: TransparentDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 300,
                  height: 80,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/button2.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: const Center(
                    child: Text(
                      "Game Paused",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          isGamePaused = false;
                          timer.cancel();
                          gameController.gameState.pins.clear();
                          userObject!.points = 0;
                          startGame();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Container(
                        height: 80,
                        width: 150,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/button2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: const Center(
                          child: Text(
                            "Restart",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          isGamePaused = false;
                          startGame();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Container(
                        height: 80,
                        width: 150,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/button2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        child: const Center(
                          child: Text(
                            "Resume",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void _endGame() {
    setState(() {
      isGamePaused = true;
      timer.cancel();
    });

    int knockedDownPins = userObject!.points;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: TransparentDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 270,
                  height: 80,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/button2.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: const Center(
                    child: Text(
                      "Game Over!",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  width: 310,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/button2.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      "You knocked down $knockedDownPins pins",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  width: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/button2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        isGamePaused = false;
                        timer.cancel();
                        gameController.gameState.pins.clear();
                        userObject!.points = 0;
                        startGame();
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        "Restart",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
