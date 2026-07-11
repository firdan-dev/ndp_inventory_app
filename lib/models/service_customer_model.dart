class ServiceCustomer {
  final int id;
  final int? mekanikBongkarId;
  final int? mekanikPasangId;
  final String? serviceNo;
  final String? tanggalIn;
  final String? tanggalDikerjakan;
  final String? tanggalSelesai;
  final String? namaCustomer;
  final String? jenisBarang;
  final String? typeUnit;
  final String? partNo;
  final String? status;

  ServiceCustomer({
    required this.id,
    this.serviceNo,
    this.tanggalIn,
    this.tanggalDikerjakan,
    this.tanggalSelesai,
    this.namaCustomer,
    this.jenisBarang,
    this.typeUnit,
    this.partNo,
    this.status,
    this.mekanikBongkarId,
    this.mekanikPasangId,
  });

  factory ServiceCustomer.fromJson(Map<String, dynamic> json) {
    return ServiceCustomer(
      id: json['id'],
      serviceNo: json['service_no']?.toString(),
      tanggalIn: json['tanggal_in']?.toString(),
      tanggalDikerjakan:
          json['tanggal_dikerjakan']?.toString(),
      tanggalSelesai:
          json['tanggal_selesai']?.toString(),
      namaCustomer: json['nama_customer']?.toString(),
      jenisBarang: json['jenis_barang']?.toString(),
      typeUnit: json['type_unit']?.toString(),
      partNo: json['part_no']?.toString(),
      status: json['status']?.toString(),
      mekanikBongkarId: json['mekanik_bongkar_id'],
      mekanikPasangId: json['mekanik_pasang_id'],
    );
  }
}