import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fip_model.dart';

class FipApi {
  static const String baseUrl =
      'https://api.api-nusantaradiesel.tech/api/fip';

  static const Map<String, String>
  _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Fip>>
  getFips() async {
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
          'Gagal mengambil data Fuel Injection Pump',
        ),
      );
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! List) {
      throw Exception(
        'Format data Fuel Injection Pump tidak valid',
      );
    }

    return decoded.map<Fip>(
          (item) {
        return Fip.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        );
      },
    ).toList();
  }

  static Future<String>
  getNextPumpId() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/next-code',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal mengambil Pump ID berikutnya',
        ),
      );
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! Map ||
        decoded['pump_id'] == null) {
      throw Exception(
        'Format Pump ID tidak valid',
      );
    }

    return decoded[
    'pump_id']
        .toString();
  }

  static Future<int> addFip(
      Map<String, dynamic> data,
      ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers:
      _jsonHeaders,
      body:
      jsonEncode(
        data,
      ),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal menambahkan Fuel Injection Pump',
        ),
      );
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Format respons tambah FIP tidak valid',
      );
    }

    final id =
    int.tryParse(
      decoded['id']
          ?.toString() ??
          '',
    );

    if (id == null) {
      throw Exception(
        'ID Fuel Injection Pump tidak ditemukan',
      );
    }

    return id;
  }

  static Future<void>
  updateFip(
      int id,
      Map<String, dynamic> data,
      ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/$id',
      ),
      headers:
      _jsonHeaders,
      body:
      jsonEncode(
        data,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal memperbarui Fuel Injection Pump',
        ),
      );
    }
  }

  static Future<void> deleteFip(
      int id,
      ) async {
    final response =
    await http.delete(
      Uri.parse(
        '$baseUrl/$id',
      ),
      headers: const {
        'Accept':
        'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal menghapus Fuel Injection Pump',
        ),
      );
    }
  }

  static Future<void>
  stockIn({
    required int id,
    required int qty,
    String? notes,
  }) async {
    if (qty <= 0) {
      throw Exception(
        'Jumlah Stock In harus lebih dari 0',
      );
    }

    final response = await http.post(
      Uri.parse(
        '$baseUrl/stock-in',
      ),
      headers:
      _jsonHeaders,
      body:
      jsonEncode({
        'id': id,
        'qty': qty,
        'notes':
        _emptyToNull(
          notes,
        ),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Stock In Fuel Injection Pump gagal',
        ),
      );
    }
  }

  static Future<void>
  stockOut({
    required int id,
    required int qty,
    String? notes,
  }) async {
    if (qty <= 0) {
      throw Exception(
        'Jumlah Stock Out harus lebih dari 0',
      );
    }

    final response = await http.post(
      Uri.parse(
        '$baseUrl/stock-out',
      ),
      headers:
      _jsonHeaders,
      body:
      jsonEncode({
        'id': id,
        'qty': qty,
        'notes':
        _emptyToNull(
          notes,
        ),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Stock Out Fuel Injection Pump gagal',
        ),
      );
    }
  }

  static Future<List<dynamic>>
  getHistory() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/history',
      ),
      headers: const {
        'Accept':
        'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Gagal mengambil history Fuel Injection Pump',
        ),
      );
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! List) {
      throw Exception(
        'Format history Fuel Injection Pump tidak valid',
      );
    }

    return decoded;
  }

  static Future<Fip>
  findFip(
      String code,
      ) async {
    final cleanCode =
    code.trim();

    if (cleanCode.isEmpty) {
      throw Exception(
        'Kode Fuel Injection Pump kosong',
      );
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/find/${Uri.encodeComponent(cleanCode)}',
      ),
      headers: const {
        'Accept':
        'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(
          response,
          'Fuel Injection Pump tidak ditemukan',
        ),
      );
    }

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Format data Fuel Injection Pump tidak valid',
      );
    }

    return Fip.fromJson(
      Map<String, dynamic>.from(
        decoded,
      ),
    );
  }

  static String? _emptyToNull(
      String? value,
      ) {
    final text =
    value?.trim();

    if (text == null ||
        text.isEmpty) {
      return null;
    }

    return text;
  }

  static String _errorMessage(
      http.Response response,
      String fallback,
      ) {
    try {
      final decoded =
      jsonDecode(
        response.body,
      );

      if (decoded is Map) {
        final message =
        decoded['message']
            ?.toString();

        if (message != null &&
            message.trim().isNotEmpty) {
          return message;
        }

        final error =
        decoded['error']
            ?.toString();

        if (error != null &&
            error.trim().isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Respons bukan JSON.
    }

    if (response.body
        .trim()
        .isNotEmpty) {
      return response.body;
    }

    return '$fallback '
        '(HTTP ${response.statusCode})';
  }
}