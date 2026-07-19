import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ndp_inventory_app/services/api_service.dart';

class SuratJalanFormMobilePage extends StatefulWidget {
  const SuratJalanFormMobilePage({
    super.key,
  });

  @override
  State<SuratJalanFormMobilePage> createState() =>
      _SuratJalanFormMobilePageState();
}

class _SuratJalanFormMobilePageState
    extends State<SuratJalanFormMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _barcodeController =
  TextEditingController();

  final TextEditingController _keteranganController =
  TextEditingController();

  final TextEditingController _nomorSjController =
  TextEditingController();

  final TextEditingController _osNoController =
  TextEditingController();

  final TextEditingController _kodeController =
  TextEditingController(
    text: '-',
  );

  final TextEditingController _resiController =
  TextEditingController();

  final TextEditingController _beratController =
  TextEditingController(
    text: '10 Kg',
  );

  final TextEditingController _kepadaController =
  TextEditingController();

  final TextEditingController _alamatController =
  TextEditingController();

  final TextEditingController _upController =
  TextEditingController();

  final TextEditingController _hpController =
  TextEditingController();

  final FocusNode _barcodeFocus =
  FocusNode();

  final List<Map<String, dynamic>> _items = [];

  List<dynamic> _serviceCustomers = [];

  int? _selectedServiceCustomerId;

  String _tujuan = 'BJM';
  String _pic = 'Fiska';

  bool _loading = false;
  bool _loadingCustomer = false;

  final List<Map<String, String>> _tujuanList = const [
    {
      'kode': 'BJM',
      'nama': 'Banjarmasin Pump',
    },
    {
      'kode': 'RXD',
      'nama': 'Rex Diesel',
    },
    {
      'kode': 'WSP',
      'nama': 'Waroeng Sparepart',
    },
    {
      'kode': 'INT',
      'nama': 'Intern / Customer',
    },
  ];

  final List<String> _picList = const [
    'Jesslyne',
    'Jennifer',
    'Fiska',
    'Uchi',
    'Husna',
  ];

  final List<String> _satuanList = const [
    'Ea',
    'Unit',
    'Set',
    'Roll',
    'Gulung',
    'Pcs',
    'Box',
    'Kg',
  ];

  final Map<String, Map<String, String>> _tujuanDetail = const {
    'BJM': {
      'kepada': 'BANJARMASIN PUMP',
      'alamat':
      'Jl. Ahmad Yani Km. 5.7 No.432 Banjarmasin, Kalsel',
      'up': 'Ibu Endang',
      'hp': '0812 8186 4902',
    },
    'RXD': {
      'kepada': 'REX DIESEL',
      'alamat':
      'JL. Laode Hadi No. 88H, Banggoeya, Wua-Wua, Sultra',
      'up': 'Bp Chairul Kasim',
      'hp': '0812-8888-343',
    },
  };

  @override
  void initState() {
    super.initState();

    _fillTujuanOtomatis();
    _resetNomorSuratJalan();
    _fetchServiceCustomers();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _keteranganController.dispose();
    _nomorSjController.dispose();
    _osNoController.dispose();
    _kodeController.dispose();
    _resiController.dispose();
    _beratController.dispose();
    _kepadaController.dispose();
    _alamatController.dispose();
    _upController.dispose();
    _hpController.dispose();
    _barcodeFocus.dispose();

    super.dispose();
  }

  void _fillTujuanOtomatis() {
    final data =
    _tujuanDetail[_tujuan];

    if (data != null) {
      _kepadaController.text =
          data['kepada'] ?? '';

      _alamatController.text =
          data['alamat'] ?? '';

      _upController.text =
          data['up'] ?? '';

      _hpController.text =
          data['hp'] ?? '';
    } else {
      _kepadaController.clear();
      _alamatController.clear();
      _upController.clear();
      _hpController.clear();
    }
  }

  void _resetNomorSuratJalan() {
    final now =
    DateTime.now();

    final year =
        now.year;

    final month =
    now.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    final day =
    now.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    _nomorSjController.text =
    'SJ-$_tujuan-$year$month$day';
  }

  Future<void> _fetchServiceCustomers() async {
    if (!mounted) return;

    setState(() {
      _loadingCustomer = true;
    });

    try {
      final result =
      await ApiService
          .getServiceCustomers();

      if (!mounted) return;

      setState(() {
        _serviceCustomers =
            result;

        _loadingCustomer =
        false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingCustomer =
        false;
      });

      _showMessage(
        'Gagal mengambil Service Customer: $error',
        error: true,
      );
    }
  }

  Future<void> _scanBarang() async {
    if (_loading) return;

    FocusScope.of(context)
        .unfocus();

    final barcode =
    _barcodeController.text
        .trim();

    if (barcode.isEmpty) {
      _showMessage(
        'Masukkan atau scan barcode terlebih dahulu',
        error: true,
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final product =
      await ApiService
          .scanBarangSuratJalan(
        barcode,
      );

      if (!mounted) return;

      if (product == null) {
        _showMessage(
          'Barang tidak ditemukan',
          error: true,
        );

        return;
      }

      await _showBarangDialog(
        product,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal scan barang: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _showBarangDialog(
      Map<String, dynamic> product,
      ) async {
    final qtyController =
    TextEditingController(
      text: '1',
    );

    final ketController =
    TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      barrierColor:
      Colors.black.withOpacity(
        0.65,
      ),
      builder: (
          bottomSheetContext,
          ) {
        return Padding(
          padding:
          EdgeInsets.only(
            bottom:
            MediaQuery.of(
              bottomSheetContext,
            )
                .viewInsets
                .bottom,
          ),
          child: ClipRRect(
            borderRadius:
            const BorderRadius.vertical(
              top:
              Radius.circular(
                30,
              ),
            ),
            child: BackdropFilter(
              filter:
              ImageFilter.blur(
                sigmaX: 22,
                sigmaY: 22,
              ),
              child: Container(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  26,
                ),
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    colors: [
                      const Color(
                        0xff181818,
                      ).withOpacity(
                        0.98,
                      ),
                      const Color(
                        0xff0b0b0b,
                      ).withOpacity(
                        0.98,
                      ),
                    ],
                    begin:
                    Alignment.topLeft,
                    end:
                    Alignment.bottomRight,
                  ),
                  borderRadius:
                  const BorderRadius.vertical(
                    top:
                    Radius.circular(
                      30,
                    ),
                  ),
                  border:
                  Border(
                    top:
                    BorderSide(
                      color:
                      Colors.white
                          .withOpacity(
                        0.11,
                      ),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child:
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.white24,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration:
                              BoxDecoration(
                                color:
                                accent
                                    .withOpacity(
                                  0.12,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                                border:
                                Border.all(
                                  color:
                                  accent
                                      .withOpacity(
                                    0.22,
                                  ),
                                ),
                              ),
                              child:
                              const Icon(
                                Icons.inventory_2_outlined,
                                color:
                                accent,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child:
                              Text(
                                _text(
                                  product[
                                  'nama_barang'],
                                ),
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize:
                                  18,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Container(
                          padding:
                          const EdgeInsets.all(
                            15,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white
                                .withOpacity(
                              0.035,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              17,
                            ),
                            border:
                            Border.all(
                              color:
                              Colors.white
                                  .withOpacity(
                                0.07,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _infoRow(
                                'Kode',
                                _text(
                                  product[
                                  'kode_internal'],
                                ),
                              ),
                              _infoRow(
                                'Part No',
                                _text(
                                  product[
                                  'part_no'],
                                ),
                              ),
                              _infoRow(
                                'Merk',
                                _text(
                                  product[
                                  'merk'],
                                ),
                              ),
                              _infoRow(
                                'Stok',
                                '${_toInt(product['qty'])} pcs',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 17,
                        ),

                        _sheetField(
                          controller:
                          qtyController,
                          label:
                          'Qty Keluar',
                          keyboardType:
                          TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly,
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        _sheetField(
                          controller:
                          ketController,
                          label:
                          'Keterangan Item',
                          maxLines: 2,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          child:
                          ElevatedButton.icon(
                            onPressed: () {
                              final qty =
                                  int.tryParse(
                                    qtyController
                                        .text,
                                  ) ??
                                      0;

                              final stock =
                              _toInt(
                                product[
                                'qty'],
                              );

                              if (qty <= 0) {
                                _showMessage(
                                  'Qty tidak valid',
                                  error: true,
                                );

                                return;
                              }

                              if (qty > stock) {
                                _showMessage(
                                  'Qty melebihi stok',
                                  error: true,
                                );

                                return;
                              }

                              setState(() {
                                _items.add({
                                  'item_type':
                                  'barcode',
                                  'product_id':
                                  product['id'],
                                  'nama_barang':
                                  product['nama_barang'] ??
                                      '',
                                  'kode_internal':
                                  product['kode_internal'] ??
                                      '',
                                  'part_no':
                                  product['part_no'] ??
                                      '',
                                  'merk':
                                  product['merk'] ??
                                      '',
                                  'qty':
                                  qty,
                                  'satuan':
                                  'Ea',
                                  'deskripsi':
                                  '',
                                  'pic':
                                  _pic,
                                  'keterangan':
                                  ketController
                                      .text
                                      .trim(),
                                });

                                _barcodeController
                                    .clear();
                              });

                              Navigator.pop(
                                bottomSheetContext,
                              );

                              Future.delayed(
                                const Duration(
                                  milliseconds:
                                  250,
                                ),
                                    () {
                                  if (!mounted) {
                                    return;
                                  }

                                  _barcodeFocus
                                      .requestFocus();
                                },
                              );
                            },
                            style:
                            ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              accent,
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              minimumSize:
                              const Size.fromHeight(
                                54,
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),
                            icon:
                            const Icon(
                              Icons.add_rounded,
                            ),
                            label:
                            const Text(
                              'Tambah Barang',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
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
    );

    qtyController.dispose();
    ketController.dispose();
  }

  Future<void> _showManualItemDialog() async {
    final qtyController =
    TextEditingController(
      text: '1',
    );

    final namaController =
    TextEditingController();

    final deskripsiController =
    TextEditingController();

    String satuan = 'Ea';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      barrierColor:
      Colors.black.withOpacity(
        0.65,
      ),
      builder: (
          bottomSheetContext,
          ) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            return Padding(
              padding:
              EdgeInsets.only(
                bottom:
                MediaQuery.of(
                  context,
                )
                    .viewInsets
                    .bottom,
              ),
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                  top:
                  Radius.circular(
                    30,
                  ),
                ),
                child:
                BackdropFilter(
                  filter:
                  ImageFilter.blur(
                    sigmaX: 22,
                    sigmaY: 22,
                  ),
                  child: Container(
                    padding:
                    const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      26,
                    ),
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        colors: [
                          const Color(
                            0xff181818,
                          ).withOpacity(
                            0.98,
                          ),
                          const Color(
                            0xff0b0b0b,
                          ).withOpacity(
                            0.98,
                          ),
                        ],
                        begin:
                        Alignment.topLeft,
                        end:
                        Alignment.bottomRight,
                      ),
                      borderRadius:
                      const BorderRadius.vertical(
                        top:
                        Radius.circular(
                          30,
                        ),
                      ),
                      border:
                      Border(
                        top:
                        BorderSide(
                          color:
                          Colors.white
                              .withOpacity(
                            0.11,
                          ),
                        ),
                      ),
                    ),
                    child:
                    SafeArea(
                      top: false,
                      child:
                      SingleChildScrollView(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Center(
                              child:
                              Container(
                                width: 44,
                                height: 4,
                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.white24,
                                  borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    accent.withOpacity(
                                      0.12,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      16,
                                    ),
                                    border:
                                    Border.all(
                                      color:
                                      accent.withOpacity(
                                        0.22,
                                      ),
                                    ),
                                  ),
                                  child:
                                  const Icon(
                                    Icons.edit_note_rounded,
                                    color:
                                    accent,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                const Expanded(
                                  child:
                                  Text(
                                    'Tambah Item Manual',
                                    style:
                                    TextStyle(
                                      color:
                                      Colors.white,
                                      fontSize:
                                      18,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            _sheetField(
                              controller:
                              qtyController,
                              label:
                              'Qty',
                              keyboardType:
                              TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            DropdownButtonFormField<String>(
                              value:
                              satuan,
                              dropdownColor:
                              const Color(
                                0xff151515,
                              ),
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                              ),
                              decoration:
                              _inputDecoration(
                                'Satuan',
                              ),
                              items:
                              _satuanList.map(
                                    (item) {
                                  return DropdownMenuItem<String>(
                                    value:
                                    item,
                                    child:
                                    Text(
                                      item,
                                    ),
                                  );
                                },
                              ).toList(),
                              onChanged:
                                  (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setModalState(
                                      () {
                                    satuan =
                                        value;
                                  },
                                );
                              },
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _sheetField(
                              controller:
                              namaController,
                              label:
                              'Nama / Judul Barang',
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _sheetField(
                              controller:
                              deskripsiController,
                              label:
                              'Deskripsi / Serial Number',
                              maxLines: 4,
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              width:
                              double.infinity,
                              child:
                              ElevatedButton.icon(
                                onPressed:
                                    () {
                                  final qty =
                                      int.tryParse(
                                        qtyController
                                            .text,
                                      ) ??
                                          0;

                                  final nama =
                                  namaController
                                      .text
                                      .trim();

                                  if (qty <=
                                      0) {
                                    _showMessage(
                                      'Qty tidak valid',
                                      error:
                                      true,
                                    );

                                    return;
                                  }

                                  if (nama
                                      .isEmpty) {
                                    _showMessage(
                                      'Nama barang wajib diisi',
                                      error:
                                      true,
                                    );

                                    return;
                                  }

                                  setState(() {
                                    _items.add({
                                      'item_type':
                                      'manual',
                                      'product_id':
                                      null,
                                      'nama_barang':
                                      nama,
                                      'kode_internal':
                                      '',
                                      'part_no':
                                      '',
                                      'merk':
                                      '',
                                      'qty':
                                      qty,
                                      'satuan':
                                      satuan,
                                      'deskripsi':
                                      deskripsiController
                                          .text
                                          .trim(),
                                      'pic':
                                      _pic,
                                      'keterangan':
                                      deskripsiController
                                          .text
                                          .trim(),
                                    });
                                  });

                                  Navigator.pop(
                                    bottomSheetContext,
                                  );
                                },
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  accent,
                                  foregroundColor:
                                  Colors.white,
                                  elevation:
                                  0,
                                  minimumSize:
                                  const Size.fromHeight(
                                    54,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      18,
                                    ),
                                  ),
                                ),
                                icon:
                                const Icon(
                                  Icons.add_rounded,
                                ),
                                label:
                                const Text(
                                  'Tambah Item',
                                  style:
                                  TextStyle(
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
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
        );
      },
    );

    qtyController.dispose();
    namaController.dispose();
    deskripsiController.dispose();
  }

  Future<void> _save({
    required bool approve,
  }) async {
    if (_loading) return;

    FocusScope.of(context)
        .unfocus();

    if (_items.isEmpty) {
      _showMessage(
        'Belum ada item di Surat Jalan',
        error: true,
      );

      return;
    }

    final valid =
        _formKey.currentState
            ?.validate() ??
            false;

    if (!valid) return;

    setState(() {
      _loading = true;
    });

    try {
      final transactionType =
      _tujuan == 'INT'
          ? 'INTERNAL'
          : _tujuan == 'WSP'
          ? 'WAROENG'
          : 'CABANG';

      final status =
      approve
          ? 'Approved'
          : 'Pending';

      final result =
      await ApiService
          .createSuratJalan(
        tujuan:
        _tujuan,
        transactionType:
        transactionType,
        status:
        status,
        serviceCustomerId:
        _selectedServiceCustomerId,
        pic:
        _pic,
        keterangan:
        _keteranganController
            .text
            .trim(),
        nomorSurat:
        _nomorSjController
            .text
            .trim(),
        osNo:
        _osNoController
            .text
            .trim(),
        kode:
        _kodeController
            .text
            .trim(),
        resiNo:
        _resiController
            .text
            .trim(),
        berat:
        _beratController
            .text
            .trim(),
        kepada:
        _kepadaController
            .text
            .trim(),
        alamat:
        _alamatController
            .text
            .trim(),
        up:
        _upController
            .text
            .trim(),
        hp:
        _hpController
            .text
            .trim(),
        items:
        _items,
      );

      if (!mounted) return;

      _showMessage(
        result['message']
            ?.toString() ??
            'Surat Jalan berhasil dibuat',
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal membuat Surat Jalan: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _text(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final text =
    value.toString().trim();

    if (text.toLowerCase() ==
        'null') {
      return '';
    }

    return text;
  }

  int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String? _requiredValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    return null;
  }

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          error
              ? Colors.redAccent
              : const Color(
            0xff222222,
          ),
          content:
          Text(
            message,
          ),
        ),
      );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return WillPopScope(
      onWillPop: () async {
        return !_loading;
      },
      child: Scaffold(
        backgroundColor:
        background,
        body: Stack(
          children: [
            Positioned(
              top: 60,
              right: -140,
              child:
              _buildGlow(
                color:
                accent,
                size:
                320,
              ),
            ),

            Positioned(
              bottom: 80,
              left: -160,
              child:
              _buildGlow(
                color:
                const Color(
                  0xff00bcd4,
                ),
                size:
                320,
              ),
            ),

            SafeArea(
              child:
              Form(
                key:
                _formKey,
                child:
                CustomScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
                  physics:
                  const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        22,
                        16,
                        22,
                        110,
                      ),
                      sliver:
                      SliverList(
                        delegate:
                        SliverChildListDelegate(
                          [
                            _buildPageHeader(),

                            const SizedBox(
                              height:
                              20,
                            ),

                            _buildHeader(),

                            const SizedBox(
                              height:
                              16,
                            ),

                            _buildBasicSection(),

                            const SizedBox(
                              height:
                              16,
                            ),

                            if (_tujuan ==
                                'INT') ...[
                              _buildServiceCustomerSection(),

                              const SizedBox(
                                height:
                                16,
                              ),
                            ],

                            _buildScanSection(),

                            const SizedBox(
                              height:
                              16,
                            ),

                            _buildItemsSection(),

                            const SizedBox(
                              height:
                              16,
                            ),

                            _buildDocumentSection(),

                            const SizedBox(
                              height:
                              16,
                            ),

                            _buildDestinationSection(),

                            const SizedBox(
                              height:
                              16,
                            ),

                            _buildNotesSection(),

                            const SizedBox(
                              height:
                              24,
                            ),

                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child:
                LinearProgressIndicator(
                  color:
                  accent,
                  backgroundColor:
                  Colors.transparent,
                  minHeight:
                  2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow({
    required Color color,
    required double size,
  }) {
    return IgnorePointer(
      child: Container(
        width:
        size,
        height:
        size,
        decoration:
        BoxDecoration(
          shape:
          BoxShape.circle,
          color:
          color.withOpacity(
            0.015,
          ),
          boxShadow: [
            BoxShadow(
              color:
              color.withOpacity(
                0.08,
              ),
              blurRadius:
              130,
              spreadRadius:
              45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Material(
          color:
          Colors.transparent,
          child:
          InkWell(
            onTap:
            _loading
                ? null
                : () {
              Navigator.pop(
                context,
              );
            },
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            child:
            Container(
              width:
              54,
              height:
              54,
              decoration:
              BoxDecoration(
                color:
                Colors.white
                    .withOpacity(
                  0.04,
                ),
                borderRadius:
                BorderRadius.circular(
                  17,
                ),
                border:
                Border.all(
                  color:
                  Colors.white
                      .withOpacity(
                    0.09,
                  ),
                ),
              ),
              child:
              const Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                color:
                Colors.white70,
                size:
                20,
              ),
            ),
          ),
        ),

        const SizedBox(
          width:
          16,
        ),

        const Expanded(
          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Surat Jalan',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  25,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing:
                  -0.5,
                ),
              ),

              SizedBox(
                height:
                5,
              ),

              Text(
                'Lengkapi transaksi dan barang yang akan dikirim',
                style:
                TextStyle(
                  color:
                  Colors.white38,
                  fontSize:
                  10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        25,
      ),
      child:
      BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX:
          18,
          sigmaY:
          18,
        ),
        child:
        Container(
          padding:
          const EdgeInsets.all(
            19,
          ),
          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                accent.withOpacity(
                  0.13,
                ),
                Colors.white
                    .withOpacity(
                  0.045,
                ),
                Colors.white
                    .withOpacity(
                  0.02,
                ),
              ],
              begin:
              Alignment.topLeft,
              end:
              Alignment.bottomRight,
            ),
            borderRadius:
            BorderRadius.circular(
              25,
            ),
            border:
            Border.all(
              color:
              accent.withOpacity(
                0.20,
              ),
            ),
          ),
          child:
          Row(
            children: [
              Container(
                width:
                58,
                height:
                58,
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    colors: [
                      accent
                          .withOpacity(
                        0.22,
                      ),
                      accent
                          .withOpacity(
                        0.08,
                      ),
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                  border:
                  Border.all(
                    color:
                    accent.withOpacity(
                      0.28,
                    ),
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .local_shipping_outlined,
                  color:
                  accent,
                  size:
                  29,
                ),
              ),

              const SizedBox(
                width:
                14,
              ),

              const Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surat Jalan Baru',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        16,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(
                      height:
                      5,
                    ),
                    Text(
                      'Scan barang dari inventory atau tambahkan item manual.',
                      style:
                      TextStyle(
                        color:
                        Colors.white38,
                        fontSize:
                        10,
                        height:
                        1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicSection() {
    return _section(
      title:
      'Informasi Transaksi',
      icon:
      Icons.assignment_outlined,
      child:
      Column(
        children: [
          DropdownButtonFormField<
              String>(
            value:
            _tujuan,
            dropdownColor:
            const Color(
              0xff151515,
            ),
            style:
            const TextStyle(
              color:
              Colors.white,
            ),
            decoration:
            _inputDecoration(
              'Tujuan',
            ),
            items:
            _tujuanList.map(
                  (item) {
                return DropdownMenuItem<
                    String>(
                  value:
                  item['kode'],
                  child:
                  Text(
                    '${item['kode']} - ${item['nama']}',
                  ),
                );
              },
            ).toList(),
            onChanged:
            _loading
                ? null
                : (value) {
              if (value ==
                  null) {
                return;
              }

              setState(() {
                _tujuan =
                    value;
                _selectedServiceCustomerId =
                null;
              });

              _fillTujuanOtomatis();
              _resetNomorSuratJalan();
            },
          ),

          const SizedBox(
            height:
            13,
          ),

          DropdownButtonFormField<
              String>(
            value:
            _pic,
            dropdownColor:
            const Color(
              0xff151515,
            ),
            style:
            const TextStyle(
              color:
              Colors.white,
            ),
            decoration:
            _inputDecoration(
              'PIC',
            ),
            items:
            _picList.map(
                  (value) {
                return DropdownMenuItem<
                    String>(
                  value:
                  value,
                  child:
                  Text(
                    value,
                  ),
                );
              },
            ).toList(),
            onChanged:
            _loading
                ? null
                : (value) {
              if (value ==
                  null) {
                return;
              }

              setState(() {
                _pic =
                    value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCustomerSection() {
    return _section(
      title:
      'Service Customer',
      icon:
      Icons.support_agent_outlined,
      child:
      _loadingCustomer
          ? const Padding(
        padding:
        EdgeInsets.all(
          20,
        ),
        child:
        Center(
          child:
          CircularProgressIndicator(
            color:
            accent,
          ),
        ),
      )
          : DropdownButtonFormField<
          int>(
        value:
        _selectedServiceCustomerId,
        dropdownColor:
        const Color(
          0xff151515,
        ),
        style:
        const TextStyle(
          color:
          Colors.white,
        ),
        decoration:
        _inputDecoration(
          'Pilih Service Customer',
        ),
        items:
        _serviceCustomers
            .where(
              (item) =>
          _toInt(
            item[
            'id'],
          ) >
              0,
        )
            .map<
            DropdownMenuItem<
                int>>(
              (item) {
            final id =
            _toInt(
              item[
              'id'],
            );

            return DropdownMenuItem<
                int>(
              value:
              id,
              child:
              Text(
                '${_text(item['service_no'])} - ${_text(item['nama_customer'])}',
                overflow:
                TextOverflow
                    .ellipsis,
              ),
            );
          },
        ).toList(),
        onChanged:
        _loading
            ? null
            : (value) {
          setState(() {
            _selectedServiceCustomerId =
                value;

            final selected =
            _serviceCustomers
                .where(
                  (item) =>
              _toInt(
                item[
                'id'],
              ) ==
                  value,
            )
                .toList();

            if (selected
                .isNotEmpty) {
              final customer =
                  selected
                      .first;

              _kepadaController.text =
                  _text(
                    customer[
                    'nama_customer'],
                  );

              _upController.text =
                  _text(
                    customer[
                    'nama_customer'],
                  );

              _keteranganController.text =
              'Service: ${_text(customer['service_no'])}'
                  ' | ${_text(customer['jenis_barang'])}'
                  ' | ${_text(customer['part_no'])}';
            }
          });
        },
      ),
    );
  }

  Widget _buildScanSection() {
    return _section(
      title:
      'Tambah Barang',
      icon:
      Icons.qr_code_scanner_rounded,
      child:
      Column(
        children: [
          TextField(
            controller:
            _barcodeController,
            focusNode:
            _barcodeFocus,
            enabled:
            !_loading,
            onSubmitted:
                (_) =>
                _scanBarang(),
            style:
            const TextStyle(
              color:
              Colors.white,
            ),
            decoration:
            _inputDecoration(
              'Scan / Input Barcode',
            ).copyWith(
              prefixIcon:
              const Icon(
                Icons
                    .qr_code_scanner_rounded,
                color:
                accent,
              ),
            ),
          ),

          const SizedBox(
            height:
            13,
          ),

          Row(
            children: [
              Expanded(
                child:
                ElevatedButton.icon(
                  onPressed:
                  _loading
                      ? null
                      : _scanBarang,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    accent,
                    foregroundColor:
                    Colors.white,
                    elevation:
                    0,
                    minimumSize:
                    const Size.fromHeight(
                      51,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                    ),
                  ),
                  icon:
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                  ),
                  label:
                  const Text(
                    'Scan',
                  ),
                ),
              ),

              const SizedBox(
                width:
                10,
              ),

              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed:
                  _loading
                      ? null
                      : _showManualItemDialog,
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    Colors.white,
                    backgroundColor:
                    Colors.white.withOpacity(
                      0.025,
                    ),
                    minimumSize:
                    const Size.fromHeight(
                      51,
                    ),
                    side:
                    BorderSide(
                      color:
                      Colors.white.withOpacity(
                        0.11,
                      ),
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        17,
                      ),
                    ),
                  ),
                  icon:
                  const Icon(
                    Icons.edit_note_rounded,
                  ),
                  label:
                  const Text(
                    'Manual',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return _section(
      title:
      'Daftar Item (${_items.length})',
      icon:
      Icons.inventory_2_outlined,
      child:
      _items.isEmpty
          ? const Padding(
        padding:
        EdgeInsets.symmetric(
          vertical:
          32,
        ),
        child:
        Center(
          child:
          Text(
            'Belum ada barang di Surat Jalan',
            style:
            TextStyle(
              color:
              Colors.white38,
              fontSize:
              11,
            ),
          ),
        ),
      )
          : Column(
        children:
        List.generate(
          _items.length,
              (index) {
            final item =
            _items[index];

            return _buildItemCard(
              item,
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(
      Map<String, dynamic> item,
      int index,
      ) {
    final manual =
        item['item_type'] ==
            'manual';

    return Padding(
      padding:
      EdgeInsets.only(
        bottom:
        index <
            _items.length -
                1
            ? 10
            : 0,
      ),
      child:
      ClipRRect(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        child:
        BackdropFilter(
          filter:
          ImageFilter.blur(
            sigmaX:
            12,
            sigmaY:
            12,
          ),
          child:
          Container(
            padding:
            const EdgeInsets.all(
              13,
            ),
            decoration:
            BoxDecoration(
              gradient:
              LinearGradient(
                colors: [
                  accent.withOpacity(
                    0.055,
                  ),
                  Colors.white
                      .withOpacity(
                    0.035,
                  ),
                ],
              ),
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border:
              Border.all(
                color:
                Colors.white
                    .withOpacity(
                  0.08,
                ),
              ),
            ),
            child:
            Row(
              children: [
                Container(
                  width:
                  46,
                  height:
                  46,
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      colors: [
                        accent.withOpacity(
                          0.18,
                        ),
                        accent.withOpacity(
                          0.07,
                        ),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    border:
                    Border.all(
                      color:
                      accent.withOpacity(
                        0.18,
                      ),
                    ),
                  ),
                  child:
                  Icon(
                    manual
                        ? Icons
                        .edit_note_rounded
                        : Icons
                        .inventory_2_outlined,
                    color:
                    accent,
                    size:
                    22,
                  ),
                ),

                const SizedBox(
                  width:
                  12,
                ),

                Expanded(
                  child:
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        _text(
                          item[
                          'nama_barang'],
                        ),
                        maxLines:
                        1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize:
                          12,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height:
                        5,
                      ),

                      Text(
                        manual
                            ? '${_text(item['deskripsi'])} • ${item['qty']} ${item['satuan']}'
                            : '${_text(item['kode_internal'])} • ${_text(item['part_no'])} • ${item['qty']} pcs',
                        maxLines:
                        1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          color:
                          Colors.white30,
                          fontSize:
                          9,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration:
                  BoxDecoration(
                    color:
                    redAccent.withOpacity(
                      0.08,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child:
                  IconButton(
                    onPressed:
                    _loading
                        ? null
                        : () {
                      setState(() {
                        _items.removeAt(
                          index,
                        );
                      });
                    },
                    icon:
                    const Icon(
                      Icons.delete_outline_rounded,
                      color:
                      redAccent,
                      size:
                      20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection() {
    return _section(
      title:
      'Informasi Surat Jalan',
      icon:
      Icons.description_outlined,
      child:
      Column(
        children: [
          _field(
            controller:
            _nomorSjController,
            label:
            'Nomor Surat Jalan',
            validator:
            _requiredValidator,
          ),
          _field(
            controller:
            _osNoController,
            label:
            'OS No',
          ),
          _field(
            controller:
            _kodeController,
            label:
            'Kode',
          ),
          _field(
            controller:
            _resiController,
            label:
            'Resi No',
          ),
          _field(
            controller:
            _beratController,
            label:
            'Berat',
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationSection() {
    return _section(
      title:
      'Informasi Penerima',
      icon:
      Icons.location_on_outlined,
      child:
      Column(
        children: [
          _field(
            controller:
            _kepadaController,
            label:
            'Kepada Yth',
          ),
          _field(
            controller:
            _alamatController,
            label:
            'Alamat',
            maxLines:
            3,
          ),
          _field(
            controller:
            _upController,
            label:
            'UP',
          ),
          _field(
            controller:
            _hpController,
            label:
            'Nomor HP',
            keyboardType:
            TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _section(
      title:
      'Keterangan',
      icon:
      Icons.notes_rounded,
      child:
      _field(
        controller:
        _keteranganController,
        label:
        'Keterangan Surat Jalan',
        maxLines:
        3,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width:
          double.infinity,
          child:
          OutlinedButton.icon(
            onPressed:
            _loading
                ? null
                : () {
              _save(
                approve:
                false,
              );
            },
            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              accent,
              backgroundColor:
              accent.withOpacity(
                0.035,
              ),
              minimumSize:
              const Size.fromHeight(
                56,
              ),
              side:
              BorderSide(
                color:
                accent.withOpacity(
                  0.35,
                ),
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
            ),
            icon:
            const Icon(
              Icons.save_outlined,
            ),
            label:
            const Text(
              'Simpan Sebagai Pending',
              style:
              TextStyle(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(
          height:
          11,
        ),

        SizedBox(
          width:
          double.infinity,
          child:
          ElevatedButton.icon(
            onPressed:
            _loading
                ? null
                : () {
              _save(
                approve:
                true,
              );
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              greenAccent,
              foregroundColor:
              Colors.black,
              elevation:
              0,
              minimumSize:
              const Size.fromHeight(
                57,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
            ),
            icon:
            _loading
                ? const SizedBox(
              width:
              20,
              height:
              20,
              child:
              CircularProgressIndicator(
                color:
                Colors.black,
                strokeWidth:
                2,
              ),
            )
                : const Icon(
              Icons.check_circle_rounded,
            ),
            label:
            Text(
              _loading
                  ? 'Memproses...'
                  : 'Buat & Approve Surat Jalan',
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        24,
      ),
      child:
      BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX:
          16,
          sigmaY:
          16,
        ),
        child:
        Container(
          width:
          double.infinity,
          padding:
          const EdgeInsets.all(
            18,
          ),
          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                Colors.white
                    .withOpacity(
                  0.055,
                ),
                Colors.white
                    .withOpacity(
                  0.025,
                ),
              ],
              begin:
              Alignment.topLeft,
              end:
              Alignment.bottomRight,
            ),
            borderRadius:
            BorderRadius.circular(
              24,
            ),
            border:
            Border.all(
              color:
              Colors.white
                  .withOpacity(
                0.09,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black
                    .withOpacity(
                  0.20,
                ),
                blurRadius:
                25,
                offset:
                const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),
          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width:
                    44,
                    height:
                    44,
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        colors: [
                          accent.withOpacity(
                            0.17,
                          ),
                          accent.withOpacity(
                            0.07,
                          ),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      border:
                      Border.all(
                        color:
                        accent.withOpacity(
                          0.17,
                        ),
                      ),
                    ),
                    child:
                    Icon(
                      icon,
                      color:
                      accent,
                      size:
                      21,
                    ),
                  ),

                  const SizedBox(
                    width:
                    12,
                  ),

                  Expanded(
                    child:
                    Text(
                      title,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                18,
              ),

              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        13,
      ),
      child:
      TextFormField(
        controller:
        controller,
        maxLines:
        maxLines,
        keyboardType:
        keyboardType,
        validator:
        validator,
        enabled:
        !_loading,
        style:
        const TextStyle(
          color:
          Colors.white,
          fontSize:
          13,
        ),
        decoration:
        _inputDecoration(
          label,
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller:
      controller,
      maxLines:
      maxLines,
      keyboardType:
      keyboardType,
      inputFormatters:
      inputFormatters,
      style:
      const TextStyle(
        color:
        Colors.white,
      ),
      decoration:
      _inputDecoration(
        label,
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label,
      ) {
    return InputDecoration(
      labelText:
      label,
      labelStyle:
      const TextStyle(
        color:
        Colors.white38,
        fontSize:
        11,
      ),
      floatingLabelStyle:
      const TextStyle(
        color:
        accent,
        fontSize:
        11,
      ),
      filled:
      true,
      fillColor:
      Colors.black
          .withOpacity(
        0.16,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal:
        15,
        vertical:
        16,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide(
          color:
          Colors.white
              .withOpacity(
            0.08,
          ),
        ),
      ),
      disabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide(
          color:
          Colors.white
              .withOpacity(
            0.04,
          ),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        BorderSide(
          color:
          accent.withOpacity(
            0.70,
          ),
          width:
          1.2,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
        ),
      ),
    );
  }

  Widget _infoRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        8,
      ),
      child:
      Row(
        children: [
          SizedBox(
            width:
            85,
            child:
            Text(
              label,
              style:
              const TextStyle(
                color:
                Colors.white38,
                fontSize:
                11,
              ),
            ),
          ),

          Expanded(
            child:
            Text(
              value.isEmpty
                  ? '-'
                  : value,
              style:
              const TextStyle(
                color:
                Colors.white,
                fontSize:
                11,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}