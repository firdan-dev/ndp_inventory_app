import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/radiator_model.dart';
import 'dart:io';

class RadiatorApi {
  static const String baseUrl = "https://api.api-nusantaradiesel.tech/api/radiators";

  static Future<List<Radiator>> getRadiators() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil data radiator");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Radiator.fromJson(e)).toList();
  }

      static Future<int> addRadiator(Map<String, dynamic> body) async {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        throw Exception("Gagal tambah radiator");
      }

      final data = jsonDecode(res.body);
      return data['id'];
    }

  static Future<void> stockIn({
  required String barcode,
  required int qty,
  String? notes,
  String? noSuratJalan,
  }) async {
  final res = await http.post(
    Uri.parse("$baseUrl/stock-in"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "barcode": barcode,
      "qty": qty,
      "notes": notes,
      "no_surat_jalan": noSuratJalan,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }
}


 static Future<void> stockOut({
  required String barcode,
  required int qty,
  String? notes,
  String? noSuratJalan,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/stock-out"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "barcode": barcode,
      "qty": qty,
      "notes": notes,
      "no_surat_jalan": noSuratJalan,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }
}


  static Future<List<dynamic>> getHistory() async {
  final res = await http.get(Uri.parse("$baseUrl/history"));

  if (res.statusCode != 200) {
    throw Exception("Gagal mengambil history radiator");
  }

  return jsonDecode(res.body);
}


static Future<void> uploadImage({
  required int id,
  required File image,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse("$baseUrl/upload-image/$id"),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'radiator_image',
      image.path,
    ),
  );

  final response = await request.send();

  if (response.statusCode != 200) {
    throw Exception("Gagal upload foto radiator");
  }
}

static Future<int> addRadiatorAndGetId(Map<String, dynamic> body) async {
  final res = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  final data = jsonDecode(res.body);
  return data['id'];
  
}

static Future<List<dynamic>> getRecentTransactions() async {
  final res = await http.get(
    Uri.parse("$baseUrl/radiators/recent-transactions"),
  );

  print("RECENT STATUS: ${res.statusCode}");
  print("RECENT BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }

  return jsonDecode(res.body);
}


static Future<void> updateRadiator(int id, Map<String, dynamic> body) async {
  final res = await http.put(
    Uri.parse("$baseUrl/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal update radiator");
  }
}


}