import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static Future<void> saveUser(Map<String, dynamic> user) async {
    // disable save user
  }

  static Future<Map<String, dynamic>?> getUser() async {
    // selalu paksa ke login page
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}