  import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SuratJalanPage extends StatefulWidget {
  const SuratJalanPage({super.key});

  @override
  State<SuratJalanPage> createState() => _SuratJalanPageState();
}

class _SuratJalanPageState extends State<SuratJalanPage> {
  static const Color accent = Color(0xffff6a00);

  final barcodeController = TextEditingController();
  final barcodeFocus = FocusNode();
  final keteranganController = TextEditingController();

  final nomorSjController = TextEditingController();
  final osNoController = TextEditingController();
  final kodeController = TextEditingController(text: '-');
  final resiNoController = TextEditingController();
  final beratController = TextEditingController(text: '10 Kg');

  final kepadaController = TextEditingController();
  final alamatController = TextEditingController();
  final upController = TextEditingController();
  final hpController = TextEditingController();

  String tujuan = 'BJM';
  String pic = 'Fiska';
  bool loading = false;

  int? activeSuratJalanId;

  final String baseUrl = 'https://api.api-nusantaradiesel.tech/api';
  List serviceCustomers = [];
  int? selectedServiceCustomerId;
  final List<Map<String, dynamic>> items = [];

  final satuanList = [
    'Ea',
    'Unit',
    'Set',
    'Roll',
    'Gulung',
    'Pcs',
    'Box',
    'Kg',
  ];

  final tujuanList = const [
    {'kode': 'BJM', 'nama': 'Banjarmasin Pump'},
    {'kode': 'RXD', 'nama': 'Rex Diesel'},
    {'kode': 'WSP', 'nama': 'Waroeng Sparepart'},
    {'kode': 'INT', 'nama': 'Intern / Customer'},
  ];

  final picList = const [
    'Jesslyne',
    'Jennifer',
    'Fiska',
    'Uchi',
    'Husna',
  ];

  final tujuanDetail = {
    'BJM': {
      'kepada': 'BANJARMASIN PUMP',
      'alamat': 'Jl. Ahmad Yani Km. 5.7 No.432 Banjarmasin, Kalsel',
      'up': 'Ibu Endang',
      'hp': '0812 8186 4902',
    },
    'RXD': {
      'kepada': 'REX DIESEL',
      'alamat': 'JL. Laode Hadi No. 88H, Banggoeya, Wua-Wua, Sultra',
      'up': 'Bp Chairul Kasim',
      'hp': '0812-8888-343',
    },
  };

  @override
  void initState() {
  super.initState();
  isiTujuanOtomatis();
  resetNomorSuratJalan();
  fetchServiceCustomers();
}

  @override
  void dispose() {
    barcodeController.dispose();
    barcodeFocus.dispose();
    keteranganController.dispose();
    nomorSjController.dispose();
    osNoController.dispose();
    kodeController.dispose();
    resiNoController.dispose();
    beratController.dispose();
    kepadaController.dispose();
    alamatController.dispose();
    upController.dispose();
    hpController.dispose();
    super.dispose();
  }

  void isiTujuanOtomatis() {
    final data = tujuanDetail[tujuan];

    if (data != null) {
      kepadaController.text = data['kepada']!;
      alamatController.text = data['alamat']!;
      upController.text = data['up']!;
      hpController.text = data['hp']!;
    } else {
      kepadaController.clear();
      alamatController.clear();
      upController.clear();
      hpController.clear();
    }
  }

