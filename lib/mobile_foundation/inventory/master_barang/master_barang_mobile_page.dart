import 'dart:convert';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../utils/print_helper.dart';
import '../../../models/barang_model.dart';

class MasterBarangMobilePage extends StatefulWidget {
  const MasterBarangMobilePage({super.key});

  @override
  State<MasterBarangMobilePage> createState() =>
      _MasterBarangMobilePageState();
}

class _MasterBarangMobilePageState
    extends State<MasterBarangMobilePage> {
  static const Color accent = Color(0xffff6a00);

  static const String _productsUrl =
      'https://api.api-nusantaradiesel.tech/api/products';

  final TextEditingController _searchController =
  TextEditingController();

  List<Barang> _allItems = [];
  List<Barang> _filteredItems = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBarang({
    bool refresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }

      _errorMessage = null;
    });

    try {
      final response = await http
          .get(
        Uri.parse(_productsUrl),
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
          'Format data barang tidak valid',
        );
      }

      final items = decoded
          .whereType<Map>()
          .map(
            (item) =>
            Barang.fromJson(
              Map<String, dynamic>.from(item),
            ),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        _allItems = items;
        _applyFilter();
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      _filteredItems = List<Barang>.from(_allItems);
      return;
    }

    _filteredItems = _allItems.where((item) {
      return item.namaBarang.toLowerCase().contains(query) ||
          item.kodeInternal.toLowerCase().contains(query) ||
          item.kodeSupplier.toLowerCase().contains(query) ||
          item.partNo.toLowerCase().contains(query) ||
          item.barcode.toLowerCase().contains(query) ||
          item.merk.toLowerCase().contains(query) ||
          item.lokasi.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearch(String value) {
    setState(_applyFilter);
  }

  Future<void> _refresh() async {
    await _fetchBarang(refresh: true);
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isLowStock(Barang item) {
    return _parseInt(item.qty) <= _parseInt(item.minStock);
  }

  int get _totalStock {
    return _allItems.fold<int>(
      0,
          (total, item) => total + _parseInt(item.qty),
    );
  }

  int get _lowStockCount {
    return _allItems
        .where(_isLowStock)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Stack(
        children: [
          Positioned(
            top: 30,
            right: -120,
            child: _backgroundGlow(
              color: accent,
              size: 270,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: accent,
              backgroundColor: const Color(0xff191919),
              onRefresh: _refresh,
              child: CustomScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      110,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(height: 18),
                          _buildSummary(),
                          const SizedBox(height: 18),
                          _buildSearch(),
                          const SizedBox(height: 17),
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
          if (_isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
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

  Widget _backgroundGlow({
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
                color: Colors.white.withOpacity(0.045),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Master Barang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola data, stok, lokasi, dan barcode',
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
            onTap: _filteredItems.isEmpty
                ? null
                : _printAllBarcode,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.print_rounded,
                color: accent,
                size: 21,
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
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.12),
                Colors.white.withOpacity(0.045),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _summaryItem(
                  label: 'Jenis Barang',
                  value: _allItems.length.toString(),
                  icon: Icons.category_outlined,
                  color: accent,
                ),
              ),
              _summaryDivider(),
              Expanded(
                child: _summaryItem(
                  label: 'Total Stok',
                  value: _formatNumber(_totalStock),
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xff64b5f6),
                ),
              ),
              _summaryDivider(),
              Expanded(
                child: _summaryItem(
                  label: 'Stok Menipis',
                  value: _lowStockCount.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xffffc107),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      color: Colors.white.withOpacity(0.07),
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
        hintText: 'Cari nama, kode, part no, barcode...',
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
            color: accent.withOpacity(0.65),
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
            'Daftar Barang',
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
            '${_filteredItems.length} data',
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
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null && _allItems.isEmpty) {
      return _buildError();
    }

    if (_filteredItems.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: List.generate(
        _filteredItems.length,
            (index) {
          final item = _filteredItems[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _filteredItems.length - 1
                  ? 11
                  : 0,
            ),
            child: _BarangMobileCard(
              item: item,
              lowStock: _isLowStock(item),
              onTap: () => _showDetail(item),
              onEdit: () => _showEditBarang(item),
              onBarcode: () => _showBarcode(item),
              onPrint: () => _printSingle(item),
              onDelete: () => _confirmDelete(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
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
            'Mengambil data barang...',
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
          color: Colors.redAccent.withOpacity(0.18),
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
            'Gagal mengambil data barang',
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
            onPressed: _fetchBarang,
            icon: const Icon(Icons.refresh_rounded),
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
            Icons.inventory_2_outlined,
            color: Colors.white24,
            size: 43,
          ),
          SizedBox(height: 13),
          Text(
            'Data barang tidak ditemukan',
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

  void _showDetail(Barang item) {
    final qty = _parseInt(item.qty);
    final minStock = _parseInt(item.minStock);
    final lowStock = qty <= minStock;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xff111111),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 59,
                        height: 59,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaBarang,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.partNo,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _stockBadge(
                        qty: qty,
                        lowStock: lowStock,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _detailRow(
                    'Kode Internal',
                    item.kodeInternal,
                  ),
                  _detailRow(
                    'Kode Supplier',
                    item.kodeSupplier,
                  ),
                  _detailRow('Merk', item.merk),
                  _detailRow('Lokasi', item.lokasi),
                  _detailRow('Barcode', item.barcode),
                  _detailRow(
                    'Minimum Stok',
                    item.minStock,
                  ),
                  const SizedBox(height: 19),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showBarcode(item);
                          },
                          icon: const Icon(
                            Icons.qr_code_2_rounded,
                          ),
                          label: const Text('Barcode'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            minimumSize:
                            const Size.fromHeight(49),
                            side: BorderSide(
                              color:
                              Colors.white.withOpacity(0.10),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showEditBarang(item);
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize:
                            const Size.fromHeight(49),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
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
              value.isEmpty ? '-' : value,
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

  Widget _stockBadge({
    required int qty,
    required bool lowStock,
  }) {
    final color = lowStock
        ? const Color(0xffff6b6b)
        : const Color(0xff43d17b);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Text(
        '$qty pcs',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _showEditBarang(Barang item) async {
    final kodeInternal = TextEditingController(
      text: item.kodeInternal,
    );
    final kodeSupplier = TextEditingController(
      text: item.kodeSupplier,
    );
    final namaBarang = TextEditingController(
      text: item.namaBarang,
    );
    final partNo = TextEditingController(
      text: item.partNo,
    );
    final merk = TextEditingController(
      text: item.merk,
    );
    final lokasi = TextEditingController(
      text: item.lokasi,
    );
    final minStock = TextEditingController(
      text: item.minStock,
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
                bottom:
                MediaQuery
                    .viewInsetsOf(context)
                    .bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery
                      .sizeOf(context)
                      .height * 0.91,
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
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        19,
                        20,
                        14,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Edit Barang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: saving
                                ? null
                                : () =>
                                Navigator.pop(sheetContext),
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
                      color: Colors.white.withOpacity(0.07),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          17,
                          20,
                          20,
                        ),
                        child: Column(
                          children: [
                            _formField(
                              controller: kodeInternal,
                              label: 'Kode Internal',
                              icon: Icons.tag_rounded,
                            ),
                            _formField(
                              controller: kodeSupplier,
                              label: 'Kode Supplier',
                              icon: Icons.store_outlined,
                            ),
                            _formField(
                              controller: namaBarang,
                              label: 'Nama Barang',
                              icon:
                              Icons.inventory_2_outlined,
                            ),
                            _formField(
                              controller: partNo,
                              label: 'Part Number',
                              icon: Icons.numbers_rounded,
                            ),
                            _formField(
                              controller: merk,
                              label: 'Merk',
                              icon: Icons.branding_watermark_outlined,
                            ),
                            _formField(
                              controller: lokasi,
                              label: 'Lokasi',
                              icon: Icons.location_on_outlined,
                            ),
                            _formField(
                              controller: minStock,
                              label: 'Minimum Stok',
                              icon:
                              Icons.warning_amber_rounded,
                              keyboardType:
                              TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
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
                                  : () =>
                                  Navigator.pop(sheetContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                minimumSize:
                                const Size.fromHeight(51),
                                side: BorderSide(
                                  color: Colors.white
                                      .withOpacity(0.10),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                if (namaBarang.text
                                    .trim()
                                    .isEmpty) {
                                  _showMessage(
                                    'Nama barang wajib diisi',
                                    error: true,
                                  );
                                  return;
                                }

                                setSheetState(() {
                                  saving = true;
                                });

                                final success =
                                await _updateBarang(
                                  item: item,
                                  kodeInternal:
                                  kodeInternal.text,
                                  kodeSupplier:
                                  kodeSupplier.text,
                                  namaBarang:
                                  namaBarang.text,
                                  partNo: partNo.text,
                                  merk: merk.text,
                                  lokasi: lokasi.text,
                                  minStock:
                                  minStock.text,
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                minimumSize:
                                const Size.fromHeight(51),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
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
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            icon,
            color: accent,
            size: 20,
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

  Future<bool> _updateBarang({
    required Barang item,
    required String kodeInternal,
    required String kodeSupplier,
    required String namaBarang,
    required String partNo,
    required String merk,
    required String lokasi,
    required String minStock,
  }) async {
    try {
      final response = await http
          .put(
        Uri.parse('$_productsUrl/${item.id}'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'kode_internal': kodeInternal.trim(),
          'kode_supplier': kodeSupplier.trim(),
          'nama_barang': namaBarang.trim(),
          'part_no': partNo.trim(),
          'merk': merk.trim(),
          'lokasi': lokasi.trim(),
          'min_stock': int.tryParse(minStock) ?? 0,
        }),
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Update gagal dengan status ${response.statusCode}',
        );
      }

      final updatedItem = Barang(
        id: item.id,
        barcode: item.barcode,
        kodeInternal: kodeInternal.trim(),
        kodeSupplier: kodeSupplier.trim(),
        namaBarang: namaBarang.trim(),
        partNo: partNo.trim(),
        merk: merk.trim(),
        lokasi: lokasi.trim(),
        qty: item.qty,
        minStock: (int.tryParse(minStock) ?? 0).toString(),
      );

      if (!mounted) return false;

      setState(() {
        final index = _allItems.indexWhere(
              (element) => element.id == item.id,
        );

        if (index != -1) {
          _allItems[index] = updatedItem;
        }

        _applyFilter();
      });

      _showMessage('Barang berhasil diperbarui');
      return true;
    } catch (error) {
      if (!mounted) return false;

      _showMessage(
        'Gagal memperbarui barang: $error',
        error: true,
      );

      return false;
    }
  }

  void _showBarcode(Barang item) {
    final cleanBarcode = item.barcode
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toUpperCase();

    if (cleanBarcode.isEmpty) {
      _showMessage(
        'Barang ini belum memiliki barcode',
        error: true,
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.80),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff171717),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.09),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.namaBarang,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 23,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: cleanBarcode,
                    width: double.infinity,
                    height: 112,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    drawText: true,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.barcode,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _printSingle(item);
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print Barcode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(49),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _printSingle(Barang item) {
    try {
      printThermal(item.barcode);
    } catch (error) {
      _showMessage(
        'Print barcode gagal: $error',
        error: true,
      );
    }
  }

  void _printAllBarcode() {
    try {
      final barcodes = _filteredItems
          .map((item) => item.barcode)
          .where((barcode) =>
      barcode
          .trim()
          .isNotEmpty)
          .toList();

      if (barcodes.isEmpty) {
        _showMessage(
          'Tidak ada barcode yang dapat dicetak',
          error: true,
        );
        return;
      }

      printMultiple(barcodes);
    } catch (error) {
      _showMessage(
        'Print semua barcode gagal: $error',
        error: true,
      );
    }
  }

  Future<void> _confirmDelete(Barang item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.78),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.redAccent.withOpacity(0.20),
            ),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 29,
            ),
          ),
          title: const Text(
            'Hapus barang?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '${item.namaBarang} akan dihapus permanen.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
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
      await _deleteBarang(item);
    }
  }

  Future<void> _deleteBarang(Barang item) async {
    _showBlockingLoading('Menghapus barang...');

    try {
      final response = await http
          .delete(
        Uri.parse('$_productsUrl/${item.id}'),
        headers: const {
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Hapus gagal dengan status ${response.statusCode}',
        );
      }

      if (!mounted) return;

      setState(() {
        _allItems.removeWhere(
              (element) => element.id == item.id,
        );
        _applyFilter();
      });

      _showMessage('Barang berhasil dihapus');
    } catch (error) {
      if (mounted &&
          Navigator.of(
            context,
            rootNavigator: true,
          ).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      _showMessage(
        'Gagal menghapus barang: $error',
        error: true,
      );
    }
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
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
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

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
    );
  }

  void _showMessage(String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? const Color(0xff6d2525)
              : const Color(0xff202020),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }
}

class _BarangMobileCard extends StatefulWidget {
  final Barang item;
  final bool lowStock;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onBarcode;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  const _BarangMobileCard({
    required this.item,
    required this.lowStock,
    required this.onTap,
    required this.onEdit,
    required this.onBarcode,
    required this.onPrint,
    required this.onDelete,
  });

  @override
  State<_BarangMobileCard> createState() =>
      _BarangMobileCardState();
}

class _BarangMobileCardState
    extends State<_BarangMobileCard> {
  static const Color accent = Color(0xffff6a00);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(widget.item.qty) ?? 0;

    final stockColor = widget.lowStock
        ? const Color(0xffff6b6b)
        : const Color(0xff43d17b);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: () => _showActions(context),
            borderRadius: BorderRadius.circular(22),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _pressed
                        ? accent.withOpacity(0.065)
                        : Colors.white.withOpacity(0.035),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _pressed
                          ? accent.withOpacity(0.30)
                          : Colors.white.withOpacity(0.085),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.22),
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
                            width: 51,
                            height: 51,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: accent.withOpacity(0.20),
                              ),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.namaBarang,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${widget.item.kodeInternal} · '
                                      '${widget.item.partNo}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: stockColor.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              '$qty pcs',
                              style: TextStyle(
                                color: stockColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.055),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _info(
                              Icons.branding_watermark_outlined,
                              widget.item.merk,
                            ),
                          ),
                          Expanded(
                            child: _info(
                              Icons.location_on_outlined,
                              widget.item.lokasi,
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: const Color(0xff202020),
                            tooltip: 'Aksi',
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white38,
                              size: 21,
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  widget.onEdit();
                                  break;
                                case 'barcode':
                                  widget.onBarcode();
                                  break;
                                case 'print':
                                  widget.onPrint();
                                  break;
                                case 'delete':
                                  widget.onDelete();
                                  break;
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: _PopupAction(
                                  icon: Icons.edit_rounded,
                                  label: 'Edit Barang',
                                  color: accent,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'barcode',
                                child: _PopupAction(
                                  icon: Icons.qr_code_2_rounded,
                                  label: 'Lihat Barcode',
                                  color: Colors.white70,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'print',
                                child: _PopupAction(
                                  icon: Icons.print_rounded,
                                  label: 'Print Barcode',
                                  color: Color(0xff43d17b),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: _PopupAction(
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Hapus Barang',
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ),
        ),
    );
  }

  Widget _info(IconData icon, String value) {
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
            value.isEmpty ? '-' : value,
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

  void _showActions(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 17),
                _actionTile(
                  icon: Icons.edit_rounded,
                  title: 'Edit Barang',
                  color: accent,
                  onTap: widget.onEdit,
                  sheetContext: sheetContext,
                ),
                _actionTile(
                  icon: Icons.qr_code_2_rounded,
                  title: 'Lihat Barcode',
                  color: Colors.white70,
                  onTap: widget.onBarcode,
                  sheetContext: sheetContext,
                ),
                _actionTile(
                  icon: Icons.print_rounded,
                  title: 'Print Barcode',
                  color: const Color(0xff43d17b),
                  onTap: widget.onPrint,
                  sheetContext: sheetContext,
                ),
                _actionTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Hapus Barang',
                  color: Colors.redAccent,
                  onTap: widget.onDelete,
                  sheetContext: sheetContext,
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
    required BuildContext sheetContext,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(sheetContext);
        onTap();
      },
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
}

class _PopupAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PopupAction({
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