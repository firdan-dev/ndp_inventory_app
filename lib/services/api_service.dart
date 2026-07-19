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
    required int supplierId,
    required String kodeInternal,
    required String kodeSupplier,
    required String namaBarang,
    required String partNo,
    required String merk,
    required String lokasi,
    required int qty,
    required int minStock,
    required int hargaBeli,
    required String pic,
    required String keterangan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/barang-masuk'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'barcode': barcode.trim(),
        'supplier_id': supplierId,
        'kode_internal': kodeInternal.trim(),
        'kode_supplier': kodeSupplier.trim(),
        'nama_barang': namaBarang.trim(),
        'part_no': partNo.trim(),
        'merk': merk.trim(),
        'lokasi': lokasi.trim(),
        'qty': qty,
        'min_stock': minStock,
        'harga_beli': hargaBeli,
        'pic': pic.trim(),
        'keterangan': keterangan.trim(),
      }),
    );

    if (response.statusCode != 200) {
      try {
        final decoded = jsonDecode(response.body);

        throw Exception(
          decoded['message'] ??
              'Gagal simpan barang masuk',
        );
      } catch (_) {
        throw Exception(
          'Gagal simpan barang masuk: '
              '${response.body}',
        );
      }
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
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


  static Future<List<dynamic>> getSuppliers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/suppliers'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data supplier: '
            '${response.body}',
      );
    }

    final decoded =
    jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format data supplier tidak valid',
      );
    }

    return decoded;
  }


  static Future<Map<String, dynamic>?> scanBarangSuratJalan(
      String barcode,
      ) async {
    final clean = barcode
        .trim()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toUpperCase();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/surat-jalan/barang/${Uri.encodeComponent(clean)}',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 404 ||
        response.body.trim() == 'null') {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mencari barang: ${response.body}',
      );
    }

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  static Future<List<dynamic>> getServiceCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/service-customers'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil service customer: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format service customer tidak valid',
      );
    }

    return decoded;
  }

  static Future<Map<String, dynamic>> createSuratJalan({
    required String tujuan,
    required String transactionType,
    required String status,
    int? serviceCustomerId,
    required String pic,
    required String keterangan,
    required String nomorSurat,
    required String osNo,
    required String kode,
    required String resiNo,
    required String berat,
    required String kepada,
    required String alamat,
    required String up,
    required String hp,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/surat-jalan'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'tujuan': tujuan,
        'transaction_type': transactionType,
        'status': status,
        'service_customer_id': serviceCustomerId,
        'pic': pic,
        'keterangan': keterangan,
        'nomor_surat': nomorSurat,
        'os_no': osNo,
        'kode': kode,
        'resi_no': resiNo,
        'berat': berat,
        'kepada': kepada,
        'alamat': alamat,
        'up': up,
        'hp': hp,
        'items': items,
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal membuat surat jalan'
            : 'Gagal membuat surat jalan',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  static Future<List<dynamic>> getSuratJalan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/surat-jalan'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil surat jalan: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Format surat jalan tidak valid',
      );
    }

    return decoded;
  }

  static Future<Map<String, dynamic>> getSuratJalanDetail(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/surat-jalan/$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal membuka surat jalan'
            : 'Gagal membuka surat jalan',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  static Future<void> approveSuratJalan(
      int id,
      ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/surat-jalan/$id/approve',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final decoded =
      jsonDecode(response.body);

      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal approve surat jalan'
            : 'Gagal approve surat jalan',
      );
    }
  }

  static Future<void> updateSuratJalanStatus({
    required int id,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/surat-jalan/$id/status',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      final decoded =
      jsonDecode(response.body);

      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal update status'
            : 'Gagal update status',
      );
    }
  }

  static Future<int> addSuratJalanItem({
    required int suratJalanId,
    required Map<String, dynamic> item,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/surat-jalan/$suratJalanId/items',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(item),
    );

    final decoded =
    jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal tambah item'
            : 'Gagal tambah item',
      );
    }

    return int.tryParse(
      decoded['id']?.toString() ?? '',
    ) ??
        0;
  }

  static Future<void> updateSuratJalanItemQty({
    required int itemId,
    required int qty,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/surat-jalan/items/$itemId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'qty': qty,
      }),
    );

    if (response.statusCode != 200) {
      final decoded =
      jsonDecode(response.body);

      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal update qty'
            : 'Gagal update qty',
      );
    }
  }

  static Future<void> deleteSuratJalanItem(
      int itemId,
      ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/surat-jalan/items/$itemId',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final decoded =
      jsonDecode(response.body);

      throw Exception(
        decoded is Map
            ? decoded['message'] ?? 'Gagal hapus item'
            : 'Gagal hapus item',
      );
    }
  }

}