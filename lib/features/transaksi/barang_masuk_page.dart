import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

class BarangMasukPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  const BarangMasukPage({super.key, this.onSuccess});

  @override
  State<BarangMasukPage> createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  static const Color accent = Color(0xffff6a00);

  final barcodeController = TextEditingController();
  final kodeInternalController = TextEditingController();
  final kodeSupplierController = TextEditingController();
  final namaController = TextEditingController();
  final partNoController = TextEditingController();
  final merkController = TextEditingController();
  final lokasiController = TextEditingController();
  final qtyController = TextEditingController();
  final hargaController = TextEditingController();
  final minStockController = TextEditingController();
  final keteranganController = TextEditingController();

  String selectedPIC = "Fiska";
  bool isSaving = false;

  List suppliers = [];
  int? selectedSupplierId;

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
    qtyController.addListener(() => setState(() {}));
    hargaController.addListener(() => setState(() {}));
  }

  String formatRupiah(int value) =>
    NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);

    @override
  void dispose() {
    barcodeController.dispose();
    kodeInternalController.dispose();
    kodeSupplierController.dispose();
    namaController.dispose();
    partNoController.dispose();
    merkController.dispose();
    lokasiController.dispose();
    qtyController.dispose();
    hargaController.dispose();
    minStockController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  Future<void> fetchSuppliers() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.api-nusantaradiesel.tech/api/suppliers'),
      );

      if (!mounted) return;

      setState(() {
        suppliers = jsonDecode(res.body);
      });
    } catch (e) {
      debugPrint("SUPPLIER ERROR: $e");
    }
  }

  void generateBarcode() {
    if (kodeInternalController.text.isEmpty ||
        kodeSupplierController.text.isEmpty ||
        partNoController.text.isEmpty) {
      setState(() => barcodeController.clear());
      return;
    }

    setState(() {
      barcodeController.text =
          "${kodeInternalController.text}-${kodeSupplierController.text}-${partNoController.text}"
              .toUpperCase();
    });
  }

  Future<void> simpanBarangMasuk() async {
    if (isSaving) return;

    final qty = int.tryParse(qtyController.text) ?? 0;
    final hargaBeli = int.tryParse(
          hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    if (selectedSupplierId == null ||
        barcodeController.text.isEmpty ||
        kodeInternalController.text.isEmpty ||
        kodeSupplierController.text.isEmpty ||
        namaController.text.isEmpty ||
        partNoController.text.isEmpty ||
        qty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data wajib")),
      );
      return;
    }

    setState(() => isSaving = true);

    debugPrint("HARGA TEXT: ${hargaController.text}");
    debugPrint("HARGA KIRIM: $hargaBeli");

        try {
      final response = await http.post(
        Uri.parse('https://api.api-nusantaradiesel.tech/api/barang-masuk'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "barcode": barcodeController.text,
          "supplier_id": selectedSupplierId,
          "kode_internal": kodeInternalController.text,
          "kode_supplier": kodeSupplierController.text,
          "nama_barang": namaController.text,
          "part_no": partNoController.text,
          "merk": merkController.text,
          "lokasi": lokasiController.text,
          "qty": qty,
          "harga_beli": hargaBeli,
          "min_stock": int.tryParse(minStockController.text) ?? 0,
          "pic": selectedPIC,
          "keterangan": keteranganController.text,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(result['message'] ?? 'Gagal menyimpan barang');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Barang masuk berhasil')),
      );

      clearForm();
      widget.onSuccess?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) setState(() => isSaving = false);
  }

  void clearForm() {
    barcodeController.clear();
    kodeInternalController.clear();
    kodeSupplierController.clear();
    namaController.clear();
    partNoController.clear();
    merkController.clear();
    lokasiController.clear();
    qtyController.clear();
    hargaController.clear();
    minStockController.clear();
    keteranganController.clear();

    setState(() {
      selectedPIC = "Fiska";
      selectedSupplierId = null;
    });
  }

    @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff050505),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: buildForm()),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: buildBarcode()),
          ],
        ),
      ),
    );
  }

      Widget buildForm() {
      final total =
      (int.tryParse(qtyController.text) ?? 0) *
      (int.tryParse(hargaController.text.replaceAll('.', '')) ?? 0);
      return Container(
      padding: const EdgeInsets.all(26),
      decoration: glassBox(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerTitle("Barang Masuk", Icons.add_box_outlined),
            const SizedBox(height: 24),

            input(barcodeController, "Barcode (Auto)", readOnly: true),
            const SizedBox(height: 14),

            supplierDropdown(),
            const SizedBox(height: 14),

                        Row(
              children: [
                Expanded(
                  child: input(
                    kodeInternalController,
                    "Kode Internal",
                    onChanged: (_) => generateBarcode(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: input(
                    kodeSupplierController,
                    "Kode Supplier",
                    onChanged: (_) => generateBarcode(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            input(namaController, "Nama Barang"),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: input(
                    partNoController,
                    "Part Number",
                    onChanged: (_) => generateBarcode(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: input(
                    merkController,
                    "Merk",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: input(
                    lokasiController,
                    "Lokasi Rak",
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: picDropdown(),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: input(
                    qtyController,
                    "Qty",
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: input(
                    hargaController,
                    "Harga Beli",
                    onChanged: (value) {
                      final formatted = formatRupiahInput(value);

                      hargaController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: input(
                    minStockController,
                    "Min Stock",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            input(
              keteranganController,
              "Keterangan",
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withOpacity(.25),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Estimasi Total : ${formatRupiah(total)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget buildBarcode() {
    final cleanData = barcodeController.text
        .replaceAll(" ", "")
        .replaceAll("-", "")
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: glassBox(),
      child: Column(
        children: [
          headerTitle(
            "Preview Barcode",
            Icons.qr_code_2_rounded,
          ),

          const SizedBox(height: 40),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: cleanData.isEmpty ? "TEST123" : cleanData,
              width: 340,
              height: 130,
              color: Colors.black,
              drawText: true,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            barcodeController.text.isEmpty
                ? "Barcode akan dibuat otomatis"
                : barcodeController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: accent.withOpacity(.12),
              border: Border.all(
                color: accent.withOpacity(.30),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: accent,
                ),
                SizedBox(height: 10),
                Text(
                  "Barcode otomatis dibuat dari:\nKode Internal + Kode Supplier + Part Number",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

      Widget supplierDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: fieldBox(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedSupplierId,
          hint: const Text("Pilih Supplier", style: TextStyle(color: Colors.white38)),
          isExpanded: true,
          dropdownColor: const Color(0xff111111),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: accent),
          style: const TextStyle(color: Colors.white),
          items: suppliers.map<DropdownMenuItem<int>>((s) {
            return DropdownMenuItem<int>(
              value: s['id'],
              child: Text(s['nama_supplier'] ?? '-'),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedSupplierId = value),
        ),
      ),
    );
  }

  Widget picDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: fieldBox(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPIC,
          isExpanded: true,
          dropdownColor: const Color(0xff111111),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: accent),
          style: const TextStyle(color: Colors.white),
          items: ["Fiska", "Uchi", "Jesslyne", "Ibu"].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, color: accent, size: 18),
                  const SizedBox(width: 10),
                  Text(e),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedPIC = value!),
        ),
      ),
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSaving ? null : simpanBarangMasuk,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white12,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Simpan Barang",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget headerTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accent),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget input(
    TextEditingController c,
    String hint, {
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: c,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration(hint),
    );
  }

  String formatRupiahInput(String value) {
    final angka = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (angka.isEmpty) return '';

    return angka.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
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
    );
  }

  BoxDecoration fieldBox() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.045),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.10)),
    );
  }

  BoxDecoration glassBox() {
    return BoxDecoration(
      color: const Color(0xff111111).withOpacity(0.94),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.50),
          blurRadius: 36,
        ),
      ],
    );
  }
}