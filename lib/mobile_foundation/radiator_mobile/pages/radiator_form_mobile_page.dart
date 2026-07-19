import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ndp_inventory_app/services/radiator_api.dart';

class RadiatorFormMobilePage extends StatefulWidget {
  const RadiatorFormMobilePage({
    super.key,
  });

  @override
  State<RadiatorFormMobilePage> createState() =>
      _RadiatorFormMobilePageState();
}

class _RadiatorFormMobilePageState
    extends State<RadiatorFormMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _kodeController =
  TextEditingController();

  final TextEditingController _barcodeController =
  TextEditingController();

  final TextEditingController _namaController =
  TextEditingController();

  final TextEditingController _tinggiController =
  TextEditingController();

  final TextEditingController _lebarController =
  TextEditingController();

  final TextEditingController _tebalController =
  TextEditingController();

  final TextEditingController _modelSarangController =
  TextEditingController();

  final TextEditingController _lokasiController =
  TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  bool _loadingCode = true;
  bool _saving = false;

  String? _codeError;

  @override
  void initState() {
    super.initState();

    _kodeController.addListener(_updateBarcode);
    _namaController.addListener(_updateBarcode);

    _loadNextCode();
  }

  @override
  void dispose() {
    _kodeController.removeListener(_updateBarcode);
    _namaController.removeListener(_updateBarcode);

    _kodeController.dispose();
    _barcodeController.dispose();
    _namaController.dispose();
    _tinggiController.dispose();
    _lebarController.dispose();
    _tebalController.dispose();
    _modelSarangController.dispose();
    _lokasiController.dispose();

    super.dispose();
  }

  Future<void> _loadNextCode() async {
    if (!mounted) return;

    setState(() {
      _loadingCode = true;
      _codeError = null;
    });

    try {
      final code = await RadiatorApi.getNextCode();

      if (!mounted) return;

      _kodeController.text = code;

      setState(() {
        _loadingCode = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingCode = false;
        _codeError = error.toString();
      });

      _showMessage(
        'Kode otomatis gagal dimuat. Silakan isi manual.',
        error: true,
      );
    }
  }

  void _updateBarcode() {
    final code =
    _kodeController.text.trim().toUpperCase();

    final name = _namaController.text
        .trim()
        .toUpperCase()
        .replaceAll(
      RegExp(r'[^A-Z0-9]+'),
      '-',
    )
        .replaceAll(
      RegExp(r'^-+'),
      '',
    )
        .replaceAll(
      RegExp(r'-+$'),
      '',
    );

    final barcode = [
      if (code.isNotEmpty) code,
      if (name.isNotEmpty) name,
    ].join('-');

    if (_barcodeController.text != barcode) {
      _barcodeController.text = barcode;
    }
  }

  Future<void> _pickImage() async {
    if (_saving) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (picked == null || !mounted) return;

      setState(() {
        _selectedImage = File(picked.path);
      });
    } catch (error) {
      _showMessage(
        'Gagal memilih foto: $error',
        error: true,
      );
    }
  }

  void _removeImage() {
    if (_saving) return;

    setState(() {
      _selectedImage = null;
    });
  }

  int? _optionalInt(
      TextEditingController controller,
      ) {
    final value = controller.text.trim();

    if (value.isEmpty) return null;

    return int.tryParse(value);
  }

  String? _optionalText(String value) {
    final text = value.trim();

    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    final valid =
        _formKey.currentState?.validate() ??
            false;

    if (!valid) return;

    final kode =
    _kodeController.text.trim().toUpperCase();

    final nama =
    _namaController.text.trim();

    final barcode =
    _barcodeController.text.trim().isEmpty
        ? kode
        : _barcodeController.text.trim();

    setState(() {
      _saving = true;
    });

    try {
      final id = await RadiatorApi.addRadiator({
        'barcode': barcode,
        'kode_radiator': kode,
        'nama_radiator': nama,
        'tinggi': _optionalInt(
          _tinggiController,
        ),
        'lebar': _optionalInt(
          _lebarController,
        ),
        'tebal': _optionalInt(
          _tebalController,
        ),
        'model_sarang': _optionalText(
          _modelSarangController.text,
        ),
        'stok': 0,
        'lokasi': _optionalText(
          _lokasiController.text,
        ),
      });

      if (_selectedImage != null) {
        await RadiatorApi.uploadImage(
          id: id,
          image: _selectedImage!,
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
        'Gagal menyimpan radiator: $error',
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

  String? _numberValidator(
      String? value,
      ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;

    final number = int.tryParse(text);

    if (number == null) {
      return 'Harus berupa angka';
    }

    if (number <= 0) {
      return 'Harus lebih dari 0';
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? Colors.redAccent
              : const Color(0xff252525),
          content: Text(message),
        ),
      );
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
          title: const Text(
            'Tambah Radiator',
            style: TextStyle(
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
              _informationCard(),
              const SizedBox(height: 15),
              _identityCard(),
              const SizedBox(height: 15),
              _sizeCard(),
              const SizedBox(height: 15),
              _locationCard(),
              const SizedBox(height: 15),
              _imageCard(),
              const SizedBox(height: 22),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _informationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withOpacity(0.20),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: accent,
            size: 29,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Master Radiator Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Stok awal otomatis 0. Penambahan stok dilakukan melalui menu Stock In.',
                  style: TextStyle(
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

  Widget _identityCard() {
    return _section(
      title: 'Identitas Radiator',
      icon: Icons.qr_code_2_rounded,
      child: Column(
        children: [
          _field(
            controller: _kodeController,
            label: 'Kode Radiator',
            hint: 'Contoh: RAD-001',
            icon: Icons.tag_rounded,
            textCapitalization:
            TextCapitalization.characters,
            validator: _requiredValidator,
            suffixIcon: _loadingCode
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  color: accent,
                  strokeWidth: 2,
                ),
              ),
            )
                : IconButton(
              onPressed: _saving
                  ? null
                  : _loadNextCode,
              icon: Icon(
                _codeError == null
                    ? Icons.refresh_rounded
                    : Icons
                    .error_outline_rounded,
                color: _codeError == null
                    ? Colors.white38
                    : Colors.redAccent,
              ),
            ),
          ),
          _field(
            controller: _namaController,
            label: 'Nama Radiator',
            hint:
            'Contoh: Radiator Mitsubishi L300',
            icon:
            Icons.inventory_2_outlined,
            validator: _requiredValidator,
          ),
          _field(
            controller: _barcodeController,
            label: 'Barcode',
            hint: 'Dibuat otomatis',
            icon: Icons.qr_code_2_rounded,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _sizeCard() {
    return _section(
      title: 'Ukuran Radiator',
      icon: Icons.straighten_rounded,
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  controller:
                  _tinggiController,
                  label: 'Tinggi',
                  hint: 'mm',
                  icon: Icons.height_rounded,
                  keyboardType:
                  TextInputType.number,
                  validator:
                  _numberValidator,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  controller:
                  _lebarController,
                  label: 'Lebar',
                  hint: 'mm',
                  icon:
                  Icons.swap_horiz_rounded,
                  keyboardType:
                  TextInputType.number,
                  validator:
                  _numberValidator,
                ),
              ),
            ],
          ),
          _field(
            controller: _tebalController,
            label: 'Tebal',
            hint: 'mm',
            icon: Icons.view_in_ar_outlined,
            keyboardType:
            TextInputType.number,
            validator: _numberValidator,
          ),
          _field(
            controller:
            _modelSarangController,
            label: 'Model Sarang',
            hint:
            'Contoh: 3 Row / Plate Fin',
            icon: Icons.grid_view_rounded,
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return _section(
      title: 'Lokasi Penyimpanan',
      icon: Icons.warehouse_outlined,
      child: _field(
        controller: _lokasiController,
        label: 'Lokasi',
        hint:
        'Contoh: Gudang A / Rak R-01',
        icon:
        Icons.location_on_outlined,
      ),
    );
  }

  Widget _imageCard() {
    return _section(
      title: 'Foto Radiator',
      icon: Icons.image_outlined,
      child: _selectedImage == null
          ? InkWell(
        onTap:
        _saving ? null : _pickImage,
        borderRadius:
        BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 170,
          decoration: BoxDecoration(
            color:
            Colors.white.withOpacity(
              0.03,
            ),
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              Colors.white.withOpacity(
                0.09,
              ),
            ),
          ),
          child: const Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .add_photo_alternate_outlined,
                color: accent,
                size: 39,
              ),
              SizedBox(height: 10),
              Text(
                'Pilih foto radiator',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'JPG, JPEG atau PNG',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      )
          : Stack(
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius.circular(18),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  height: 210,
                  alignment:
                  Alignment.center,
                  color: Colors.white
                      .withOpacity(0.04),
                  child: const Icon(
                    Icons
                        .broken_image_outlined,
                    color: Colors.white30,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color:
                Colors.black.withOpacity(
                  0.70,
                ),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _saving
                        ? null
                        : _pickImage,
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _saving
                        ? null
                        : _removeImage,
                    icon: const Icon(
                      Icons
                          .delete_outline_rounded,
                      color:
                      Colors.redAccent,
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
                width: 43,
                height: 43,
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
          const SizedBox(height: 16),
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
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization:
        textCapitalization,
        readOnly: readOnly,
        style: TextStyle(
          color: readOnly
              ? Colors.white54
              : Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: accent,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
          hintStyle: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
          ),
          filled: true,
          fillColor:
          Colors.white.withOpacity(0.04),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: BorderSide(
              color:
              Colors.white.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: accent,
            ),
          ),
          errorBorder: OutlineInputBorder(
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
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          accent.withOpacity(0.40),
          minimumSize:
          const Size.fromHeight(55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
        icon: _saving
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(
          Icons.save_rounded,
        ),
        label: Text(
          _saving
              ? 'Menyimpan...'
              : 'Simpan Radiator',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}