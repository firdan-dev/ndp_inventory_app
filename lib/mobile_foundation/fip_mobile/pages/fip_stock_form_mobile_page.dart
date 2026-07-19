import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ndp_inventory_app/models/fip_model.dart';
import 'package:ndp_inventory_app/services/fip_api.dart';

class FipStockFormMobilePage extends StatefulWidget {
  final bool isStockIn;

  const FipStockFormMobilePage({
    super.key,
    required this.isStockIn,
  });

  @override
  State<FipStockFormMobilePage> createState() =>
      _FipStockFormMobilePageState();
}

class _FipStockFormMobilePageState
    extends State<FipStockFormMobilePage> {
  static const Color accent =
  Color(0xffff6a00);

  static const Color background =
  Color(0xff050505);

  static const Color greenAccent =
  Color(0xff69f0ae);

  static const Color redAccent =
  Color(0xffff5252);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController
  _searchController =
  TextEditingController();

  final TextEditingController
  _qtyController =
  TextEditingController(
    text: '1',
  );

  final TextEditingController
  _notesController =
  TextEditingController();

  List<Fip> _fips = [];
  List<Fip> _filteredFips = [];

  Fip? _selectedFip;

  bool _loading = true;
  bool _saving = false;

  String? _errorMessage;

  bool get _isStockIn =>
      widget.isStockIn;

  Color get _actionColor {
    return _isStockIn
        ? greenAccent
        : redAccent;
  }

  String get _pageTitle {
    return _isStockIn
        ? 'Stock In Fuel Injection Pump'
        : 'Stock Out Fuel Injection Pump';
  }

  String get _buttonTitle {
    return _isStockIn
        ? 'Simpan Stock In'
        : 'Simpan Stock Out';
  }

  @override
  void initState() {
    super.initState();

    _loadFips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _loadFips() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result =
      await FipApi.getFips();

      if (!mounted) return;

      setState(() {
        _fips = result;
        _filteredFips = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage =
            error.toString();
      });
    }
  }

  void _filterFips(
      String value,
      ) {
    final query =
    value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredFips =
        List<Fip>.from(
          _fips,
        );

        return;
      }

      _filteredFips =
          _fips.where((fip) {
            final searchableText = [
              fip.pumpId,
              fip.kodePump,
              fip.nama,
              fip.fuelInjection,
              fip.partNo,
              fip.brand,
            ].join(' ').toLowerCase();

            return searchableText.contains(
              query,
            );
          }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();

    _filterFips('');
  }

  void _selectFip(
      Fip fip,
      ) {
    setState(() {
      _selectedFip = fip;
    });
  }

  void _removeSelectedFip() {
    if (_saving) return;

    setState(() {
      _selectedFip = null;
    });
  }

  String _safeText(
      String value, {
        String fallback = '-',
      }) {
    final text =
    value.trim();

    if (text.isEmpty ||
        text.toLowerCase() ==
            'null') {
      return fallback;
    }

    return text;
  }

  Color _stockColor(
      Fip fip,
      ) {
    if (fip.qty <= 0) {
      return redAccent;
    }

    if (fip.qty <=
        fip.minStock) {
      return accent;
    }

    return greenAccent;
  }

  String? _emptyToNull(
      String value,
      ) {
    final text =
    value.trim();

    return text.isEmpty
        ? null
        : text;
  }

  Future<void> _submit() async {
    if (_saving) return;

    FocusScope.of(context)
        .unfocus();

    final valid =
        _formKey.currentState
            ?.validate() ??
            false;

    if (!valid) return;

    final fip =
        _selectedFip;

    if (fip == null) {
      _showMessage(
        'Pilih Fuel Injection Pump terlebih dahulu',
        error: true,
      );

      return;
    }

    final qty =
    int.tryParse(
      _qtyController.text.trim(),
    );

    if (qty == null ||
        qty <= 0) {
      _showMessage(
        'Jumlah stok tidak valid',
        error: true,
      );

      return;
    }

    if (!_isStockIn &&
        qty > fip.qty) {
      _showMessage(
        'Stok tidak cukup. Stok tersedia ${fip.qty} pcs.',
        error: true,
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (_isStockIn) {
        await FipApi.stockIn(
          id: fip.id,
          qty: qty,
          notes: _emptyToNull(
            _notesController.text,
          ),
        );
      } else {
        await FipApi.stockOut(
          id: fip.id,
          qty: qty,
          notes: _emptyToNull(
            _notesController.text,
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        '${_isStockIn ? 'Stock in' : 'Stock out'} gagal: $error',
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
          behavior:
          SnackBarBehavior
              .floating,
          backgroundColor:
          error
              ? Colors.redAccent
              : const Color(
            0xff242424,
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
          backgroundColor:
          background,
          foregroundColor:
          Colors.white,
          elevation: 0,
          title: Text(
            _pageTitle,
            style:
            const TextStyle(
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

              _buildFipSelector(),

              if (_selectedFip !=
                  null) ...[
                const SizedBox(
                  height: 16,
                ),
                _buildSelectedFip(),
              ],

              const SizedBox(
                height: 16,
              ),

              _buildTransactionForm(),

              const SizedBox(
                height: 22,
              ),

              _buildSubmitButton(),
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
        _actionColor
            .withOpacity(
          0.08,
        ),
        borderRadius:
        BorderRadius.circular(
          21,
        ),
        border:
        Border.all(
          color:
          _actionColor
              .withOpacity(
            0.21,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration:
            BoxDecoration(
              color:
              _actionColor
                  .withOpacity(
                0.13,
              ),
              borderRadius:
              BorderRadius
                  .circular(
                17,
              ),
            ),
            child: Icon(
              _isStockIn
                  ? Icons.login_rounded
                  : Icons.logout_rounded,
              color:
              _actionColor,
              size: 27,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  _isStockIn
                      ? 'Penambahan Stok FIP'
                      : 'Pengeluaran Stok FIP',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _isStockIn
                      ? 'Catat Fuel Injection Pump yang masuk ke gudang.'
                      : 'Catat Fuel Injection Pump yang keluar dari gudang.',
                  style:
                  const TextStyle(
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

  Widget _buildFipSelector() {
    return _section(
      title:
      'Pilih Fuel Injection Pump',
      icon:
      Icons
          .settings_input_component_outlined,
      child: Column(
        children: [
          TextField(
            controller:
            _searchController,
            onChanged:
            _filterFips,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 13,
            ),
            decoration:
            InputDecoration(
              hintText:
              'Cari Pump ID, kode, nama, brand atau part number...',
              hintStyle:
              const TextStyle(
                color:
                Colors.white30,
                fontSize: 10,
              ),
              prefixIcon:
              const Icon(
                Icons.search_rounded,
                color: accent,
                size: 21,
              ),
              suffixIcon:
              _searchController
                  .text
                  .isEmpty
                  ? null
                  : IconButton(
                onPressed:
                _clearSearch,
                icon:
                const Icon(
                  Icons
                      .close_rounded,
                  color:
                  Colors.white38,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor:
              Colors.white
                  .withOpacity(
                0.04,
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
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
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  16,
                ),
                borderSide:
                const BorderSide(
                  color: accent,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          _buildFipList(),
        ],
      ),
    );
  }

  Widget _buildFipList() {
    if (_loading) {
      return const SizedBox(
        height: 145,
        child: Center(
          child:
          CircularProgressIndicator(
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
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .cloud_off_rounded,
                color:
                Colors.redAccent,
                size: 30,
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                _errorMessage!,
                textAlign:
                TextAlign.center,
                maxLines: 3,
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

              const SizedBox(
                height: 7,
              ),

              TextButton.icon(
                onPressed:
                _loadFips,
                icon:
                const Icon(
                  Icons
                      .refresh_rounded,
                ),
                label:
                const Text(
                  'Coba Lagi',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredFips
        .isEmpty) {
      return const SizedBox(
        height: 130,
        child: Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .search_off_rounded,
                color:
                Colors.white24,
                size: 34,
              ),

              SizedBox(
                height: 8,
              ),

              Text(
                'Fuel Injection Pump tidak ditemukan',
                style:
                TextStyle(
                  color:
                  Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints:
      const BoxConstraints(
        maxHeight: 285,
      ),
      child:
      ListView.separated(
        shrinkWrap: true,
        physics:
        const BouncingScrollPhysics(),
        itemCount:
        _filteredFips.length,
        separatorBuilder:
            (_, __) {
          return Divider(
            height: 1,
            color:
            Colors.white
                .withOpacity(
              0.06,
            ),
          );
        },
        itemBuilder:
            (context, index) {
          final fip =
          _filteredFips[index];

          final selected =
              fip.id ==
                  _selectedFip?.id;

          final stockColor =
          _stockColor(
            fip,
          );

          return Material(
            color:
            Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _selectFip(
                    fip,
                  ),
              borderRadius:
              BorderRadius
                  .circular(
                15,
              ),
              child: Padding(
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration:
                      BoxDecoration(
                        color:
                        selected
                            ? accent
                            .withOpacity(
                          0.14,
                        )
                            : Colors
                            .white
                            .withOpacity(
                          0.04,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                        border:
                        Border.all(
                          color:
                          selected
                              ? accent
                              .withOpacity(
                            0.28,
                          )
                              : Colors
                              .white
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
                            .settings_input_component_outlined,
                        color:
                        selected
                            ? accent
                            : Colors
                            .white30,
                        size: 22,
                      ),
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
                          Text(
                            fip.pumpId,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              color:
                              selected
                                  ? accent
                                  : Colors
                                  .white,
                              fontSize: 10,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            fip.nama,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              Colors
                                  .white70,
                              fontSize: 11,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            '${_safeText(fip.brand)}'
                                ' • '
                                '${_safeText(fip.partNo)}',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              color:
                              Colors
                                  .white24,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        stockColor
                            .withOpacity(
                          0.11,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        border:
                        Border.all(
                          color:
                          stockColor
                              .withOpacity(
                            0.25,
                          ),
                        ),
                      ),
                      child: Text(
                        '${fip.qty} pcs',
                        style:
                        TextStyle(
                          color:
                          stockColor,
                          fontSize: 9,
                          fontWeight:
                          FontWeight
                              .w700,
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

  Widget _buildSelectedFip() {
    final fip =
    _selectedFip!;

    final stockColor =
    _stockColor(
      fip,
    );

    return Container(
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        accent.withOpacity(
          0.07,
        ),
        borderRadius:
        BorderRadius.circular(
          21,
        ),
        border:
        Border.all(
          color:
          accent.withOpacity(
            0.20,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            BoxDecoration(
              color:
              accent.withOpacity(
                0.13,
              ),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
            ),
            child:
            const Icon(
              Icons
                  .check_circle_rounded,
              color: accent,
              size: 25,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  fip.pumpId,
                  style:
                  const TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  fip.nama,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 13,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  'Stok saat ini: ${fip.qty} pcs',
                  style:
                  TextStyle(
                    color:
                    stockColor,
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Kode: ${_safeText(fip.kodePump)}',
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white30,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
            _removeSelectedFip,
            tooltip:
            'Batalkan pilihan',
            icon:
            const Icon(
              Icons.close_rounded,
              color:
              Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return _section(
      title:
      'Detail Transaksi',
      icon:
      Icons.receipt_long_outlined,
      child: Column(
        children: [
          _field(
            controller:
            _qtyController,
            label:
            'Jumlah',
            hint:
            'Masukkan jumlah Fuel Injection Pump',
            icon:
            Icons.numbers_rounded,
            keyboardType:
            TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],
            validator:
                (value) {
              final qty =
              int.tryParse(
                value?.trim() ??
                    '',
              );

              if (qty == null ||
                  qty <= 0) {
                return 'Jumlah harus lebih dari 0';
              }

              if (!_isStockIn &&
                  _selectedFip !=
                      null &&
                  qty >
                      _selectedFip!
                          .qty) {
                return 'Melebihi stok tersedia';
              }

              return null;
            },
          ),

          _field(
            controller:
            _notesController,
            label:
            'Catatan',
            hint:
            'Tambahkan keterangan transaksi',
            icon:
            Icons.notes_rounded,
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
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        17,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withOpacity(
          0.035,
        ),
        borderRadius:
        BorderRadius.circular(
          22,
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
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  color:
                  accent
                      .withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 14,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController
    controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    List<TextInputFormatter>?
    inputFormatters,
    String? Function(String?)?
    validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 13,
      ),
      child: TextFormField(
        controller:
        controller,
        keyboardType:
        keyboardType,
        inputFormatters:
        inputFormatters,
        validator:
        validator,
        maxLines:
        maxLines,
        enabled:
        !_saving,
        style:
        const TextStyle(
          color:
          Colors.white,
          fontSize: 13,
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
            fontSize: 11,
          ),

          hintStyle:
          const TextStyle(
            color:
            Colors.white24,
            fontSize: 10,
          ),

          prefixIcon:
          Icon(
            icon,
            color: accent,
            size: 20,
          ),

          filled: true,

          fillColor:
          Colors.white
              .withOpacity(
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
              Colors.white
                  .withOpacity(
                0.08,
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
              color: accent,
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
                0.05,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width:
      double.infinity,
      child:
      ElevatedButton.icon(
        onPressed:
        _saving
            ? null
            : _submit,

        style:
        ElevatedButton
            .styleFrom(
          backgroundColor:
          _actionColor,

          foregroundColor:
          _isStockIn
              ? Colors.black
              : Colors.white,

          disabledBackgroundColor:
          _actionColor
              .withOpacity(
            0.38,
          ),

          minimumSize:
          const Size
              .fromHeight(
            55,
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
            ? SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            color:
            _isStockIn
                ? Colors.black
                : Colors.white,
            strokeWidth:
            2,
          ),
        )
            : Icon(
          _isStockIn
              ? Icons.login_rounded
              : Icons.logout_rounded,
        ),

        label:
        Text(
          _saving
              ? 'Menyimpan...'
              : _buttonTitle,

          style:
          const TextStyle(
            fontWeight:
            FontWeight
                .w700,
          ),
        ),
      ),
    );
  }
}