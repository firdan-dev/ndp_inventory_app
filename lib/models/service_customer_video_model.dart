class ServiceCustomerVideo {
  final int id;
  final int serviceCustomerId;
  final String videoPath;
  final String caption;
  final String uploadedAt;

  ServiceCustomerVideo({
    required this.id,
    required this.serviceCustomerId,
    required this.videoPath,
    required this.caption,
    required this.uploadedAt,
  });

  factory ServiceCustomerVideo.fromJson(Map<String, dynamic> json) {
    return ServiceCustomerVideo(
      id: json["id"],
      serviceCustomerId: json["service_customer_id"],
      videoPath: json["video_path"],
      caption: json["caption"] ?? "",
      uploadedAt: json["uploaded_at"] ?? "",
    );
  }
}