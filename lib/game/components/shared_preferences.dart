import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<int> getBestScore() async {
    final prefs = await _prefs;
    return prefs.getInt('bestScore') ?? 0;
  }

  Future<void> setBestScore(int score) async {
    final prefs = await _prefs;
    await prefs.setInt('bestScore', score);

    print('New best score: $score');
  }
}
