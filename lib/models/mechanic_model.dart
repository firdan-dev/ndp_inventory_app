class Mechanic {
  final int id;
  final String namaMekanik;
  final String status;

  Mechanic({
    required this.id,
    required this.namaMekanik,
    required this.status,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'],
      namaMekanik: json['nama_mekanik']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'active',
    );
  }
}