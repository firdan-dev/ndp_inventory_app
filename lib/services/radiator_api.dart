import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/radiator_model.dart';

class RadiatorApi {
  static const String baseUrl =
      'https://api.api-nusantaradiesel.tech/api/radiators';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<String> getNextCode() async {
    final response = await http.get(
      Uri.parse('$baseUrl/next-code'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _readError(
          response,
          fallback:
          'Gagal mengambil kode radiator berikutnya',
        ),
      );
    }

    final dynamic decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Format kode radiator tidak valid',
      );
    }

    final code =
    decoded['kode_radiator']?.toString().trim();

    if (code == null || code.isEmpty) {
      throw Exception(
        'Kode radiator tidak ditemukan',
      );
    }

    return code;
  }

  static Future<List<Radiator>>
  getRadiators() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _readError(
          response,
          fallback:
          'Gagal mengambil data radiator',
        ),
      );
    }

    final dynamic decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format daftar radiator tidak valid',
      );
    }

    return decoded.map<Radiator>((item) {
      if (item is! Map) {
        throw Exception(
          'Format data radiator tidak valid',
        );
      }

      return Radiator.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  static Future<int> addRadiator(
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        _readError(
          response,
          fallback:
          'Gagal menambahkan radiator',
        ),
      );
    }

    final dynamic decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Format respons tambah radiator tidak valid',
      );
    }

    final dynamic idValue = decoded['id'];

    if (idValue is int) {
      return idValue;
    }

    final int? parsedId =
    int.tryParse(idValue?.toString() ?? '');

    if (parsedId == null) {
      throw Exception(
        'ID radiator tidak ditemukan dari server',
      );
    }

    return parsedId;
  }

  static Future<void> stockIn({
    required String barcode,
    required int qty,
    String? notes,
    String? noSuratJalan,
  }) async {
    if (barcode.trim().isEmpty) {
      throw Exception(
        'Barcode atau kode radiator wajib diisi',
      );
    }

    if (qty <= 0) {
      throw Exception(
        'Jumlah stock in harus lebih dari 0',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/stock-in'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'barcode': barcode.trim(),
        'qty': qty,
        'notes': _nullableText(notes),
        'no_surat_jalan':
        _nullableText(noSuratJalan),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _readError(
          response,
          fallback: 'Stock in radiator gagal',
        ),
      );
    }
  }

  static Future<void> stockOut({
    required String barcode,
    required int qty,
    String? notes,
    String? noSuratJalan,
  }) async {
    if (barcode.trim().isEmpty) {
      throw Exception(
        'Barcode atau kode radiator wajib diisi',
      );
    }

    if (qty <= 0) {
      throw Exception(
        'Jumlah stock out harus lebih dari 0',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/stock-out'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'barcode': barcode.trim(),
        'qty': qty,
        'notes': _nullableText(notes),
        'no_surat_jalan':
        _nullableText(noSuratJalan),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _readError(
          response,
          fallback: 'Stock out radiator gagal',
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
        _readError(
          response,
          fallback:
          'Gagal mengambil history radiator',
        ),
      );
    }

    final dynamic decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format history radiator tidak valid',
      );
    }

    return decoded;
  }

  static Future<void> uploadImage({
    required int id,
    required File image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-image/$id'),
    );

    final fileName = image.path
        .replaceAll('\\', '/')
        .split('/')
        .last;

    request.files.add(
      await http.MultipartFile.fromPath(
        'radiator_image',
        image.path,
        filename: fileName,
      ),
    );

    final streamedResponse =
    await request.send();

    final response =
    await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'Gagal upload foto radiator',
      );
    }
  }

  static Future<List<dynamic>>
  getRecentTransactions() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/recent-transactions',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        _readError(
          response,
          fallback:
          'Gagal mengambil transaksi radiator terbaru',
        ),
      );
    }

    final dynamic decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format transaksi radiator tidak valid',
      );
    }

    return decoded;
  }

  static Future<void> updateRadiator(
      int id,
      Map<String, dynamic> body,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _readError(
          response,
          fallback:
          'Gagal memperbarui radiator',
        ),
      );
    }
  }

  static String? _nullableText(
      String? value,
      ) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static String _readError(
      http.Response response, {
        required String fallback,
      }) {
    try {
      final dynamic decoded =
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
      // Respons server bukan JSON.
    }

    if (response.body.trim().isNotEmpty) {
      return response.body;
    }

    return '$fallback '
        '(HTTP ${response.statusCode})';
  }
}