import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MasterSupplierPage extends StatefulWidget {
  const MasterSupplierPage({super.key});

  @override
  State<MasterSupplierPage> createState() => _MasterSupplierPageState();
}



class _MasterSupplierPageState extends State<MasterSupplierPage> {
  final baseUrl = "http://127.0.0.1:3000/api";
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

  Future<void> fetchSuppliers() async {
    setState(() => loading = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/suppliers"));
      suppliers = jsonDecode(res.body);
    } catch (e) {
      debugPrint("SUPPLIER ERROR: $e");
    }

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

    setState(() => loadingTransactions = false);
  }

String formatRupiah(dynamic value) {
  final angka = double.tryParse(value.toString()) ?? 0;

  final intAngka = angka.toInt();

  return "Rp ${intAngka.toString().replaceAllMapped(
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

    BoxDecoration glassBox({double radius = 24}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.085),
          Colors.white.withOpacity(0.025),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 30,
        ),
      ],
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                        child: const Text("Batal"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Simpan"),
                        onPressed: () async {
                          final body = jsonEncode({
                            "nama_supplier": nama.text.trim(),
                            "kontak": kontak.text.trim(),
                            "alamat": alamat.text.trim(),
                            "catatan": catatan.text.trim(),
                          });

                          if (supplier == null) {
                          final res = await http.post(
                            Uri.parse("$baseUrl/suppliers"),
                            headers: {"Content-Type": "application/json"},
                            body: body,
                          );

                          debugPrint("POST SUPPLIER STATUS: ${res.statusCode}");
                          debugPrint("POST SUPPLIER BODY: ${res.body}");
                        } else {
                          final res = await http.put(
                            Uri.parse("$baseUrl/suppliers/${supplier['id']}"),
                            headers: {"Content-Type": "application/json"},
                            body: body,
                          );

                          debugPrint("PUT SUPPLIER STATUS: ${res.statusCode}");
                          debugPrint("PUT SUPPLIER BODY: ${res.body}");
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
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff0f172a),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: buildSupplierList(),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 5,
            child: buildSupplierDetail(),
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
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, hover ? -3 : 0, 0),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: glassBox(radius: 22).copyWith(
              color: hover
                  ? Colors.white.withOpacity(0.075)
                  : Colors.white.withOpacity(0.025),
              border: Border.all(
                color: isSelected
                    ? const Color(0xff38bdf8)
                    : hover
                        ? const Color(0xff38bdf8).withOpacity(0.45)
                        : Colors.white.withOpacity(0.12),
              ),
              boxShadow: hover
                  ? [
                      BoxShadow(
                        color: const Color(0xff38bdf8).withOpacity(0.16),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff38bdf8).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: Color(0xff38bdf8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['nama_supplier'] ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Kontak: ${s['kontak'] ?? '-'}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      Text(
                        "Alamat: ${s['alamat'] ?? '-'}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showForm(supplier: s),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
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

    Widget buildSupplierList() {
  final filteredSuppliers = suppliers.where((s) {
    final nama = (s['nama_supplier'] ?? '').toString().toLowerCase();
    final kontak = (s['kontak'] ?? '').toString().toLowerCase();
    final alamat = (s['alamat'] ?? '').toString().toLowerCase();

    return nama.contains(keyword) ||
        kontak.contains(keyword) ||
        alamat.contains(keyword);
  }).toList();

  return ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: glassBox(radius: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Master Supplier",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Klik supplier untuk lihat riwayat transaksi",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari supplier...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.055),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xff38bdf8)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => keyword = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => showForm(),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff38bdf8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Total Supplier: ${filteredSuppliers.length}",
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredSuppliers.length,
                      itemBuilder: (_, i) {
                        final s = filteredSuppliers[i];
                        final isSelected = selectedSupplier?['id'] == s['id'];

                        return supplierCard(s, isSelected);(
                          onTap: () => fetchSupplierTransactions(s),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: glassBox(radius: 22).copyWith(
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xff38bdf8)
                                    : Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.store,
                                    color: Color(0xff38bdf8)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s['nama_supplier'] ?? '-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Kontak: ${s['kontak'] ?? '-'}",
                                        style: const TextStyle(
                                            color: Colors.white54),
                                      ),
                                      Text(
                                        "Alamat: ${s['alamat'] ?? '-'}",
                                        style: const TextStyle(
                                            color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => showForm(supplier: s),
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () => deleteSupplier(s['id']),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

    Widget buildSupplierDetail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: glassBox(radius: 32),
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
                    const SizedBox(height: 22),
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
                          ? const Center(child: CircularProgressIndicator())
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

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: glassBox(radius: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t['nama_barang'] ?? '-',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Part No: ${t['part_no'] ?? '-'}",
                                            style: const TextStyle(
                                                color: Colors.white54),
                                          ),
                                          Text(
                                            "Merk: ${t['merk'] ?? '-'}",
                                            style: const TextStyle(
                                                color: Colors.white54),
                                          ),
                                          Text(
                                            "Tanggal: ${formatTanggal(t['created_at'])}",
                                            style: const TextStyle(color: Colors.white54),
                                          ),
                                          Text(
                                            "Kode Supplier: ${t['kode_supplier'] ?? '-'}",
                                            style: const TextStyle(
                                                color: Colors.white54),
                                          ),
                                          Text(
                                            "Harga Beli: ${formatRupiah(t['harga_beli'])}",
                                            style: const TextStyle(color: Colors.white54),
                                          ),
                                          Text(
                                            "Total: ${formatRupiah(t['total_harga'])}",
                                            style: const TextStyle(color: Colors.white54),
                                          ),

                                          Text(
                                            "PIC: ${t['pic'] ?? '-'}",
                                            style: const TextStyle(
                                                color: Colors.white54),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.055),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xff38bdf8)),
          ),
        ),
      ),
    );
  }
}