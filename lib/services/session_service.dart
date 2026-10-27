import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kUserId = 'user_id';

  static Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUserId, id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUserId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
  }
}

