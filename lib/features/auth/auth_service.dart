import 'dart:convert';
import 'package:flutter/foundation.dart'; // Tambahkan ini
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://api.api-nusantaradiesel.tech/api";

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username.trim(),
        "password": password.trim(),
      }),
    );

    // ==========================
    // DEBUG
    // ==========================
    debugPrint("STATUS : ${res.statusCode}");
    debugPrint("BODY   : ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['user'] ?? data;
    }

    return null;
  }
}