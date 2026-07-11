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
  static const Color accent = Color(0xffff6a00);

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

  String get displayDate {
    return "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
  }

  String formatPdfDate(dynamic value) {
  if (value == null) return "-";

  final dt = DateTime.tryParse(value.toString());
  if (dt == null) return value.toString();

  return "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year} "
      "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}";
}


  Map<String, List<dynamic>> groupPdfRows(List<dynamic> rows) {
  final grouped = <String, List<dynamic>>{};

  for (final r in rows) {
    final kategori = r['kategori']?.toString() ?? 'MASTER';
    grouped.putIfAbsent(kategori, () => []);
    grouped[kategori]!.add(r);
  }

  return grouped;
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
          Uri.parse("https://api.api-nusantaradiesel.tech/api/report/daily?date=$formattedDate"),
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accent,
              surface: Color(0xff111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchDailyReport();
    }
  }

  Future<void> generatePdf() async {
  try {
    final res = await http.get(
      Uri.parse(
        "https://api.api-nusantaradiesel.tech/api/report/daily?date=$formattedDate",
      ),
    );

    final json = jsonDecode(res.body);
    final rows = json['transactions'] ?? [];

    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada data")),
      );
      return;
    }

    final grouped = groupPdfRows(rows);

    final total = rows.length;
    final stockIn = rows.where((e) {
      final t = e['type']?.toString().toUpperCase() ?? '';
      return t == 'IN' || t == 'MASUK';
    }).length;

    final stockOut = rows.where((e) {
      final t = e['type']?.toString().toUpperCase() ?? '';
      return t == 'OUT' || t == 'KELUAR';
    }).length;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pdfHeader(),
          pw.SizedBox(height: 18),

          pw.Row(
            children: [
              pdfSummaryCard("TOTAL", total.toString()),
              pw.SizedBox(width: 12),
              pdfSummaryCard("STOCK IN", stockIn.toString()),
              pw.SizedBox(width: 12),
              pdfSummaryCard("STOCK OUT", stockOut.toString()),
              pw.SizedBox(width: 12),
              pdfSummaryCard("TANGGAL", formattedDate),
            ],
          ),

          pw.SizedBox(height: 22),

          ...grouped.entries.map((entry) {
            return pdfCategorySection(entry.key, entry.value);
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      format: PdfPageFormat.a4.landscape,
      onLayout: (format) async => pdf.save(),
    );
  } catch (e) {
    debugPrint("PDF ERROR: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal generate PDF: $e")),
    );
  }
}




   pw.Widget pdfHeader() {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(18),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex("#111111"),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "PT NUSANTARA DIESEL PRATAMA",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "DAILY STOCK REPORT",
              style: const pw.TextStyle(
                color: PdfColors.grey400,
                fontSize: 10,
              ),
            ),
          ],
        ),
        pw.Text(
          formattedDate,
          style: pw.TextStyle(
            color: PdfColor.fromHex("#ff6a00"),
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

pw.Widget pdfSummaryCard(String title, String value) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex("#1a1a1a"),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromHex("#ff6a00")),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              color: PdfColors.grey400,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget pdfCategorySection(String kategori, List<dynamic> items) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 18),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              kategori,
              style: pw.TextStyle(
                color: PdfColor.fromHex("#ff6a00"),
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Divider(color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.4),
          columnWidths: {
            0: const pw.FixedColumnWidth(55),
            1: const pw.FixedColumnWidth(55),
            2: const pw.FlexColumnWidth(4),
            3: const pw.FixedColumnWidth(45),
            4: const pw.FlexColumnWidth(2.5),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex("#222222")),
              children: [
                pdfHeaderCell("Jam"),
                pdfHeaderCell("Tipe"),
                pdfHeaderCell("Item"),
                pdfHeaderCell("Qty"),
                pdfHeaderCell("Notes"),
              ],
            ),
            ...items.map((item) {
              return pw.TableRow(
                children: [
                  pdfBodyCell(formatPdfTime(item['created_at'])),
                  pdfBodyCell(item['type']),
                  pdfBodyCell(item['item_name']),
                  pdfBodyCell(item['qty']),
                  pdfBodyCell(item['notes']),
                ],
              );
            }),
          ],
        ),
      ],
    ),
  );
}

