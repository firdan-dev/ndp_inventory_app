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

    final String baseUrl = 'http://localhost:3000/api';
    final List<Map<String, dynamic>> items = [];
    final satuanList = ['Ea', 'Unit', 'Set', 'Roll', 'Gulung', 'Pcs', 'Box', 'Kg'];


    final tujuanList = const [
      {'kode': 'BJM', 'nama': 'Banjarmasin Pump'},
      {'kode': 'RXD', 'nama': 'Rex Diesel'},
      {'kode': 'WSP', 'nama': 'Waroeng Sparepart'},
      {'kode': 'INT', 'nama': 'Intern / Customer'},
    ];

    final picList = const ['Jesslyne', 'Jennifer', 'Fiska', 'Uchi', 'Husna'];

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
    }


    void dispose() {
    barcodeController.dispose();
    barcodeFocus.dispose();
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
      final barcode = barcodeController.text.trim();
      if (barcode.isEmpty) return;

      setState(() => loading = true);

      try {
        final res = await http.get(Uri.parse('$baseUrl/barang/$barcode'));

        if (res.statusCode != 200 || res.body == 'null') {
          showMsg('Barang tidak ditemukan');
          return;
        }

        final product = jsonDecode(res.body);
        showBarangPopup(product);
      } catch (e) {
        showMsg('Gagal scan barang: $e');
      } finally {
        setState(() => loading = false);
      }
    }

    

    void showBarangPopup(Map<String, dynamic> product) {
      final qtyController = TextEditingController(text: '1');
      final ketItemController = TextEditingController();

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Detail Barang',
        barrierColor: Colors.black.withOpacity(0.55),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 430,
                    padding: const EdgeInsets.all(28),
                    decoration: glassDecoration(radius: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xff38bdf8).withOpacity(0.16),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xff38bdf8).withOpacity(0.28),
                                ),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: Color(0xff38bdf8),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                product['nama_barang'] ?? 'Detail Barang',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                                final stok = int.tryParse(product['qty'].toString()) ?? 0;

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


                                // 🔥 INI YANG PENTING
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
          barrierColor: Colors.black.withOpacity(0.55),
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, __, ___) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                              const Text(
                                'Tambah Item Manual',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 22),
                              input(qtyController, 'Qty'),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: satuan,
                                dropdownColor: const Color(0xff111827),
                                style: const TextStyle(color: Colors.white),
                                decoration: inputDecoration('Satuan'),
                                items: satuanList.map((e) {
                                  return DropdownMenuItem(value: e, child: Text(e));
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
                                decoration: inputDecoration('Deskripsi / Serial Number'),
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
                                      final qty = int.tryParse(qtyController.text) ?? 0;
                                      if (qty <= 0) return showMsg('Qty tidak valid');
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
                                          "deskripsi": deskripsiController.text.trim(),
                                          "pic": pic,
                                          "keterangan": deskripsiController.text.trim(),
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
        barrierColor: Colors.black.withOpacity(0.55),
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                          const Text(
                            'Edit Surat Jalan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
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
      if (items.isEmpty) return;

      setState(() => loading = true);

      try {
        final res = await http.post(
          Uri.parse('$baseUrl/surat-jalan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "tujuan": tujuan,
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

        final data = jsonDecode(res.body);

        if (res.statusCode == 200) {
          await generatePdf(data['nomor_surat']);

          showMsg('Surat jalan berhasil: ${data['nomor_surat']}');

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
        setState(() => loading = false);
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

    Future<void> generatePdf(String nomorSurat) async {
      final pdf = pw.Document();
      final now = DateTime.now();
      final picInitial = getPicInitial(pic);

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
                                  'Jakarta, ${now.day}-${now.month}-${now.year}',
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
        fillColor: Colors.white.withOpacity(0.055),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xff38bdf8)),
        ),
      );
    }

    Widget glassPanel({required Widget child}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: glassDecoration(radius: 30),
            child: child,
          ),
        ),
      );
    }

    BoxDecoration glassDecoration({double radius = 24}) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
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
                      hover ? const Color(0xff0ea5e9) : const Color(0xff38bdf8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
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
      bool hover = false;

      return StatefulBuilder(
        builder: (_, setHover) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setHover(() => hover = true),
            onExit: (_) => setHover(() => hover = false),
            child: TextButton(
              onPressed: onTap,
              child: Text(
                title,
                style: TextStyle(
                  color: hover ? Colors.white : Colors.white60,
                ),
              ),
            ),
          );
        },
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
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(hover ? 0.075 : 0.035),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(hover ? 0.14 : 0.06),
                ),
                boxShadow: hover
                    ? [
                        BoxShadow(
                          color: const Color(0xff38bdf8).withOpacity(0.12),
                          blurRadius: 26,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_rounded, color: Color(0xff38bdf8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nama_barang'] ?? '-',
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 5),
                        Text(
                          '${item['kode_internal']} | Part: ${item['part_no'] ?? '-'} | Merk: ${item['merk'] ?? '-'}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Qty: ${item['qty']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => setState(() => items.removeAt(index)),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent),
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
        dropdownColor: const Color(0xff111827),
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration('Tujuan'),
        items: tujuanList.map((e) {
          return DropdownMenuItem(
            value: e['kode'],
            child: Text('${e['kode']} - ${e['nama']}'),
          );
        }).toList(),
        onChanged: (v) {
          setState(() => tujuan = v!);
          isiTujuanOtomatis();
          resetNomorSuratJalan();
        },
      );
    }

    Widget dropdownPic() {
      return DropdownButtonFormField<String>(
        value: pic,
        dropdownColor: const Color(0xff111827),
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration('PIC'),
        items: picList.map((e) {
          return DropdownMenuItem(value: e, child: Text(e));
        }).toList(),
        onChanged: (v) => setState(() => pic = v!),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        color: const Color(0xff0f172a),
        padding: const EdgeInsets.all(24),
        child: glassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Surat Jalan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
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
              const SizedBox(height: 16),
              input(keteranganController, 'Keterangan surat jalan'),
              const SizedBox(height: 22),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
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
              Align(
                alignment: Alignment.centerRight,
                child: glassActionButton(
                  title: loading ? 'Memproses...' : 'Generate Surat Jalan',
                  icon: Icons.local_shipping_rounded,
                  onTap: loading || items.isEmpty ? null : showFormEditSuratJalan,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }