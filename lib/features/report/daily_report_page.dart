import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const columnWidths = {
  0: FlexColumnWidth(1.1),
  1: FlexColumnWidth(2),
  2: FlexColumnWidth(3),
  3: FlexColumnWidth(2.5),
  4: FlexColumnWidth(1),
  5: FlexColumnWidth(1.4),
  6: FlexColumnWidth(1),
};

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  DateTime selectedDate = DateTime.now();

  int barangMasukQty = 0;
  int barangMasukJenis = 0;
  int barangKeluarQty = 0;
  int barangKeluarJenis = 0;
  int totalTransaksi = 0;
  int lowStock = 0;

  List<dynamic> transactions = [];
  bool isLoading = true;

  String get formattedDate {
    return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    fetchDailyReport();
  }

  Future<void> fetchDailyReport() async {
    setState(() => isLoading = true);

    try {
      final res = await http.get(
        Uri.parse("http://127.0.0.1:3000/api/report/daily?date=$formattedDate"),
      );

      final data = jsonDecode(res.body);
      final summary = data['summary'] ?? {};

      setState(() {
        barangMasukQty =
            int.tryParse(summary['barang_masuk_qty']?.toString() ?? '0') ?? 0;
        barangMasukJenis =
            int.tryParse(summary['barang_masuk_jenis']?.toString() ?? '0') ?? 0;
        barangKeluarQty =
            int.tryParse(summary['barang_keluar_qty']?.toString() ?? '0') ?? 0;
        barangKeluarJenis =
            int.tryParse(summary['barang_keluar_jenis']?.toString() ?? '0') ?? 0;
        totalTransaksi =
            int.tryParse(summary['total_transaksi']?.toString() ?? '0') ?? 0;
        lowStock = int.tryParse(summary['low_stock']?.toString() ?? '0') ?? 0;

        transactions = data['transactions'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("REPORT ERROR: $e");
      setState(() => isLoading = false);
    }
  }

    Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchDailyReport();
    }
  }

  Future<void> generatePdf() async {
  if (transactions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tidak ada data untuk dibuat PDF")),
    );
    return;
  }

  final pdf = pw.Document();

  final barangMasuk = transactions
      .where((t) => (t['tipe'] ?? '').toString().toLowerCase() == 'masuk')
      .toList();

  final barangKeluar = transactions
      .where((t) => (t['tipe'] ?? '').toString().toLowerCase() == 'keluar')
      .toList();

  pw.Widget headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget cell(dynamic text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text?.toString() ?? '-',
        style: const pw.TextStyle(fontSize: 7),
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  pw.Widget buildTable(String title, List data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(7),
          color: PdfColors.blueGrey800,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.4,
          ),
          columnWidths: {
            0: const pw.FixedColumnWidth(38),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.4),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1.2),
            5: const pw.FlexColumnWidth(1.2),
            6: const pw.FixedColumnWidth(32),
            7: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                headerCell('Jam'),
                headerCell('Barang'),
                headerCell('Merk'),
                headerCell('Part No'),
                headerCell('Kode Sup'),
                headerCell('Kode Int'),
                headerCell('Qty'),
                headerCell('PIC'),
              ],
            ),
            ...data.map(
              (t) => pw.TableRow(
                children: [
                  cell(t['jam']),
                  cell(t['nama_barang']),
                  cell(t['merk']),
                  cell(t['part_no']),
                  cell(t['kode_supplier']),
                  cell(t['kode_intern']),
                  cell(t['qty']),
                  cell(t['pic']),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pdf.addPage(
    pw.MultiPage(
      maxPages: 100,
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PT NUSANTARA DIESEL PRATAMA',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'LAPORAN HARIAN STOK',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Text(
              'Tanggal: $formattedDate',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),

        pw.SizedBox(height: 14),

        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(9),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text('Masuk: $barangMasukQty pcs',
                  style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Keluar: $barangKeluarQty pcs',
                  style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Transaksi: $totalTransaksi',
                  style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Low Stock: $lowStock',
                  style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),

        pw.SizedBox(height: 16),

        buildTable('BARANG MASUK', barangMasuk),
        pw.SizedBox(height: 18),
        
        pw.NewPage(freeSpace: 220),
        buildTable('BARANG KELUAR', barangKeluar),
      ],
    ),
  );

  await Printing.layoutPdf(
    format: PdfPageFormat.a4.landscape,
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

    @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff0f172a),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
              decoration: glassBox(),
              child: Column(
                children: [
                  filterBar(),
                  const SizedBox(height: 18),
                  rowHeader(),
                  const Divider(color: Colors.white12),
                  Expanded(child: buildList()),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: glowButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return const Row(
      children: [
        Icon(Icons.analytics_outlined, color: Color(0xff38bdf8)),
        SizedBox(width: 14),
        Text(
          "Laporan Harian Stok",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget filterBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: softBox(),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: Color(0xff38bdf8)),
          const SizedBox(width: 12),
          const Text("Tanggal laporan", style: TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            onPressed: pickDate,
            icon: const Icon(Icons.date_range, size: 16),
            label: const Text("Pilih Tanggal"),
          ),
        ],
      ),
    );
  }

    Widget buildList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada transaksi pada tanggal ini",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 10),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => transactionRow(transactions[i]),
    );
  }

  Widget rowHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Table(
        columnWidths: columnWidths,
        children: const [
          TableRow(
            children: [
              Text("Jam", style: headerStyle),
              Text("Tipe", style: headerStyle),
              Text("Barang", style: headerStyle),
              Text("Merk", style: headerStyle),
              Center(child: Text("Qty", style: headerStyle)),
              Text("PIC", style: headerStyle),
              Center(child: Text("Aksi", style: headerStyle)),
            ],
          ),
        ],
      ),
    );
  }

    Widget transactionRow(dynamic t) {
    final tipe = t['tipe']?.toString() ?? '-';
    final isMasuk = tipe.toLowerCase() == 'masuk';
    final color = isMasuk ? const Color(0xff22c55e) : const Color(0xfff97316);

    return GestureDetector(
      onTap: () => showTransactionDetail(t),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Table(
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                textCell(t['jam']),
                statusBadge(tipe, color),
                textCell(t['nama_barang'], bold: true),
                textCell(t['merk']),
                Center(child: textCell(t['qty'])),
                textCell(t['pic']),
                Center(
                  child: IconButton(
                    onPressed: () => showTransactionDetail(t),
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: Color(0xff38bdf8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

    Widget statusBadge(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(minWidth: 70, maxWidth: 90),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

    void showTransactionDetail(dynamic t) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                width: 700,
                padding: const EdgeInsets.all(32),
                decoration: popupBox(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Transaksi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 26),
                    detailRow("Jam", t['jam']),
                    detailRow("Tipe", t['tipe']),
                    detailRow("Nama Barang", t['nama_barang']),
                    detailRow("Part No", t['part_no']),
                    detailRow("Merk", t['merk']),
                    detailRow("Qty", t['qty']),
                    detailRow("PIC", t['pic']),
                    detailRow("Keterangan", t['keterangan']),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Tutup"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget textCell(dynamic value, {bool bold = false}) {
    return Text(
      value?.toString() ?? '-',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        color: bold ? Colors.white : Colors.white70,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }


Widget glowButton() {
  return InkWell(
    onTap: () {
      debugPrint("GENERATE PDF CLICKED");
      generatePdf();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xff38bdf8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          SizedBox(width: 10),
          Text(
            "Generate PDF",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

  BoxDecoration glassBox() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.025),
        ],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.10)),
    );
  }

  BoxDecoration softBox() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.045),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    );
  }

  BoxDecoration popupBox() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [
          const Color(0xff1e293b).withOpacity(0.95),
          const Color(0xff0f172a).withOpacity(0.98),
        ],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
    );
  }
}

const headerStyle = TextStyle(
  color: Colors.white54,
  fontSize: 12,
  fontWeight: FontWeight.bold,
);