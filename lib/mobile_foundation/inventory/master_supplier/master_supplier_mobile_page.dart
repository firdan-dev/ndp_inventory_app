import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MasterSupplierMobilePage extends StatefulWidget {
  const MasterSupplierMobilePage({super.key});

  @override
  State<MasterSupplierMobilePage> createState() =>
      _MasterSupplierMobilePageState();
}

class _MasterSupplierMobilePageState
    extends State<MasterSupplierMobilePage> {
  static const Color accent = Color(0xffff6a00);

  static const String _baseUrl =
      'https://api.api-nusantaradiesel.tech/api';

  final TextEditingController _searchController =
  TextEditingController();

  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _filteredSuppliers = [];

  bool _loading = true;
  bool _refreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers({
    bool refresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }

      _errorMessage = null;
    });

    try {
      final response = await http
          .get(
        Uri.parse('$_baseUrl/suppliers'),
        headers: const {
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Server mengembalikan status ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'Format data supplier tidak valid',
        );
      }

      final data = decoded
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        _suppliers = data;
        _applyFilter();
        _loading = false;
        _refreshing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshing = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _applyFilter() {
    final query =
    _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      _filteredSuppliers =
      List<Map<String, dynamic>>.from(_suppliers);
      return;
    }

    _filteredSuppliers = _suppliers.where((supplier) {
      final nama = _text(supplier['nama_supplier'])
          .toLowerCase();
      final kode = _text(supplier['kode_supplier'])
          .toLowerCase();
      final kontak =
      _text(supplier['kontak']).toLowerCase();
      final nomorHp =
      _text(supplier['no_hp']).toLowerCase();
      final alamat =
      _text(supplier['alamat']).toLowerCase();

      return nama.contains(query) ||
          kode.contains(query) ||
          kontak.contains(query) ||
          nomorHp.contains(query) ||
          alamat.contains(query);
    }).toList();
  }

  void _onSearch(String value) {
    setState(_applyFilter);
  }

  Future<void> _refresh() async {
    await _fetchSuppliers(refresh: true);
  }

  String _text(
      dynamic value, {
        String fallback = '-',
      }) {
    final text = value?.toString().trim();

    if (text == null ||
        text.isEmpty ||
        text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSupplierForm(),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 30,
            right: -120,
            child: _buildGlow(
              color: accent,
              size: 280,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: accent,
              backgroundColor:
              const Color(0xff191919),
              onRefresh: _refresh,
              child: CustomScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(height: 18),
                          _buildSummary(),
                          const SizedBox(height: 18),
                          _buildSearch(),
                          const SizedBox(height: 18),
                          _buildListHeader(),
                          const SizedBox(height: 12),
                          _buildContent(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_refreshing)
            const Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: accent,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            ),
        ],
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
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(16),
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
                'Master Supplier',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola supplier dan riwayat transaksi',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(16),
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
                Icons.refresh_rounded,
                color: accent,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.035),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: 'Total Supplier',
                  value: _suppliers.length.toString(),
                  icon: Icons.storefront_outlined,
                  color: accent,
                ),
              ),
              Container(
                width: 1,
                height: 52,
                margin: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                color: Colors.white.withOpacity(0.07),
              ),
              Expanded(
                child: _summaryItem(
                  title: 'Hasil Pencarian',
                  value:
                  _filteredSuppliers.length.toString(),
                  icon: Icons.search_rounded,
                  color: const Color(0xff64b5f6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
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
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearch,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText:
        'Cari nama, kode, kontak, atau alamat...',
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: accent,
          size: 21,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            _searchController.clear();
            _onSearch('');
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white38,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.045),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: accent.withOpacity(0.70),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Daftar Supplier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withOpacity(0.17),
            ),
          ),
          child: Text(
            '${_filteredSuppliers.length} data',
            style: const TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return _buildLoading();
    }

    if (_errorMessage != null &&
        _suppliers.isEmpty) {
      return _buildError();
    }

    if (_filteredSuppliers.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: List.generate(
        _filteredSuppliers.length,
            (index) {
          final supplier =
          _filteredSuppliers[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom:
              index < _filteredSuppliers.length - 1
                  ? 11
                  : 0,
            ),
            child: _buildSupplierCard(supplier),
          );
        },
      ),
    );
  }

  Widget _buildSupplierCard(
      Map<String, dynamic> supplier,
      ) {
    final nama =
    _text(supplier['nama_supplier']);
    final kode =
    _text(supplier['kode_supplier']);
    final kontak = _text(
      supplier['kontak'],
      fallback: _text(supplier['no_hp']),
    );
    final alamat = _text(supplier['alamat']);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showSupplierDetail(supplier),
            onLongPress: () =>
                _showSupplierActions(supplier),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.035),
                borderRadius:
                BorderRadius.circular(22),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color:
                          accent.withOpacity(0.11),
                          borderRadius:
                          BorderRadius.circular(17),
                          border: Border.all(
                            color:
                            accent.withOpacity(0.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: accent,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              kode,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        color:
                        const Color(0xff202020),
                        tooltip: 'Aksi',
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white38,
                          size: 21,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showSupplierForm(
                              supplier: supplier,
                            );
                          }

                          if (value == 'delete') {
                            _confirmDelete(supplier);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: _SupplierPopupAction(
                              icon: Icons.edit_rounded,
                              label: 'Edit Supplier',
                              color: accent,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: _SupplierPopupAction(
                              icon: Icons
                                  .delete_outline_rounded,
                              label: 'Hapus Supplier',
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Divider(
                    height: 1,
                    color:
                    Colors.white.withOpacity(0.06),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _supplierInfo(
                          icon:
                          Icons.phone_outlined,
                          value: kontak,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _supplierInfo(
                          icon: Icons
                              .location_on_outlined,
                          value: alamat,
                        ),
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
  }

  Widget _supplierInfo({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white30,
          size: 15,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: 230,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: accent,
            strokeWidth: 3,
          ),
          SizedBox(height: 15),
          Text(
            'Mengambil data supplier...',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xff1a1010),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
          Colors.redAccent.withOpacity(0.18),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.redAccent,
            size: 36,
          ),
          const SizedBox(height: 13),
          const Text(
            'Gagal mengambil data supplier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _fetchSuppliers,
            icon:
            const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: TextButton.styleFrom(
              foregroundColor: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      height: 210,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_outlined,
            color: Colors.white24,
            size: 43,
          ),
          SizedBox(height: 13),
          Text(
            'Supplier tidak ditemukan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Coba gunakan kata pencarian lain',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showSupplierDetail(
      Map<String, dynamic> supplier,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.78),
      builder: (sheetContext) {
        return _SupplierDetailSheet(
          supplier: supplier,
          baseUrl: _baseUrl,
          onEdit: () {
            Navigator.pop(sheetContext);
            _showSupplierForm(
              supplier: supplier,
            );
          },
          textValue: _text,
        );
      },
    );
  }

  Future<void> _showSupplierForm({
    Map<String, dynamic>? supplier,
  }) async {
    final namaController =
    TextEditingController(
      text: supplier == null
          ? ''
          : _text(
        supplier['nama_supplier'],
        fallback: '',
      ),
    );

    final kontakController =
    TextEditingController(
      text: supplier == null
          ? ''
          : _text(
        supplier['kontak'],
        fallback: '',
      ),
    );

    final alamatController =
    TextEditingController(
      text: supplier == null
          ? ''
          : _text(
        supplier['alamat'],
        fallback: '',
      ),
    );

    final catatanController =
    TextEditingController(
      text: supplier == null
          ? ''
          : _text(
        supplier['catatan'],
        fallback: '',
      ),
    );

    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.78),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context)
                      .size
                      .height *
                      0.90,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff111111),
                  borderRadius:
                  BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        19,
                        20,
                        14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              supplier == null
                                  ? 'Tambah Supplier'
                                  : 'Edit Supplier',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.pop(
                              sheetContext,
                            ),
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
                      Colors.white.withOpacity(0.07),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                        const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          20,
                        ),
                        child: Column(
                          children: [
                            _formField(
                              controller:
                              namaController,
                              label: 'Nama Supplier',
                              icon: Icons
                                  .storefront_outlined,
                            ),
                            _formField(
                              controller:
                              kontakController,
                              label: 'Kontak',
                              icon:
                              Icons.phone_outlined,
                              keyboardType:
                              TextInputType.phone,
                            ),
                            _formField(
                              controller:
                              alamatController,
                              label: 'Alamat',
                              icon: Icons
                                  .location_on_outlined,
                              maxLines: 3,
                            ),
                            _formField(
                              controller:
                              catatanController,
                              label: 'Catatan',
                              icon:
                              Icons.notes_rounded,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.pop(
                                sheetContext,
                              ),
                              style:
                              OutlinedButton.styleFrom(
                                foregroundColor:
                                Colors.white70,
                                minimumSize:
                                const Size.fromHeight(
                                  51,
                                ),
                                side: BorderSide(
                                  color: Colors.white
                                      .withOpacity(0.10),
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              child:
                              const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                if (namaController
                                    .text
                                    .trim()
                                    .isEmpty) {
                                  _showMessage(
                                    'Nama supplier wajib diisi',
                                    error: true,
                                  );
                                  return;
                                }

                                setSheetState(() {
                                  saving = true;
                                });

                                final success =
                                await _saveSupplier(
                                  supplier: supplier,
                                  namaSupplier:
                                  namaController
                                      .text,
                                  kontak:
                                  kontakController
                                      .text,
                                  alamat:
                                  alamatController
                                      .text,
                                  catatan:
                                  catatanController
                                      .text,
                                );

                                if (!context.mounted) {
                                  return;
                                }

                                setSheetState(() {
                                  saving = false;
                                });

                                if (success) {
                                  Navigator.pop(
                                    sheetContext,
                                  );
                                }
                              },
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor:
                                Colors.white,
                                minimumSize:
                                const Size.fromHeight(
                                  51,
                                ),
                                elevation: 0,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              child: saving
                                  ? const SizedBox(
                                width: 21,
                                height: 21,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                                  : const Text(
                                'Simpan',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w700,
                                ),
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
          },
        );
      },
    );

    // Controller lokal tidak di-dispose manual agar tidak
    // bentrok dengan animasi penutupan bottom sheet.
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              bottom: maxLines > 1 ? 44 : 0,
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: accent.withOpacity(0.70),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _saveSupplier({
    required Map<String, dynamic>? supplier,
    required String namaSupplier,
    required String kontak,
    required String alamat,
    required String catatan,
  }) async {
    try {
      final isEditing = supplier != null;

      final uri = isEditing
          ? Uri.parse(
        '$_baseUrl/suppliers/${supplier['id']}',
      )
          : Uri.parse('$_baseUrl/suppliers');

      final body = jsonEncode({
        'nama_supplier': namaSupplier.trim(),
        'kontak': kontak.trim(),
        'alamat': alamat.trim(),
        'catatan': catatan.trim(),
      });

      final response = isEditing
          ? await http
          .put(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      )
          .timeout(
        const Duration(seconds: 20),
      )
          : await http
          .post(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      )
          .timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        String message =
            'Gagal menyimpan supplier';

        try {
          final errorJson =
          jsonDecode(response.body);

          if (errorJson is Map &&
              errorJson['message'] != null) {
            message =
                errorJson['message'].toString();
          }
        } catch (_) {}

        throw Exception(message);
      }

      await _fetchSuppliers(refresh: true);

      if (!mounted) return false;

      _showMessage(
        isEditing
            ? 'Supplier berhasil diperbarui'
            : 'Supplier berhasil ditambahkan',
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      _showMessage(
        'Gagal menyimpan supplier: $error',
        error: true,
      );

      return false;
    }
  }

  Future<void> _confirmDelete(
      Map<String, dynamic> supplier,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.78),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          const Color(0xff181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color:
              Colors.redAccent.withOpacity(0.20),
            ),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
              Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 29,
            ),
          ),
          title: const Text(
            'Hapus supplier?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '${_text(supplier['nama_supplier'])} akan dihapus permanen.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text(
                'Batal',
                style:
                TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteSupplier(supplier);
    }
  }

  Future<void> _deleteSupplier(
      Map<String, dynamic> supplier,
      ) async {
    _showBlockingLoading(
      'Menghapus supplier...',
    );

    try {
      final id = _toInt(supplier['id']);

      final response = await http
          .delete(
        Uri.parse('$_baseUrl/suppliers/$id'),
        headers: const {
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Server mengembalikan status ${response.statusCode}',
        );
      }

      if (!mounted) return;

      setState(() {
        _suppliers.removeWhere(
              (item) => _toInt(item['id']) == id,
        );

        _applyFilter();
      });

      _showMessage(
        'Supplier berhasil dihapus',
      );
    } catch (error) {
      if (mounted &&
          Navigator.of(
            context,
            rootNavigator: true,
          ).canPop()) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();
      }

      if (!mounted) return;

      _showMessage(
        'Gagal menghapus supplier: $error',
        error: true,
      );
    }
  }

  void _showSupplierActions(
      Map<String, dynamic> supplier,
      ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 17),
                _actionTile(
                  icon: Icons.visibility_outlined,
                  title: 'Lihat Detail',
                  color: Colors.white70,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showSupplierDetail(supplier);
                  },
                ),
                _actionTile(
                  icon: Icons.edit_rounded,
                  title: 'Edit Supplier',
                  color: accent,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showSupplierForm(
                      supplier: supplier,
                    );
                  },
                ),
                _actionTile(
                  icon:
                  Icons.delete_outline_rounded,
                  title: 'Hapus Supplier',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(supplier);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.11),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: color,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white24,
      ),
    );
  }

  void _showBlockingLoading(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: const Color(0xff191919),
                borderRadius:
                BorderRadius.circular(21),
                border: Border.all(
                  color:
                  Colors.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: accent,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          elevation: 0,
          backgroundColor: error
              ? const Color(0xff6d2525)
              : const Color(0xff202020),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Icon(
                error
                    ? Icons.error_outline_rounded
                    : Icons
                    .check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _SupplierDetailSheet extends StatefulWidget {
  final Map<String, dynamic> supplier;
  final String baseUrl;
  final VoidCallback onEdit;
  final String Function(
      dynamic value, {
      String fallback,
      }) textValue;

  const _SupplierDetailSheet({
    required this.supplier,
    required this.baseUrl,
    required this.onEdit,
    required this.textValue,
  });

  @override
  State<_SupplierDetailSheet> createState() =>
      _SupplierDetailSheetState();
}

class _SupplierDetailSheetState
    extends State<_SupplierDetailSheet> {
  static const Color accent = Color(0xffff6a00);

  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final id = widget.supplier['id'];

      final response = await http
          .get(
        Uri.parse(
          '${widget.baseUrl}/suppliers/$id/batches',
        ),
        headers: const {
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Status ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'Format riwayat transaksi tidak valid',
        );
      }

      if (!mounted) return;

      setState(() {
        _transactions = decoded
            .whereType<Map>()
            .map(
              (item) =>
          Map<String, dynamic>.from(item),
        )
            .toList();

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  String _formatRupiah(dynamic value) {
    final number =
        double.tryParse(value?.toString() ?? '') ?? 0;

    final formatted =
    number.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
    );

    return 'Rp $formatted';
  }

  String _formatDate(dynamic value) {
    final date =
    DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return '-';

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} '
        '${monthNames[date.month - 1]} '
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final supplier = widget.supplier;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
          MediaQuery.of(context).size.height * 0.91,
        ),
        decoration: const BoxDecoration(
          color: Color(0xff111111),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                19,
                20,
                16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: accent,
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
                          widget.textValue(
                            supplier['nama_supplier'],
                          ),
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.textValue(
                            supplier['kode_supplier'],
                          ),
                          style: const TextStyle(
                            color: accent,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Colors.white.withOpacity(0.07),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  17,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _detailRow(
                      'Kontak',
                      widget.textValue(
                        supplier['kontak'],
                      ),
                    ),
                    _detailRow(
                      'Nomor HP',
                      widget.textValue(
                        supplier['no_hp'],
                      ),
                    ),
                    _detailRow(
                      'Alamat',
                      widget.textValue(
                        supplier['alamat'],
                      ),
                    ),
                    _detailRow(
                      'Catatan',
                      widget.textValue(
                        supplier['catatan'],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Riwayat Transaksi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _fetchTransactions,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: accent,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    _buildTransactions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: accent,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xff1a1010),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              color: Colors.white38,
            ),
            const SizedBox(height: 8),
            const Text(
              'Riwayat belum dapat dimuat',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 9,
              ),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.025),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: Colors.white24,
              size: 33,
            ),
            SizedBox(height: 10),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(
        _transactions.length,
            (index) {
          final transaction =
          _transactions[index];

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              bottom:
              index < _transactions.length - 1
                  ? 10
                  : 0,
            ),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.035),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color:
                Colors.white.withOpacity(0.07),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.textValue(
                          transaction['nama_barang'],
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${transaction['qty'] ?? 0} pcs',
                      style: const TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _transactionInfo(
                  'Part No',
                  widget.textValue(
                    transaction['part_no'],
                  ),
                ),
                _transactionInfo(
                  'Tanggal',
                  _formatDate(
                    transaction['created_at'],
                  ),
                ),
                _transactionInfo(
                  'Harga Beli',
                  _formatRupiah(
                    transaction['harga_beli'],
                  ),
                ),
                _transactionInfo(
                  'Total',
                  _formatRupiah(
                    transaction['total_harga'],
                  ),
                ),
                _transactionInfo(
                  'PIC',
                  widget.textValue(
                    transaction['pic'],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _transactionInfo(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierPopupAction
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SupplierPopupAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 11),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}