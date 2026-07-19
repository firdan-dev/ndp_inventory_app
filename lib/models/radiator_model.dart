class Radiator {
  final int id;
  final String barcode;
  final String kodeRadiator;
  final String namaRadiator;
  final int? tinggi;
  final int? lebar;
  final int? tebal;
  final String? modelSarang;
  final int stok;
  final int minStock;
  final String? lokasi;
  final String? radiatorImage;
  final String? labelImage;
  final String? sarangImage;

  const Radiator({
    required this.id,
    required this.barcode,
    required this.kodeRadiator,
    required this.namaRadiator,
    this.tinggi,
    this.lebar,
    this.tebal,
    this.modelSarang,
    required this.stok,
    this.minStock = 5,
    this.lokasi,
    this.radiatorImage,
    this.labelImage,
    this.sarangImage,
  });

  factory Radiator.fromJson(
      Map<String, dynamic> json,
      ) {
    int? toNullableInt(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value.toString());
    }

    int toInt(dynamic value) {
      return toNullableInt(value) ?? 0;
    }

    String? toNullableString(dynamic value) {
      if (value == null) return null;

      final text = value.toString().trim();

      if (text.isEmpty || text.toLowerCase() == 'null') {
        return null;
      }

      return text;
    }

    return Radiator(
      id: toInt(json['id']),
      barcode: json['barcode']?.toString() ?? '',
      kodeRadiator:
      json['kode_radiator']?.toString() ?? '',
      namaRadiator:
      json['nama_radiator']?.toString() ?? '',
      tinggi: toNullableInt(json['tinggi']),
      lebar: toNullableInt(json['lebar']),
      tebal: toNullableInt(json['tebal']),
      modelSarang:
      toNullableString(json['model_sarang']),
      stok: toInt(json['stok']),
      minStock: toNullableInt(json['min_stock']) ?? 5,
      lokasi: toNullableString(json['lokasi']),
      radiatorImage:
      toNullableString(json['radiator_image']),
      labelImage:
      toNullableString(json['label_image']),
      sarangImage:
      toNullableString(json['sarang_image']),
    );
  }

  String get ukuranText {
    return 'T. ${tinggi ?? '-'} × '
        'L. ${lebar ?? '-'} × '
        'Tebal ${tebal ?? '-'} / '
        '${modelSarang ?? '-'}';
  }
}