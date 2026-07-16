import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _userKey = 'auth_user';

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userKey);

    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawUser);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      await prefs.remove(_userKey);
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}