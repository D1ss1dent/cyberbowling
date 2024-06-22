import 'package:cyberbowling/game/components/shared_preferences.dart';
import 'package:cyberbowling/menu_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: MenuScreen(
      sharedPreferencesService: SharedPreferencesService(),
    ),
    debugShowCheckedModeBanner: false,
  ));
}
