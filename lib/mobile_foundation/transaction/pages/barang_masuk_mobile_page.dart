import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';

import 'package:ndp_inventory_app/services/api_service.dart';

class BarangMasukMobilePage extends StatefulWidget {
  const BarangMasukMobilePage({
    super.key,
  });

  @override
  State<BarangMasukMobilePage> createState() =>
      _BarangMasukMobilePageState();
}

class _BarangMasukMobilePageState
    extends State<BarangMasukMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff43d17b);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _barcodeController =
  TextEditingController();

  final TextEditingController _kodeInternalController =
  TextEditingController();

  final TextEditingController _kodeSupplierController =
  TextEditingController();

  final TextEditingController _namaController =
  TextEditingController();

  final TextEditingController _partNoController =
  TextEditingController();

  final TextEditingController _merkController =
  TextEditingController();

  final TextEditingController _lokasiController =
  TextEditingController();

  final TextEditingController _qtyController =
  TextEditingController(text: '1');

  final TextEditingController _hargaController =
  TextEditingController();

  final TextEditingController _minStockController =
  TextEditingController(text: '5');

  final TextEditingController _keteranganController =
  TextEditingController();

  List<dynamic> _suppliers = [];

  int? _selectedSupplierId;

  String _selectedPIC = 'Fiska';

  final List<String> _picOptions = const [
    'Fiska',
    'Uchi',
    'Jesslyne',
    'Ibu',
  ];

  bool _loadingSuppliers = true;
  bool _saving = false;

  String? _supplierError;

  @override
  void initState() {
    super.initState();

    _fetchSuppliers();

    _qtyController.addListener(
      _refreshTotal,
    );

    _hargaController.addListener(
      _refreshTotal,
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _kodeInternalController.dispose();
    _kodeSupplierController.dispose();
    _namaController.dispose();
    _partNoController.dispose();
    _merkController.dispose();
    _lokasiController.dispose();
    _qtyController.dispose();
    _hargaController.dispose();
    _minStockController.dispose();
    _keteranganController.dispose();

    super.dispose();
  }

  void _refreshTotal() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _fetchSuppliers() async {
    if (!mounted) return;

    setState(() {
      _loadingSuppliers = true;
      _supplierError = null;
    });

    try {
      final result =
      await ApiService.getSuppliers();

      if (!mounted) return;

      setState(() {
        _suppliers = result;
        _loadingSuppliers = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingSuppliers = false;
        _supplierError = error.toString();
      });
    }
  }

  void _generateBarcode() {
    final kodeInternal =
    _kodeInternalController.text.trim();

    final kodeSupplier =
    _kodeSupplierController.text.trim();

    final partNo =
    _partNoController.text.trim();

    if (kodeInternal.isEmpty ||
        kodeSupplier.isEmpty ||
        partNo.isEmpty) {
      _barcodeController.clear();

      if (mounted) {
        setState(() {});
      }

      return;
    }

    _barcodeController.text =
        '$kodeInternal-$kodeSupplier-$partNo'
            .toUpperCase();

    if (mounted) {
      setState(() {});
    }
  }

  int get _qty {
    return int.tryParse(
      _qtyController.text.trim(),
    ) ??
        0;
  }

  int get _hargaBeli {
    final clean =
    _hargaController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return int.tryParse(clean) ?? 0;
  }

  int get _totalHarga {
    return _qty * _hargaBeli;
  }

  String _formatRupiah(
      int value,
      ) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _formatRupiahInput(
      String value,
      ) {
    final angka =
    value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (angka.isEmpty) {
      return '';
    }

    return angka.replaceAllMapped(
      RegExp(
        r'(\d)(?=(\d{3})+(?!\d))',
      ),
          (match) =>
      '${match[1]}.',
    );
  }

  String _supplierName(
      dynamic supplier,
      ) {
    if (supplier == null) {
      return '-';
    }

    final value =
    supplier['nama_supplier'];

    if (value == null) {
      return '-';
    }

    final text =
    value.toString().trim();

    return text.isEmpty
        ? '-'
        : text;
  }

  int? _supplierId(
      dynamic supplier,
      ) {
    if (supplier == null) {
      return null;
    }

    final value =
    supplier['id'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
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

  String? _positiveNumberValidator(
      String? value,
      ) {
    final number =
    int.tryParse(
      value?.trim() ?? '',
    );

    if (number == null ||
        number <= 0) {
      return 'Harus lebih dari 0';
    }

    return null;
  }

  String? _nonNegativeValidator(
      String? value,
      ) {
    final number =
    int.tryParse(
      value?.trim() ?? '',
    );

    if (number == null ||
        number < 0) {
      return 'Angka tidak valid';
    }

    return null;
  }

  Future<void> _save() async {
    if (_saving) return;

    FocusScope.of(context)
        .unfocus();

    final valid =
        _formKey.currentState
            ?.validate() ??
            false;

    if (!valid) return;

    if (_selectedSupplierId == null) {
      _showMessage(
        'Pilih supplier terlebih dahulu',
        error: true,
      );

      return;
    }

    if (_barcodeController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'Barcode belum terbentuk. Lengkapi kode internal, kode supplier, dan part number.',
        error: true,
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final result =
      await ApiService
          .simpanBarangMasuk(
        barcode:
        _barcodeController.text
            .trim(),
        supplierId:
        _selectedSupplierId!,
        kodeInternal:
        _kodeInternalController
            .text
            .trim(),
        kodeSupplier:
        _kodeSupplierController
            .text
            .trim(),
        namaBarang:
        _namaController.text
            .trim(),
        partNo:
        _partNoController.text
            .trim(),
        merk:
        _merkController.text
            .trim(),
        lokasi:
        _lokasiController.text
            .trim(),
        qty:
        _qty,
        minStock:
        int.tryParse(
          _minStockController
              .text
              .trim(),
        ) ??
            0,
        hargaBeli:
        _hargaBeli,
        pic:
        _selectedPIC,
        keterangan:
        _keteranganController
            .text
            .trim(),
      );

      if (!mounted) return;

      _showMessage(
        result['message']
            ?.toString() ??
            'Barang masuk berhasil disimpan',
      );

      _clearForm();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal menyimpan barang masuk: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _clearForm() {
    _barcodeController.clear();
    _kodeInternalController.clear();
    _kodeSupplierController.clear();
    _namaController.clear();
    _partNoController.clear();
    _merkController.clear();
    _lokasiController.clear();

    _qtyController.text = '1';
    _hargaController.clear();
    _minStockController.text = '5';

    _keteranganController.clear();

    setState(() {
      _selectedSupplierId = null;
      _selectedPIC = 'Fiska';
    });
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
            0xff202020,
          ),
          content: Text(
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
        return !_saving;
      },
      child: Scaffold(
        backgroundColor:
        background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
          background,
          foregroundColor:
          Colors.white,
          title: const Text(
            'Barang Masuk',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior
                .onDrag,
            padding:
            const EdgeInsets
                .fromLTRB(
              18,
              10,
              18,
              100,
            ),
            children: [
              _buildHeader(),

              const SizedBox(
                height: 16,
              ),

              _buildSupplierSection(),

              const SizedBox(
                height: 16,
              ),

              _buildIdentitySection(),

              const SizedBox(
                height: 16,
              ),

              _buildPartSection(),

              const SizedBox(
                height: 16,
              ),

              _buildStorageSection(),

              const SizedBox(
                height: 16,
              ),

              _buildPurchaseSection(),

              const SizedBox(
                height: 16,
              ),

              _buildNotesSection(),

              const SizedBox(
                height: 16,
              ),

              _buildBarcodePreview(),

              const SizedBox(
                height: 22,
              ),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),
      decoration:
      BoxDecoration(
        color:
        greenAccent.withOpacity(
          0.08,
        ),
        borderRadius:
        BorderRadius.circular(
          21,
        ),
        border:
        Border.all(
          color:
          greenAccent.withOpacity(
            0.20,
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.add_box_outlined,
            color:
            greenAccent,
            size: 30,
          ),

          SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Input Barang Masuk',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  'Barang baru akan dibuat otomatis, sedangkan barang lama akan menambah stok yang sudah ada.',
                  style: TextStyle(
                    color:
                    Colors.white38,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection() {
    return _section(
      title:
      'Supplier',
      icon:
      Icons.local_shipping_outlined,
      child:
      _buildSupplierDropdown(),
    );
  }

  Widget _buildIdentitySection() {
    return _section(
      title:
      'Identitas Barang',
      icon:
      Icons.badge_outlined,
      child: Column(
        children: [
          _field(
            controller:
            _barcodeController,
            label:
            'Barcode',
            hint:
            'Dibuat otomatis',
            icon:
            Icons.qr_code_2_rounded,
            readOnly: true,
          ),

          _field(
            controller:
            _kodeInternalController,
            label:
            'Kode Internal',
            hint:
            'Masukkan kode internal',
            icon:
            Icons.tag_rounded,
            validator:
            _requiredValidator,
            textCapitalization:
            TextCapitalization
                .characters,
            onChanged: (_) {
              _generateBarcode();
            },
          ),

          _field(
            controller:
            _kodeSupplierController,
            label:
            'Kode Supplier',
            hint:
            'Masukkan kode supplier',
            icon:
            Icons.sell_outlined,
            validator:
            _requiredValidator,
            textCapitalization:
            TextCapitalization
                .characters,
            onChanged: (_) {
              _generateBarcode();
            },
          ),

          _field(
            controller:
            _namaController,
            label:
            'Nama Barang',
            hint:
            'Masukkan nama barang',
            icon:
            Icons.inventory_2_outlined,
            validator:
            _requiredValidator,
          ),
        ],
      ),
    );
  }

  Widget _buildPartSection() {
    return _section(
      title:
      'Informasi Part',
      icon:
      Icons.settings_outlined,
      child: Column(
        children: [
          _field(
            controller:
            _partNoController,
            label:
            'Part Number',
            hint:
            'Masukkan part number',
            icon:
            Icons.numbers_rounded,
            validator:
            _requiredValidator,
            textCapitalization:
            TextCapitalization
                .characters,
            onChanged: (_) {
              _generateBarcode();
            },
          ),

          _field(
            controller:
            _merkController,
            label:
            'Merk',
            hint:
            'Contoh: Denso, Bosch, Delphi',
            icon:
            Icons.factory_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection() {
    return _section(
      title:
      'Penyimpanan & PIC',
      icon:
      Icons.warehouse_outlined,
      child: Column(
        children: [
          _field(
            controller:
            _lokasiController,
            label:
            'Lokasi Rak',
            hint:
            'Contoh: Rak A-01',
            icon:
            Icons.location_on_outlined,
          ),

          _buildPicDropdown(),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection() {
    return _section(
      title:
      'Informasi Pembelian',
      icon:
      Icons.payments_outlined,
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  controller:
                  _qtyController,
                  label:
                  'Qty',
                  hint:
                  '1',
                  icon:
                  Icons.numbers_rounded,
                  keyboardType:
                  TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                  validator:
                  _positiveNumberValidator,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: _field(
                  controller:
                  _minStockController,
                  label:
                  'Min Stock',
                  hint:
                  '5',
                  icon:
                  Icons.warning_amber_rounded,
                  keyboardType:
                  TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                  validator:
                  _nonNegativeValidator,
                ),
              ),
            ],
          ),

          _field(
            controller:
            _hargaController,
            label:
            'Harga Beli',
            hint:
            'Contoh: 500.000',
            icon:
            Icons.payments_rounded,
            keyboardType:
            TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            onChanged:
            _handleHargaChanged,
          ),

          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.all(
              15,
            ),
            decoration:
            BoxDecoration(
              color:
              accent.withOpacity(
                0.08,
              ),
              borderRadius:
              BorderRadius.circular(
                16,
              ),
              border:
              Border.all(
                color:
                accent.withOpacity(
                  0.18,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_outlined,
                  color:
                  accent,
                  size: 23,
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'Estimasi Total',
                        style: TextStyle(
                          color:
                          Colors.white38,
                          fontSize: 9,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        _formatRupiah(
                          _totalHarga,
                        ),
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize: 16,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleHargaChanged(
      String value,
      ) {
    final formatted =
    _formatRupiahInput(
      value,
    );

    if (_hargaController.text ==
        formatted) {
      return;
    }

    _hargaController.value =
        TextEditingValue(
          text: formatted,
          selection:
          TextSelection.collapsed(
            offset:
            formatted.length,
          ),
        );
  }

  Widget _buildNotesSection() {
    return _section(
      title:
      'Keterangan',
      icon:
      Icons.notes_rounded,
      child: _field(
        controller:
        _keteranganController,
        label:
        'Catatan',
        hint:
        'Tambahkan keterangan jika diperlukan',
        icon:
        Icons.description_outlined,
        maxLines:
        3,
      ),
    );
  }

  Widget _buildBarcodePreview() {
    final barcodeData =
    _barcodeController.text
        .replaceAll(
      ' ',
      '',
    )
        .replaceAll(
      '-',
      '',
    )
        .toUpperCase();

    return _section(
      title:
      'Preview Barcode',
      icon:
      Icons.qr_code_2_rounded,
      child: Column(
        children: [
          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.all(
              18,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.white,
              borderRadius:
              BorderRadius.circular(
                17,
              ),
            ),
            child:
            BarcodeWidget(
              barcode:
              Barcode.code128(),
              data:
              barcodeData.isEmpty
                  ? 'TEST123'
                  : barcodeData,
              height:
              90,
              color:
              Colors.black,
              drawText:
              true,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            _barcodeController.text
                .trim()
                .isEmpty
                ? 'Barcode akan dibuat otomatis'
                : _barcodeController
                .text,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              Colors.white54,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.all(
              13,
            ),
            decoration:
            BoxDecoration(
              color:
              accent.withOpacity(
                0.07,
              ),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
              border:
              Border.all(
                color:
                accent.withOpacity(
                  0.16,
                ),
              ),
            ),
            child:
            const Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color:
                  accent,
                  size: 18,
                ),

                SizedBox(
                  width: 9,
                ),

                Expanded(
                  child: Text(
                    'Barcode dibuat dari Kode Internal + Kode Supplier + Part Number.',
                    style:
                    TextStyle(
                      color:
                      Colors.white38,
                      fontSize: 9,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    if (_loadingSuppliers) {
      return Container(
        height: 56,
        decoration: _fieldBox(),
        child: const Center(
          child:
          CircularProgressIndicator(
            color: accent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_supplierError != null) {
      return Container(
        padding:
        const EdgeInsets.all(13),
        decoration: _fieldBox(),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'Gagal mengambil supplier',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ),
            TextButton(
              onPressed:
              _fetchSuppliers,
              child:
              const Text(
                'Coba Lagi',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 56,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: _fieldBox(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value:
          _selectedSupplierId,
          isExpanded: true,
          dropdownColor:
          const Color(
            0xff151515,
          ),
          icon:
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: accent,
          ),
          hint:
          const Row(
            children: [
              Icon(
                Icons
                    .local_shipping_outlined,
                color: accent,
                size: 20,
              ),
              SizedBox(width: 11),
              Text(
                'Pilih Supplier',
                style: TextStyle(
                  color:
                  Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          style:
          const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),

          items: _suppliers
              .where((supplier) {
            return _supplierId(
              supplier,
            ) !=
                null;
          })
              .map<
              DropdownMenuItem<int>>(
                (supplier) {
              final id =
              _supplierId(
                supplier,
              )!;

              return DropdownMenuItem<
                  int>(
                value: id,
                child: Text(
                  _supplierName(
                    supplier,
                  ),
                  overflow:
                  TextOverflow
                      .ellipsis,
                ),
              );
            },
          ).toList(),

          onChanged:
          _saving
              ? null
              : (value) {
            setState(() {
              _selectedSupplierId =
                  value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPicDropdown() {
    return Container(
      height:
      56,
      padding:
      const EdgeInsets
          .symmetric(
        horizontal:
        15,
      ),
      decoration:
      _fieldBox(),
      child:
      DropdownButtonHideUnderline(
        child:
        DropdownButton<String>(
          value:
          _selectedPIC,
          isExpanded:
          true,
          dropdownColor:
          const Color(
            0xff151515,
          ),
          icon:
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color:
            accent,
          ),
          style:
          const TextStyle(
            color:
            Colors.white,
            fontSize:
            12,
          ),
          items:
          _picOptions.map(
                (pic) {
              return DropdownMenuItem<
                  String>(
                value:
                pic,
                child:
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      color:
                      accent,
                      size:
                      18,
                    ),

                    const SizedBox(
                      width:
                      10,
                    ),

                    Text(
                      pic,
                    ),
                  ],
                ),
              );
            },
          ).toList(),
          onChanged:
          _saving
              ? null
              : (value) {
            if (value ==
                null) {
              return;
            }

            setState(() {
              _selectedPIC =
                  value;
            });
          },
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        17,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white.withOpacity(
          0.035,
        ),
        borderRadius:
        BorderRadius.circular(
          22,
        ),
        border:
        Border.all(
          color:
          Colors.white.withOpacity(
            0.08,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:
                42,
                height:
                42,
                decoration:
                BoxDecoration(
                  color:
                  accent.withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
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
                11,
              ),

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
            ],
          ),

          const SizedBox(
            height:
            16,
          ),

          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    TextCapitalization textCapitalization =
        TextCapitalization.sentences,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
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
        readOnly:
        readOnly,
        enabled:
        !_saving,
        maxLines:
        maxLines,
        keyboardType:
        keyboardType,
        textCapitalization:
        textCapitalization,
        inputFormatters:
        inputFormatters,
        validator:
        validator,
        onChanged:
        onChanged,
        style:
        TextStyle(
          color:
          readOnly
              ? Colors.white54
              : Colors.white,
          fontSize:
          13,
        ),
        decoration:
        InputDecoration(
          labelText:
          label,
          hintText:
          hint,
          labelStyle:
          const TextStyle(
            color:
            Colors.white38,
            fontSize:
            11,
          ),
          hintStyle:
          const TextStyle(
            color:
            Colors.white24,
            fontSize:
            10,
          ),
          prefixIcon:
          Icon(
            icon,
            color:
            accent,
            size:
            20,
          ),
          filled:
          true,
          fillColor:
          Colors.white.withOpacity(
            0.04,
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
              Colors.white.withOpacity(
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
              Colors.white.withOpacity(
                0.05,
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
            const BorderSide(
              color:
              accent,
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
        ),
      ),
    );
  }

  BoxDecoration _fieldBox() {
    return BoxDecoration(
      color:
      Colors.white.withOpacity(
        0.04,
      ),
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      border:
      Border.all(
        color:
        Colors.white.withOpacity(
          0.08,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width:
      double.infinity,
      child:
      ElevatedButton.icon(
        onPressed:
        _saving
            ? null
            : _save,
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          greenAccent,
          foregroundColor:
          Colors.black,
          disabledBackgroundColor:
          greenAccent.withOpacity(
            0.35,
          ),
          minimumSize:
          const Size.fromHeight(
            56,
          ),
          elevation:
          0,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),
        ),
        icon:
        _saving
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
          Icons.save_rounded,
        ),
        label:
        Text(
          _saving
              ? 'Menyimpan...'
              : 'Simpan Barang Masuk',
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }
}