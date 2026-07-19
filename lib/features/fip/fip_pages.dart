import 'package:flutter/material.dart';
import '../../models/fip_model.dart';
import '../../services/fip_api.dart';
import 'package:dropdown_search/dropdown_search.dart';

class FipPage extends StatefulWidget {
  const FipPage({super.key});

  @override
  State<FipPage> createState() => _FipPageState();
}

class _FipPageState extends State<FipPage> {
  static const Color accentOrange = Color(0xffff6a00);

  late Future<List<Fip>> futureFips;
  final searchC = TextEditingController();
  String keyword = "";

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      futureFips = FipApi.getFips();
    });
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

  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(label),
      ),
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

  Widget searchBar() {
    return TextField(
      controller: searchC,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => setState(() => keyword = v.toLowerCase()),
      decoration: InputDecoration(
        hintText: "Cari pump id, kode pump, nama, part no, brand...",
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
        border: Border.all(color: isSafe ? Colors.green : Colors.red),
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

  void showAddFipDialog() {
    final namaC = TextEditingController();
    final fuelC = TextEditingController();
    final partNoC = TextEditingController();
    final brandC = TextEditingController();
    final qtyC = TextEditingController(text: "0");

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
                "Tambah Fuel Injection Pump",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 18),
              input("Nama", namaC),
              input("Fuel Injection", fuelC),
              input("Part No", partNoC),
              input("Brand", brandC),
              input("Qty", qtyC),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await FipApi.addFip({
                    "nama": namaC.text.trim(),
                    "fuel_injection": fuelC.text.trim(),
                    "part_no": partNoC.text.trim(),
                    "brand": brandC.text.trim(),
                    "qty": int.tryParse(qtyC.text) ?? 0,
                  });

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  refresh();
                },
                icon: const Icon(Icons.save),
                label: const Text("Simpan FIP"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditFipDialog(Fip f) {
    final namaC = TextEditingController(text: f.nama);
    final fuelC = TextEditingController(text: f.fuelInjection);
    final partNoC = TextEditingController(text: f.partNo);
    final brandC = TextEditingController(text: f.brand);

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
                "Edit Fuel Injection Pump",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 18),
              input("Nama", namaC),
              input("Fuel Injection", fuelC),
              input("Part No", partNoC),
              input("Brand", brandC),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await FipApi.updateFip(f.id, {
                    "nama": namaC.text.trim(),
                    "fuel_injection": fuelC.text.trim(),
                    "part_no": partNoC.text.trim(),
                    "brand": brandC.text.trim(),
                  });

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  refresh();
                },
                icon: const Icon(Icons.save),
                label: const Text("Update FIP"),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void showStockOutSelectDialog() {
  Fip? selected;
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
                  "Stock Out FIP",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 18),

                DropdownSearch<Fip>(
                    items: (filter, infiniteScrollProps) async {
                      return await FipApi.getFips();
                    },
                    selectedItem: selected,
                    itemAsString: (f) =>
                        "${f.pumpId} - ${f.kodePump} - ${f.nama} | Qty: ${f.qty}",
                    compareFn: (a, b) => a.id == b.id,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                        itemBuilder: (context, item, isDisabled, isSelected) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            "${item.pumpId} - ${item.kodePump} - ${item.nama} | Qty: ${item.qty}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                      menuProps: const MenuProps(
                        backgroundColor: Color(0xff151515),
                      ),
                      searchFieldProps: TextFieldProps(
                        style: const TextStyle(color: Colors.white),
                        decoration: inputDecoration("Cari FIP..."),
                      ),
                    ),
                    onChanged: (v) => setModal(() => selected = v),
                  ),

                const SizedBox(height: 12),
                input("Qty Keluar", qtyC),
                input("Catatan", notesC),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (selected == null) return;

                    await FipApi.stockOut(
                      id: selected!.id,
                      qty: int.tryParse(qtyC.text) ?? 0,
                      notes: notesC.text.trim(),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    refresh();
                  },
                  icon: const Icon(Icons.remove_circle),
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


void showFipHistoryDialog() async {
  final history = await FipApi.getHistory();

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
              "History Fuel Injection Pump",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final h = history[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: h['type'] == 'IN'
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${h['type']} - ${h['kode_pump']} - ${h['nama']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Qty: ${h['qty']} | Stock: ${h['stock_before']} → ${h['stock_after']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
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





  Widget headerRow() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.045),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white10),
    ),
    child: const Row(
      children: [
        Expanded(flex: 2, child: Text("Pump ID", style: tableHead)),
        Expanded(flex: 2, child: Text("Kode", style: tableHead)),
        Expanded(flex: 3, child: Text("Nama", style: tableHead)),
        Expanded(flex: 4, child: Text("Fuel Injection", style: tableHead)),
        Expanded(flex: 3, child: Text("Part No", style: tableHead)),
        Expanded(flex: 2, child: Text("Brand", style: tableHead)),
        Expanded(flex: 1, child: Center(child: Text("Qty", style: tableHead))),
        Expanded(flex: 2, child: Center(child: Text("Action", style: tableHead))),
      ],
    ),
  );
}

  Widget fipRow(Fip f) {
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
        Expanded(flex: 2, child: Text(f.pumpId, style: tableTextBold)),
        Expanded(flex: 2, child: Text(f.kodePump, style: tableText)),
        Expanded(flex: 3, child: Text(f.nama, style: tableTextBold)),
        Expanded(flex: 4, child: Text(f.fuelInjection, style: tableText)),
        Expanded(flex: 3, child: Text(f.partNo, style: tableText)),
        Expanded(flex: 2, child: Text(f.brand, style: tableText)),
        Expanded(flex: 1, child: qtyBadge(f.qty)),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => showEditFipDialog(f),
                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
              ),
              IconButton(
                onPressed: () async {
                  await FipApi.deleteFip(f.id);
                  refresh();
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
              ),
              IconButton(
                onPressed: () => showStockOutSelectDialog(),
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget fipTable() {
    return FutureBuilder<List<Fip>>(
      future: futureFips,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];

        final filtered = data.where((f) {
          final text =
              "${f.pumpId} ${f.kodePump} ${f.nama} ${f.fuelInjection} ${f.partNo} ${f.brand}"
                  .toLowerCase();

          return text.contains(keyword);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada data Fuel Injection Pump",
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
                itemBuilder: (_, i) => fipRow(filtered[i]),
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
              "Stock Fuel Injection Pump",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Kelola stok fuel injection pump, part number, brand, dan qty",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: searchBar()),

                const SizedBox(width: 14),

                button(Icons.add, "Tambah FIP", showAddFipDialog),

                const SizedBox(width: 10),

                button(Icons.remove_circle, "Stock Out", showStockOutSelectDialog),

                const SizedBox(width: 10),

                button(Icons.history, "History", showFipHistoryDialog),
              ],
            ),

            const SizedBox(height: 22),
            Expanded(child: fipTable()),
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