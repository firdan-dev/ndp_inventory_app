class Fip {
  final int id;
  final String pumpId;
  final String kodePump;
  final String nama;
  final String fuelInjection;
  final String partNo;
  final String brand;
  final int qty;
  final int minStock;

  const Fip({
    required this.id,
    required this.pumpId,
    required this.kodePump,
    required this.nama,
    required this.fuelInjection,
    required this.partNo,
    required this.brand,
    required this.qty,
    this.minStock = 5,
  });

  factory Fip.fromJson(
      Map<String, dynamic> json,
      ) {
    return Fip(
      id: _toInt(
        json['id'],
      ),
      pumpId: _toText(
        json['pump_id'],
      ),
      kodePump: _toText(
        json['kode_pump'],
      ),
      nama: _toText(
        json['nama'],
      ),
      fuelInjection: _toText(
        json['fuel_injection'],
      ),
      partNo: _toText(
        json['part_no'],
      ),
      brand: _toText(
        json['brand'],
      ),
      qty: _toInt(
        json['qty'],
      ),
      minStock:
      _toNullableInt(
        json['min_stock'],
      ) ??
          5,
    );
  }

  static int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

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
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static String _toText(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final text =
    value.toString().trim();

    if (text.toLowerCase() ==
        'null') {
      return '';
    }

    return text;
  }
}