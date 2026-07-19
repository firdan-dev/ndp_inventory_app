  import 'package:flutter/material.dart';
  import '../../../models/service_customer_model.dart';
  import '../../../services/service_customer_api.dart';
  import 'package:ndp_inventory_app/models/mechanic_model.dart';
  import 'package:image_picker/image_picker.dart';
  import '../../../models/service_customer_image_model.dart';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:file_selector/file_selector.dart';
  import '../../../models/service_customer_video_model.dart';
  import 'package:video_player/video_player.dart';
  
  class ServiceCustomerDetailPage extends StatefulWidget {
    final ServiceCustomer service;
  
    const ServiceCustomerDetailPage({
      super.key,
      required this.service,
    });
  
    @override
    State<ServiceCustomerDetailPage> createState() =>
        _ServiceCustomerDetailPageState();
  }
  
  
  
  class VideoPreviewDialog extends StatefulWidget {
    final String videoUrl;
    final VoidCallback onDownload;
    final VoidCallback onClose;
  
  
    const VideoPreviewDialog({
      super.key,
      required this.videoUrl,
      required this.onDownload,
      required this.onClose,
    });
  
    @override
    State<VideoPreviewDialog> createState() =>
        _VideoPreviewDialogState();
  }
  
  class _VideoPreviewDialogState extends State<VideoPreviewDialog> {
    late VideoPlayerController controller;
    bool initialized = false;
    String? errorMessage;
  
    @override
    void initState() {
      super.initState();
  
      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
  
      controller.initialize().then((_) {
      if (!mounted) return;
  
      setState(() {
        initialized = true;
      });
  
      controller.play();
    }).catchError((e) {
      debugPrint("VIDEO ERROR: $e");
  
      if (!mounted) return;
  
      setState(() {
        errorMessage = e.toString();
      });
    });
    }
  
    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      return Stack(
        children: [
          Center(
            child: errorMessage != null
      ? Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        )
      : initialized
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            )
          : const CircularProgressIndicator(),
          ),
  
          if (initialized)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xffff6a00),
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
  
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                IconButton(
                  tooltip: "Download",
                  onPressed: widget.onDownload,
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: "Tutup",
                  onPressed: widget.onClose,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
  
  
  
  class _ServiceCustomerDetailPageState
      extends State<ServiceCustomerDetailPage> {
    static const Color accentOrange = Color(0xffff6a00);
  
    late Future<List<dynamic>> futureParts;
    late Future<List<ServiceCustomerImage>> futureImages;
    late Future<List<ServiceCustomerVideo>> futureVideos;
    late Future<List<Mechanic>> futureMechanics;
  
    DateTime? tanggalDikerjakan;
    DateTime? tanggalSelesai;
  
    int? mekanikBongkarId;
    int? mekanikPasangId;
  
    void refreshVideos() {
    setState(() {
      futureVideos = ServiceCustomerApi.getVideos(widget.service.id);
    });
  }
  
  // tambahkan controller di State
  final partNameC = TextEditingController();
  final merkC = TextEditingController();
  final partNoC = TextEditingController();
  final qtyC = TextEditingController(text: "1");
  
  
  void openPhoto(ServiceCustomerImage image) {
    final imageUrl =
        "https://api.api-nusantaradiesel.tech${image.imagePath}";
  
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: SizedBox(
          width: 900,
          height: 650,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: "Download",
                      onPressed: () => downloadPhoto(image),
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: "Tutup",
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  
  Future<void> downloadPhoto(ServiceCustomerImage image) async {
    try {
      final imageUrl =
          "https://api.api-nusantaradiesel.tech${image.imagePath}";
  
      final extension = image.imagePath.split('.').last;
      final fileName = "service_photo_${image.id}.$extension";
  
      final location = await getSaveLocation(
        suggestedName: fileName,
      );
  
      if (location == null) return;
  
      final response = await http.get(Uri.parse(imageUrl));
  
      if (response.statusCode != 200) {
        throw Exception("Gagal mengambil file");
      }
  
      final file = File(location.path);
      await file.writeAsBytes(response.bodyBytes);
  
      showMsg("Foto berhasil disimpan");
    } catch (e) {
      showMsg("Download gagal: $e");
    }
  }
  
  
  
  
  void refreshParts() {
    setState(() {
      futureParts = ServiceCustomerApi.getParts(widget.service.id);
    });
  }
  
  void refreshImages() {
    setState(() {
      futureImages = ServiceCustomerApi.getImages(widget.service.id);
    });
  }
  
  void showAddPartDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xff111111),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Pergantian Part",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 18),
              input("Nama Part", partNameC),
              input("Merk", merkC),
              input("Part No", partNoC),
              input("Qty", qtyC),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await ServiceCustomerApi.addPart(widget.service.id, {
                    "part_name": partNameC.text,
                    "merk": merkC.text,
                    "part_no": partNoC.text,
                    "qty": int.tryParse(qtyC.text) ?? 1,
                  });
  
                  partNameC.clear();
                  merkC.clear();
                  partNoC.clear();
                  qtyC.text = "1";
  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  refreshParts();
                },
                icon: const Icon(Icons.save),
                label: const Text("Simpan Part"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  
  Widget documentationSection() {
    return FutureBuilder<List<ServiceCustomerImage>>(
      future: futureImages,
      builder: (context, snapshot) {
        final images = snapshot.data ?? [];
  
        return glassBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dokumentasi Service",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
  
              photoCategoryCard(
                title: "Barang Masuk",
                kategori: "MASUK",
                icon: Icons.inventory_2_rounded,
                images: images.where((e) => e.kategori == "MASUK").toList(),
              ),
              photoCategoryCard(
                title: "Saat Pengerjaan",
                kategori: "PENGERJAAN",
                icon: Icons.build_rounded,
                images: images.where((e) => e.kategori == "PENGERJAAN").toList(),
              ),
              photoCategoryCard(
                title: "Saat Test",
                kategori: "TEST",
                icon: Icons.science_rounded,
                images: images.where((e) => e.kategori == "TEST").toList(),
              ),
              photoCategoryCard(
                title: "Selesai",
                kategori: "SELESAI",
                icon: Icons.check_circle_rounded,
                images: images.where((e) => e.kategori == "SELESAI").toList(),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget photoCategoryCard({
    required String title,
    required String kategori,
    required IconData icon,
    required List<ServiceCustomerImage> images,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: accentOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title (${images.length})",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => uploadPhoto(kategori),
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text("Tambah Foto"),
            style: TextButton.styleFrom(
              foregroundColor: accentOrange,
            ),
          ),
        ],
      ),
  
      if (images.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: images.map((image) {
            final imageUrl =
                "https://api.api-nusantaradiesel.tech${image.imagePath}";
  
            return SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    InkWell(
                    onTap: () => openPhoto(image),
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                      imageUrl,
                      width: 150,
                      height: 110,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('IMAGE ERROR: $error');
                        debugPrint('IMAGE URL: $imageUrl');
  
                        return Container(
                          width: 150,
                          height: 110,
                          color: Colors.redAccent,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    image.caption.isEmpty ? "Tanpa keterangan" : image.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ],
  ),
    );
  }
  
  
  final ImagePicker picker = ImagePicker();
  
  
  
  void showMsg(String message) {
    if (!mounted) return;
  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  
  
  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
  
  
    @override
  void initState() {
    super.initState();
  
    futureParts = ServiceCustomerApi.getParts(widget.service.id);
    futureMechanics = ServiceCustomerApi.getMechanics();
    futureImages = ServiceCustomerApi.getImages(widget.service.id);
    futureVideos = ServiceCustomerApi.getVideos(widget.service.id);
  
    mekanikBongkarId = widget.service.mekanikBongkarId;
    mekanikPasangId = widget.service.mekanikPasangId;
  
    tanggalDikerjakan = DateTime.tryParse(
      widget.service.tanggalDikerjakan ?? '',
    );
  
    tanggalSelesai = DateTime.tryParse(
      widget.service.tanggalSelesai ?? '',
    );
  }
  
  
    void updateStatus(String status) async {
    await ServiceCustomerApi.updateStatus(
      widget.service.id,
      status,
    );
  
    if (!context.mounted) return;
    Navigator.pop(context, true); // Menutup dialog dan mengirimkan sinyal untuk refresh data
  }
  
    String formatDate(String? value) {
      if (value == null || value.isEmpty) return "-";
      return value.split("T").first;
    }
  
    Widget mechanicSection() {
    return glassBox(
      child: FutureBuilder<List<Mechanic>>(
        future: futureMechanics,
        builder: (context, snapshot) {
          final mechanics = snapshot.data ?? [];
  
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Assignment Mekanik",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
  
              dropdownMechanic("Mekanik Bongkar", mekanikBongkarId, mechanics, (v) {
                setState(() => mekanikBongkarId = v);
              }),
  
              dropdownMechanic("Mekanik Pasang", mekanikPasangId, mechanics, (v) {
                setState(() => mekanikPasangId = v);
              }),
  
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await ServiceCustomerApi.assignMechanics(
                    widget.service.id,
                    mekanikBongkarId,
                    mekanikPasangId,
                  );
  
                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                },
                child: const Text("Simpan Mekanik"),
              ),
            ],
          );
        },
      ),
    );
  }
  
  
  Widget dropdownMechanic(
    String label,
    int? value,
    List<Mechanic> mechanics,
    Function(int?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: const TextStyle(color: Colors.white38)),
          ),
          Expanded(
            child: DropdownButton<int>(
              dropdownColor: const Color(0xff222222),
              value: value,
              hint: const Text("Pilih mekanik", style: TextStyle(color: Colors.white54)),
              isExpanded: true,
              items: mechanics.map<DropdownMenuItem<int>>((m) {
                return DropdownMenuItem<int>(
                  value: m.id,
                  child: Text(
                    m.namaMekanik,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
  
    @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(28),
      child: Container(
        width: 850,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xff111111).withOpacity(0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white10),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                header(context),
                const SizedBox(height: 22),
                infoSection(),
                const SizedBox(height: 22),
                mechanicSection(),
                const SizedBox(height: 22),
                partsSection(),
                const SizedBox(height: 22),
                documentationSection(),
                const SizedBox(height: 22),
                videoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
    Widget header(BuildContext context) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentOrange.withOpacity(0.35)),
            ),
            child: const Icon(
              Icons.build_circle_rounded,
              color: accentOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.service.serviceNo ?? "Detail Service",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.service.namaCustomer ?? "-",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context, true), // Menutup dialog dan mengirimkan sinyal untuk refresh data
            icon: const Icon(Icons.close_rounded),
            color: Colors.white54,
          ),
        ],
      );
    }
  
  
   Widget videoSection() {
    return glassBox(
      child: FutureBuilder<List<ServiceCustomerVideo>>(
        future: futureVideos,
        builder: (context, snapshot) {
          final videos = snapshot.data ?? [];
  
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.video_library_rounded,
                    color: accentOrange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Hasil Test Video (${videos.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: uploadTestVideo,
                    icon: const Icon(Icons.video_call_rounded),
                    label: const Text("Tambah Video"),
                    style: TextButton.styleFrom(
                      foregroundColor: accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
  
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (videos.isEmpty)
                const Text(
                  "Belum ada video hasil test",
                  style: TextStyle(color: Colors.white54),
                )
              else
                Column(
                  children: videos.map((video) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accentOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: accentOrange,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.caption.isEmpty
                                      ? "Video hasil test"
                                      : video.caption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Klik tombol play untuk melihat video",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                              tooltip: "Putar Video",
                              onPressed: () => openVideo(video),
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: accentOrange,
                              ),
                            ),
                          IconButton(
                            tooltip: "Hapus",
                            onPressed: () => deleteTestVideo(video),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
  
  
  
  Future<void> uploadTestVideo() async {
    try {
      final video = await picker.pickVideo(
        source: ImageSource.gallery,
      );
  
      if (video == null || !mounted) return;
  
      final captionC = TextEditingController();
  
      final caption = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xff191919),
          title: const Text(
            "Keterangan Video",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: captionC,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Contoh: Hasil test injector",
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  captionC.text.trim(),
                );
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      );
  
      if (caption == null) return;
  
      await ServiceCustomerApi.uploadVideo(
        serviceId: widget.service.id,
        video: video,
        caption: caption,
      );
  
      refreshVideos();
      showMsg("Video berhasil ditambahkan");
    } catch (e) {
      showMsg("Upload video gagal: $e");
    }
  }
  
  
  Future<void> deleteTestVideo(
    ServiceCustomerVideo video,
  ) async {
    await ServiceCustomerApi.deleteVideo(
      widget.service.id,
      video.id,
    );
  
    refreshVideos();
    showMsg("Video berhasil dihapus");
  }
  
  
    String dateToApi(DateTime? value) {
    if (value == null) return '';
  
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
  
  String dateToDisplay(DateTime? value) {
    if (value == null) return '-';
  
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }
  
  Future<void> pilihTanggal({
    required bool isTanggalSelesai,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isTanggalSelesai
          ? tanggalSelesai ?? DateTime.now()
          : tanggalDikerjakan ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  
    if (selected == null || !mounted) return;
  
    setState(() {
      if (isTanggalSelesai) {
        tanggalSelesai = selected;
      } else {
        tanggalDikerjakan = selected;
      }
    });
  
    await ServiceCustomerApi.updateTanggalService(
      widget.service.id,
      tanggalDikerjakan == null
          ? null
          : dateToApi(tanggalDikerjakan),
      tanggalSelesai == null
          ? null
          : dateToApi(tanggalSelesai),
    );
  
    showMsg('Tanggal service berhasil diperbarui');
  }
  
  Future<void> hapusTanggal({
    required bool isTanggalSelesai,
  }) async {
    setState(() {
      if (isTanggalSelesai) {
        tanggalSelesai = null;
      } else {
        tanggalDikerjakan = null;
      }
    });
  
    await ServiceCustomerApi.updateTanggalService(
      widget.service.id,
      tanggalDikerjakan == null
          ? null
          : dateToApi(tanggalDikerjakan),
      tanggalSelesai == null
          ? null
          : dateToApi(tanggalSelesai),
    );
  
    showMsg('Tanggal berhasil dikosongkan');
  }
  
  Widget datePickerRow({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: accentOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateToDisplay(value),
                        style: TextStyle(
                          color: value == null
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                    ),
                    if (value != null)
                      IconButton(
                        onPressed: onClear,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white38,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  
    Widget infoSection() {
      return glassBox(
        child: Column(
          children: [
            row("Tanggal In", formatDate(widget.service.tanggalIn)),
            datePickerRow(
              label: "Tanggal Dikerjakan",
              value: tanggalDikerjakan,
              onTap: () => pilihTanggal(
                isTanggalSelesai: false,
              ),
              onClear: () => hapusTanggal(
                isTanggalSelesai: false,
              ),
            ),
  
            datePickerRow(
              label: "Tanggal Selesai",
              value: tanggalSelesai,
              onTap: () => pilihTanggal(
                isTanggalSelesai: true,
              ),
              onClear: () => hapusTanggal(
                isTanggalSelesai: true,
              ),
            ),
            row("Nama Customer", widget.service.namaCustomer ?? "-"),
            row("Jenis Barang", widget.service.jenisBarang ?? "-"),
            row("Type Unit", widget.service.typeUnit ?? "-"),
            row("Part No", widget.service.partNo ?? "-"),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 170,
                    child: Text(
                      "Status",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xff222222),
                    value: widget.service.status ?? "Waiting",
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: "Waiting",
                        child: Text("Waiting"),
                      ),
                      DropdownMenuItem(
                        value: "On Progress",
                        child: Text("On Progress"),
                      ),
                      DropdownMenuItem(
                        value: "Finished",
                        child: Text("Finished"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) updateStatus(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  
    Future<void> downloadVideo(ServiceCustomerVideo video) async {
    try {
      final videoUrl =
          "https://api.api-nusantaradiesel.tech${video.videoPath}";
  
      final extension = video.videoPath.split('.').last;
      final fileName = "service_video_${video.id}.$extension";
  
      final location = await getSaveLocation(
        suggestedName: fileName,
      );
  
      if (location == null) return;
  
      final response = await http.get(Uri.parse(videoUrl));
  
      if (response.statusCode != 200) {
        throw Exception("Gagal mengambil video");
      }
  
      final file = File(location.path);
      await file.writeAsBytes(response.bodyBytes);
  
      showMsg("Video berhasil disimpan");
    } catch (e) {
      showMsg("Download video gagal: $e");
    }
  }
  
  
  void openVideo(ServiceCustomerVideo video) {
    final videoUrl =
        "https://api.api-nusantaradiesel.tech${video.videoPath}";
  
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        child: SizedBox(
          width: 900,
          height: 650,
          child: VideoPreviewDialog(
            videoUrl: videoUrl,
            onDownload: () => downloadVideo(video),
            onClose: () => Navigator.pop(dialogContext),
          ),
        ),
      ),
    );
  }
  
  
  
    Widget partsSection() {
    return glassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Pergantian Part",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: showAddPartDialog,
                icon: const Icon(Icons.add, color: accentOrange),
                label: const Text(
                  "Tambah Part",
                  style: TextStyle(color: accentOrange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
  
          FutureBuilder<List<dynamic>>(
            future: futureParts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }
  
              final parts = snapshot.data ?? [];
  
              if (parts.isEmpty) {
                return const Text(
                  "Belum ada data pergantian part",
                  style: TextStyle(color: Colors.white54),
                );
              }
  
              return Column(
                children: parts.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: textPart(p['part_name'] ?? "-")),
                        Expanded(child: textPart(p['merk'] ?? "-")),
                        Expanded(child: textPart(p['part_no'] ?? "-")),
                        textPart("Qty: ${p['qty'] ?? 0}"),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> uploadPhoto(String kategori) async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
  
      if (image == null) return;
  
      final captionC = TextEditingController();
  
      if (!mounted) return;
  
      final caption = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xff191919),
          title: const Text(
            'Keterangan Foto',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: captionC,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Contoh: Kondisi sebelum dibongkar',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, captionC.text.trim());
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      );
  
      if (caption == null) return;
  
      await ServiceCustomerApi.uploadImage(
    serviceId: widget.service.id,
    image: image,
    kategori: kategori,
    caption: caption,
  );
  
  refreshImages();
  showMsg('Foto berhasil ditambahkan');
    } catch (e) {
      showMsg('Upload foto gagal: $e');
    }
  }
  
    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SizedBox(
              width: 170,
              child: Text(label, style: const TextStyle(color: Colors.white38)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  
  
  
    Widget textPart(String text) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white70),
      );
    }
  
    Widget glassBox({required Widget child}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.035),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: child,
      );
    }
  }