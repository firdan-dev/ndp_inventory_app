import 'package:flutter/material.dart';
import '../master_barang/barang_model.dart';

class BarangMasukPage extends StatefulWidget {
  final List<Barang> dataBarang;

  const BarangMasukPage({super.key, required this.dataBarang});

  @override
  State<BarangMasukPage> createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  Barang? selectedBarang;

  void cariBarang(String barcode) {
    try {
      final barang = widget.dataBarang.firstWhere(
        (item) => item.barcode == barcode,
      );

      setState(() {
        selectedBarang = barang;
      });
    } catch (e) {
      setState(() {
        selectedBarang = null;
      });
    }
  }

  void simpanBarangMasuk() {
    if (selectedBarang == null) return;

    final qtyMasuk = int.tryParse(qtyController.text) ?? 0;

    setState(() {
      int currentQty = int.tryParse(selectedBarang!.qty) ?? 0;
      selectedBarang!.qty = (currentQty + qtyMasuk).toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Barang berhasil ditambahkan")),
    );

    qtyController.clear();
    barcodeController.clear();
    selectedBarang = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff111827), Color(0xff020617)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Barang Masuk",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // 🔍 SCAN BARCODE
            TextField(
              controller: barcodeController,
              onSubmitted: cariBarang,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Scan / input barcode...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xff020617),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📦 INFO BARANG
            if (selectedBarang != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${selectedBarang!.nama} | ${selectedBarang!.merk} | Stok: ${selectedBarang!.qty}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

            const SizedBox(height: 20),

            // 🔢 INPUT QTY
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Qty Masuk",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xff020617),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 💾 BUTTON SIMPAN
            ElevatedButton(
              onPressed: simpanBarangMasuk,
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}