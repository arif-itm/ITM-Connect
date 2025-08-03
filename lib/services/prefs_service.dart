import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _kHasOnboarded = 'hasOnboarded';

  static Future<bool> getHasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasOnboarded) ?? false;
    }

  static Future<void> setHasOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasOnboarded, value);
  }

  static Future<void> clearHasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHasOnboarded);
  }
}
