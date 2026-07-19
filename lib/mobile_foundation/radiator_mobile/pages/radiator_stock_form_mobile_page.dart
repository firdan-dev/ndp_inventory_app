import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ndp_inventory_app/models/radiator_model.dart';
import 'package:ndp_inventory_app/services/radiator_api.dart';

class RadiatorStockFormMobilePage extends StatefulWidget {
  final bool isStockIn;

  const RadiatorStockFormMobilePage({
    super.key,
    required this.isStockIn,
  });

  @override
  State<RadiatorStockFormMobilePage> createState() =>
      _RadiatorStockFormMobilePageState();
}

class _RadiatorStockFormMobilePageState
    extends State<RadiatorStockFormMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _searchController =
  TextEditingController();

  final TextEditingController _qtyController =
  TextEditingController(text: '1');

  final TextEditingController _notesController =
  TextEditingController();

  final TextEditingController _suratJalanController =
  TextEditingController();

  List<Radiator> _radiators = [];
  List<Radiator> _filteredRadiators = [];

  Radiator? _selectedRadiator;

  bool _loading = true;
  bool _saving = false;

  String? _errorMessage;

  bool get _isStockIn => widget.isStockIn;

  Color get _actionColor {
    return _isStockIn ? greenAccent : redAccent;
  }

  String get _pageTitle {
    return _isStockIn
        ? 'Stock In Radiator'
        : 'Stock Out Radiator';
  }

  String get _buttonTitle {
    return _isStockIn
        ? 'Simpan Stock In'
        : 'Simpan Stock Out';
  }

  @override
  void initState() {
    super.initState();
    _loadRadiators();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    _suratJalanController.dispose();

    super.dispose();
  }

  Future<void> _loadRadiators() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result =
      await RadiatorApi.getRadiators();

      if (!mounted) return;

      setState(() {
        _radiators = result;
        _filteredRadiators = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _filterRadiators(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredRadiators =
        List<Radiator>.from(_radiators);
        return;
      }

      _filteredRadiators =
          _radiators.where((radiator) {
            final searchableText = [
              radiator.kodeRadiator,
              radiator.namaRadiator,
              radiator.barcode,
              radiator.ukuranText,
              radiator.modelSarang ?? '',
              radiator.lokasi ?? '',
            ].join(' ').toLowerCase();

            return searchableText.contains(query);
          }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterRadiators('');
  }

  void _selectRadiator(Radiator radiator) {
    setState(() {
      _selectedRadiator = radiator;
    });
  }

  void _removeSelectedRadiator() {
    if (_saving) return;

    setState(() {
      _selectedRadiator = null;
    });
  }

  String _transactionCode(
      Radiator radiator,
      ) {
    final barcode = radiator.barcode.trim();

    if (barcode.isNotEmpty &&
        barcode.toLowerCase() != 'null') {
      return barcode;
    }

    return radiator.kodeRadiator.trim();
  }

  String? _emptyToNull(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  Future<void> _submit() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    final valid =
        _formKey.currentState?.validate() ??
            false;

    if (!valid) return;

    final radiator = _selectedRadiator;

    if (radiator == null) {
      _showMessage(
        'Pilih radiator terlebih dahulu',
        error: true,
      );
      return;
    }

    final qty =
    int.tryParse(_qtyController.text.trim());

    if (qty == null || qty <= 0) {
      _showMessage(
        'Jumlah stok tidak valid',
        error: true,
      );
      return;
    }

    if (!_isStockIn && qty > radiator.stok) {
      _showMessage(
        'Stok tidak cukup. Stok tersedia '
            '${radiator.stok} pcs.',
        error: true,
      );
      return;
    }

    final transactionCode =
    _transactionCode(radiator);

    if (transactionCode.isEmpty) {
      _showMessage(
        'Barcode atau kode radiator kosong',
        error: true,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (_isStockIn) {
        await RadiatorApi.stockIn(
          barcode: transactionCode,
          qty: qty,
          notes: _emptyToNull(
            _notesController.text,
          ),
          noSuratJalan: _emptyToNull(
            _suratJalanController.text,
          ),
        );
      } else {
        await RadiatorApi.stockOut(
          barcode: transactionCode,
          qty: qty,
          notes: _emptyToNull(
            _notesController.text,
          ),
          noSuratJalan: _emptyToNull(
            _suratJalanController.text,
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        '${_isStockIn ? 'Stock in' : 'Stock out'} '
            'gagal: $error',
        error: true,
      );
    }
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? Colors.redAccent
              : const Color(0xff242424),
          content: Text(message),
        ),
      );
  }

  String _safeText(
      String? value, {
        String fallback = '-',
      }) {
    final text = value?.trim();

    if (text == null ||
        text.isEmpty ||
        text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  Color _stockColor(Radiator radiator) {
    if (radiator.stok <= 0) {
      return redAccent;
    }

    if (radiator.stok <= radiator.minStock) {
      return accent;
    }

    return greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_saving;
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _pageTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior
                .onDrag,
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              100,
            ),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildRadiatorSelector(),
              if (_selectedRadiator != null) ...[
                const SizedBox(height: 16),
                _buildSelectedRadiator(),
              ],
              const SizedBox(height: 16),
              _buildTransactionForm(),
              const SizedBox(height: 22),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _actionColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: _actionColor.withOpacity(0.21),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color:
              _actionColor.withOpacity(0.13),
              borderRadius:
              BorderRadius.circular(17),
            ),
            child: Icon(
              _isStockIn
                  ? Icons.login_rounded
                  : Icons.logout_rounded,
              color: _actionColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _isStockIn
                      ? 'Penambahan Stok'
                      : 'Pengeluaran Stok',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isStockIn
                      ? 'Catat radiator yang masuk ke gudang.'
                      : 'Catat radiator yang keluar dari gudang.',
                  style: const TextStyle(
                    color: Colors.white38,
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

  Widget _buildRadiatorSelector() {
    return _section(
      title: 'Pilih Radiator',
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterRadiators,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText:
              'Cari kode, nama, barcode atau ukuran...',
              hintStyle: const TextStyle(
                color: Colors.white30,
                fontSize: 10,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: accent,
                size: 21,
              ),
              suffixIcon:
              _searchController.text.isEmpty
                  ? null
                  : IconButton(
                onPressed: _clearSearch,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor:
              Colors.white.withOpacity(0.04),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(16),
                borderSide: BorderSide(
                  color:
                  Colors.white.withOpacity(
                    0.08,
                  ),
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          _buildRadiatorList(),
        ],
      ),
    );
  }

  Widget _buildRadiatorList() {
    if (_loading) {
      return const SizedBox(
        height: 145,
        child: Center(
          child: CircularProgressIndicator(
            color: accent,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 155,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 7),
              TextButton.icon(
                onPressed: _loadRadiators,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRadiators.isEmpty) {
      return const SizedBox(
        height: 130,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: Colors.white24,
                size: 34,
              ),
              SizedBox(height: 8),
              Text(
                'Radiator tidak ditemukan',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 285,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics:
        const BouncingScrollPhysics(),
        itemCount: _filteredRadiators.length,
        separatorBuilder: (_, __) {
          return Divider(
            height: 1,
            color:
            Colors.white.withOpacity(0.06),
          );
        },
        itemBuilder: (context, index) {
          final radiator =
          _filteredRadiators[index];

          final selected =
              radiator.id ==
                  _selectedRadiator?.id;

          final stockColor =
          _stockColor(radiator);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _selectRadiator(radiator),
              borderRadius:
              BorderRadius.circular(15),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withOpacity(
                          0.14,
                        )
                            : Colors.white
                            .withOpacity(0.04),
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color: selected
                              ? accent.withOpacity(
                            0.28,
                          )
                              : Colors.white
                              .withOpacity(
                            0.05,
                          ),
                        ),
                      ),
                      child: Icon(
                        selected
                            ? Icons
                            .check_circle_rounded
                            : Icons
                            .inventory_2_outlined,
                        color: selected
                            ? accent
                            : Colors.white30,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            radiator.kodeRadiator,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? accent
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            radiator.namaRadiator,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${radiator.ukuranText} • '
                                '${_safeText(radiator.lokasi)}',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              Colors.white24,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor
                            .withOpacity(0.11),
                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color: stockColor
                              .withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        '${radiator.stok} pcs',
                        style: TextStyle(
                          color: stockColor,
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedRadiator() {
    final radiator = _selectedRadiator!;
    final stockColor =
    _stockColor(radiator);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: accent.withOpacity(0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.13),
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: accent,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  radiator.kodeRadiator,
                  style: const TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  radiator.namaRadiator,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stok saat ini: '
                      '${radiator.stok} pcs',
                  style: TextStyle(
                    color: stockColor,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Barcode: ${_safeText(radiator.barcode)}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
            _removeSelectedRadiator,
            tooltip: 'Batalkan pilihan',
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return _section(
      title: 'Detail Transaksi',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _field(
            controller: _qtyController,
            label: 'Jumlah',
            hint: 'Masukkan jumlah radiator',
            icon: Icons.numbers_rounded,
            keyboardType:
            TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            validator: (value) {
              final qty = int.tryParse(
                value?.trim() ?? '',
              );

              if (qty == null || qty <= 0) {
                return 'Jumlah harus lebih dari 0';
              }

              if (!_isStockIn &&
                  _selectedRadiator != null &&
                  qty >
                      _selectedRadiator!.stok) {
                return 'Melebihi stok tersedia';
              }

              return null;
            },
          ),
          _field(
            controller:
            _suratJalanController,
            label: 'Nomor Surat Jalan',
            hint:
            'Opsional, contoh: SJ-001',
            icon:
            Icons.description_outlined,
            textCapitalization:
            TextCapitalization.characters,
          ),
          _field(
            controller: _notesController,
            label: 'Catatan',
            hint:
            'Tambahkan keterangan transaksi',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
    TextInputType keyboardType =
        TextInputType.text,
    TextCapitalization textCapitalization =
        TextCapitalization.sentences,
    List<TextInputFormatter>?
    inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization:
        textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        enabled: !_saving,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
          hintStyle: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
          ),
          prefixIcon: Icon(
            icon,
            color: accent,
            size: 20,
          ),
          filled: true,
          fillColor:
          Colors.white.withOpacity(0.04),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: BorderSide(
              color:
              Colors.white.withOpacity(0.08),
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: accent,
            ),
          ),
          errorBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          disabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: BorderSide(
              color:
              Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _actionColor,
          foregroundColor: _isStockIn
              ? Colors.black
              : Colors.white,
          disabledBackgroundColor:
          _actionColor.withOpacity(0.38),
          disabledForegroundColor:
          Colors.white54,
          minimumSize:
          const Size.fromHeight(55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
        icon: _saving
            ? SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            color: _isStockIn
                ? Colors.black
                : Colors.white,
            strokeWidth: 2,
          ),
        )
            : Icon(
          _isStockIn
              ? Icons.login_rounded
              : Icons.logout_rounded,
        ),
        label: Text(
          _saving
              ? 'Menyimpan...'
              : _buttonTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}