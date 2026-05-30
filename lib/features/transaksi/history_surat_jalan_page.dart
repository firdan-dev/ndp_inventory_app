import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistorySuratJalanPage extends StatefulWidget {
  const HistorySuratJalanPage({super.key});

  @override
  State<HistorySuratJalanPage> createState() => _HistorySuratJalanPageState();
}

class _HistorySuratJalanPageState extends State<HistorySuratJalanPage> {
  final String baseUrl = 'http://localhost:3000/api';

  bool loading = true;
  List data = [];
  List filteredData = [];

  Map? selectedSurat;
  List selectedItems = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/surat-jalan'));
      final json = jsonDecode(res.body);

      setState(() {
        data = json;
        filteredData = json;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void filterData(String keyword) {
    final result = data.where((item) {
      final nomor = item['nomor_surat'].toString().toLowerCase();
      final tujuan = item['tujuan_cabang'].toString().toLowerCase();
      final pic = item['pic'].toString().toLowerCase();

      return nomor.contains(keyword.toLowerCase()) ||
          tujuan.contains(keyword.toLowerCase()) ||
          pic.contains(keyword.toLowerCase());
    }).toList();

    setState(() => filteredData = result);
  }

  Future<void> loadPreview(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/surat-jalan/$id'));
    final json = jsonDecode(res.body);

    setState(() {
      selectedSurat = json['surat'];
      selectedItems = json['items'];
    });
  }

  Future<void> updateStatus(int id, String status) async {
    await http.put(
      Uri.parse('$baseUrl/surat-jalan/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    await fetchHistory();

    if (selectedSurat != null && selectedSurat!['id'] == id) {
      await loadPreview(id);
    }
  }

  Future<Uint8List> buildSuratJalanPdf(
  PdfPageFormat format,
  Map surat,
  List items,
) async {
  final pdf = pw.Document();
  final now = DateTime.now();

  String getPicInitial(String pic) {
    switch (pic) {
      case 'Jesslyne':
        return 'JS';
      case 'Jennifer':
        return 'JN';
      case 'Fiska':
        return 'FS';
      case 'Uchi':
        return 'UC';
      case 'Husna':
        return 'HS';
      default:
        return pic;
    }
  }

  String angkaHuruf(int n) {
    const angka = {
      1: 'satu',
      2: 'dua',
      3: 'tiga',
      4: 'empat',
      5: 'lima',
      6: 'enam',
      7: 'tujuh',
      8: 'delapan',
      9: 'sembilan',
      10: 'sepuluh',
      11: 'sebelas',
      12: 'dua belas',
      13: 'tiga belas',
      14: 'empat belas',
      15: 'lima belas',
      20: 'dua puluh',
      30: 'tiga puluh',
      40: 'empat puluh',
      50: 'lima puluh',
    };

    return angka[n] ?? n.toString();
  }

  String formatBanyaknya(dynamic item) {
    final qty = int.tryParse(item['qty'].toString()) ?? 0;
    final satuan = item['satuan'] ?? 'Ea';
    return '$qty (${angkaHuruf(qty)}) $satuan';
  }

  String formatKeterangan(dynamic item) {
    if (item['item_type'] == 'manual') {
      final nama = item['nama_barang'] ?? '';
      final deskripsi = item['deskripsi'] ?? '';
      return deskripsi.toString().trim().isEmpty ? nama : '$nama\n$deskripsi';
    }

    return '${item['nama_barang'] ?? ''} ${item['part_no'] ?? ''} ${item['merk'] ?? ''}'.trim();
  }

  pw.Widget centerText(String text, {bool bold = false, double size = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: size,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  final picInitial = getPicInitial(surat['pic'] ?? '');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(42),
      build: (context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 1),
          ),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'SURAT JALAN NO : ${surat['nomor_surat']}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text('OS No   : ${surat['os_no'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Kode    : ${surat['kode'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Resi No : ${surat['resi'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 18),
                          pw.Text(
                            'BERAT : ${surat['berat'] ?? '-'}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 24),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Jakarta, ${now.day}-${now.month}-${now.year}', style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 12),
                          pw.Text('Kepada Yth,', style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            surat['kepada'] ?? '-',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(surat['alamat'] ?? '-', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Up : ${surat['up'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Hp : ${surat['hp'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.Table(
                border: const pw.TableBorder(
                  top: pw.BorderSide(width: 0.8),
                  left: pw.BorderSide(width: 0.8),
                  right: pw.BorderSide(width: 0.8),
                  bottom: pw.BorderSide(width: 0.8),
                  verticalInside: pw.BorderSide(width: 0.8),
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(160),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    children: [
                      centerText('Banyaknya', bold: true),
                      centerText('Keterangan', bold: true),
                    ],
                  ),
                ],
              ),

              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(width: 0.8),
                  right: pw.BorderSide(width: 0.8),
                  bottom: pw.BorderSide(width: 0.8),
                  verticalInside: pw.BorderSide(width: 0.8),
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(160),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        centerText(formatBanyaknya(item)),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: pw.Text(
                            formatKeterangan(item),
                            textAlign: pw.TextAlign.left,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    );
                  }),
                  pw.TableRow(
                    children: [
                      pw.SizedBox(height: 55),
                      pw.SizedBox(height: 55),
                    ],
                  ),
                ],
              ),

              pw.Table(
                border: pw.TableBorder.all(width: 0.8),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            pw.Text('Penerima,', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Pembawa,', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Dibuat Oleh,', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.SizedBox(
                        height: 55,
                        child: pw.Align(
                          alignment: pw.Alignment.bottomRight,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 70, bottom: 6),
                            child: pw.Text(
                              '($picInitial)',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff0f172a),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 440,
            child: glassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header(),
                  const SizedBox(height: 20),
                  searchBox(),
                  const SizedBox(height: 16),
                  Expanded(child: historyList()),
                ],
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: glassPanel(
              child: selectedSurat == null
                  ? emptyPreview()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: PdfPreview(
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        build: (format) => buildSuratJalanPdf(
                          format,
                          selectedSurat!,
                          selectedItems,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff38bdf8).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.history_rounded, color: Color(0xff38bdf8)),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History Surat Jalan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Preview, status, dan cetak surat jalan",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget searchBox() {
    return TextField(
      controller: searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Cari nomor SJ / cabang / PIC...',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.045),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xff38bdf8)),
        ),
      ),
      onChanged: filterData,
    );
  }

  Widget historyList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredData.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada surat jalan",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (_, i) {
        final item = filteredData[i];
        final active = selectedSurat != null && selectedSurat!['id'] == item['id'];

        return historyCard(item, active);
      },
    );
  }

  Widget historyCard(dynamic item, bool active) {
    bool hover = false;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setHover(() => hover = true),
          onExit: (_) => setHover(() => hover = false),
          child: GestureDetector(
            onTap: () => loadPreview(item['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: active
                    ? const Color(0xff38bdf8).withOpacity(0.16)
                    : Colors.white.withOpacity(hover ? 0.075 : 0.04),
                border: Border.all(
                  color: active
                      ? const Color(0xff38bdf8).withOpacity(0.45)
                      : Colors.white.withOpacity(hover ? 0.12 : 0.06),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xff38bdf8).withOpacity(0.20),
                          blurRadius: 28,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded,
                      color: Color(0xff38bdf8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nomor_surat'] ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tujuan: ${item['tujuan_cabang']} | PIC: ${item['pic']} | Item: ${item['total_item']}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        statusBadge(item['status'] ?? 'Dikirim'),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xff0f172a),
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.white54),
                    onSelected: (status) => updateStatus(item['id'], status),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'Dikirim', child: Text('Dikirim')),
                      PopupMenuItem(value: 'Diterima', child: Text('Diterima')),
                      PopupMenuItem(value: 'Selesai', child: Text('Selesai')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Dikirim':
        color = Colors.orange;
        break;
      case 'Diterima':
        color = Colors.blue;
        break;
      case 'Selesai':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget emptyPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            size: 72,
            color: Colors.white.withOpacity(0.22),
          ),
          const SizedBox(height: 14),
          const Text(
            "Pilih surat jalan untuk preview",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget glassPanel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.025),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff38bdf8).withOpacity(0.08),
                blurRadius: 40,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}