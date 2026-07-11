import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.api-nusantaradiesel.tech/api';

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

static Future<List<dynamic>> getCategorySummary() async {
  final res = await http.get(Uri.parse("$baseUrl/dashboard/category-summary"));
  return jsonDecode(res.body);
}

static Future<List<dynamic>> getLowStockItems() async {
  final res = await http.get(Uri.parse("$baseUrl/dashboard/low-stock"));

  if (res.statusCode != 200) {
    throw Exception("Gagal ambil low stock: ${res.body}");
  }

  return jsonDecode(res.body);
}

static Future<List<dynamic>> getCustomerServiceDashboard() async {
  final res = await http.get(
    Uri.parse("$baseUrl/dashboard/customer-service"),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal ambil customer service");
  }

  return jsonDecode(res.body);
}


static Future<Map<String, dynamic>> getSuratJalanSummary() async {
  final res = await http.get(
    Uri.parse("$baseUrl/dashboard/surat-jalan-summary"),
  );

  print("SJ SUMMARY BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Gagal ambil surat jalan summary: ${res.body}");
  }

  return Map<String, dynamic>.from(jsonDecode(res.body));
}


static Future<List<dynamic>> getSuratJalanDashboard() async {
  final res = await http.get(
    Uri.parse("$baseUrl/dashboard/surat-jalan"),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal ambil surat jalan dashboard: ${res.body}");
  }

  return jsonDecode(res.body);
}


static Future<Map<String, dynamic>> getCustomerServiceSummary() async {
  final res = await http.get(
    Uri.parse("$baseUrl/dashboard/customer-service-summary"),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal ambil customer service summary");
  }

  return jsonDecode(res.body);
}

}