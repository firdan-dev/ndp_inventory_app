class ServiceCustomerImage {
  final int id;
  final int serviceCustomerId;
  final String imagePath;
  final String caption;
  final String kategori;
  final String? uploadedAt;

  ServiceCustomerImage({
    required this.id,
    required this.serviceCustomerId,
    required this.imagePath,
    required this.caption,
    required this.kategori,
    this.uploadedAt,
  });

  factory ServiceCustomerImage.fromJson(Map<String, dynamic> json) {
    return ServiceCustomerImage(
      id: json['id'],
      serviceCustomerId: json['service_customer_id'],
      imagePath: json['image_path'],
      caption: json['caption'] ?? '',
      kategori: json['kategori'] ?? 'MASUK',
      uploadedAt: json['uploaded_at'],
    );
  }
}