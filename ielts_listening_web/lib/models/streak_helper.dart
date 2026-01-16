import 'package:shared_preferences/shared_preferences.dart';

class StreakHelper {
  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastActive = prefs.getString('lastActiveDate');
    int currentStreak = prefs.getInt('streak') ?? 0;

    if (lastActive != null) {
      final lastDate = DateTime.parse(lastActive);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        currentStreak += 1;
      } else if (difference > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    await prefs.setString('lastActiveDate', today.toIso8601String());
    await prefs.setInt('streak', currentStreak);
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak') ?? 0;
  }
}
