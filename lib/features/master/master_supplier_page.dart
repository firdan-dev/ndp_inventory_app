import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MasterSupplierPage extends StatefulWidget {
  const MasterSupplierPage({super.key});

  @override
  State<MasterSupplierPage> createState() => _MasterSupplierPageState();
}

class _MasterSupplierPageState extends State<MasterSupplierPage> {
  static const Color accent = Color(0xffff6a00);

  final baseUrl = "https://api.api-nusantaradiesel.tech/api";
  final searchController = TextEditingController();

  String keyword = "";
  List suppliers = [];
  List supplierTransactions = [];
  Map? selectedSupplier;

  bool loading = true;
  bool loadingTransactions = false;

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSuppliers() async {
    setState(() => loading = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/suppliers"));
      suppliers = jsonDecode(res.body);
    } catch (e) {
      debugPrint("SUPPLIER ERROR: $e");
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> fetchSupplierTransactions(Map supplier) async {
    setState(() {
      selectedSupplier = supplier;
      supplierTransactions = [];
      loadingTransactions = true;
    });

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/suppliers/${supplier['id']}/batches"),
      );
      supplierTransactions = jsonDecode(res.body);
    } catch (e) {
      debugPrint("SUPPLIER TRANSACTION ERROR: $e");
    }

    if (!mounted) return;
    setState(() => loadingTransactions = false);
  }

  Future<void> deleteSupplier(int id) async {
    await http.delete(Uri.parse("$baseUrl/suppliers/$id"));
    fetchSuppliers();

    if (selectedSupplier?['id'] == id) {
      setState(() {
        selectedSupplier = null;
        supplierTransactions = [];
      });
    }
  }

  String formatRupiah(dynamic value) {
    final angka = double.tryParse(value.toString()) ?? 0;
    return "Rp ${angka.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => "${m[1]}.",
        )}";
  }

  String formatTanggal(String? date) {
    if (date == null) return '-';
    final d = DateTime.tryParse(date);
    if (d == null) return date;

    const bulan = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];

    return "${d.day} ${bulan[d.month - 1]} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff050505),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(flex: 4, child: buildSupplierList()),
          const SizedBox(width: 22),
          Expanded(flex: 5, child: buildSupplierDetail()),
        ],
      ),
    );
  }

  BoxDecoration glassBox({double radius = 24}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: const Color(0xff111111).withOpacity(0.94),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 35,
        ),
      ],
    );
  }

  Widget buildSupplierList() {
    final filteredSuppliers = suppliers.where((s) {
      final nama = (s['nama_supplier'] ?? '').toString().toLowerCase();
      final kontak = (s['kontak'] ?? '').toString().toLowerCase();
      final alamat = (s['alamat'] ?? '').toString().toLowerCase();

      return nama.contains(keyword) ||
          kontak.contains(keyword) ||
          alamat.contains(keyword);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: glassBox(radius: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Master Supplier",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Klik supplier untuk lihat riwayat transaksi",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    "Cari supplier...",
                    Icons.search,
                  ),
                  onChanged: (value) {
                    setState(() => keyword = value.toLowerCase());
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => showForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text("Tambah"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              const Icon(Icons.store_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                "Total Supplier: ${filteredSuppliers.length}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: accent),
                  )
                : filteredSuppliers.isEmpty
                    ? const Center(
                        child: Text(
                          "Supplier tidak ditemukan",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSuppliers.length,
                        itemBuilder: (_, i) {
                          final s = filteredSuppliers[i];
                          final selected = selectedSupplier?['id'] == s['id'];
                          return supplierCard(s, selected);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget supplierCard(Map s, bool isSelected) {
    bool hover = false;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setHover(() => hover = true),
          onExit: (_) => setHover(() => hover = false),
          child: GestureDetector(
            onTap: () => fetchSupplierTransactions(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isSelected
                    ? accent.withOpacity(0.14)
                    : hover
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white.withOpacity(0.035),
                border: Border.all(
                  color: isSelected
                      ? accent.withOpacity(0.42)
                      : hover
                          ? accent.withOpacity(0.25)
                          : Colors.white.withOpacity(0.06),
                ),
                boxShadow: isSelected || hover
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.14),
                          blurRadius: 24,
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withOpacity(0.26)),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['nama_supplier'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Kontak: ${s['kontak'] ?? '-'}",
                          style: const TextStyle(color: Colors.white60),
                        ),
                        Text(
                          "Alamat: ${s['alamat'] ?? '-'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => showForm(supplier: s),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                  ),
                  IconButton(
                    onPressed: () => deleteSupplier(s['id']),
                    icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSupplierDetail() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: glassBox(radius: 30),
      child: selectedSupplier == null
          ? const Center(
              child: Text(
                "Pilih supplier untuk lihat transaksi",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSupplier!['nama_supplier'] ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Kontak: ${selectedSupplier!['kontak'] ?? '-'}",
                  style: const TextStyle(color: Colors.white54),
                ),
                Text(
                  "Alamat: ${selectedSupplier!['alamat'] ?? '-'}",
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Riwayat Transaksi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: loadingTransactions
                      ? const Center(
                          child: CircularProgressIndicator(color: accent),
                        )
                      : supplierTransactions.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada transaksi",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: supplierTransactions.length,
                              itemBuilder: (_, i) {
                                final t = supplierTransactions[i];
                                return transactionCard(t);
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget transactionCard(Map t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['nama_barang'] ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          info("Part No", t['part_no']),
          info("Merk", t['merk']),
          info("Tanggal", formatTanggal(t['created_at'])),
          info("Kode Supplier", t['kode_supplier']),
          info("Harga Beli", formatRupiah(t['harga_beli'])),
          info("Total", formatRupiah(t['total_harga'])),
          info("PIC", t['pic']),
        ],
      ),
    );
  }

  Widget info(String label, dynamic value) {
    return Text(
      "$label: ${value ?? '-'}",
      style: const TextStyle(color: Colors.white54),
    );
  }

  void showForm({Map? supplier}) {
    final nama = TextEditingController(text: supplier?['nama_supplier'] ?? '');
    final kontak = TextEditingController(text: supplier?['kontak'] ?? '');
    final alamat = TextEditingController(text: supplier?['alamat'] ?? '');
    final catatan = TextEditingController(text: supplier?['catatan'] ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(28),
          decoration: glassBox(radius: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                supplier == null ? "Tambah Supplier" : "Edit Supplier",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),

              input(nama, "Nama Supplier", Icons.storefront),
              input(kontak, "Kontak", Icons.phone),
              input(alamat, "Alamat", Icons.location_on),
              input(catatan, "Catatan", Icons.notes),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final body = jsonEncode({
                        "nama_supplier": nama.text.trim(),
                        "kontak": kontak.text.trim(),
                        "alamat": alamat.text.trim(),
                        "catatan": catatan.text.trim(),
                      });

                      if (supplier == null) {
                        await http.post(
                          Uri.parse("$baseUrl/suppliers"),
                          headers: {"Content-Type": "application/json"},
                          body: body,
                        );
                      } else {
                        await http.put(
                          Uri.parse("$baseUrl/suppliers/${supplier['id']}"),
                          headers: {"Content-Type": "application/json"},
                          body: body,
                        );
                      }

                      if (!mounted) return;
                      Navigator.pop(context);
                      fetchSuppliers();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget input(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: accent),
      filled: true,
      fillColor: Colors.white.withOpacity(0.045),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accent),
      ),
    );
  }
}