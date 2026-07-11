import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';

import 'barang_model.dart';
import '../../utils/print_helper.dart';

class MasterBarangPage extends StatefulWidget {
  const MasterBarangPage({super.key});

  @override
  State<MasterBarangPage> createState() => _MasterBarangPageState();
}

class _MasterBarangPageState extends State<MasterBarangPage> {
  static const Color accentOrange = Color(0xffff6a00);

  List<Barang> dataBarang = [];
  List<Barang> filteredBarang = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.api-nusantaradiesel.tech/api/products'));

      final data = jsonDecode(response.body);

      setState(() {
        dataBarang = (data as List).map((e) => Barang.fromJson(e)).toList();
        filteredBarang = dataBarang;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH: $e");
      setState(() => isLoading = false);
    }
  }

  void onSearch(String value) {
    final query = value.toLowerCase();

    setState(() {
      filteredBarang = query.isEmpty
          ? dataBarang
          : dataBarang.where((item) {
              return item.namaBarang.toLowerCase().contains(query) ||
                  item.kodeInternal.toLowerCase().contains(query) ||
                  item.kodeSupplier.toLowerCase().contains(query) ||
                  item.partNo.toLowerCase().contains(query) ||
                  item.barcode.toLowerCase().contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: box(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerTop(),
              const SizedBox(height: 10),
              searchAndPrint(),
              const SizedBox(height: 10),
              tableHeader(),
              const SizedBox(height: 6),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: accentOrange,
                        ),
                      )
                    : filteredBarang.isEmpty
                        ? const Center(
                            child: Text(
                              "Data barang tidak ditemukan",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredBarang.length,
                            itemBuilder: (context, index) {
                              return itemRow(filteredBarang[index], index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerTop() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentOrange.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentOrange.withOpacity(0.28)),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: accentOrange,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Master Barang",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Kelola data barang, barcode, lokasi, dan stok",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget searchAndPrint() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: onSearch,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration().copyWith(
              hintText: "Search barang, kode, part no...",
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () {
              final list = filteredBarang.map((e) => e.barcode).toList();
              printMultiple(list);
            },
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text("Print Semua"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget input(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration().copyWith(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }

  void showEditBarangDialog(Barang item) {
    final kodeInternal = TextEditingController(text: item.kodeInternal);
    final kodeSupplier = TextEditingController(text: item.kodeSupplier);
    final namaBarang = TextEditingController(text: item.namaBarang);
    final partNo = TextEditingController(text: item.partNo);
    final merk = TextEditingController(text: item.merk);
    final lokasi = TextEditingController(text: item.lokasi);
    final minStock = TextEditingController(text: item.minStock);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xff111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: accentOrange.withOpacity(0.18)),
          ),
          title: const Text(
            "Edit Barang",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  input(kodeInternal, "Kode Internal"),
                  const SizedBox(height: 10),
                  input(kodeSupplier, "Kode Supplier"),
                  const SizedBox(height: 10),
                  input(namaBarang, "Nama Barang"),
                  const SizedBox(height: 10),
                  input(partNo, "Part No"),
                  const SizedBox(height: 10),
                  input(merk, "Merk"),
                  const SizedBox(height: 10),
                  input(lokasi, "Lokasi"),
                  const SizedBox(height: 10),
                  input(minStock, "Min Stock"),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final res = await http.put(
                  Uri.parse('https://api.api-nusantaradiesel.tech/api/products/${item.id}'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    "kode_internal": kodeInternal.text,
                    "kode_supplier": kodeSupplier.text,
                    "nama_barang": namaBarang.text,
                    "part_no": partNo.text,
                    "merk": merk.text,
                    "lokasi": lokasi.text,
                    "min_stock": int.tryParse(minStock.text) ?? 5,
                  }),
                );

                debugPrint("AFTER FETCH:");
                  for (final b in dataBarang) {
                    if (b.id == item.id) {
                      debugPrint("${b.id} | ${b.namaBarang} | ${b.partNo}");
                    }
                  }

                  debugPrint("EDIT ID: ${item.id}");
                  debugPrint("STATUS: ${res.statusCode}");
                  debugPrint("BODY: ${res.body}");

                    if (res.statusCode == 200) {
                    final updatedItem = Barang(
                      id: item.id,
                      kodeInternal: kodeInternal.text,
                      kodeSupplier: kodeSupplier.text,
                      namaBarang: namaBarang.text,
                      partNo: partNo.text,
                      merk: merk.text,
                      lokasi: lokasi.text,
                      minStock: minStock.text,
                      qty: item.qty,
                      barcode: item.barcode,
                    );

                    setState(() {
                      final index = dataBarang.indexWhere((e) => e.id == item.id);
                      if (index != -1) {
                        dataBarang[index] = updatedItem;
                      }

                      final filteredIndex = filteredBarang.indexWhere((e) => e.id == item.id);
                      if (filteredIndex != -1) {
                        filteredBarang[filteredIndex] = updatedItem;
                      }
                    });

                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Barang berhasil diupdate")),
                    );
                  }
                
                else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal update barang")),
                  );
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget tableHeader() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentOrange.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          header("Kode", 2),
          header("Kode Sup", 2),
          header("Nama", 4),
          header("Merk", 2),
          header("Part No", 3),
          header("Qty", 1),
          header("Lokasi", 3),
          header("Aksi", 2, align: TextAlign.center),
        ],
      ),
    );
  }

  Widget itemRow(Barang item, int index) {
    bool hover = false;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setHover(() => hover = true),
          onExit: (_) => setHover(() => hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  hover
                      ? accentOrange.withOpacity(0.10)
                      : Colors.white.withOpacity(index % 2 == 0 ? 0.025 : 0.04),
                  Colors.white.withOpacity(0.015),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hover
                    ? accentOrange.withOpacity(0.28)
                    : Colors.white.withOpacity(0.04),
              ),
              boxShadow: hover
                  ? [
                      BoxShadow(
                        color: accentOrange.withOpacity(0.16),
                        blurRadius: 24,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                cell(item.kodeInternal, 2, bold: true),
                cell(item.kodeSupplier, 2),
                cell(item.namaBarang, 4, bold: true),
                cell(item.merk, 2),
                cell(item.partNo, 3),
                qtyBadge(int.tryParse(item.qty.toString()) ?? 0),
                cell(item.lokasi, 3),
                actionButtons(item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget qtyBadge(int qty) {
    final bool low = qty <= 10;

    return Expanded(
      flex: 1,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: low
                ? Colors.red.withOpacity(0.16)
                : Colors.green.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: low
                  ? Colors.red.withOpacity(0.35)
                  : Colors.green.withOpacity(0.30),
            ),
          ),
          child: Text(
            qty.toString(),
            style: TextStyle(
              color: low ? Colors.redAccent : Colors.greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget actionButtons(Barang item) {
    return Expanded(
      flex: 2,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconAction(Icons.edit_rounded, Colors.orangeAccent, () {
              showEditBarangDialog(item);
            }),
            iconAction(Icons.qr_code_2_rounded, Colors.white, () {
              final clean = item.barcode
                  .replaceAll("-", "")
                  .replaceAll(" ", "")
                  .toUpperCase();

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.transparent,
                  content: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: clean,
                      width: 280,
                      height: 120,
                      color: Colors.black,
                      drawText: true,
                    ),
                  ),
                ),
              );
            }),
            iconAction(Icons.print_rounded, Colors.greenAccent, () {
              printThermal(item.barcode);
            }),
          ],
        ),
      ),
    );
  }

  Widget iconAction(IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }

  Widget cell(String text, int flex, {bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: bold ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget header(String text, int flex, {TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            color: accentOrange.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [
          const Color(0xff0b0b0b),
          const Color(0xff151515),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff38bdf8).withOpacity(0.08),
          blurRadius: 40,
        ),
      ],
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      filled: true,
      fillColor: Colors.white.withOpacity(0.045),
      prefixIconColor: accentOrange,
      prefixIconConstraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentOrange.withOpacity(0.12)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: accentOrange),
      ),
    );
  }
}