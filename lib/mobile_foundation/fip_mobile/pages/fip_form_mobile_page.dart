import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ndp_inventory_app/services/fip_api.dart';

class FipFormMobilePage extends StatefulWidget {
  const FipFormMobilePage({
    super.key,
  });

  @override
  State<FipFormMobilePage> createState() =>
      _FipFormMobilePageState();
}

class _FipFormMobilePageState
    extends State<FipFormMobilePage> {
  static const Color accent =
  Color(0xffff6a00);

  static const Color background =
  Color(0xff050505);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController
  _pumpIdController =
  TextEditingController();

  final TextEditingController
  _namaController =
  TextEditingController();

  final TextEditingController
  _fuelInjectionController =
  TextEditingController();

  final TextEditingController
  _partNoController =
  TextEditingController();

  final TextEditingController
  _brandController =
  TextEditingController();

  final TextEditingController
  _qtyController =
  TextEditingController(
    text: '0',
  );

  final TextEditingController
  _minStockController =
  TextEditingController(
    text: '5',
  );

  bool _loadingCode = true;
  bool _saving = false;

  String? _codeError;

  @override
  void initState() {
    super.initState();

    _loadNextCode();
  }

  @override
  void dispose() {
    _pumpIdController.dispose();
    _namaController.dispose();
    _fuelInjectionController.dispose();
    _partNoController.dispose();
    _brandController.dispose();
    _qtyController.dispose();
    _minStockController.dispose();

    super.dispose();
  }

  Future<void> _loadNextCode() async {
    if (!mounted) return;

    setState(() {
      _loadingCode = true;
      _codeError = null;
    });

    try {
      final pumpId =
      await FipApi.getNextPumpId();

      if (!mounted) return;

      _pumpIdController.text =
          pumpId;

      setState(() {
        _loadingCode = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingCode = false;
        _codeError =
            error.toString();
      });

      _showMessage(
        'Gagal mengambil Pump ID otomatis',
        error: true,
      );
    }
  }

  String? _requiredValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Kolom ini wajib diisi';
    }

    return null;
  }

  String? _nonNegativeValidator(
      String? value,
      ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Kolom ini wajib diisi';
    }

    final number =
    int.tryParse(text);

    if (number == null) {
      return 'Harus berupa angka';
    }

    if (number < 0) {
      return 'Tidak boleh negatif';
    }

    return null;
  }

  String? _emptyToNull(
      String value,
      ) {
    final text =
    value.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
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

    final qty =
        int.tryParse(
          _qtyController.text
              .trim(),
        ) ??
            0;

    final minStock =
        int.tryParse(
          _minStockController
              .text
              .trim(),
        ) ??
            5;

    setState(() {
      _saving = true;
    });

    try {
      await FipApi.addFip({
        'nama':
        _namaController
            .text
            .trim(),
        'fuel_injection':
        _emptyToNull(
          _fuelInjectionController
              .text,
        ),
        'part_no':
        _emptyToNull(
          _partNoController.text,
        ),
        'brand':
        _emptyToNull(
          _brandController.text,
        ),
        'qty': qty,
        'min_stock': minStock,
      });

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
        'Gagal menyimpan Fuel Injection Pump: '
            '$error',
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
          SnackBarBehavior.floating,
          backgroundColor:
          error
              ? Colors.redAccent
              : const Color(
            0xff242424,
          ),
          content:
          Text(message),
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
          title: const Text(
            'Tambah Fuel Injection Pump',
            style: TextStyle(
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

              _buildIdentitySection(),

              const SizedBox(
                height: 16,
              ),

              _buildSpecificationSection(),

              const SizedBox(
                height: 16,
              ),

              _buildStockSection(),

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
        accent.withOpacity(
          0.08,
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
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .settings_input_component_outlined,
            color: accent,
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
                  'Master Fuel Injection Pump Baru',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                SizedBox(
                  height: 5,
                ),

                Text(
                  'Pump ID dan kode pump akan dibuat otomatis oleh sistem.',
                  style:
                  TextStyle(
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

  Widget _buildIdentitySection() {
    return _section(
      title:
      'Identitas Pump',
      icon:
      Icons.badge_outlined,
      child: Column(
        children: [
          _field(
            controller:
            _pumpIdController,
            label:
            'Pump ID',
            hint:
            'Dibuat otomatis',
            icon:
            Icons.tag_rounded,
            readOnly: true,
            suffixIcon:
            _loadingCode
                ? const Padding(
              padding:
              EdgeInsets.all(
                14,
              ),
              child:
              SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  color:
                  accent,
                  strokeWidth:
                  2,
                ),
              ),
            )
                : IconButton(
              onPressed:
              _saving
                  ? null
                  : _loadNextCode,
              icon: Icon(
                _codeError ==
                    null
                    ? Icons
                    .refresh_rounded
                    : Icons
                    .error_outline_rounded,
                color: _codeError ==
                    null
                    ? Colors
                    .white38
                    : Colors
                    .redAccent,
              ),
            ),
          ),

          _field(
            controller:
            _namaController,
            label:
            'Nama Fuel Injection Pump',
            hint:
            'Contoh: FIP Cummins 6BT',
            icon:
            Icons
                .settings_input_component_outlined,
            validator:
            _requiredValidator,
          ),

          _field(
            controller:
            _brandController,
            label:
            'Brand',
            hint:
            'Contoh: Bosch, Denso, Zexel',
            icon:
            Icons.factory_outlined,
            textCapitalization:
            TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationSection() {
    return _section(
      title:
      'Spesifikasi Pump',
      icon:
      Icons.settings_outlined,
      child: Column(
        children: [
          _field(
            controller:
            _fuelInjectionController,
            label:
            'Fuel Injection',
            hint:
            'Contoh: Inline Pump, Rotary Pump',
            icon:
            Icons
                .tune_rounded,
            textCapitalization:
            TextCapitalization.words,
          ),

          _field(
            controller:
            _partNoController,
            label:
            'Part Number',
            hint:
            'Masukkan part number pump',
            icon:
            Icons.numbers_rounded,
            textCapitalization:
            TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    return _section(
      title:
      'Informasi Stok',
      icon:
      Icons.inventory_2_outlined,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _field(
              controller:
              _qtyController,
              label:
              'Stok Awal',
              hint:
              '0',
              icon:
              Icons.numbers_rounded,
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

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: _field(
              controller:
              _minStockController,
              label:
              'Minimum Stok',
              hint:
              '5',
              icon:
              Icons
                  .warning_amber_rounded,
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
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
                width: 43,
                height: 43,
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
                  color:
                  accent,
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
            height: 16,
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
    TextCapitalization
    textCapitalization =
        TextCapitalization.sentences,
    List<TextInputFormatter>?
    inputFormatters,
    String? Function(String?)?
    validator,
    Widget? suffixIcon,
    int maxLines = 1,
    bool readOnly = false,
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
        textCapitalization:
        textCapitalization,
        inputFormatters:
        inputFormatters,
        validator:
        validator,
        maxLines:
        maxLines,
        readOnly:
        readOnly,
        enabled:
        !_saving,
        style:
        TextStyle(
          color:
          readOnly
              ? Colors.white54
              : Colors.white,
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
            color:
            accent,
            size: 20,
          ),

          suffixIcon:
          suffixIcon,

          filled:
          true,

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
        ElevatedButton
            .styleFrom(
          backgroundColor:
          accent,
          foregroundColor:
          Colors.white,

          disabledBackgroundColor:
          accent.withOpacity(
            0.40,
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
            Colors.white,
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
              : 'Simpan Fuel Injection Pump',
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
    );
  }
}