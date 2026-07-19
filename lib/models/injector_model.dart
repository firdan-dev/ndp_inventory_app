class Injector {
  final int id;
  final String injectorId;
  final String kodeInjector;
  final String nama;
  final String merk;
  final String partNo;
  final String noSeri;
  final int qty;
  final String lokasi;
  final String ket;
  final String barcode;
  final int minStock;

  const Injector({
    required this.id,
    required this.injectorId,
    required this.kodeInjector,
    required this.nama,
    required this.merk,
    required this.partNo,
    required this.noSeri,
    required this.qty,
    required this.lokasi,
    required this.ket,
    required this.barcode,
    this.minStock = 5,
  });

  factory Injector.fromJson(
      Map<String, dynamic> json,
      ) {
    return Injector(
      id: _toInt(json['id']),
      injectorId:
      _toText(json['injector_id']),
      kodeInjector:
      _toText(json['kode_injector']),
      nama: _toText(json['nama']),
      merk: _toText(json['merk']),
      partNo: _toText(json['part_no']),
      noSeri: _toText(json['no_seri']),
      qty: _toInt(json['qty']),
      lokasi: _toText(json['lokasi']),
      ket: _toText(json['ket']),
      barcode: _toText(json['barcode']),
      minStock:
      _toNullableInt(
        json['min_stock'],
      ) ??
          5,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static int? _toNullableInt(
      dynamic value,
      ) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static String _toText(dynamic value) {
    if (value == null) return '';

    final text = value.toString().trim();

    if (text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }
}