import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/summary'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal ambil summary dashboard');
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getRecentTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/recent-transactions'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal ambil recent transactions');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> simpanBarangMasuk({
    required String barcode,
    required String kodeInternal,
    required String kodeSupplier,
    required String namaBarang,
    required String partNo,
    required String merk,
    required String lokasi,
    required int qty,
    required int minStock,
    required String pic,
    required String keterangan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/barang-masuk'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'barcode': barcode,
        'kode_internal': kodeInternal,
        'kode_supplier': kodeSupplier,
        'nama_barang': namaBarang,
        'part_no': partNo,
        'merk': merk,
        'lokasi': lokasi,
        'qty': qty,
        'min_stock': minStock,
        'pic': pic,
        'keterangan': keterangan,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal simpan barang masuk');
    }

    return jsonDecode(response.body);
  }
}