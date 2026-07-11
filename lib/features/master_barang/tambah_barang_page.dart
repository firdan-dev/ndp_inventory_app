import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'barang_model.dart';

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  static const Color accent = Color(0xffff6a00);

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
      id: 0,
      barcode: barcodeValue.isEmpty ? kode.text : barcodeValue,
      kodeInternal: kode.text,
      kodeSupplier: kodeSup.text,
      namaBarang: nama.text,
      partNo: partNo.text,
      merk: merk.text,
      lokasi: lokasi.text,
      qty: qty.text,
      minStock: stam.text.isEmpty ? "0" : stam.text,
    );

    Navigator.pop(context, barang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: AppBar(
        title: const Text("Tambah Barang"),
        backgroundColor: const Color(0xff0b0b0b),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: box(),
                child: ListView(
                  children: [
                    title("Barang Masuk", Icons.inventory_2_outlined),
                    const SizedBox(height: 24),
                    input(kode, "Kode", onChanged: (_) => generateBarcode()),
                    input(kodeSup, "Kode Supplier"),
                    input(nama, "Nama Barang"),
                    input(merk, "Merk", onChanged: (_) => generateBarcode()),
                    input(partNo, "Part No", onChanged: (_) => generateBarcode()),
                    input(stam, "Min Stock"),
                    input(qty, "Qty"),
                    input(lokasi, "Lokasi"),
                    input(ket, "Keterangan"),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Simpan Barang",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: box(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title("Preview Barcode", Icons.qr_code_2_rounded),
                    const Spacer(),
                    Center(
                      child: barcodeValue.isEmpty
                          ? const Text(
                              "Barcode akan muncul otomatis",
                              style: TextStyle(color: Colors.white54),
                            )
                          : Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: barcodeValue,
                                color: Colors.black,
                                width: 280,
                                height: 120,
                                drawText: true,
                              ),
                            ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accent),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget input(
    TextEditingController controller,
    String label, {
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.045),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: accent),
          ),
        ),
      ),
    );
  }

  BoxDecoration box() {
    return BoxDecoration(
      color: const Color(0xff111111).withOpacity(0.94),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 36,
        ),
      ],
    );
  }
}