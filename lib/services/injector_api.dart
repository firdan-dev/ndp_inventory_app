import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/injector_model.dart';

class InjectorApi {
  static const String baseUrl =
      'https://api.api-nusantaradiesel.tech/api/injectors';

  static const Map<String, String>
  _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Injector>>
  getInjectors() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal mengambil data injector',
        ),
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format daftar injector tidak valid',
      );
    }

    return decoded.map<Injector>((item) {
      return Injector.fromJson(
        Map<String, dynamic>.from(
          item as Map,
        ),
      );
    }).toList();
  }

  static Future<String>
  getNextInjectorId() async {
    final response = await http.get(
      Uri.parse('$baseUrl/next-code'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal mengambil ID injector',
        ),
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map ||
        decoded['injector_id'] == null) {
      throw Exception(
        'Format ID injector tidak valid',
      );
    }

    return decoded['injector_id'].toString();
  }

  static Future<int> addInjector(
      Map<String, dynamic> data,
      ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal menambahkan injector',
        ),
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Format respons tambah injector tidak valid',
      );
    }

    final id = int.tryParse(
      decoded['id']?.toString() ?? '',
    );

    if (id == null) {
      throw Exception(
        'ID injector tidak ditemukan',
      );
    }

    return id;
  }

  static Future<void> stockIn({
    required String barcode,
    required int qty,
    String? notes,
  }) async {
    if (barcode.trim().isEmpty) {
      throw Exception(
        'Barcode injector wajib diisi',
      );
    }

    if (qty <= 0) {
      throw Exception(
        'Jumlah harus lebih dari 0',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/stock-in'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'barcode': barcode.trim(),
        'qty': qty,
        'notes': _emptyToNull(notes),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Stock in injector gagal',
        ),
      );
    }
  }

  static Future<void> stockOut({
    required String barcode,
    required int qty,
    String? notes,
  }) async {
    if (barcode.trim().isEmpty) {
      throw Exception(
        'Barcode injector wajib diisi',
      );
    }

    if (qty <= 0) {
      throw Exception(
        'Jumlah harus lebih dari 0',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/stock-out'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'barcode': barcode.trim(),
        'qty': qty,
        'notes': _emptyToNull(notes),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Stock out injector gagal',
        ),
      );
    }
  }

  static Future<List<dynamic>>
  getHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal mengambil history injector',
        ),
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format history injector tidak valid',
      );
    }

    return decoded;
  }

  static Future<void> updateInjector(
      int id,
      Map<String, dynamic> data,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal memperbarui injector',
        ),
      );
    }
  }

  static String? _emptyToNull(
      String? value,
      ) {
    final text = value?.trim();

    return text == null || text.isEmpty
        ? null
        : text;
  }

  static String _errorMessage(
      http.Response response,
      String fallback,
      ) {
    try {
      final decoded =
      jsonDecode(response.body);

      if (decoded is Map) {
        final message =
        decoded['message']?.toString();

        if (message != null &&
            message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Respons bukan JSON.
    }

    return response.body.trim().isNotEmpty
        ? response.body
        : '$fallback '
        '(HTTP ${response.statusCode})';
  }
}