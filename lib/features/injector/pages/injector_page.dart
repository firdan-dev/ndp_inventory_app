import 'package:flutter/material.dart';
import '../../../models/injector_model.dart';
import '../../../services/injector_api.dart';
import 'package:intl/intl.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:dropdown_search/dropdown_search.dart';



  class InjectorPage extends StatefulWidget {
  const InjectorPage({super.key});

  @override
  State<InjectorPage> createState() => _InjectorPageState();
}

class _InjectorPageState extends State<InjectorPage> {
  static const Color accentOrange = Color(0xffff6a00);

  late Future<List<Injector>> futureInjectors;
  final searchC = TextEditingController();
  String keyword = "";
  List<Injector> injectors = [];

  @override
 void initState() {
  super.initState();
  loadInjectors();
}

  void loadInjectors() {
  futureInjectors = InjectorApi.getInjectors();
  futureInjectors.then((data) {
    if (!mounted) return;
    setState(() => injectors = data);
  });
}

void refresh() {
  setState(() {
    loadInjectors();
  });
}


void showEditInjectorDialog(Injector i) {
final namaC = TextEditingController(text: i.nama.isNotEmpty ? i.nama : "-");
final merkC = TextEditingController(text: i.merk.isNotEmpty ? i.merk : "-");
final partNoC = TextEditingController(text: i.partNo.isNotEmpty ? i.partNo : "-");
final noSeriC = TextEditingController(text: i.noSeri.isNotEmpty ? i.noSeri : "-");
final lokasiC = TextEditingController(text: i.lokasi.isNotEmpty ? i.lokasi : "-");
final ketC = TextEditingController(text: i.ket.isNotEmpty ? i.ket : "");



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
            const Text("Edit Injector",
                style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 18),

            input("Nama", namaC),
            input("Merk", merkC),
            input("Part No", partNoC),
            input("No Seri", noSeriC),
            input("Lokasi", lokasiC),
            input("Keterangan", ketC),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await InjectorApi.updateInjector(i.id, {
                  "nama": namaC.text.trim(),
                  "merk": merkC.text.trim(),
                  "part_no": partNoC.text.trim(),
                  "no_seri": noSeriC.text.trim(),
                  "lokasi": lokasiC.text.trim(),
                  "ket": ketC.text.trim(),
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                refresh();
              },
              icon: const Icon(Icons.save),
              label: const Text("Update Injector"),
            ),
          ],
        ),
      ),
    ),
  );
}


  
  void showStockInDialog() {
  Injector? selected;
  final qtyC = TextEditingController(text: "1");
  final notesC = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setModal) {
        return Dialog(
          backgroundColor: const Color(0xff111111),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Stock In Injector Lama",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 18),


                

                DropdownButtonFormField<Injector>(
                  value: selected,
                  dropdownColor: const Color(0xff151515),
                  decoration: inputDecoration("Pilih Injector"),
                  items: injectors.map((i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text(
                        "${i.kodeInjector} - ${i.nama}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setModal(() => selected = v),
                ),

                const SizedBox(height: 12),
                input("Qty Masuk", qtyC),
                input("Catatan", notesC),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (selected == null) return;

                    await InjectorApi.stockInExisting(
                      existingId: selected!.id,
                      qty: int.tryParse(qtyC.text) ?? 0,
                      notes: notesC.text,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    refresh();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Stock In"),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}



  void showStockOutDialog() {
    Injector? selected;
    final qtyC = TextEditingController(text: "1");
    final notesC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return Dialog(
            backgroundColor: const Color(0xff111111),
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Stock Out Injector",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 18),

                  DropdownSearch<Injector>(
                  items: (filter, infiniteScrollProps) => injectors,
                  selectedItem: selected,
                  itemAsString: (i) => "${i.kodeInjector} - ${i.nama}",
                  compareFn: (a, b) => a.id == b.id,

                  dropdownBuilder: (context, item) {
                    return Text(
                      item == null ? "Pilih Injector" : "${item.kodeInjector} - ${item.nama}",
                      style: const TextStyle(color: Colors.white),
                    );
                  },

                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    menuProps: const MenuProps(
                      backgroundColor: Color(0xff151515),
                    ),
                    searchFieldProps: TextFieldProps(
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Cari Injector..."),
                    ),
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "${item.kodeInjector} - ${item.nama}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),

                  onChanged: (v) => setModal(() => selected = v),
                ),

                  const SizedBox(height: 12),
                  input("Qty Keluar", qtyC),
                  input("Catatan", notesC),

                  ElevatedButton.icon(
                    onPressed: () async {
                      if (selected == null) return;

                      await InjectorApi.stockOut(
                        barcode: selected!.barcode.isNotEmpty
                            ? selected!.barcode
                            : selected!.kodeInjector,
                        qty: int.tryParse(qtyC.text) ?? 0,
                        notes: notesC.text,
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      refresh();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Stock Out"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


void showHistoryDialog() async {
  final history = await InjectorApi.getHistory();

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: const Color(0xff111111),
      child: Container(
        width: 800,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "History Audit Injector",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final h = history[i];
                  final isIn = h['type'] == 'IN';
                  final rawDate = h['created_at'];
                  final formattedDate = rawDate != null
                      ? DateFormat('d MMMM yyyy', 'id_ID')
                          .format(DateTime.parse(rawDate).toLocal())
                      : '-';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isIn ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isIn ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${h['type']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "${h['kode_injector']} - ${h['nama']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Qty: ${h['qty']} | Stock: ${h['stock_before']} → ${h['stock_after']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Catatan: ${h['notes'] ?? '-'}",
                          style: const TextStyle(color: Colors.white54),
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



  void showAddInjectorDialog() {
  final BarcodeC = TextEditingController(text: "AUTO");
  final namaC = TextEditingController();
  final merkC = TextEditingController();
  final partNoC = TextEditingController();
  final noSeriC = TextEditingController();
  final qtyC = TextEditingController(text: "0");
  final lokasiC = TextEditingController();
  final ketC = TextEditingController();


  

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
            const Text(
              "Tambah Injector",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 18),

            
            input("Barcode (Auto)", BarcodeC, enabled: false),
            input("Nama", namaC),
            input("Merk", merkC),
            input("Part No", partNoC),
            input("No Seri", noSeriC),
            input("Qty", qtyC),
            input("Lokasi", lokasiC),
            input("Keterangan", ketC),

            const SizedBox(height: 14),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await InjectorApi.addInjector({               
                  "nama": namaC.text.trim(),
                  "merk": merkC.text.trim(),
                  "part_no": partNoC.text.trim(),
                  "no_seri": noSeriC.text.trim(),
                  "qty": int.tryParse(qtyC.text) ?? 0,
                  "lokasi": lokasiC.text.trim(),
                  "ket": ketC.text.trim(),
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                refresh();
              },
              icon: const Icon(Icons.save),
              label: const Text("Simpan Injector"),
            ),
          ],
        ),
      ),
    ),
  );
}


void showBarcodeDialog(Injector i) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: const Color(0xff111111),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Barcode Injector",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              i.kodeInjector,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: BarcodeWidget(
                barcode: Barcode.code128(),
                data: i.barcode.isNotEmpty
                    ? i.barcode
                    : i.kodeInjector,
                width: 320,
                height: 120,
                drawText: true,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Tutup"),
            ),
          ],
        ),
      ),
    ),
  );
}


Future<void> printBarcode(Injector i) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Stack(
          children: [
            pw.Positioned(
              left: 20,
              top: 20,
              child: pw.SizedBox(
                width: 120,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      i.nama,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: i.barcode.isNotEmpty
                          ? i.barcode
                          : i.kodeInjector,
                      width: 120,
                      height: 35,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      i.kodeInjector,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );
}

  Widget input(
  String label,
  TextEditingController c, {
  bool enabled = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      enabled: enabled,
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

  Widget searchBar() {
    return TextField(
      controller: searchC,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => setState(() => keyword = v.toLowerCase()),
      decoration: InputDecoration(
        hintText: "Cari injector id, kode injector, nama, part no...",
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

  Widget qtyBadge(int qty) {
    final isSafe = qty > 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSafe
            ? Colors.green.withOpacity(0.18)
            : Colors.red.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSafe ? Colors.green : Colors.red,
        ),
      ),
      child: Text(
        "$qty",
        style: TextStyle(
          color: isSafe ? Colors.greenAccent : Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("Injector ID", style: tableHead)),
          Expanded(flex: 2, child: Text("Kode Injector", style: tableHead)),
          Expanded(flex: 3, child: Text("Nama", style: tableHead)),
          Expanded(flex: 2, child: Text("Merk", style: tableHead)),
          Expanded(flex: 3, child: Text("Part No", style: tableHead)),
          Expanded(flex: 2, child: Text("No Seri", style: tableHead)),
          Expanded(flex: 1, child: Text("Qty", style: tableHead)),
          Expanded(flex: 3, child: Text("Lokasi", style: tableHead)),
          Expanded(flex: 3, child: const SizedBox(),),
        ],
      ),
    );
  }

  Widget injectorRow(Injector i) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(i.injectorId, style: tableTextBold)),
          Expanded(flex: 2, child: Text(i.kodeInjector, style: tableText)),
          Expanded(flex: 3, child: Text(i.nama, style: tableTextBold)),
          Expanded(flex: 2, child: Text(i.merk, style: tableText)),
          Expanded(flex: 3, child: Text(i.partNo, style: tableText)),
          Expanded(flex: 2, child: Text(i.noSeri, style: tableText)),
          Expanded(flex: 1, child: Align(
          alignment: Alignment.centerLeft,
          child: qtyBadge(i.qty)),),
          Expanded(flex: 3, child: Text(i.lokasi, style: tableText)),
          Expanded(
            flex: 3,
            child: Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => showEditInjectorDialog(i),
                  child: const Icon(Icons.edit, color: Colors.orange, size: 20),
                ),
                InkWell(
                  onTap: () => showBarcodeDialog(i),
                  child: const Icon(Icons.qr_code, color: Colors.white70, size: 20),
                ),
                InkWell(
                  onTap: () => printBarcode (i),
                  child: const Icon(Icons.print, color: Colors.greenAccent, size: 20),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget injectorTable() {
    return FutureBuilder<List<Injector>>(
      future: futureInjectors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];

        final filtered = data.where((i) {
          final text =
              "${i.injectorId} ${i.kodeInjector} ${i.nama} ${i.merk} ${i.partNo} ${i.noSeri} ${i.lokasi}"
                  .toLowerCase();

          return text.contains(keyword);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada data injector",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return Column(
          children: [
            headerRow(),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return injectorRow(filtered[index]);
                },
              ),
            ),
          ],
        );
      },
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
            const Text(
              "Stock Injector",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Kelola stok injector, barcode, lokasi, dan history audit",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(child: searchBar()),
                const SizedBox(width: 14),
                button(Icons.add, "Tambah Injector", showAddInjectorDialog),
                const SizedBox(width: 10),
                button(Icons.login_rounded, "Stock In", showStockInDialog),
                const SizedBox(width: 10),
                button(Icons.logout_rounded, "Stock Out", showStockOutDialog),
                const SizedBox(width: 10),
                button(Icons.history, "History", showHistoryDialog),
              ],
            ),

            const SizedBox(height: 22),
            Expanded(child: injectorTable()),
          ],
        ),
      ),
    );
  }
}

const TextStyle tableHead = TextStyle(
  color: Color(0xffff6a00),
  fontWeight: FontWeight.bold,
);

const TextStyle tableText = TextStyle(
  color: Colors.white70,
);

const TextStyle tableTextBold = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);