import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../services/service_customer_api.dart';

class ServiceCustomerFormMobilePage extends StatefulWidget {
  const ServiceCustomerFormMobilePage({
    super.key,
  });

  @override
  State<ServiceCustomerFormMobilePage> createState() =>
      _ServiceCustomerFormMobilePageState();
}

class _ServiceCustomerFormMobilePageState
    extends State<ServiceCustomerFormMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerController =
  TextEditingController();

  final TextEditingController _jenisBarangController =
  TextEditingController();

  final TextEditingController _typeUnitController =
  TextEditingController();

  final TextEditingController _partNoController =
  TextEditingController();

  DateTime _tanggalMasuk = DateTime.now();
  DateTime? _tanggalDikerjakan;

  bool _saving = false;

  @override
  void dispose() {
    _customerController.dispose();
    _jenisBarangController.dispose();
    _typeUnitController.dispose();
    _partNoController.dispose();

    super.dispose();
  }

  String _dateToApi(DateTime? value) {
    if (value == null) return '';

    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _dateToDisplay(DateTime? value) {
    if (value == null) return 'Belum ditentukan';

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
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

  Future<void> _pickTanggalMasuk() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _tanggalMasuk,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal masuk',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accent,
              surface: Color(0xff191919),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xff191919),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _tanggalMasuk = selected;
    });
  }

  Future<void> _pickTanggalDikerjakan() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
      _tanggalDikerjakan ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal dikerjakan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accent,
              surface: Color(0xff191919),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xff191919),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _tanggalDikerjakan = selected;
    });
  }

  Future<void> _saveService() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    final valid =
        _formKey.currentState?.validate() ?? false;

    if (!valid) return;

    setState(() {
      _saving = true;
    });

    try {
      await ServiceCustomerApi.create({
        'tanggal_in': _dateToApi(_tanggalMasuk),

        'tanggal_dikerjakan':
        _tanggalDikerjakan == null
            ? null
            : _dateToApi(
          _tanggalDikerjakan,
        ),

        'nama_customer':
        _customerController.text.trim(),

        'jenis_barang':
        _jenisBarangController.text.trim(),

        'type_unit':
        _typeUnitController.text.trim(),

        'part_no':
        _partNoController.text.trim(),

        'mekanik_bongkar_id': null,
        'mekanik_pasang_id': null,

        'status': _tanggalDikerjakan == null
            ? 'Waiting'
            : 'On Progress',
      });

      if (!mounted) return;

      _showMessage(
        'Service customer berhasil ditambahkan',
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Gagal menambahkan service: $error',
        error: true,
      );
    }
  }

  Future<bool> _onBack() async {
    if (_saving) return false;

    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      onPopInvokedWithResult: (
          bool didPop,
          dynamic result,
          ) {
        if (!didPop && !_saving) {
          Navigator.pop(context);
        }
      },
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
            SafeArea(
              child: Form(
                key: _formKey,
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
                        14,
                        18,
                        110,
                      ),
                      sliver: SliverList(
                        delegate:
                        SliverChildListDelegate(
                          [
                            _buildHeader(),
                            const SizedBox(height: 18),
                            _buildIntroCard(),
                            const SizedBox(height: 15),
                            _buildCustomerSection(),
                            const SizedBox(height: 15),
                            _buildUnitSection(),
                            const SizedBox(height: 15),
                            _buildDateSection(),
                            const SizedBox(height: 22),
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
            onTap: _saving
                ? null
                : () => Navigator.pop(context),
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
                'Tambah Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Masukkan data barang milik customer',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntroCard() {
    return _glassCard(
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.11),
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color: accent.withOpacity(0.20),
              ),
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              color: accent,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Service Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Nomor service akan dibuat otomatis oleh sistem',
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

  Widget _buildCustomerSection() {
    return _sectionCard(
      title: 'Informasi Customer',
      subtitle: 'Masukkan identitas customer',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _textField(
            controller: _customerController,
            label: 'Nama Customer',
            hint: 'Contoh: PT Nusantara Diesel',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Nama customer wajib diisi';
              }

              return null;
            },
          ),
          _textField(
            controller: _jenisBarangController,
            label: 'Jenis Barang',
            hint:
            'Contoh: Injector, FIP, Supply Pump',
            icon:
            Icons.inventory_2_outlined,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Jenis barang wajib diisi';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSection() {
    return _sectionCard(
      title: 'Informasi Unit',
      subtitle: 'Data unit dan part number',
      icon:
      Icons.precision_manufacturing_outlined,
      child: Column(
        children: [
          _textField(
            controller: _typeUnitController,
            label: 'Type Unit',
            hint:
            'Contoh: CAT 320D, Fortuner 2KD',
            icon:
            Icons.precision_manufacturing_outlined,
          ),
          _textField(
            controller: _partNoController,
            label: 'Part Number',
            hint: 'Masukkan part number',
            icon: Icons.numbers_rounded,
            textCapitalization:
            TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return _sectionCard(
      title: 'Tanggal Service',
      subtitle:
      'Tanggal masuk dan mulai pengerjaan',
      icon: Icons.calendar_month_rounded,
      child: Column(
        children: [
          _dateTile(
            title: 'Tanggal Masuk',
            value: _tanggalMasuk,
            requiredField: true,
            onTap: _pickTanggalMasuk,
          ),
          const SizedBox(height: 11),
          _dateTile(
            title: 'Tanggal Dikerjakan',
            value: _tanggalDikerjakan,
            requiredField: false,
            onTap: _pickTanggalDikerjakan,
            onClear: _tanggalDikerjakan == null
                ? null
                : () {
              setState(() {
                _tanggalDikerjakan = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.055),
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: accent.withOpacity(0.14),
              ),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: accent,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tanggalDikerjakan == null
                        ? 'Service akan dibuat dengan status Waiting.'
                        : 'Karena tanggal dikerjakan sudah diisi, status awal menjadi On Progress.',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      height: 1.45,
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
        _saving ? null : _saveService,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          accent.withOpacity(0.45),
          minimumSize:
          const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
        icon: _saving
            ? const SizedBox(
          width: 21,
          height: 21,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.3,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.save_rounded,
        ),
        label: Text(
          _saving
              ? 'Menyimpan Service...'
              : 'Simpan Service',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType =
        TextInputType.text,
    TextCapitalization textCapitalization =
        TextCapitalization.sentences,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization:
        textCapitalization,
        textInputAction:
        TextInputAction.next,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
          hintStyle: const TextStyle(
            color: Colors.white24,
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
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 10,
          ),
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
            borderSide: BorderSide(
              color: accent.withOpacity(0.70),
              width: 1.2,
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
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
    required bool requiredField,
    VoidCallback? onClear,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _saving ? null : onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color:
            Colors.white.withOpacity(0.04),
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                  accent.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: accent,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                        if (requiredField) ...[
                          const SizedBox(width: 3),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateToDisplay(value),
                      style: TextStyle(
                        color: value == null
                            ? Colors.white30
                            : Colors.white,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  onPressed:
                  _saving ? null : onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white38,
                    size: 19,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return _glassCard(
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
                  color:
                  accent.withOpacity(0.10),
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
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                  ],
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

  Widget _glassCard({
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color:
            Colors.white.withOpacity(0.035),
            borderRadius:
            BorderRadius.circular(23),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}