  void resetNomorSuratJalan() {
    final now = DateTime.now();

    nomorSjController.text =
        'SJ-$tujuan-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> scanBarang() async {
    final barcode = barcodeController.text
    .trim()
    .replaceAll('-', '')
    .replaceAll(' ', '')
    .toUpperCase();
    
    debugPrint("SCAN BARCODE: $barcode");


    try {
      final res = await http.get(
        Uri.parse('$baseUrl/surat-jalan/barang/$barcode'),
      );

      if (res.statusCode != 200 || res.body == 'null') {
        showMsg('Barang tidak ditemukan');
        return;
      }

      final product = jsonDecode(res.body);
      showBarangPopup(product);
    } catch (e) {
      showMsg('Gagal scan barang: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  
    void showBarangPopup(Map<String, dynamic> product) {
  final qtyController = TextEditingController(text: '1');
  final ketItemController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Detail Barang',
    barrierColor: Colors.black.withOpacity(0.65),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(28),
            decoration: glassDecoration(radius: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerDialog(
                  product['nama_barang'] ?? 'Detail Barang',
                  Icons.inventory_2_rounded,
                ),
                const SizedBox(height: 22),
                info('Kode', product['kode_internal']),
                info('Part No', product['part_no']),
                info('Merk', product['merk']),
                info('Stok', product['qty'].toString()),
                const SizedBox(height: 18),
                input(qtyController, 'Qty keluar'),
                const SizedBox(height: 12),
                input(ketItemController, 'Keterangan item'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    glassTextButton(
                      title: 'Batal',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    glassActionButton(
                      title: 'Tambah',
                      icon: Icons.add_rounded,
                      onTap: () {
                        final qty = int.tryParse(qtyController.text) ?? 0;
                        final stok =
                            int.tryParse(product['qty'].toString()) ?? 0;

                        if (qty <= 0) return showMsg('Qty tidak valid');
                        if (qty > stok) return showMsg('Qty melebihi stok');

                        setState(() {
                          items.add({
                            "item_type": "barcode",
                            "product_id": product['id'],
                            "nama_barang": product['nama_barang'],
                            "kode_internal": product['kode_internal'],
                            "part_no": product['part_no'],
                            "merk": product['merk'],
                            "qty": qty,
                            "satuan": "Ea",
                            "deskripsi": "",
                            "pic": pic,
                            "keterangan": ketItemController.text,
                          });

                          barcodeController.clear();
                        });

                        Navigator.pop(context);

                        Future.delayed(const Duration(milliseconds: 400), () {
                          barcodeController.clear();
                          barcodeFocus.requestFocus();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: Opacity(opacity: anim.value, child: child),
      );
    },
  );
}

        void showManualItemDialog() {
  final qtyController = TextEditingController(text: '1');
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  String satuan = 'Ea';

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tambah Item Manual',
    barrierColor: Colors.black.withOpacity(0.65),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            decoration: glassDecoration(radius: 30),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerDialog(
                      'Tambah Item Manual',
                      Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 22),

                    input(qtyController, 'Qty'),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: satuan,
                      dropdownColor: const Color(0xff111111),
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration('Satuan'),
                      items: satuanList.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setModalState(() => satuan = v ?? 'Ea');
                      },
                    ),

                    const SizedBox(height: 12),
                    input(namaController, 'Nama / Judul Barang'),
                    const SizedBox(height: 12),

                    TextField(
                      controller: deskripsiController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        'Deskripsi / Serial Number',
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        glassTextButton(
                          title: 'Batal',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        glassActionButton(
                          title: 'Tambah',
                          icon: Icons.add_rounded,
                          onTap: () {
                            final qty =
                                int.tryParse(qtyController.text) ?? 0;

                            if (qty <= 0) {
                              return showMsg('Qty tidak valid');
                            }

                            if (namaController.text.trim().isEmpty) {
                              return showMsg('Nama barang wajib diisi');
                            }

                            setState(() {
                              items.add({
                                "item_type": "manual",
                                "product_id": null,
                                "nama_barang": namaController.text.trim(),
                                "kode_internal": "",
                                "part_no": "",
                                "merk": "",
                                "qty": qty,
                                "satuan": satuan,
                                "deskripsi":
                                    deskripsiController.text.trim(),
                                "pic": pic,
                                "keterangan":
                                    deskripsiController.text.trim(),
                              });
                            });

                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

      void showFormEditSuratJalan() {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Edit Surat Jalan',
        barrierColor: Colors.black.withOpacity(0.65),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 720,
                constraints: const BoxConstraints(maxHeight: 720),
                padding: const EdgeInsets.all(28),
                decoration: glassDecoration(radius: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      headerDialog(
                        'Edit Surat Jalan',
                        Icons.local_shipping_rounded,
                      ),
                      const SizedBox(height: 22),

                      input(nomorSjController, 'Nomor Surat Jalan'),
                      const SizedBox(height: 10),
                      input(osNoController, 'OS No'),
                      const SizedBox(height: 10),
                      input(kodeController, 'Kode'),
                      const SizedBox(height: 10),
                      input(resiNoController, 'Resi No'),
                      const SizedBox(height: 10),
                      input(beratController, 'Berat'),
                      const SizedBox(height: 10),
                      input(kepadaController, 'Kepada Yth'),
                      const SizedBox(height: 10),
                      input(alamatController, 'Alamat'),
                      const SizedBox(height: 10),
                      input(upController, 'Up'),
                      const SizedBox(height: 10),
                      input(hpController, 'HP'),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          glassTextButton(
                            title: 'Batal',
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          glassActionButton(
                            title: 'Generate',
                            icon: Icons.local_shipping_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              generateSuratJalan();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (_, anim, __, child) {
          return Transform.scale(
            scale: Curves.easeOutBack.transform(anim.value),
            child: Opacity(opacity: anim.value, child: child),
          );
        },
      );
    }

     Future<void> generateSuratJalan() async {
      if (items.isEmpty) return showMsg('Belum ada item');

      final transactionType = tujuan == 'INT'
          ? 'INTERNAL'
          : tujuan == 'WSP'
              ? 'WAROENG'
              : 'CABANG';

      final status = tujuan == 'INT' ? 'Pending' : 'Approved';

      setState(() => loading = true);

      try {
        final res = await http.post(
          Uri.parse('$baseUrl/surat-jalan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "tujuan": tujuan,
            "transaction_type": transactionType,
            "status": status,
            "service_customer_id": selectedServiceCustomerId,
            "pic": pic,
            "keterangan": keteranganController.text,
            "nomor_surat": nomorSjController.text,
            "os_no": osNoController.text,
            "kode": kodeController.text,
            "resi_no": resiNoController.text,
            "berat": beratController.text,
            "kepada": kepadaController.text,
            "alamat": alamatController.text,
            "up": upController.text,
            "hp": hpController.text,
            "items": items,
          }),
        );

        debugPrint("STATUS SJ: ${res.statusCode}");
        debugPrint("BODY SJ: ${res.body}");

        if (res.headers['content-type']?.contains('application/json') != true) {
          showMsg("Backend mengembalikan HTML, cek route/backend");
          return;
        }

        final data = jsonDecode(res.body);

        if (res.statusCode == 200) {
          if (data['status'] == 'Approved') {
            await generatePdf(data['nomor_surat']);
            showMsg('Surat jalan berhasil dibuat & approved');
          } else {
            showMsg('Surat jalan disimpan sebagai Pending');
          }

          setState(() {
            items.clear();
            keteranganController.clear();
            resetNomorSuratJalan();
          });
        } else {
          showMsg(data['message'] ?? 'Gagal membuat surat jalan');
        }
      } catch (e) {
        showMsg('Error: $e');
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }

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
    

    Future<void> fetchServiceCustomers() async {
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/service-customers'),
    );

    if (!mounted) return;

    setState(() {
      serviceCustomers = jsonDecode(res.body);
    });
  } catch (e) {
    showMsg('Gagal mengambil customer service: $e');
  }
}


    Future<void> generatePdf(String nomorSurat) async {
      final pdf = pw.Document();
      final now = DateTime.now();
      final picInitial = getPicInitial(pic);

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
          50: 'Lima Puluh ',
        };

        if (angka.containsKey(n)) return angka[n]!;
        return n.toString();
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
          return deskripsi.toString().trim().isEmpty
              ? nama
              : '$nama\n$deskripsi';
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
                                  'SURAT JALAN NO : $nomorSurat',
                                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Text('OS No   : ${osNoController.text}', style: const pw.TextStyle(fontSize: 10)),
                                pw.Text('Kode    : ${kodeController.text}', style: const pw.TextStyle(fontSize: 10)),
                                pw.Text('Resi No : ${resiNoController.text}', style: const pw.TextStyle(fontSize: 10)),
                                pw.SizedBox(height: 18),
                                pw.Text(
                                  'BERAT : ${beratController.text}',
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
                                pw.Text(
                                  'Jakarta, ${formatTanggalIndonesia(now)}',
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                                pw.SizedBox(height: 12),
                                pw.Text('Kepada Yth,', style: const pw.TextStyle(fontSize: 10)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  kepadaController.text,
                                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(alamatController.text, style: const pw.TextStyle(fontSize: 10)),
                                pw.Text('Up : ${upController.text}', style: const pw.TextStyle(fontSize: 10)),
                                pw.Text('Hp : ${hpController.text}', style: const pw.TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              

                  // HEADER TABEL
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

                  // ISI TABEL
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
                          pw.Container(
                            height: 18,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 14),
                            alignment: pw.Alignment.center,
                            child: pw.Row(
                              children: [
                                pw.SizedBox(
                                  width: 30,
                                  child: pw.Text('${item['qty']}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
                                ),
                                pw.SizedBox(
                                  width: 80,
                                  child: pw.Text(
                                    '(${angkaHuruf(int.tryParse(item['qty'].toString()) ?? 0)})',
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(item['satuan'] ?? 'Ea', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
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
                              child: pw.Text('($picInitial)', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
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

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    }

    pw.Widget pdfCell(String text, {bool bold = false}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    void showMsg(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    Widget headerDialog(String title, IconData icon) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.28)),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    Widget info(String label, dynamic value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 85,
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

    Widget input(TextEditingController controller, String label) {
      return TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(label),
      );
    }

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.045),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: accent),
        ),
      );
    }

    Widget glassPanel({required Widget child}) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: glassDecoration(radius: 30),
        child: child,
      );
    }

    BoxDecoration glassDecoration({double radius = 24}) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: const Color(0xff111111).withOpacity(0.94),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 42,
          ),
        ],
      );
    }

        Widget glassActionButton({
        required String title,
        required IconData icon,
        required VoidCallback? onTap,
      }) {
        bool hover = false;

        return StatefulBuilder(
          builder: (_, setHover) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setHover(() => hover = true),
              onExit: (_) => setHover(() => hover = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                transform: Matrix4.translationValues(0, hover ? -3 : 0, 0),
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(icon, size: 17),
                  label: Text(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hover ? accent.withOpacity(0.85) : accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white38,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }

      Widget glassTextButton({
        required String title,
        required VoidCallback onTap,
      }) {
        return TextButton(
          onPressed: onTap,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white60),
          ),
        );
      }

  Widget itemCard(Map<String, dynamic> item, int index) {
  bool hover = false;

  return StatefulBuilder(
    builder: (_, setHover) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setHover(() => hover = true),
        onExit: (_) => setHover(() => hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: hover ? accent.withOpacity(0.09) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hover ? accent.withOpacity(0.24) : Colors.white.withOpacity(0.06),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_rounded, color: accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama_barang'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item['kode_internal']} | Part: ${item['part_no'] ?? '-'} | Merk: ${item['merk'] ?? '-'}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                'Qty: ${item['qty']}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => items.removeAt(index)),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              ),
            ],
          ),
        ),
          );
        },
      );
    }

      Widget dropdownTujuan() {
      return DropdownButtonFormField<String>(
        value: tujuan,
        dropdownColor: const Color(0xff151515),
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration('Tujuan'),
        iconEnabledColor: accent,
        items: tujuanList.map((e) {
          return DropdownMenuItem(
            value: e['kode'],
            child: Text(
              '${e['kode']} - ${e['nama']}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) {
          setState(() => tujuan = v!);
          isiTujuanOtomatis();
          resetNomorSuratJalan();
        },
      );
    }

    Widget serviceCustomerDropdown() {
  return RawAutocomplete<Map<String, dynamic>>(
    displayStringForOption: (c) =>
        '${c['service_no']} - ${c['nama_customer']}',
    optionsBuilder: (TextEditingValue value) {
      final q = value.text.toLowerCase();

      return serviceCustomers
          .cast<Map<String, dynamic>>()
          .where((c) {
        final text =
            '${c['service_no']} ${c['nama_customer']} ${c['jenis_barang']} ${c['part_no']}'
                .toLowerCase();
        return text.contains(q);
      });
    },
    onSelected: (c) {
      setState(() {
        selectedServiceCustomerId = c['id'];
        kepadaController.text = c['nama_customer'] ?? '';
        upController.text = c['nama_customer'] ?? '';
        alamatController.text = '';
        hpController.text = '';
        keteranganController.text =
            'Service: ${c['service_no']} | ${c['jenis_barang']} | ${c['part_no']}';
      });
    },
    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration('Cari Service Customer'),
      );
    },
    optionsViewBuilder: (context, onSelected, options) {
      return Material(
        color: const Color(0xff151515),
        child: SizedBox(
          height: 300,
          child: ListView(
            padding: EdgeInsets.zero,
            children: options.map((c) {
              return ListTile(
                title: Text(
                  '${c['service_no']} - ${c['nama_customer']}',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${c['jenis_barang'] ?? '-'} | ${c['part_no'] ?? '-'}',
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () => onSelected(c),
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}



    Widget dropdownPic() {
      return DropdownButtonFormField<String>(
        value: pic,
        dropdownColor: const Color(0xff151515),
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration('PIC'),
        iconEnabledColor: accent,
        items: picList.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => pic = v);
          }
        },
      );
    }



    Future<void> showPendingSuratJalan() async {
  try {
    setState(() => loading = true);

    final res = await http.get(
      Uri.parse('$baseUrl/surat-jalan'),
    );

    if (res.statusCode != 200) {
      showMsg('Gagal mengambil data Surat Jalan');
      return;
    }

    final List data = jsonDecode(res.body);

    final pendingList = data.where((sj) {
      return sj['status'] == 'Pending';
    }).toList();

    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Pending Surat Jalan',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 720,
              constraints: const BoxConstraints(maxHeight: 620),
              padding: const EdgeInsets.all(28),
              decoration: glassDecoration(radius: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerDialog(
                    'Pending Surat Jalan',
                    Icons.pending_actions_rounded,
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: pendingList.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada Surat Jalan Pending',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: pendingList.length,
                            itemBuilder: (_, i) {
                              final sj = pendingList[i];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.description_rounded,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sj['nomor_surat'] ?? '-',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${sj['tujuan_cabang'] ?? '-'} | ${sj['kepada'] ?? '-'} | ${sj['pic'] ?? '-'} | ${sj['total_item']} item',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                      glassActionButton(
                                      title: "Lanjutkan",
                                      icon: Icons.arrow_forward_rounded,
                                      onTap: () {
                                        Navigator.pop(context);
                                        loadPendingSuratJalan(sj['id']);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: glassTextButton(
                      title: 'Tutup',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } catch (e) {
    showMsg('Error mengambil Pending SJ: $e');
  } finally {
    if (mounted) setState(() => loading = false);
  }
}



        Future<void> loadPendingSuratJalan(int id) async {
          try {
            setState(() => loading = true);
            
            final res = await http.get(
              Uri.parse('$baseUrl/surat-jalan/$id'),
            );

            if (res.statusCode != 200) {
              showMsg('Gagal membuka Surat Jalan Pending');
              return;
            }

            final data = jsonDecode(res.body);
            final surat = data['surat'];
            final List itemRows = data['items'];
            

            setState(() {
                activeSuratJalanId = id;

              nomorSjController.text = surat['nomor_surat'] ?? '';
              tujuan = surat['tujuan_cabang'] ?? tujuan;
              pic = surat['pic'] ?? pic;
              keteranganController.text = surat['keterangan'] ?? '';

              osNoController.text = surat['os_no'] ?? '';
              kodeController.text = surat['kode'] ?? '-';
              resiNoController.text = surat['resi'] ?? '';
              beratController.text = surat['berat']?.toString() ?? '10 Kg';

              kepadaController.text = surat['kepada'] ?? '';
              alamatController.text = surat['alamat'] ?? '';
              upController.text = surat['up'] ?? '';
              hpController.text = surat['hp'] ?? '';
              

              items.clear();
              items.addAll(itemRows.cast<Map<String, dynamic>>());
            });

            showMsg('Surat Jalan Pending berhasil dibuka');
          } catch (e) {
            showMsg('Error buka Pending SJ: $e');
          } finally {
            if (mounted) setState(() => loading = false);
          }
        }


        Future<void> approveSuratJalan(int id) async {
        final res = await http.put(
          Uri.parse('$baseUrl/surat-jalan/$id/approve'),
        );

        if (res.statusCode == 200) {
          showMsg('Surat Jalan berhasil di-approve');
        } else {
          final data = jsonDecode(res.body);
          showMsg(data['message'] ?? 'Gagal approve Surat Jalan');
        }
      }



      Future<void> updatePendingSuratJalan() async {
      if (activeSuratJalanId == null) {
        showMsg('Tidak ada Surat Jalan Pending yang dibuka');
        return;
      }

      if (items.isEmpty) {
        showMsg('Belum ada item');
        return;
      }

      try {
        setState(() => loading = true);

        for (final item in items) {
          final res = await http.post(
            Uri.parse('$baseUrl/surat-jalan/$activeSuratJalanId/items'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(item),
          );

          if (res.statusCode != 200) {
            final data = jsonDecode(res.body);
            showMsg(data['message'] ?? 'Gagal update item pending');
            return;
          }
        }

        showMsg('Pending Surat Jalan berhasil diupdate');

        setState(() {
          items.clear();
          activeSuratJalanId = null;
          keteranganController.clear();
          resetNomorSuratJalan();
        });
      } catch (e) {
        showMsg('Error update pending: $e');
      } finally {
        if (mounted) setState(() => loading = false);
      }
    }

      Future<void> approveAndPrint() async {
      if (activeSuratJalanId == null) {
        showMsg('Tidak ada Surat Jalan Pending yang dibuka');
        return;
      }

      try {
        setState(() => loading = true);

        final res = await http.put(
          Uri.parse('$baseUrl/surat-jalan/$activeSuratJalanId/approve'),
        );

        final data = jsonDecode(res.body);

        if (res.statusCode == 200) {
          await generatePdf(nomorSjController.text);

          showMsg('Surat Jalan berhasil difinalisasi');

          setState(() {
            activeSuratJalanId = null;
            items.clear();
            keteranganController.clear();
            resetNomorSuratJalan();
          });
        } else {
          showMsg(data['message'] ?? 'Gagal finalisasi Surat Jalan');
        }
      } catch (e) {
        showMsg('Error finalisasi: $e');
      } finally {
        if (mounted) setState(() => loading = false);
      }
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
        child: glassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                     Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          color: accent,
                          size: 34,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Surat Jalan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        OutlinedButton.icon(
                        onPressed: () {
                          showPendingSuratJalan();
                        },
                        icon: const Icon(
                          Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          "Pending SJ",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(
                            color: Colors.orange,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      ],
                    ),  

              const SizedBox(height: 24),

               Row(
                children: [
                  SizedBox(width: 260, child: dropdownTujuan()),
                  const SizedBox(width: 14),
                  SizedBox(width: 180, child: dropdownPic()),
                  const SizedBox(width: 14),

                  Expanded(
                    child: TextField(
                      controller: barcodeController,
                      focusNode: barcodeFocus,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration('Scan / Input Barcode'),
                      onSubmitted: (_) => scanBarang(),
                    ),
                  ),

                  const SizedBox(width: 14),

                  glassActionButton(
                    title: 'Scan',
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: loading ? null : scanBarang,
                  ),

                  const SizedBox(width: 10),

                  glassActionButton(
                    title: 'Manual',
                    icon: Icons.edit_note_rounded,
                    onTap: showManualItemDialog,
                  ),
                ],
              ),

              if (tujuan == 'INT') ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: serviceCustomerDropdown(),
                ),
              ],
            

  

              const SizedBox(height: 16),

              input(keteranganController, 'Keterangan surat jalan'),

              const SizedBox(height: 22),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xff0b0b0b),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada barang di surat jalan',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) => itemCard(items[i], i),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  glassActionButton(
                    title: activeSuratJalanId == null
                        ? "Simpan Pending"
                        : "Update Pending",
                    icon: Icons.save_rounded,
                    onTap: loading || items.isEmpty
                        ? null
                        : activeSuratJalanId == null
                            ? showFormEditSuratJalan
                            : updatePendingSuratJalan,
                  ),

                  const SizedBox(width: 12),

                  glassActionButton(
                    title: "Finalisasi & Print",
                    icon: Icons.check_circle_rounded,
                    onTap: activeSuratJalanId == null || loading
                        ? null
                        : approveAndPrint,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
}