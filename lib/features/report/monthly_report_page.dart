import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  static const Color accent = Color(0xffff6a00);

  DateTime selectedMonth = DateTime.now();

  Map<String, dynamic>? summary;
  List transactions = [];
  List dailyChart = [];
  bool loading = false;


  Map<String, List<dynamic>> groupedTransactions() {
  final grouped = <String, List<dynamic>>{};

  for (final t in transactions) {
    final kategori = t['kategori']?.toString() ?? 'MASTER';
    grouped.putIfAbsent(kategori, () => []);
    grouped[kategori]!.add(t);
  }

  return grouped;
}

  final baseUrl = "https://api.api-nusantaradiesel.tech/api";

  String get monthText {
    return "${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}";
  }

  Future<void> fetchReport() async {
    setState(() => loading = true);

    try {
      final url = "$baseUrl/report/monthly?month=$monthText";
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);

      setState(() {
        summary = data['summary'];
        transactions = data['transactions'] ?? [];
        dailyChart = data['daily_chart'] ?? [];
      });
    } catch (e) {
      debugPrint("MONTHLY REPORT ERROR: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "Pilih Bulan",
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
      setState(() => selectedMonth = picked);
    }
  }

  
Future<void> generatePdf() async {
  try {
    debugPrint("GENERATE PDF CLICKED");
    debugPrint("TRANSACTIONS: ${transactions.length}");

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data masih kosong, klik Load dulu")),
      );
      return;
    }

    final grouped = groupedTransactions();
    final total = transactions.length;

    final stockIn = transactions.where((e) {
      final t = e['type']?.toString().toUpperCase() ?? '';
      return t == 'IN' || t == 'MASUK';
    }).length;

    final stockOut = transactions.where((e) {
      final t = e['type']?.toString().toUpperCase() ?? '';
      return t == 'OUT' || t == 'KELUAR';
    }).length;

    final pdf = pw.Document();

    final sections = <pw.Widget>[];

grouped.entries.forEach((entry) {
  sections.addAll(pdfCategorySections(entry.key, entry.value));
});

for (int i = 0; i < sections.length; i++) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (_) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (i == 0) ...[
              pdfHeaderMonthly(),
              pw.SizedBox(height: 18),
              pw.Row(
                children: [
                  pdfSummaryCard("TOTAL", total.toString()),
                  pw.SizedBox(width: 12),
                  pdfSummaryCard("STOCK IN", stockIn.toString()),
                  pw.SizedBox(width: 12),
                  pdfSummaryCard("STOCK OUT", stockOut.toString()),
                  pw.SizedBox(width: 12),
                  pdfSummaryCard("BULAN", monthText),
                ],
              ),
              pw.SizedBox(height: 18),
            ],
            sections[i],
          ],
        );
      },
    ),
  );
}

    await Printing.layoutPdf(
      format: PdfPageFormat.a4.landscape,
      onLayout: (_) async => pdf.save(),
    );
  } catch (e) {
    debugPrint("MONTHLY PDF ERROR: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal generate PDF: $e")),
    );
  }
}

    pw.Widget pdfHeaderMonthly() {
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
        pw.Text(
          "PT NUSANTARA DIESEL PRATAMA",
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          "MONTHLY STOCK REPORT",
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
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(value, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );
}


List<pw.Widget> pdfCategorySections(String kategori, List items) {
  const chunkSize = 8;
  final widgets = <pw.Widget>[];

  for (int i = 0; i < items.length; i += chunkSize) {
    final chunk = items.skip(i).take(chunkSize).toList();

    widgets.add(
      pdfCategorySection(
        i == 0 ? kategori : "$kategori (lanjutan)",
        chunk,
      ),
    );
  }

  return widgets;
}

pw.Widget pdfCategorySection(String kategori, List items) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 16),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: PdfColor.fromHex("#ff6a00"),
        child: pw.Text(kategori, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
      ),
      pw.Table(
        border: pw.TableBorder.all(width: 0.4),
        columnWidths: {
          0: const pw.FixedColumnWidth(75),
          1: const pw.FlexColumnWidth(4.5),
          2: const pw.FixedColumnWidth(70),
          3: const pw.FixedColumnWidth(45),
          4: const pw.FlexColumnWidth(2.4),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pdfHeaderCell("Tanggal"),
              pdfHeaderCell("Item"),
              pdfHeaderCell("Tipe"),
              pdfHeaderCell("Qty"),
              pdfHeaderCell("Notes"),
            ],
          ),
          ...items.map<pw.TableRow>((t) {
            return pw.TableRow(
              children: [
                pdfBodyCell(formatPdfDate(t['created_at'])),
                pdfBodyCell(t['item_name'], align: pw.TextAlign.left),
                pdfBodyCell(t['type']),
                pdfBodyCell(t['qty']),
                pdfBodyCell(t['notes'], align: pw.TextAlign.left),
              ],
            );
          }),
        ],
      ),
    ],
  );
}

