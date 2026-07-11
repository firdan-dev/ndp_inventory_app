class Fip {
  final int id;
  final String pumpId;
  final String kodePump;
  final String nama;
  final String fuelInjection;
  final String partNo;
  final String brand;
  final int qty;

  Fip({
    required this.id,
    required this.pumpId,
    required this.kodePump,
    required this.nama,
    required this.fuelInjection,
    required this.partNo,
    required this.brand,
    required this.qty,
  });

  factory Fip.fromJson(Map<String, dynamic> json) {
    return Fip(
      id: json['id'] ?? 0,
      pumpId: json['pump_id'] ?? '',
      kodePump: json['kode_pump'] ?? '',
      nama: json['nama'] ?? '',
      fuelInjection: json['fuel_injection'] ?? '',
      partNo: json['part_no'] ?? '',
      brand: json['brand'] ?? '',
      qty: json['qty'] ?? 0,
    );
  }
}