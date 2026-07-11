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
  final String? lokasi;
  final String? radiatorImage;
  final String? labelImage;
  final String? sarangImage;

  Radiator({
    required this.id,
    required this.barcode,
    required this.kodeRadiator,
    required this.namaRadiator,
    this.tinggi,
    this.lebar,
    this.tebal,
    this.modelSarang,
    required this.stok,
    this.lokasi,
    this.radiatorImage,
    this.labelImage,
    this.sarangImage,
  });

  factory Radiator.fromJson(Map<String, dynamic> json) {
    return Radiator(
      id: json['id'],
      barcode: json['barcode'] ?? '',
      kodeRadiator: json['kode_radiator'] ?? '',
      namaRadiator: json['nama_radiator'] ?? '',
      tinggi: json['tinggi'],
      lebar: json['lebar'],
      tebal: json['tebal'],
      modelSarang: json['model_sarang'],
      stok: json['stok'] ?? 0,
      lokasi: json['lokasi'],
      radiatorImage: json['radiator_image'],
      labelImage: json['label_image'],
      sarangImage: json['sarang_image'],
    );
  }

  String get ukuranText {
    return "T. ${tinggi ?? '-'} x L. ${lebar ?? '-'} x ${tebal ?? '-'} / ${modelSarang ?? '-'}";
  }
}