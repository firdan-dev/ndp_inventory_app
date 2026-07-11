import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SystemGudangPage extends StatefulWidget {
  const SystemGudangPage({super.key});

  @override
  State<SystemGudangPage> createState() => _SystemGudangPageState();
}

class _SystemGudangPageState extends State<SystemGudangPage> {
  static const Color accent = Color(0xffff6a00);

  final baseUrl = "https://api.api-nusantaradiesel.tech/api/system-gudang";

  final namaPerusahaanC = TextEditingController();
  final namaGudangC = TextEditingController();
  final alamatC = TextEditingController();
  final teleponC = TextEditingController();
  final emailC = TextEditingController();
  final logoC = TextEditingController();
  final defaultPicC = TextEditingController();
  final footerPdfC = TextEditingController();

  bool loading = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    fetchSystemGudang();
  }

  @override
  void dispose() {
    namaPerusahaanC.dispose();
    namaGudangC.dispose();
    alamatC.dispose();
    teleponC.dispose();
    emailC.dispose();
    logoC.dispose();
    defaultPicC.dispose();
    footerPdfC.dispose();
    super.dispose();
  }

  Future<void> fetchSystemGudang() async {
    setState(() => loading = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/system-gudang"));
      final data = jsonDecode(res.body);

      namaPerusahaanC.text = data['nama_perusahaan'] ?? '';
      namaGudangC.text = data['nama_gudang'] ?? '';
      alamatC.text = data['alamat'] ?? '';
      teleponC.text = data['telepon'] ?? '';
      emailC.text = data['email'] ?? '';
      logoC.text = data['logo'] ?? '';
      defaultPicC.text = data['default_pic'] ?? '';
      footerPdfC.text = data['footer_pdf'] ?? '';
    } catch (e) {
      debugPrint("FETCH SYSTEM GUDANG ERROR: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

    Future<void> saveSystemGudang() async {
    setState(() => saving = true);

    final body = {
      "nama_perusahaan": namaPerusahaanC.text.trim(),
      "nama_gudang": namaGudangC.text.trim(),
      "alamat": alamatC.text.trim(),
      "telepon": teleponC.text.trim(),
      "email": emailC.text.trim(),
      "logo": logoC.text.trim(),
      "default_pic": defaultPicC.text.trim(),
      "footer_pdf": footerPdfC.text.trim(),
    };

    try {
      await http.put(
        Uri.parse("$baseUrl/system-gudang"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System Gudang berhasil disimpan")),
      );

      setState(() {});
    } catch (e) {
      debugPrint("SAVE SYSTEM GUDANG ERROR: $e");
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  BoxDecoration glassBox({double radius = 24}) {
    return BoxDecoration(
      color: const Color(0xff111111).withOpacity(.94),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.55),
          blurRadius: 38,
        ),
      ],
    );
  }

    InputDecoration inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      prefixIcon: icon == null ? null : Icon(icon, color: accent),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(.045),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accent),
      ),
    );
  }

  Widget input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration(label, icon),
      onChanged: (_) => setState(() {}),
    );
  }

    Widget previewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: glassBox(radius: 28),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(.25)),
            ),
            child: const Icon(
              Icons.warehouse_rounded,
              color: accent,
              size: 40,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPerusahaanC.text.isEmpty
                      ? "Nama Perusahaan"
                      : namaPerusahaanC.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  namaGudangC.text.isEmpty
                      ? "Nama Gudang"
                      : namaGudangC.text,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  alamatC.text.isEmpty
                      ? "Alamat Gudang"
                      : alamatC.text,
                  style: const TextStyle(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff050505),
            Color(0xff0b0b0b),
            Color(0xff111111),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: accent),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_rounded,
                          color: accent, size: 28),
                      SizedBox(width: 14),
                      Text(
                        "System Gudang",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  previewCard(),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: glassBox(radius: 28),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: input(
                                "Nama Perusahaan",
                                namaPerusahaanC,
                                icon: Icons.business_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: input(
                                "Nama Gudang",
                                namaGudangC,
                                icon: Icons.warehouse_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        input(
                          "Alamat Gudang",
                          alamatC,
                          icon: Icons.location_on_rounded,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: input(
                                "Telepon",
                                teleponC,
                                icon: Icons.phone_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: input(
                                "Email",
                                emailC,
                                icon: Icons.email_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: input(
                                "Logo URL",
                                logoC,
                                icon: Icons.image_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: input(
                                "Default PIC",
                                defaultPicC,
                                icon: Icons.person_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        input(
                          "Footer PDF",
                          footerPdfC,
                          icon: Icons.description_rounded,
                          maxLines: 2,
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed:
                                saving ? null : saveSystemGudang,
                            icon: const Icon(Icons.save_rounded),
                            label: Text(
                              saving
                                  ? "Menyimpan..."
                                  : "Simpan Pengaturan",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}