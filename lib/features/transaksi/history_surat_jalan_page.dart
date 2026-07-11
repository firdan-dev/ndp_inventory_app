import 'dart:convert';
import 'dart:typed_data';

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
  static const Color accent = Color(0xffff6a00);

  final String baseUrl = 'https://api.api-nusantaradiesel.tech/api';

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchHistory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/surat-jalan'));
      final json = jsonDecode(res.body);

      if (!mounted) return;

      setState(() {
        data = json;
        filteredData = json;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void filterData(String keyword) {
    final q = keyword.toLowerCase();

    final result = data.where((item) {
      final nomor = (item['nomor_surat'] ?? '').toString().toLowerCase();
      final tujuan = (item['tujuan_cabang'] ?? '').toString().toLowerCase();
      final pic = (item['pic'] ?? '').toString().toLowerCase();

      return nomor.contains(q) || tujuan.contains(q) || pic.contains(q);
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

  String formatTanggalIndonesia(DateTime date) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${bulan[date.month]} ${date.year}';
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
        1: 'Satu',
        2: 'Dua',
        3: 'Tiga',
        4: 'Empat',
        5: 'Lima',
        6: 'Enam',
        7: 'Tujuh',
        8: 'Delapan',
        9: 'Sembilan',
        10: 'Sepuluh',
        11: 'Sebelas',
        12: 'Dua Belas',
        13: 'Tiga Belas',
        14: 'Empat Belas',
        15: 'Lima Belas',
        20: 'Dua Puluh',
        30: 'Tiga Puluh',
        40: 'Empat Puluh',
        50: 'Lima Puluh',
      };

      return angka[n] ?? n.toString();
    }

    String formatKeterangan(dynamic item) {
      if (item['item_type'] == 'manual') {
        final nama = item['nama_barang'] ?? '';
        final deskripsi = item['deskripsi'] ?? '';
        return deskripsi.toString().trim().isEmpty
            ? nama
            : '$nama\n$deskripsi';
      }

      return '${item['nama_barang'] ?? ''} ${item['part_no'] ?? ''} ${item['merk'] ?? ''}'
          .trim();
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
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text('OS No   : ${surat['os_no'] ?? '-'}',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('Kode    : ${surat['kode'] ?? '-'}',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('Resi No : ${surat['resi'] ?? '-'}',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 18),
                            pw.Text(
                              'BERAT : ${surat['berat'] ?? '-'}',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
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
                            pw.Text(
                              'Jakarta, ${formatTanggalIndonesia(now)}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                            pw.SizedBox(height: 12),
                            pw.Text('Kepada Yth,',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              surat['kepada'] ?? '-',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(surat['alamat'] ?? '-',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('Up : ${surat['up'] ?? '-'}',
                                style: const pw.TextStyle(fontSize: 10)),
                            pw.Text('Hp : ${surat['hp'] ?? '-'}',
                                style: const pw.TextStyle(fontSize: 10)),
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
                      final qty = int.tryParse(item['qty'].toString()) ?? 0;

                      return pw.TableRow(
                        children: [
                          pw.Container(
                            height: 18,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 14),
                            alignment: pw.Alignment.center,
                            child: pw.Row(
                              children: [
                                pw.SizedBox(
                                  width: 30,
                                  child: pw.Text(
                                    '$qty',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                ),
                                pw.SizedBox(
                                  width: 80,
                                  child: pw.Text(
                                    '(${angkaHuruf(qty)})',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    item['satuan'] ?? 'Ea',
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            height: 18,
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                            child: pw.Text(
                              formatKeterangan(item),
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
                              pw.Text('Penerima,',
                                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                              pw.Text('Pembawa,',
                                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                              pw.Text('Dibuat Oleh,',
                                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
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
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff050505),
          Color(0xff0b0b0b),
          Color(0xff111111),
        ],
      ),
    ),
    padding: const EdgeInsets.all(24),
    child: Row(
      children: [
        SizedBox(
          width: 420,
          child: glassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                const SizedBox(height: 20),
                searchBox(),
                const SizedBox(height: 18),
                Expanded(child: historyList()),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),

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
                      pdfFileName:
                          "${selectedSurat!['nomor_surat']}.pdf",
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
          color: accent.withOpacity(.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withOpacity(.25),
          ),
        ),
        child: const Icon(
          Icons.history_rounded,
          color: accent,
          size: 26,
        ),
      ),

      const SizedBox(width: 14),

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
            "Preview & Tracking Surat Jalan",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
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
      hintText: 'Cari nomor SJ / PIC / Cabang',
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: const Icon(Icons.search, color: accent),
      filled: true,
      fillColor: Colors.white.withOpacity(.04),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.08),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: accent,
        ),
      ),
    ),
    onChanged: filterData,
  );
}

Widget historyList() {
  if (loading) {
    return const Center(
      child: CircularProgressIndicator(
        color: accent,
      ),
    );
  }

  if (filteredData.isEmpty) {
    return const Center(
      child: Text(
        'Belum ada surat jalan',
        style: TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }

  return ListView.builder(
    itemCount: filteredData.length,
    itemBuilder: (_, i) {
      final item = filteredData[i];

      final active =
          selectedSurat != null &&
          selectedSurat!['id'] == item['id'];

      return historyCard(item, active);
    },
  );
}

Widget historyCard(dynamic item, bool active) {
  bool hover = false;

  return StatefulBuilder(
    builder: (_, setHover) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setHover(() => hover = true),
        onExit: (_) => setHover(() => hover = false),
        child: GestureDetector(
          onTap: () => loadPreview(item['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: active
                  ? accent.withOpacity(.12)
                  : Colors.white.withOpacity(
                      hover ? .08 : .04,
                    ),
              border: Border.all(
                color: active
                    ? accent.withOpacity(.35)
                    : Colors.white.withOpacity(
                        hover ? .12 : .06,
                      ),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(.12),
                        blurRadius: 30,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: accent,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        '${item['tujuan_cabang']} • ${item['pic']} • ${item['total_item']} Item',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      statusBadge(
                        item['status'] ?? 'Dikirim',
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  color: const Color(0xff111111),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white54,
                  ),
                  onSelected: (status) {
                    updateStatus(
                      item['id'],
                      status,
                    );
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'Dikirim',
                      child: Text('Dikirim'),
                    ),
                    PopupMenuItem(
                      value: 'Diterima',
                      child: Text('Diterima'),
                    ),
                    PopupMenuItem(
                      value: 'Selesai',
                      child: Text('Selesai'),
                    ),
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
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(.15),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: color.withOpacity(.25),
      ),
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
          size: 80,
          color: Colors.white.withOpacity(.18),
        ),

        const SizedBox(height: 14),

        const Text(
          'Pilih surat jalan untuk preview',
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
      ],
    ),
  );
}

Widget glassPanel({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xff111111).withOpacity(.94),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withOpacity(.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.55),
          blurRadius: 40,
        ),
      ],
    ),
    child: child,
  );
}
}