import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/injector_model.dart';

class InjectorApi {
  static const String baseUrl =
    "https://api.api-nusantaradiesel.tech/api/injectors";
  

  static Future<List<Injector>> getInjectors() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Injector.fromJson(e)).toList();
  }

  static Future<int> addInjector(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return jsonDecode(res.body)['id'];
  }


  static Future<void> stockOut({
    required String barcode,
    required int qty,
    required String notes,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/stock-out"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "barcode": barcode,
        "qty": qty,
        "notes": notes,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }
  }

  static Future<List<dynamic>> getHistory() async {
    final res = await http.get(Uri.parse("$baseUrl/history"));

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return jsonDecode(res.body);
  }

  static Future<void> stockInExisting({
  required int existingId,
  required int qty,
  required String notes,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/stock-in"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "existing_id": existingId,
      "qty": qty,
      "ket": notes,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }
}


static Future<void> updateInjector(int id, Map<String, dynamic> data) async {
  final res = await http.put(
    Uri.parse("$baseUrl/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }
}


}


