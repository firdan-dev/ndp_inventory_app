import 'package:flutter/material.dart';
import 'tambah_barang_page.dart';
import 'barang_model.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../utils/print_helper.dart';

class MasterBarangPage extends StatefulWidget {
  const MasterBarangPage({super.key});

  @override
  State<MasterBarangPage> createState() => _MasterBarangPageState();
}

class _MasterBarangPageState extends State<MasterBarangPage> {
  List<Barang> dataBarang = [];

  void tambahBarang(Barang barang) {
    setState(() {
      dataBarang.add(barang);
    });
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

            // 🔥 BUTTON TAMBAH
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TambahBarangPage(),
                    ),
                  );

                  if (result != null && result is Barang) {
                    tambahBarang(result);
                  }
                },
                child: const Text("+ Tambah Barang"),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                "Master Barang",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // HEADER
            Row(
              children: [
                header("Kode", 2),
                header("Kode Sup", 2),
                header("Nama", 4),
                header("Merk", 2),
                header("Part No", 3),
                header("Qty", 1),
                header("Lokasi", 2),
                header("Aksi", 2),
              ],
            ),

            const Divider(color: Colors.white12),

            // DATA
            Expanded(
              child: ListView.builder(
                itemCount: dataBarang.length,
                itemBuilder: (context, index) {
                  final item = dataBarang[index];
                  return itemRow(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget header(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ROW
  Widget itemRow(Barang item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.kode, style: const TextStyle(color: Colors.white70))),
          Expanded(flex: 2, child: Text(item.kodeSup, style: const TextStyle(color: Colors.white54))),
          Expanded(flex: 4, child: Text(item.nama, style: const TextStyle(color: Colors.white))),
          Expanded(flex: 2, child: Text(item.merk, style: const TextStyle(color: Colors.white70))),
          Expanded(flex: 3, child: Text(item.partNo, style: const TextStyle(color: Colors.white54))),
          Expanded(flex: 1, child: Center(child: Text(item.qty))),
          Expanded(flex: 2, child: Text(item.lokasi)),

          // 🔥 AKSI
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // 👁 LIHAT
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.black,
                        content: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: item.barcode,
                          color: Colors.white,
                          backgroundColor: Colors.black,
                          width: 400,
                          height: 120,
                        ),
                      ),
                    );
                  },
                ),

                // 🖨 PRINT
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.white),
                  onPressed: () {
                    printBarcode(item.barcode);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}