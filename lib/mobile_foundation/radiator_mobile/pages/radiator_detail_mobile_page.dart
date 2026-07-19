import 'dart:ui';


import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndp_inventory_app/models/radiator_model.dart';
import 'package:ndp_inventory_app/services/radiator_api.dart';

class RadiatorDetailMobilePage extends StatefulWidget {
  final Radiator radiator;

  const RadiatorDetailMobilePage({
    super.key,
    required this.radiator,
  });

  @override
  State<RadiatorDetailMobilePage> createState() =>
      _RadiatorDetailMobilePageState();
}

class _RadiatorDetailMobilePageState
    extends State<RadiatorDetailMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);

  late Radiator _radiator;

  bool _saving = false;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _radiator = widget.radiator;
  }

  Color get _stockColor {
    if (_radiator.stok <= 0) {
      return redAccent;
    }

    if (_radiator.stok <= _radiator.minStock) {
      return accent;
    }

    return greenAccent;
  }

  String get _stockLabel {
    if (_radiator.stok <= 0) {
      return 'Kosong';
    }

    if (_radiator.stok <= _radiator.minStock) {
      return 'Menipis';
    }

    return 'Tersedia';
  }

  bool get _hasImage {
    final image = _radiator.radiatorImage?.trim();

    return image != null &&
        image.isNotEmpty &&
        image.toLowerCase() != 'null';
  }

  String get _imageUrl {
    const String host =
        'https://api.api-nusantaradiesel.tech';

    final String rawPath =
        _radiator.radiatorImage?.trim() ?? '';

    if (rawPath.isEmpty ||
        rawPath.toLowerCase() == 'null') {
      return '';
    }

    if (rawPath.startsWith('http://') ||
        rawPath.startsWith('https://')) {
      return rawPath;
    }

    final String normalizedPath = rawPath
        .replaceAll('\\', '/')
        .replaceFirst(
      RegExp(r'^/+'),
      '',
    );

    return '$host/$normalizedPath';
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

  String _dimensionText(
      dynamic value,
      ) {
    if (value == null) {
      return '-';
    }

    final text = value.toString().trim();

    if (text.isEmpty ||
        text == '0' ||
        text.toLowerCase() == 'null') {
      return '-';
    }

    return '$text mm';
  }




  Future<void> _openImagePreview() async {
    if (!_hasImage || _imageUrl.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  boundaryMargin:
                  const EdgeInsets.all(60),
                  child: Center(
                    child: Hero(
                      tag:
                      'radiator-image-${_radiator.id}',
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (
                            context,
                            child,
                            progress,
                            ) {
                          if (progress == null) {
                            return child;
                          }

                          return const Center(
                            child:
                            CircularProgressIndicator(
                              color: accent,
                            ),
                          );
                        },
                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const Center(
                            child: Column(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .broken_image_outlined,
                                  color:
                                  Colors.redAccent,
                                  size: 52,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Foto gagal dimuat',
                                  style: TextStyle(
                                    color:
                                    Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withOpacity(
                    0.65,
                  ),
                  borderRadius:
                  BorderRadius.circular(16),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: IgnorePointer(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.55,
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Cubit atau scroll untuk memperbesar foto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _handleBack() async {
    Navigator.pop(context, _hasChanged);
    return false;
  }

  Future<void> _copyBarcode() async {
    final barcode = _radiator.barcode.trim();

    if (barcode.isEmpty) {
      _showMessage(
        'Barcode radiator masih kosong',
        error: true,
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: barcode),
    );

    if (!mounted) return;

    _showMessage(
      'Barcode berhasil disalin',
    );
  }

  Future<void> _openEdit() async {
    if (_saving) return;

    final bool? updated =
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RadiatorEditSheet(
          radiator: _radiator,
        );
      },
    );

    if (updated == true && mounted) {
      setState(() {
        _hasChanged = true;
      });

      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Positioned(
              top: 40,
              right: -120,
              child: _buildGlow(
                color: accent,
                size: 280,
              ),
            ),
            Positioned(
              bottom: 20,
              left: -140,
              child: _buildGlow(
                color: const Color(0xff64b5f6),
                size: 280,
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                physics:
                const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      13,
                      18,
                      110,
                    ),
                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(height: 17),
                          _buildImage(),
                          const SizedBox(height: 15),
                          _buildTitleCard(),
                          const SizedBox(height: 15),
                          _buildStockCard(),
                          const SizedBox(height: 15),
                          _buildIdentityCard(),
                          const SizedBox(height: 15),
                          _buildSizeCard(),
                          const SizedBox(height: 15),
                          _buildLocationCard(),
                          const SizedBox(height: 22),
                          _buildEditButton(),
                        ],
                      ),
                    ),
                  ),
                ],
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
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.02),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 120,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(
                context,
                _hasChanged,
              );
            },
            borderRadius:
            BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.045),
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                size: 19,
              ),
            ),
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Radiator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Informasi master dan stok radiator',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openEdit,
            borderRadius:
            BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.11),
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withOpacity(0.22),
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: accent,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = _imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _hasImage && imageUrl.isNotEmpty
              ? _openImagePreview
              : null,
          child: Container(
            width: double.infinity,
            height: 235,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.035),
              borderRadius:
              BorderRadius.circular(25),
              border: Border.all(
                color:
                Colors.white.withOpacity(0.08),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!_hasImage || imageUrl.isEmpty)
                  _imagePlaceholder()
                else
                  Hero(
                    tag:
                    'radiator-image-${_radiator.id}',
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      filterQuality:
                      FilterQuality.medium,
                      loadingBuilder: (
                          context,
                          child,
                          progress,
                          ) {
                        if (progress == null) {
                          return child;
                        }

                        return const Center(
                          child:
                          CircularProgressIndicator(
                            color: accent,
                            strokeWidth: 2.5,
                          ),
                        );
                      },
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        debugPrint(
                          'Gagal memuat foto: '
                              '$imageUrl',
                        );

                        return _imagePlaceholder();
                      },
                    ),
                  ),
                if (_hasImage &&
                    imageUrl.isNotEmpty)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(0.62),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Lihat Foto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
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

  Widget _imageErrorPlaceholder(
      String imageUrl,
      ) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.025),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 10),
          const Text(
            'Foto gagal dimuat',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            imageUrl,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.025),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white24,
            size: 52,
          ),
          SizedBox(height: 10),
          Text(
            'Foto radiator belum tersedia',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color:
            Colors.white.withOpacity(0.035),
            borderRadius:
            BorderRadius.circular(23),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _radiator.kodeRadiator,
                style: const TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _radiator.namaRadiator,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 13),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _copyBarcode,
                  borderRadius:
                  BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(
                        0.035,
                      ),
                      borderRadius:
                      BorderRadius.circular(15),
                      border: Border.all(
                        color:
                        Colors.white.withOpacity(
                          0.07,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          color: accent,
                          size: 21,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _safeText(
                              _radiator.barcode,
                            ),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.copy_rounded,
                          color: Colors.white30,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _stockColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _stockColor.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color:
              _stockColor.withOpacity(0.14),
              borderRadius:
              BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: _stockColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stok Saat Ini',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_radiator.stok} pcs',
                  style: TextStyle(
                    color: _stockColor,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color:
              _stockColor.withOpacity(0.13),
              borderRadius:
              BorderRadius.circular(30),
              border: Border.all(
                color:
                _stockColor.withOpacity(0.30),
              ),
            ),
            child: Text(
              _stockLabel,
              style: TextStyle(
                color: _stockColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return _section(
      title: 'Identitas Radiator',
      icon: Icons.badge_outlined,
      children: [
        _detailRow(
          label: 'Kode Radiator',
          value: _radiator.kodeRadiator,
          icon: Icons.tag_rounded,
        ),
        _detailRow(
          label: 'Nama Radiator',
          value: _radiator.namaRadiator,
          icon: Icons.inventory_2_outlined,
        ),
        _detailRow(
          label: 'Barcode',
          value: _safeText(
            _radiator.barcode,
          ),
          icon: Icons.qr_code_2_rounded,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSizeCard() {
    return _section(
      title: 'Ukuran dan Sarang',
      icon: Icons.straighten_rounded,
      children: [
        _detailRow(
          label: 'Tinggi',
          value: _dimensionText(
            _radiator.tinggi,
          ),
          icon: Icons.height_rounded,
        ),
        _detailRow(
          label: 'Lebar',
          value: _dimensionText(
            _radiator.lebar,
          ),
          icon: Icons.swap_horiz_rounded,
        ),
        _detailRow(
          label: 'Tebal',
          value: _dimensionText(
            _radiator.tebal,
          ),
          icon: Icons.view_in_ar_outlined,
        ),
        _detailRow(
          label: 'Model Sarang',
          value: _safeText(
            _radiator.modelSarang,
          ),
          icon: Icons.grid_view_rounded,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return _section(
      title: 'Penyimpanan',
      icon: Icons.warehouse_outlined,
      children: [
        _detailRow(
          label: 'Lokasi',
          value: _safeText(
            _radiator.lokasi,
          ),
          icon: Icons.location_on_outlined,
        ),
        _detailRow(
          label: 'Minimum Stok',
          value:
          '${_radiator.minStock} pcs',
          icon:
          Icons.warning_amber_rounded,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required IconData icon,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                  Colors.white.withOpacity(
                    0.035,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white38,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color:
            Colors.white.withOpacity(0.06),
          ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving
            ? null
            : _openEdit,
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
        icon: const Icon(
          Icons.edit_rounded,
        ),
        label: const Text(
          'Edit Data Radiator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RadiatorEditSheet
    extends StatefulWidget {
  final Radiator radiator;

  const _RadiatorEditSheet({
    required this.radiator,
  });

  @override
  State<_RadiatorEditSheet> createState() =>
      _RadiatorEditSheetState();
}

class _RadiatorEditSheetState
    extends State<_RadiatorEditSheet> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff101010);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  late final TextEditingController
  _barcodeController;

  late final TextEditingController
  _kodeController;

  late final TextEditingController
  _namaController;

  late final TextEditingController
  _tinggiController;

  late final TextEditingController
  _lebarController;

  late final TextEditingController
  _tebalController;

  late final TextEditingController
  _modelSarangController;

  late final TextEditingController
  _lokasiController;

  late final TextEditingController
  _minStockController;

  bool _saving = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
      await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (pickedImage == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImage = File(
          pickedImage.path,
        );
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(
              'Gagal memilih foto: $error',
            ),
          ),
        );
    }
  }

  @override
  void initState() {
    super.initState();

    final radiator = widget.radiator;

    _barcodeController =
        TextEditingController(
          text: radiator.barcode,
        );

    _kodeController =
        TextEditingController(
          text: radiator.kodeRadiator,
        );

    _namaController =
        TextEditingController(
          text: radiator.namaRadiator,
        );

    _tinggiController =
        TextEditingController(
          text: radiator.tinggi?.toString() ?? '',
        );

    _lebarController =
        TextEditingController(
          text: radiator.lebar?.toString() ?? '',
        );

    _tebalController =
        TextEditingController(
          text: radiator.tebal?.toString() ?? '',
        );

    _modelSarangController =
        TextEditingController(
          text: radiator.modelSarang ?? '',
        );

    _lokasiController =
        TextEditingController(
          text: radiator.lokasi ?? '',
        );

    _minStockController =
        TextEditingController(
          text: radiator.minStock.toString(),
        );


  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _kodeController.dispose();
    _namaController.dispose();
    _tinggiController.dispose();
    _lebarController.dispose();
    _tebalController.dispose();
    _modelSarangController.dispose();
    _lokasiController.dispose();
    _minStockController.dispose();

    super.dispose();
  }

  int? _optionalInt(
      TextEditingController controller,
      ) {
    final text = controller.text.trim();

    if (text.isEmpty) return null;

    return int.tryParse(text);
  }

  String? _optionalText(
      TextEditingController controller,
      ) {
    final text = controller.text.trim();

    return text.isEmpty ? null : text;
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

  String? _numberValidator(
      String? value,
      ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;

    final number = int.tryParse(text);

    if (number == null) {
      return 'Harus berupa angka';
    }

    if (number < 0) {
      return 'Tidak boleh negatif';
    }

    return null;
  }

  Future<void> _save() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    final valid =
        _formKey.currentState?.validate() ??
            false;

    if (!valid) return;

    setState(() {
      _saving = true;
    });

    try {
      await RadiatorApi.updateRadiator(
        widget.radiator.id,
        {
          'barcode':
          _barcodeController.text.trim(),
          'kode_radiator':
          _kodeController.text
              .trim()
              .toUpperCase(),
          'nama_radiator':
          _namaController.text.trim(),
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
            _modelSarangController,
          ),
          'lokasi': _optionalText(
            _lokasiController,
          ),
          'min_stock':
          int.tryParse(
            _minStockController.text.trim(),
          ) ??
              5,
        },
      );

      if (_selectedImage != null) {
        await RadiatorApi.uploadImage(
          id: widget.radiator.id,
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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior.floating,
            backgroundColor:
            Colors.redAccent,
            content: Text(
              'Gagal memperbarui radiator: '
                  '$error',
            ),
          ),
        );
    }
  }



  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight:
        MediaQuery.of(context)
            .size
            .height *
            0.91,
      ),
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      decoration: const BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  17,
                  10,
                  12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'Edit Radiator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Perbarui informasi master radiator',
                            style: TextStyle(
                              color:
                              Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color:
                Colors.white.withOpacity(
                  0.07,
                ),
              ),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    17,
                    18,
                    25,
                  ),
                  children: [
                    _field(
                      controller:
                      _kodeController,
                      label: 'Kode Radiator',
                      icon: Icons.tag_rounded,
                      validator:
                      _requiredValidator,
                    ),
                    _field(
                      controller:
                      _namaController,
                      label: 'Nama Radiator',
                      icon: Icons
                          .inventory_2_outlined,
                      validator:
                      _requiredValidator,
                    ),
                    _field(
                      controller:
                      _barcodeController,
                      label: 'Barcode',
                      icon:
                      Icons.qr_code_2_rounded,
                    ),
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field(
                            controller:
                            _tinggiController,
                            label: 'Tinggi',
                            icon:
                            Icons.height_rounded,
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
                            icon: Icons
                                .swap_horiz_rounded,
                            keyboardType:
                            TextInputType.number,
                            validator:
                            _numberValidator,
                          ),
                        ),
                      ],
                    ),
                    _field(
                      controller:
                      _tebalController,
                      label: 'Tebal',
                      icon: Icons
                          .view_in_ar_outlined,
                      keyboardType:
                      TextInputType.number,
                      validator:
                      _numberValidator,
                    ),
                    _field(
                      controller:
                      _modelSarangController,
                      label: 'Model Sarang',
                      icon:
                      Icons.grid_view_rounded,
                    ),
                    _field(
                      controller:
                      _lokasiController,
                      label: 'Lokasi',
                      icon: Icons
                          .location_on_outlined,
                    ),
                    _field(
                      controller:
                      _minStockController,
                      label: 'Minimum Stok',
                      icon: Icons
                          .warning_amber_rounded,
                      keyboardType:
                      TextInputType.number,
                      validator:
                      _numberValidator,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  18,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    _saving ? null : _save,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor:
                      Colors.white,
                      disabledBackgroundColor:
                      accent.withOpacity(0.4),
                      minimumSize:
                      const Size.fromHeight(
                        54,
                      ),
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          17,
                        ),
                      ),
                    ),
                    icon: _saving
                        ? const SizedBox(
                      width: 19,
                      height: 19,
                      child:
                      CircularProgressIndicator(
                        color:
                        Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.save_rounded,
                    ),
                    label: Text(
                      _saving
                          ? 'Menyimpan...'
                          : 'Simpan Perubahan',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
          prefixIcon: Icon(
            icon,
            color: accent,
            size: 20,
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
}