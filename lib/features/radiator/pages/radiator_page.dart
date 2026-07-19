import 'package:flutter/material.dart';
import '../../../models/radiator_model.dart';
import '../../../services/radiator_api.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RadiatorPage extends StatefulWidget {
  const RadiatorPage({super.key});

  @override
  State<RadiatorPage> createState() => _RadiatorPageState();
}

class _RadiatorPageState extends State<RadiatorPage> {
  static const Color accentOrange = Color(0xffff6a00);

  late Future<List<Radiator>> futureRadiators;
  final searchC = TextEditingController();

  File? selectedImage;
  String keyword = "";
  bool isListView = false;



  @override
  void initState() {
    super.initState();
    futureRadiators = RadiatorApi.getRadiators();
  }

  void refresh() {
    setState(() {
      futureRadiators = RadiatorApi.getRadiators();
    });
  }

  void showImagePreview(Radiator r) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Image.network(
        "https://api.api-nusantaradiesel.tech${r.radiatorImage}",
      ),
    ),
  );
}

  void showAddRadiatorDialog() {
    final kodeC = TextEditingController();
    final namaC = TextEditingController();
    final tinggiC = TextEditingController();
    final lebarC = TextEditingController();
    final tebalC = TextEditingController();
    final sarangC = TextEditingController();
    final lokasiC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xff111111),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Tambah Radiator",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 18),

                    input("Kode Radiator", kodeC),
                    input("Nama Radiator", namaC),
                    input("Tinggi", tinggiC),
                    input("Lebar", lebarC),
                    input("Tebal", tebalC),
                    input("Model Sarang", sarangC),
                    input("Lokasi", lokasiC),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Pilih Gambar Radiator"),
                    ),

                    const SizedBox(height: 12),

                    if (selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          selectedImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final barcode =
                            "${kodeC.text}-${namaC.text.replaceAll(' ', '-').toUpperCase()}";

                        final id = await RadiatorApi.addRadiator({
                          "barcode": barcode,
                          "kode_radiator": kodeC.text,
                          "nama_radiator": namaC.text,
                          "tinggi": int.tryParse(tinggiC.text),
                          "lebar": int.tryParse(lebarC.text),
                          "tebal": int.tryParse(tebalC.text),
                          "model_sarang": sarangC.text,
                          "stok": 0,
                          "lokasi": lokasiC.text,
                        });

                        if (selectedImage != null) {
                          await RadiatorApi.uploadImage(
                            id: id,
                            image: selectedImage!,
                          );
                        }

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        refresh();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Simpan Radiator"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  void showStockInDialog() {
    int? selectedRadiatorId;
    Radiator? selectedRadiator;
    final qtyC = TextEditingController(text: "1");
    final notesC = TextEditingController();
    final noSuratJalanC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xff111111),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: FutureBuilder<List<Radiator>>(
                  future: RadiatorApi.getRadiators(),
                  builder: (context, snapshot) {
                    final radiators = snapshot.data ?? [];

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Stock In Radiator",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        const SizedBox(height: 18),

                        DropdownSearch<Radiator>(
                          items: (filter, infiniteScrollProps) => radiators,
                          itemAsString: (r) =>
                              "${r.kodeRadiator} - ${r.namaRadiator}",
                          selectedItem: selectedRadiator,
                          compareFn: (Radiator a, Radiator b) => a.id == b.id,

                          dropdownBuilder: (context, selectedItem) {
                            if (selectedItem == null) {
                              return const Text(
                                "Pilih Radiator",
                                style: TextStyle(color: Colors.white54),
                              );
                            }

                            return Text(
                              "${selectedItem.kodeRadiator} - ${selectedItem.namaRadiator}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },

                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            menuProps: const MenuProps(
                              backgroundColor: Color(0xff222222),
                            ),
                            itemBuilder: (context, item, isDisabled, isSelected) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Text(
                                  "${item.kodeRadiator} - ${item.namaRadiator}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            },

                            searchFieldProps: TextFieldProps(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Cari radiator...",
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                filled: true,
                                fillColor: const Color(0xff111111),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: accentOrange,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedRadiator = value;
                              selectedRadiatorId = value?.id;
                            });
                          },
                        ),

                        const SizedBox(height: 12),
                        input("Qty Masuk", qtyC),
                        input("Catatan", notesC),
                        input("No Surat Jalan", noSuratJalanC),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () async {
                            if (selectedRadiator == null) return;

                            await RadiatorApi.stockIn(
                              barcode: selectedRadiator!.kodeRadiator,
                              qty: int.tryParse(qtyC.text) ?? 1,
                              notes: notesC.text,
                              noSuratJalan: noSuratJalanC.text.trim(),
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            refresh();
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Simpan Stock In"),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showStockOutDialog() {
    final barcodeC = TextEditingController();
    final qtyC = TextEditingController(text: "1");
    final notesC = TextEditingController();
    final noSuratJalanC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xff111111),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Stock Out Radiator",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 18),
              input("Scan / Input Barcode", barcodeC),
              input("Qty Keluar", qtyC),
              input("Catatan", notesC),
              input("No Surat Jalan", noSuratJalanC),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await RadiatorApi.stockOut(
                      barcode: barcodeC.text.trim(),
                      qty: int.tryParse(qtyC.text) ?? 1,
                      notes: notesC.text,
                      noSuratJalan: noSuratJalanC.text.trim(),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    refresh();
                  } catch (e) {
                    debugPrint("ERROR STOCK OUT: $e");
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Konfirmasi Stock Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showHistoryDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xff111111),
        child: Container(
          width: 850,
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<List<dynamic>>(
            future: RadiatorApi.getHistory(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "History Audit Radiator",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 480,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        final h = data[i];
                        final isIn = h['type'] == 'IN';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isIn
                                  ? Colors.greenAccent.withOpacity(0.3)
                                  : Colors.redAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isIn ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      h['type'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm').format(
                                      DateTime.parse(h['created_at']).toLocal(),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "${h['kode_radiator']} - ${h['nama_radiator']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Qty: ${h['qty']} | Stok: ${h['stock_before']} → ${h['stock_after']}",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Catatan: ${h['notes'] ?? '-'}",
                                style: const TextStyle(color: Colors.white54),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "No. SJ: ${h['no_surat_jalan']?.toString().isNotEmpty == true ? h['no_surat_jalan'] : '-'}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void showRadiatorDetail(Radiator r) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xff111111),
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: r.radiatorImage != null && r.radiatorImage!.isNotEmpty
                    ? Image.network(
                        "https://api.api-nusantaradiesel.tech${r.radiatorImage}",
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        height: 260,
                        color: Colors.white.withOpacity(0.05),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white30,
                          size: 60,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              Text(
                r.kodeRadiator,
                style: const TextStyle(
                  color: accentOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                r.namaRadiator,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(r.ukuranText, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                "Stok : ${r.stok} pcs",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Lokasi : ${r.lokasi ?? '-'}",
                style: const TextStyle(color: Colors.white60),
              ),

              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => showBarcodeDialog(r),
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Lihat Barcode"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => printRadiatorLabel(r),
                    icon: const Icon(Icons.print),
                    label: const Text("Print Label"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBarcodeDialog(Radiator r) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xff111111),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${r.kodeRadiator} | ${r.namaRadiator}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: accentOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: r.kodeRadiator, // barcode tetap scan kode radiator
                  width: 300,
                  height: 90,
                  color: Colors.black,
                  drawText: false, // biar tidak double text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  Future<void> printRadiatorLabel(Radiator r) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Align(
            alignment: pw.Alignment.topLeft,
            child: pw.Container(
              width: 260,
              margin: const pw.EdgeInsets.only(left: 10, top: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "${r.kodeRadiator} | ${r.namaRadiator}",
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),

                  pw.SizedBox(height: 10),

                  pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: r.kodeRadiator,
                    width: 220,
                    height: 60,
                    drawText: false,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }



  void showEditRadiatorDialog(Radiator r) {
  final kodeC = TextEditingController(text: r.kodeRadiator);
  final namaC = TextEditingController(text: r.namaRadiator);
  final tinggiC = TextEditingController(text: r.tinggi?.toString() ?? "");
  final lebarC = TextEditingController(text: r.lebar?.toString() ?? "");
  final tebalC = TextEditingController(text: r.tebal?.toString() ?? "");
  final sarangC = TextEditingController(text: r.modelSarang ?? "");
  final lokasiC = TextEditingController(text: r.lokasi ?? "");

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: const Color(0xff111111),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Radiator", style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 18),

            input("Kode Radiator", kodeC),
            input("Nama Radiator", namaC),
            input("Tinggi", tinggiC),
            input("Lebar", lebarC),
            input("Tebal", tebalC),
            input("Model Sarang", sarangC),
            input("Lokasi", lokasiC),

            ElevatedButton.icon(
              onPressed: () async {
                final barcode =
                    "${kodeC.text}-${namaC.text.replaceAll(' ', '-').toUpperCase()}";

                await RadiatorApi.updateRadiator(r.id, {
                  "barcode": barcode,
                  "kode_radiator": kodeC.text,
                  "nama_radiator": namaC.text,
                  "tinggi": int.tryParse(tinggiC.text),
                  "lebar": int.tryParse(lebarC.text),
                  "tebal": int.tryParse(tebalC.text),
                  "model_sarang": sarangC.text,
                  "lokasi": lokasiC.text,
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                refresh();
              },
              icon: const Icon(Icons.save),
              label: const Text("Update Radiator"),
            ),
          ],
        ),
      ),
    ),
  );
} 





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b0b0b),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            const SizedBox(height: 22),
            actionButtons(),
            const SizedBox(height: 18),
            searchBar(),
            const SizedBox(height: 22),
            Expanded(child: radiatorList()),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stock Radiator",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Kelola stok produksi radiator, barcode, dan history audit",
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget actionButtons() {
  return Row(
    children: [
      button(Icons.add, "Tambah Radiator", showAddRadiatorDialog),
      const SizedBox(width: 12),
      button(Icons.login_rounded, "Stock In", showStockInDialog),
      const SizedBox(width: 12),
      button(Icons.logout_rounded, "Stock Out", showStockOutDialog),
      const SizedBox(width: 12),
      button(Icons.history, "History Audit", showHistoryDialog),

      const Spacer(),

      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setState(() => isListView = false),
              icon: Icon(
                Icons.grid_view,
                color: !isListView ? accentOrange : Colors.white54,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => isListView = true),
              icon: Icon(
                Icons.view_list,
                color: isListView ? accentOrange : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget button(IconData icon, String text, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget searchBar() {
    return TextField(
      controller: searchC,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => setState(() => keyword = v.toLowerCase()),
      decoration: InputDecoration(
        hintText: "Cari kode / nama / ukuran radiator",
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

 Widget radiatorList() {
  return FutureBuilder<List<Radiator>>(
    future: futureRadiators,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = snapshot.data ?? [];

      final filtered = data.where((r) {
        final text =
            "${r.kodeRadiator} ${r.namaRadiator} ${r.ukuranText}".toLowerCase();
        return text.contains(keyword);
      }).toList();

      if (filtered.isEmpty) {
        return const Center(
          child: Text(
            "Belum ada data radiator",
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return isListView
          ? radiatorTileList(filtered)
          : radiatorGridList(filtered);
    },
  );
}

Widget radiatorGridList(List<Radiator> filtered) {
  return GridView.builder(
    itemCount: filtered.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 1.15,
    ),
    itemBuilder: (context, index) {
      return radiatorCard(filtered[index]);
    },
  );
}

Widget radiatorTileList(List<Radiator> filtered) {
  return ListView.builder(
    itemCount: filtered.length,
    itemBuilder: (context, index) {
      final r = filtered[index];

      return InkWell(
        onTap: () => showRadiatorDetail(r),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: accentOrange, size: 28),

              const SizedBox(width: 16),

              Expanded(
                flex: 2,
                child: Text(
                  r.kodeRadiator,
                  style: const TextStyle(
                    color: accentOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(
                  r.namaRadiator,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(
                  r.ukuranText,
                  style: const TextStyle(color: Colors.white60),
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  "Stok: ${r.stok} pcs",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  r.lokasi ?? "-",
                  style: const TextStyle(color: Colors.white38),
                ),
              ),

              IconButton(
                onPressed: () => showEditRadiatorDialog(r),
                icon: const Icon(Icons.edit, color: accentOrange),
              ),

              
              IconButton(
                onPressed: () => showBarcodeDialog(r),
                icon: const Icon(Icons.qr_code, color: Colors.white54),
              ),

              IconButton(
                onPressed: () => printRadiatorLabel(r),
                icon: const Icon(Icons.print, color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    },
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget radiatorCard(Radiator r) {
    return InkWell(
      onTap: () => showRadiatorDetail(r),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (r.radiatorImage != null && r.radiatorImage!.isNotEmpty) {
                  showImagePreview(r);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: r.radiatorImage != null && r.radiatorImage!.isNotEmpty
                    ? Image.network(
                        "https://api.api-nusantaradiesel.tech${r.radiatorImage}",
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.05),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white30,
                          size: 40,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),
            Text(
              r.kodeRadiator,
              style: const TextStyle(
                color: accentOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r.namaRadiator,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(r.ukuranText, style: const TextStyle(color: Colors.white60)),
            const Spacer(),
            Row(
              children: [
                Text(
                  "Stok: ${r.stok} pcs",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  r.lokasi ?? "-",
                  style: const TextStyle(color: Colors.white38),
                ),
                IconButton(
                  onPressed: () => showEditRadiatorDialog(r),
                  icon: const Icon(Icons.edit, color: accentOrange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
