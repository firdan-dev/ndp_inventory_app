import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ndp_inventory_app/models/fip_model.dart';
import 'package:ndp_inventory_app/services/fip_api.dart';

class FipDetailMobilePage extends StatefulWidget {
  final Fip fip;

  const FipDetailMobilePage({
    super.key,
    required this.fip,
  });

  @override
  State<FipDetailMobilePage> createState() =>
      _FipDetailMobilePageState();
}

class _FipDetailMobilePageState
    extends State<FipDetailMobilePage> {
  static const Color accent =
  Color(0xffff6a00);

  static const Color background =
  Color(0xff050505);

  static const Color greenAccent =
  Color(0xff69f0ae);

  static const Color redAccent =
  Color(0xffff5252);

  static const Color blueAccent =
  Color(0xff64b5f6);

  late Fip _fip;

  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();

    _fip = widget.fip;
  }

  Color get _stockColor {
    if (_fip.qty <= 0) {
      return redAccent;
    }

    if (_fip.qty <=
        _fip.minStock) {
      return accent;
    }

    return greenAccent;
  }

  String get _stockLabel {
    if (_fip.qty <= 0) {
      return 'Kosong';
    }

    if (_fip.qty <=
        _fip.minStock) {
      return 'Menipis';
    }

    return 'Tersedia';
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

  Future<bool> _handleBack() async {
    Navigator.pop(
      context,
      _hasChanged,
    );

    return false;
  }

  Future<void> _copyCode() async {
    final code =
    _fip.kodePump.trim();

    if (code.isEmpty) {
      _showMessage(
        'Kode pump masih kosong',
        error: true,
      );

      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: code,
      ),
    );

    if (!mounted) return;

    _showMessage(
      'Kode pump berhasil disalin',
    );
  }

  Future<void> _openEdit() async {
    final bool? updated =
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (context) {
        return _FipEditSheet(
          fip: _fip,
        );
      },
    );

    if (updated == true &&
        mounted) {
      setState(() {
        _hasChanged = true;
      });

      Navigator.pop(
        context,
        true,
      );
    }
  }

  Future<void> _deleteFip() async {
    final bool? confirm =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor:
          const Color(
            0xff151515,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),
          title:
          const Text(
            'Hapus Fuel Injection Pump?',
            style:
            TextStyle(
              color:
              Colors.white,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          content:
          Text(
            'Data ${_fip.nama} akan dihapus dari master Fuel Injection Pump.',
            style:
            const TextStyle(
              color:
              Colors.white54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                Colors.redAccent,
                foregroundColor:
                Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FipApi.deleteFip(
        _fip.id,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal menghapus Fuel Injection Pump: $error',
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
      onWillPop:
      _handleBack,
      child: Scaffold(
        backgroundColor:
        background,
        body: Stack(
          children: [
            Positioned(
              top: 30,
              right: -120,
              child:
              _buildGlow(
                color: accent,
                size: 290,
              ),
            ),
            Positioned(
              bottom: 40,
              left: -140,
              child:
              _buildGlow(
                color:
                blueAccent,
                size: 290,
              ),
            ),
            SafeArea(
              child:
              CustomScrollView(
                physics:
                const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      18,
                      13,
                      18,
                      110,
                    ),
                    sliver:
                    SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(
                            height: 17,
                          ),
                          _buildHeroCard(),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStockCard(),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildIdentityCard(),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildSpecificationCard(),
                          const SizedBox(
                            height: 15,
                          ),
                          _buildStockInfoCard(),
                          const SizedBox(
                            height: 22,
                          ),
                          _buildActionButtons(),
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
            0.02,
          ),
          boxShadow: [
            BoxShadow(
              color:
              color.withOpacity(
                0.08,
              ),
              blurRadius:
              120,
              spreadRadius:
              35,
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
          color:
          Colors.transparent,
          child:
          InkWell(
            onTap: () {
              Navigator.pop(
                context,
                _hasChanged,
              );
            },
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            child:
            Container(
              width:
              46,
              height:
              46,
              decoration:
              BoxDecoration(
                color:
                Colors.white
                    .withOpacity(
                  0.045,
                ),
                borderRadius:
                BorderRadius.circular(
                  16,
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
              const Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                color:
                Colors.white70,
                size:
                19,
              ),
            ),
          ),
        ),

        const SizedBox(
          width:
          13,
        ),

        const Expanded(
          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Fuel Injection Pump',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  20,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing:
                  -0.4,
                ),
              ),
              SizedBox(
                height:
                4,
              ),
              Text(
                'Informasi master dan stok pump',
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

        Material(
          color:
          Colors.transparent,
          child:
          InkWell(
            onTap:
            _openEdit,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            child:
            Container(
              width:
              46,
              height:
              46,
              decoration:
              BoxDecoration(
                color:
                accent.withOpacity(
                  0.11,
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
                Icons.edit_rounded,
                color:
                accent,
                size:
                21,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        23,
      ),
      child:
      BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX:
          14,
          sigmaY:
          14,
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
            color:
            Colors.white
                .withOpacity(
              0.035,
            ),
            borderRadius:
            BorderRadius.circular(
              23,
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
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width:
                    58,
                    height:
                    58,
                    decoration:
                    BoxDecoration(
                      color:
                      accent.withOpacity(
                        0.12,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .settings_input_component_outlined,
                      color:
                      accent,
                      size:
                      29,
                    ),
                  ),
                  const SizedBox(
                    width:
                    13,
                  ),
                  Expanded(
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fip.pumpId,
                          style:
                          const TextStyle(
                            color:
                            accent,
                            fontSize:
                            10,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height:
                          5,
                        ),
                        Text(
                          _safeText(
                            _fip.nama,
                            fallback:
                            'Fuel Injection Pump',
                          ),
                          maxLines:
                          2,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            20,
                            height:
                            1.2,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                16,
              ),

              Material(
                color:
                Colors.transparent,
                child:
                InkWell(
                  onTap:
                  _copyCode,
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                  child:
                  Container(
                    width:
                    double.infinity,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      13,
                      vertical:
                      11,
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
                        15,
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
                    child:
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .qr_code_2_rounded,
                          color:
                          accent,
                          size:
                          21,
                        ),
                        const SizedBox(
                          width:
                          10,
                        ),
                        Expanded(
                          child:
                          Text(
                            _safeText(
                              _fip.kodePump,
                            ),
                            maxLines:
                            1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            const TextStyle(
                              color:
                              Colors.white60,
                              fontSize:
                              11,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.copy_rounded,
                          color:
                          Colors.white30,
                          size:
                          17,
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
      padding:
      const EdgeInsets.all(
        17,
      ),
      decoration:
      BoxDecoration(
        color:
        _stockColor.withOpacity(
          0.08,
        ),
        borderRadius:
        BorderRadius.circular(
          22,
        ),
        border:
        Border.all(
          color:
          _stockColor.withOpacity(
            0.22,
          ),
        ),
      ),
      child:
      Row(
        children: [
          Container(
            width:
            54,
            height:
            54,
            decoration:
            BoxDecoration(
              color:
              _stockColor
                  .withOpacity(
                0.14,
              ),
              borderRadius:
              BorderRadius.circular(
                17,
              ),
            ),
            child:
            Icon(
              Icons
                  .inventory_2_outlined,
              color:
              _stockColor,
              size:
              27,
            ),
          ),

          const SizedBox(
            width:
            13,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stok Saat Ini',
                  style:
                  TextStyle(
                    color:
                    Colors.white38,
                    fontSize:
                    10,
                  ),
                ),
                const SizedBox(
                  height:
                  4,
                ),
                Text(
                  '${_fip.qty} pcs',
                  style:
                  TextStyle(
                    color:
                    _stockColor,
                    fontSize:
                    22,
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
              horizontal:
              12,
              vertical:
              7,
            ),
            decoration:
            BoxDecoration(
              color:
              _stockColor
                  .withOpacity(
                0.13,
              ),
              borderRadius:
              BorderRadius.circular(
                30,
              ),
              border:
              Border.all(
                color:
                _stockColor
                    .withOpacity(
                  0.30,
                ),
              ),
            ),
            child:
            Text(
              _stockLabel,
              style:
              TextStyle(
                color:
                _stockColor,
                fontSize:
                9,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return _section(
      title:
      'Identitas Pump',
      icon:
      Icons.badge_outlined,
      children: [
        _detailRow(
          label:
          'Pump ID',
          value:
          _safeText(
            _fip.pumpId,
          ),
          icon:
          Icons.tag_rounded,
        ),
        _detailRow(
          label:
          'Kode Pump',
          value:
          _safeText(
            _fip.kodePump,
          ),
          icon:
          Icons.qr_code_2_rounded,
          showDivider:
          false,
        ),
      ],
    );
  }

  Widget _buildSpecificationCard() {
    return _section(
      title:
      'Spesifikasi Pump',
      icon:
      Icons.settings_outlined,
      children: [
        _detailRow(
          label:
          'Nama',
          value:
          _safeText(
            _fip.nama,
          ),
          icon:
          Icons
              .settings_input_component_outlined,
        ),
        _detailRow(
          label:
          'Brand',
          value:
          _safeText(
            _fip.brand,
          ),
          icon:
          Icons.factory_outlined,
        ),
        _detailRow(
          label:
          'Fuel Injection',
          value:
          _safeText(
            _fip.fuelInjection,
          ),
          icon:
          Icons.tune_rounded,
        ),
        _detailRow(
          label:
          'Part Number',
          value:
          _safeText(
            _fip.partNo,
          ),
          icon:
          Icons.numbers_rounded,
          showDivider:
          false,
        ),
      ],
    );
  }

  Widget _buildStockInfoCard() {
    return _section(
      title:
      'Informasi Stok',
      icon:
      Icons.inventory_outlined,
      children: [
        _detailRow(
          label:
          'Stok Saat Ini',
          value:
          '${_fip.qty} pcs',
          icon:
          Icons.inventory_2_outlined,
        ),
        _detailRow(
          label:
          'Minimum Stok',
          value:
          '${_fip.minStock} pcs',
          icon:
          Icons.warning_amber_rounded,
          showDivider:
          false,
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
      child:
      Column(
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
            15,
          ),

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
            vertical:
            10,
          ),
          child:
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width:
                38,
                height:
                38,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withOpacity(
                    0.035,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                Icon(
                  icon,
                  color:
                  Colors.white38,
                  size:
                  19,
                ),
              ),

              const SizedBox(
                width:
                11,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style:
                      const TextStyle(
                        color:
                        Colors.white30,
                        fontSize:
                        9,
                      ),
                    ),
                    const SizedBox(
                      height:
                      4,
                    ),
                    Text(
                      value,
                      style:
                      const TextStyle(
                        color:
                        Colors.white70,
                        fontSize:
                        12,
                        fontWeight:
                        FontWeight.w600,
                        height:
                        1.35,
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
            height:
            1,
            color:
            Colors.white.withOpacity(
              0.06,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width:
          double.infinity,
          child:
          ElevatedButton.icon(
            onPressed:
            _openEdit,
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              accent,
              foregroundColor:
              Colors.white,
              minimumSize:
              const Size.fromHeight(
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
            const Icon(
              Icons.edit_rounded,
            ),
            label:
            const Text(
              'Edit Data Fuel Injection Pump',
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
          10,
        ),

        SizedBox(
          width:
          double.infinity,
          child:
          OutlinedButton.icon(
            onPressed:
            _deleteFip,
            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              redAccent,
              minimumSize:
              const Size.fromHeight(
                52,
              ),
              side:
              BorderSide(
                color:
                redAccent.withOpacity(
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
              Icons.delete_outline_rounded,
            ),
            label:
            const Text(
              'Hapus Fuel Injection Pump',
            ),
          ),
        ),
      ],
    );
  }
}

class _FipEditSheet
    extends StatefulWidget {
  final Fip fip;

  const _FipEditSheet({
    required this.fip,
  });

  @override
  State<_FipEditSheet> createState() =>
      _FipEditSheetState();
}

class _FipEditSheetState
    extends State<_FipEditSheet> {
  static const Color accent =
  Color(0xffff6a00);

  static const Color background =
  Color(0xff101010);

  final GlobalKey<FormState>
  _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _namaController;

  late final TextEditingController
  _fuelInjectionController;

  late final TextEditingController
  _partNoController;

  late final TextEditingController
  _brandController;

  late final TextEditingController
  _minStockController;

  bool _saving =
  false;

  @override
  void initState() {
    super.initState();

    _namaController =
        TextEditingController(
          text:
          widget.fip.nama,
        );

    _fuelInjectionController =
        TextEditingController(
          text:
          widget.fip.fuelInjection,
        );

    _partNoController =
        TextEditingController(
          text:
          widget.fip.partNo,
        );

    _brandController =
        TextEditingController(
          text:
          widget.fip.brand,
        );

    _minStockController =
        TextEditingController(
          text:
          widget.fip.minStock
              .toString(),
        );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _fuelInjectionController.dispose();
    _partNoController.dispose();
    _brandController.dispose();
    _minStockController.dispose();

    super.dispose();
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
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    final number =
    int.tryParse(
      text,
    );

    if (number == null) {
      return 'Harus berupa angka';
    }

    if (number < 0) {
      return 'Tidak boleh negatif';
    }

    return null;
  }

  String? _optionalText(
      TextEditingController controller,
      ) {
    final text =
    controller.text.trim();

    return text.isEmpty
        ? null
        : text;
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

    setState(() {
      _saving = true;
    });

    try {
      await FipApi.updateFip(
        widget.fip.id,
        {
          'nama':
          _namaController
              .text
              .trim(),
          'fuel_injection':
          _optionalText(
            _fuelInjectionController,
          ),
          'part_no':
          _optionalText(
            _partNoController,
          ),
          'brand':
          _optionalText(
            _brandController,
          ),
          'min_stock':
          int.tryParse(
            _minStockController
                .text
                .trim(),
          ) ??
              5,
        },
      );

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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior.floating,
            backgroundColor:
            Colors.redAccent,
            content:
            Text(
              'Gagal memperbarui Fuel Injection Pump: $error',
            ),
          ),
        );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final bottomInset =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return Container(
      constraints:
      BoxConstraints(
        maxHeight:
        MediaQuery.of(context)
            .size
            .height *
            0.91,
      ),
      padding:
      EdgeInsets.only(
        bottom:
        bottomInset,
      ),
      decoration:
      const BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.vertical(
          top:
          Radius.circular(
            28,
          ),
        ),
      ),
      child:
      SafeArea(
        top:
        false,
        child:
        Form(
          key:
          _formKey,
          child:
          Column(
            children: [
              const SizedBox(
                height:
                10,
              ),

              Container(
                width:
                45,
                height:
                4,
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

              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  17,
                  10,
                  12,
                ),
                child:
                Row(
                  children: [
                    const Expanded(
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Fuel Injection Pump',
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
                          SizedBox(
                            height:
                            4,
                          ),
                          Text(
                            'Perbarui informasi master pump',
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

                    IconButton(
                      onPressed:
                      _saving
                          ? null
                          : () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon:
                      const Icon(
                        Icons.close_rounded,
                        color:
                        Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height:
                1,
                color:
                Colors.white.withOpacity(
                  0.07,
                ),
              ),

              Expanded(
                child:
                ListView(
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
                      _namaController,
                      label:
                      'Nama Fuel Injection Pump',
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
                      icon:
                      Icons.factory_outlined,
                    ),

                    _field(
                      controller:
                      _fuelInjectionController,
                      label:
                      'Fuel Injection',
                      icon:
                      Icons.tune_rounded,
                    ),

                    _field(
                      controller:
                      _partNoController,
                      label:
                      'Part Number',
                      icon:
                      Icons.numbers_rounded,
                    ),

                    _field(
                      controller:
                      _minStockController,
                      label:
                      'Minimum Stok',
                      icon:
                      Icons.warning_amber_rounded,
                      keyboardType:
                      TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                      ],
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
                child:
                SizedBox(
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
                      accent,
                      foregroundColor:
                      Colors.white,
                      disabledBackgroundColor:
                      accent.withOpacity(
                        0.4,
                      ),
                      minimumSize:
                      const Size.fromHeight(
                        54,
                      ),
                      elevation:
                      0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          17,
                        ),
                      ),
                    ),
                    icon:
                    _saving
                        ? const SizedBox(
                      width:
                      19,
                      height:
                      19,
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
                          : 'Simpan Perubahan',
                      style:
                      const TextStyle(
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
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    List<TextInputFormatter>?
    inputFormatters,
    String? Function(String?)?
    validator,
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
        keyboardType:
        keyboardType,
        inputFormatters:
        inputFormatters,
        validator:
        validator,
        enabled:
        !_saving,
        style:
        const TextStyle(
          color:
          Colors.white,
          fontSize:
          13,
        ),
        decoration:
        InputDecoration(
          labelText:
          label,
          labelStyle:
          const TextStyle(
            color:
            Colors.white38,
            fontSize:
            11,
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
}