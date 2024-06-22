import 'package:cyberbowling/game/components/shared_preferences.dart';
import 'package:cyberbowling/game/game%20file/bowling_game.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MenuScreen extends StatefulWidget {
  final SharedPreferencesService sharedPreferencesService;

  MenuScreen({required this.sharedPreferencesService});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundOn = true;
  int bestScore = 1;
  AudioPlayer audioPlayer2 = AudioPlayer();
  bool isSoundOn2 = true;

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
    _loadBestScore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  void _loadBestScore() async {
    bestScore = await widget.sharedPreferencesService.getBestScore();
    setState(() {});
  }

  void _playBackgroundMusic() async {
    await audioPlayer.play(AssetSource('background.wav'));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
      if (isSoundOn) {
        _playBackgroundMusic();
      } else {
        audioPlayer.stop();
      }
    });
  }

  void _toggleSound2() {
    setState(() {
      if (isSoundOn2) {
        print('sound on');
      } else {
        print('sound off');
        audioPlayer2.stop();
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_menu.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo.png',
                      height: 250,
                      width: 250,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GameScreen(isSoundOn2: isSoundOn2)),
                        );
                      },
                      child: Container(
                        width: 350,
                        height: 90,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/button2.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color: Colors.black,
                              size: 50.0,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Start Game',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 350,
                      height: 90,
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
                          "Best Score: $bestScore",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _toggleSound,
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/button1.png',
                        ),
                        Icon(
                          isSoundOn ? Icons.music_note : Icons.music_off,
                          color: Colors.black,
                          size: 25.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50.0,
                right: 0.0,
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 30,
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/button1.png',
                        ),
                        Icon(
                          isSoundOn2 ? Icons.volume_up : Icons.volume_off,
                          color: Colors.black,
                          size: 25.0,
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        isSoundOn2 = !isSoundOn2;
                      });
                      _toggleSound2();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
