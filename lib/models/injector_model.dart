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

  Injector({
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
  });

  factory Injector.fromJson(Map<String, dynamic> json) {
    return Injector(
      id: json['id'] ?? 0,
      injectorId: json['injector_id'] ?? '',
      kodeInjector: json['kode_injector'] ?? '',
      nama: json['nama'] ?? '',
      merk: json['merk'] ?? '',
      partNo: json['part_no'] ?? '',
      noSeri: json['no_seri'] ?? '',
      qty: json['qty'] ?? 0,
      lokasi: json['lokasi'] ?? '',
      ket: json['ket'] ?? '',
      barcode: json['barcode'] ?? '',
    );
  }
}