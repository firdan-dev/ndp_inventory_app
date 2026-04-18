class Barang {
  String kode;
  String kodeSup;
  String nama;
  String merk;
  String partNo;
  String stam;
  String qty;
  String lokasi;
  String ket;
  String barcode;

  Barang({
    required this.kode,
    required this.kodeSup,
    required this.nama,
    required this.merk,
    required this.partNo,
    required this.stam,
    required this.qty,
    required this.lokasi,
    required this.ket,
    required this.barcode,
  });

  // 🔥 convert ke map (buat database nanti)
  Map<String, dynamic> toMap() {
    return {
      'kode': kode,
      'kodeSup': kodeSup,
      'nama': nama,
      'merk': merk,
      'partNo': partNo,
      'stam': stam,
      'qty': qty,
      'lokasi': lokasi,
      'ket': ket,
      'barcode': barcode,
    };
  }

  // 🔥 dari map (ambil dari database)
  factory Barang.fromMap(Map<String, dynamic> map) {
    return Barang(
      kode: map['kode'],
      kodeSup: map['kodeSup'],
      nama: map['nama'],
      merk: map['merk'],
      partNo: map['partNo'],
      stam: map['stam'],
      qty: map['qty'],
      lokasi: map['lokasi'],
      ket: map['ket'],
      barcode: map['barcode'],

    );
  }
}