class Barang {
  final int id;
  final String barcode;
  final String kodeInternal;
  final String kodeSupplier;
  final String namaBarang;
  final String partNo;
  final String merk;
  final String lokasi;
  final String qty;
  final String minStock;

  Barang({
    required this.id,
    required this.barcode,
    required this.kodeInternal,
    required this.kodeSupplier,
    required this.namaBarang,
    required this.partNo,
    required this.merk,
    required this.lokasi,
    required this.qty,
    required this.minStock,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
  return Barang(
    id: json['id'] ?? 0,
    barcode: json['barcode'] ?? '',
    kodeInternal: json['kode_internal'] ?? '-',
    kodeSupplier: json['kode_supplier'] ?? '-',
    namaBarang: json['nama_barang'] ?? '-',
    partNo: json['part_no'] ?? '-',
    merk: json['merk'] ?? '-',
    lokasi: json['lokasi'] ?? '-',
    qty: (json['qty'] ?? 0).toString(),
    minStock: (json['min_stock'] ?? 0).toString(),
  );
}
}