pw.Widget pdfHeaderCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColor.fromHex("#ff6a00"),
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget pdfBodyCell(dynamic text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child: pw.Text(
      text?.toString().isEmpty == true ? "-" : text?.toString() ?? "-",
      style: const pw.TextStyle(
        color: PdfColors.black,
        fontSize: 8,
      ),
    ),
  );
}

String formatPdfTime(dynamic value) {
  final dt = DateTime.tryParse(value?.toString() ?? "");
  if (dt == null) return "-";

  return "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}";
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff050505),
            Color(0xff0b0b0b),
            Color(0xff111111),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
        Icon(Icons.analytics_outlined, color: accent, size: 30),
        SizedBox(width: 14),
        Text(
          "Laporan Harian Stok",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
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
          const Icon(Icons.calendar_month_rounded, color: accent),
          const SizedBox(width: 12),
          const Text(
            "Tanggal laporan",
            style: TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            displayDate,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            onPressed: pickDate,
            icon: const Icon(Icons.date_range, size: 16),
            label: const Text("Pilih Tanggal"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildList() {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator(color: accent));
  }

  if (transactions.isEmpty) {
    return const Center(
      child: Text(
        "Belum ada transaksi pada tanggal ini",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }

  final grouped = groupPdfRows(transactions);
  final widgets = <Widget>[];

  grouped.forEach((kategori, items) {
    widgets.add(categoryLabel(kategori));
    widgets.addAll(
      items.map(
        (t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: transactionRow(t),
        ),
      ),
    );
  });

  return ListView(
    padding: const EdgeInsets.only(top: 10),
    children: widgets,
  );
}


Widget categoryLabel(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: accent,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: Colors.white12)),
      ],
    ),
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
  final tipe = t['type']?.toString() ?? t['tipe']?.toString() ?? '-';
  final isMasuk = tipe.toLowerCase() == 'masuk' || tipe.toUpperCase() == 'IN';
  final color = isMasuk ? const Color(0xff22c55e) : accent;

  return GestureDetector(
    onTap: () => showTransactionDetail(t),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Table(
        columnWidths: columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              textCell(t['jam'] ?? '-'),
              statusBadge(tipe, color),
              textCell(t['item_name'] ?? t['nama_barang'], bold: true),
              textCell(t['notes'] ?? t['keterangan']),
              Center(child: textCell(t['qty'])),
              textCell(t['pic'] ?? '-'),
              Center(
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => showTransactionDetail(t),
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: accent,
                    size: 22,
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

  void showTransactionDetail(dynamic t) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
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
            detailRow("Kategori", t['kategori']),
            detailRow("Tanggal", t['created_at']),
            detailRow("Tipe", t['type'] ?? t['tipe']),
            detailRow("Item", t['item_name'] ?? t['nama_barang']),
            detailRow("Qty", t['qty']),
            detailRow("PIC", t['pic'] ?? '-'),
            detailRow("Notes", t['notes'] ?? t['keterangan']),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Tutup"),
              ),
            ),
          ],
        ),
      ),
    ),
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

Widget glowButton() {
  return ElevatedButton.icon(
    onPressed: generatePdf,
    icon: const Icon(Icons.picture_as_pdf_rounded),
    label: const Text("Generate PDF"),
    style: ElevatedButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}

BoxDecoration glassBox() {
  return BoxDecoration(
    color: const Color(0xff111111).withOpacity(.94),
    borderRadius: BorderRadius.circular(30),
    border: Border.all(color: Colors.white.withOpacity(.08)),
  );
}

BoxDecoration softBox() {
  return BoxDecoration(
    color: Colors.white.withOpacity(.045),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: Colors.white.withOpacity(.08)),
  );
}

BoxDecoration popupBox() {
  return BoxDecoration(
    color: const Color(0xff111111),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withOpacity(.10)),
  );
}
}

const headerStyle = TextStyle(
  color: Colors.white54,
  fontSize: 12,
  fontWeight: FontWeight.bold,
);