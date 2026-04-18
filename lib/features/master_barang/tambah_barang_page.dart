import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'barang_model.dart';

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final kode = TextEditingController();
  final kodeSup = TextEditingController();
  final nama = TextEditingController();
  final merk = TextEditingController();
  final partNo = TextEditingController();
  final stam = TextEditingController();
  final qty = TextEditingController();
  final lokasi = TextEditingController();
  final ket = TextEditingController();

  String barcodeValue = "";

  void generateBarcode() {
    setState(() {
      barcodeValue = "${kode.text}_${partNo.text}_${merk.text}";
    });
  }

  void simpan() {
    if (kode.text.isEmpty ||
        kodeSup.text.isEmpty ||
        nama.text.isEmpty ||
        merk.text.isEmpty ||
        partNo.text.isEmpty ||
        qty.text.isEmpty ||
        lokasi.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    final barang = Barang(
  kode: kode.text,
  kodeSup: kodeSup.text,
  nama: nama.text,
  merk: merk.text,
  partNo: partNo.text,
  stam: stam.text,
  qty: qty.text,
  lokasi: lokasi.text,
  ket: ket.text,

  // 🔥 FIX UTAMA DI SINI
  barcode: kode.text,
);
 
    Navigator.pop(context, barang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      appBar: AppBar(
        title: const Text("Tambah Barang"),
        backgroundColor: const Color(0xff020617),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // FORM
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  input(kode, "Kode"),
                  input(kodeSup, "Kode Supplier"),
                  input(nama, "Nama Barang"),
                  input(merk, "Merk"),
                  input(partNo, "Part No",
                  onChanged: (_) => generateBarcode()),
                  input(stam, "Stam"),
                  input(qty, "Qty"),
                  input(lokasi, "Lokasi"),
                  input(ket, "Keterangan"),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: simpan,
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            // BARCODE
            Expanded(
              child: Center(
                child: barcodeValue.isEmpty
                    ? const Text(
                        "Barcode muncul di sini",
                        style: TextStyle(color: Colors.white54),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: barcodeValue,
                            color: Colors.white, // 🔥 putih
                            width: 250,
                            height: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            barcodeValue,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget input(TextEditingController controller, String label,
      {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xff020617),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}