pw.Widget pdfHeaderCell(String text) {
  return pw.Container(
    height: 32,
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget pdfBodyCell(dynamic text, {pw.TextAlign align = pw.TextAlign.center}) {
  return pw.Container(
    height: 28,
    alignment: align == pw.TextAlign.left ? pw.Alignment.centerLeft : pw.Alignment.center,
    padding: const pw.EdgeInsets.symmetric(horizontal: 6),
    child: pw.Text(
      text?.toString().isEmpty == true ? "-" : text?.toString() ?? "-",
      textAlign: align,
      style: const pw.TextStyle(fontSize: 8),
    ),
  );
}

String formatPdfDate(dynamic date) {
  if (date == null) return "-";

  final dt = DateTime.tryParse(date.toString());
  if (dt == null) return date.toString();

  return "${dt.day.toString().padLeft(2, '0')}/"
      "${dt.month.toString().padLeft(2, '0')}/"
      "${dt.year}";
}



    BoxDecoration glassBox({double radius = 24}) {
    return BoxDecoration(
      color: const Color(0xff111111).withOpacity(.94),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.55),
          blurRadius: 38,
        ),
      ],
    );
  }

  Widget glassButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(.08),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
      ),
      child: Text(text),
    );
  }

  Widget monthlyChartCard() {
    final masukSpots = <FlSpot>[];
    final keluarSpots = <FlSpot>[];

    for (int i = 0; i < dailyChart.length; i++) {
      final item = dailyChart[i];

      masukSpots.add(
        FlSpot(i.toDouble(), double.tryParse(item['masuk'].toString()) ?? 0),
      );

      keluarSpots.add(
        FlSpot(i.toDouble(), double.tryParse(item['keluar'].toString()) ?? 0),
      );
    }

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: glassBox(radius: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: accent),
              SizedBox(width: 10),
              Text(
                "Monthly Movement",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.circle, color: Color(0xff22c55e), size: 10),
              SizedBox(width: 6),
              Text("Barang Masuk", style: TextStyle(color: Colors.white70)),
              SizedBox(width: 18),
              Icon(Icons.circle, color: accent, size: 10),
              SizedBox(width: 6),
              Text("Barang Keluar", style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: masukSpots,
                    isCurved: true,
                    color: Color(0xff22c55e),
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Color(0xff22c55e).withOpacity(.12),
                    ),
                  ),
                  LineChartBarData(
                    spots: keluarSpots,
                    isCurved: true,
                    color: accent,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: accent.withOpacity(.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionRow(dynamic t) {
  final tipe = t['type']?.toString() ?? t['tipe']?.toString() ?? '-';
  final isMasuk = tipe.toUpperCase() == 'IN' || tipe.toLowerCase() == 'masuk';
  final color = isMasuk ? const Color(0xff22c55e) : accent;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: glassBox(radius: 18),
    child: Row(
      children: [
        Icon(
          isMasuk ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: color,
          size: 22,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            "${t['item_name'] ?? '-'} | $tipe | ${t['notes'] ?? '-'}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        Text(
          "Qty: ${t['qty']}",
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    ),
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
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: accent, size: 30),
                SizedBox(width: 14),
                Text(
                  "Laporan Bulanan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
              decoration: glassBox(radius: 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: glassBox(radius: 24),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: accent),
                        const SizedBox(width: 14),
                        glassButton(monthText, pickMonth),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: loading ? null : fetchReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(loading ? "Loading..." : "Load"),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: generatePdf,
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: const Text("Generate PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (summary != null) monthlyChartCard(),
                  const SizedBox(height: 18),
                  Container(
                    height: 430,
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: glassBox(radius: 26),
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada data laporan bulanan",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : Builder(
                        builder: (_) {
                        final grouped = groupedTransactions();
                        final widgets = <Widget>[];

                        grouped.forEach((kategori, items) {
                        widgets.add(categoryLabel(kategori));
                        widgets.addAll(items.map((t) => transactionRow(t)));
                     });

                      return ListView(children: widgets);
                     },
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}