import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_customer_model.dart';
import '../models/mechanic_model.dart';
import '../models/service_customer_image_model.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service_customer_video_model.dart';
import 'package:http_parser/http_parser.dart';

class ServiceCustomerApi {
  static const String baseUrl = "https://api.api-nusantaradiesel.tech/api";

  static Future<List<ServiceCustomer>> getAll() async {
    final res = await http.get(Uri.parse("$baseUrl/service-customers"));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ServiceCustomer.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data service customer");
    }
  }


  static Future<List<Mechanic>> getMechanics() async {
  final res = await http.get(
    Uri.parse("$baseUrl/mechanics"),
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Mechanic.fromJson(e)).toList();
  } else {
    throw Exception("Gagal mengambil data mekanik");
  }
}

static Future<void> assignMechanics(
  int serviceId,
  int? bongkarId,
  int? pasangId,
) async {
  final res = await http.put(
    Uri.parse("$baseUrl/service-customers/$serviceId/mechanics"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "mekanik_bongkar_id": bongkarId,
      "mekanik_pasang_id": pasangId,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal assign mekanik");
  }
}


static Future<List<Mechanic>> getAllMechanics() async {
  final res = await http.get(
    Uri.parse("$baseUrl/mechanics/all"),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal mengambil semua mekanik");
  }

  final data = jsonDecode(res.body) as List;
  return data.map((e) => Mechanic.fromJson(e)).toList();
}


static Future<void> updateMechanicStatus(
  int id,
  String status,
) async {
  final res = await http.put(
    Uri.parse("$baseUrl/mechanics/$id/status"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"status": status}),
  );

  if (res.statusCode != 200) {
    throw Exception(
      "Gagal update status ${res.statusCode}: ${res.body}",
    );
  }
}


static Future<void> addMechanic(String nama) async {
  final res = await http.post(
    Uri.parse("$baseUrl/mechanics"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"nama_mekanik": nama.trim()}),
  );

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception(
      "Gagal menambah mekanik ${res.statusCode}: ${res.body}",
    );
  }
}

static Future<void> updateMechanic(
  int id,
  String nama,
) async {
  final res = await http.put(
    Uri.parse("$baseUrl/mechanics/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"nama_mekanik": nama.trim()}),
  );

  if (res.statusCode != 200) {
    throw Exception(
      "Gagal memperbarui mekanik ${res.statusCode}: ${res.body}",
    );
  }
}

  static Future<void> create(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/service-customers"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal menyimpan service customer");
    }
  }

  static Future<List<dynamic>> getParts(int serviceId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/service-customers/$serviceId/parts"),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Gagal mengambil data part");
  }
}

static Future<void> addPart(int serviceId, Map<String, dynamic> body) async {
  final res = await http.post(
    Uri.parse("$baseUrl/service-customers/$serviceId/parts"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal menambahkan part");
  }
}

static Future<void> updateStatus(int id, String status) async {
  final res = await http.put(
    Uri.parse("$baseUrl/service-customers/$id/status"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"status": status}),
  );

  print("URL: $baseUrl/service-customers/$id/status");
  print("STATUS CODE: ${res.statusCode}");
  print("BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Gagal update status");
  }
}


static Future<List<ServiceCustomerImage>> getImages(int id) async {
  final res = await http.get(
    Uri.parse('$baseUrl/service-customers/$id/images'),
  );

  if (res.statusCode != 200) {
    throw Exception('Gagal mengambil foto');
  }

  final List data = jsonDecode(res.body);

  return data
      .map((e) => ServiceCustomerImage.fromJson(e))
      .toList();
}

static Future<void> uploadImage({
  required int serviceId,
  required XFile image,
  required String kategori,
  required String caption,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/service-customers/$serviceId/images'),
  );

  final bytes = await image.readAsBytes();
  final ext = image.name.split('.').last.toLowerCase();

  request.fields['kategori'] = kategori;
  request.fields['caption'] = caption;

  request.files.add(
    http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: image.name,
      contentType: MediaType(
        'image',
        ext == 'png'
            ? 'png'
            : ext == 'webp'
                ? 'webp'
                : 'jpeg',
      ),
    ),
  );

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      'Upload foto gagal ${response.statusCode}: $responseBody',
    );
  }
}

static Future<void> deleteImage(
  int serviceId,
  int imageId,
) async {
  final res = await http.delete(
    Uri.parse(
      '$baseUrl/service-customers/$serviceId/images/$imageId',
    ),
  );

  if (res.statusCode != 200) {
    throw Exception('Gagal menghapus foto');
  }
}



static Future<List<ServiceCustomerVideo>> getVideos(
  int serviceId,
) async {
  final res = await http.get(
    Uri.parse(
      '$baseUrl/service-customers/$serviceId/videos',
    ),
  );

  if (res.statusCode != 200) {
    throw Exception("Gagal mengambil video");
  }

  final List data = jsonDecode(res.body);

  return data
      .map((e) => ServiceCustomerVideo.fromJson(e))
      .toList();
}




static Future<void> uploadVideo({
  required int serviceId,
  required XFile video,
  required String caption,
}) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/service-customers/$serviceId/videos'),
  );

  final bytes = await video.readAsBytes();
  final ext = video.name.split('.').last.toLowerCase();

  final mimeSubtype = switch (ext) {
    'mov' => 'quicktime',
    'avi' => 'x-msvideo',
    'mkv' => 'x-matroska',
    'webm' => 'webm',
    _ => 'mp4',
  };

  request.fields['caption'] = caption;

  request.files.add(
    http.MultipartFile.fromBytes(
      'video',
      bytes,
      filename: video.name,
      contentType: MediaType('video', mimeSubtype),
    ),
  );

  final response = await request.send();
  final body = await response.stream.bytesToString();

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      'Upload video gagal ${response.statusCode}: $body',
    );
  }
}

static Future<void> deleteVideo(
  int serviceId,
  int videoId,
) async {
  final res = await http.delete(
    Uri.parse(
      '$baseUrl/service-customers/$serviceId/videos/$videoId',
    ),
  );

  if (res.statusCode != 200) {
    throw Exception(
      'Gagal menghapus video ${res.statusCode}: ${res.body}',
    );
  }
}

static Future<void> updateTanggalService(
  int serviceId,
  String? tanggalDikerjakan,
  String? tanggalSelesai,
) async {
  final res = await http.put(
    Uri.parse(
      '$baseUrl/service-customers/'
      '$serviceId/tanggal-service',
    ),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'tanggal_dikerjakan': tanggalDikerjakan,
      'tanggal_selesai': tanggalSelesai,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception(
      'Gagal update tanggal '
      '${res.statusCode}: ${res.body}',
    );
  }
}




}