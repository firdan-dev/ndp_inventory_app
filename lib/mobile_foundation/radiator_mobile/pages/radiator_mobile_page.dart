import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:ndp_inventory_app/models/radiator_model.dart';
import 'package:ndp_inventory_app/services/radiator_api.dart';
import 'package:ndp_inventory_app/mobile_foundation/radiator_mobile/pages/radiator_detail_mobile_page.dart';
import 'package:ndp_inventory_app/mobile_foundation/radiator_mobile/pages/radiator_form_mobile_page.dart';
import 'package:ndp_inventory_app/mobile_foundation/radiator_mobile/pages/radiator_history_mobile_page.dart';
import 'package:ndp_inventory_app/mobile_foundation/radiator_mobile/pages/radiator_stock_form_mobile_page.dart';


class RadiatorMobilePage extends StatefulWidget {
  const RadiatorMobilePage({
    super.key,
  });

  @override
  State<RadiatorMobilePage> createState() =>
      _RadiatorMobilePageState();
}

class _RadiatorMobilePageState
    extends State<RadiatorMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);

  final TextEditingController _searchController =
  TextEditingController();

  List<Radiator> _radiators = [];
  List<Radiator> _filteredRadiators = [];

  bool _loading = true;
  bool _refreshing = false;

  String? _errorMessage;
  String _selectedFilter = 'Semua';

  final List<String> _stockFilters = const [
    'Semua',
    'Tersedia',
    'Menipis',
    'Kosong',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRadiators();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRadiators({
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
      final result =
      await RadiatorApi.getRadiators();

      if (!mounted) return;

      setState(() {
        _radiators = result;
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

  Future<void> _refresh() async {
    await _fetchRadiators(refresh: true);
  }

  void _applyFilter() {
    final query =
    _searchController.text.trim().toLowerCase();

    _filteredRadiators =
        _radiators.where((radiator) {
          final searchableText = [
            radiator.kodeRadiator,
            radiator.namaRadiator,
            radiator.barcode,
            radiator.modelSarang ?? '',
            radiator.lokasi ?? '',
            radiator.ukuranText,
          ].join(' ').toLowerCase();

          final matchSearch =
              query.isEmpty ||
                  searchableText.contains(query);

          bool matchFilter;

          switch (_selectedFilter) {
            case 'Tersedia':
              matchFilter =
                  radiator.stok > radiator.minStock;
              break;

            case 'Menipis':
              matchFilter =
                  radiator.stok > 0 &&
                      radiator.stok <= radiator.minStock;
              break;

            case 'Kosong':
              matchFilter = radiator.stok <= 0;
              break;

            case 'Semua':
            default:
              matchFilter = true;
          }

          return matchSearch && matchFilter;
        }).toList();
  }

  void _onSearchChanged(String value) {
    setState(_applyFilter);
  }

  void _changeFilter(String value) {
    setState(() {
      _selectedFilter = value;
      _applyFilter();
    });
  }

  int get _totalStock {
    return _radiators.fold<int>(
      0,
          (total, radiator) =>
      total + radiator.stok,
    );
  }

  int get _lowStockCount {
    return _radiators.where((radiator) {
      return radiator.stok > 0 &&
          radiator.stok <= radiator.minStock;
    }).length;
  }

  int get _emptyStockCount {
    return _radiators.where((radiator) {
      return radiator.stok <= 0;
    }).length;
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

  String _stockLabel(Radiator radiator) {
    if (radiator.stok <= 0) {
      return 'Kosong';
    }

    if (radiator.stok <= radiator.minStock) {
      return 'Menipis';
    }

    return 'Tersedia';
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

  Future<void> _openAddRadiator() async {
    final result =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
        const RadiatorFormMobilePage(),
      ),
    );

    if (result == true) {
      await _fetchRadiators(refresh: true);
    }
  }

  Future<void> _openDetail(
      Radiator radiator,
      ) async {
    final result =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            RadiatorDetailMobilePage(
              radiator: radiator,
            ),
      ),
    );

    if (result == true) {
      await _fetchRadiators(refresh: true);
    }
  }

  Future<void> _openStockForm({
    required bool isStockIn,
  }) async {
    final result =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            RadiatorStockFormMobilePage(
              isStockIn: isStockIn,
            ),
      ),
    );

    if (result == true) {
      await _fetchRadiators(refresh: true);
    }
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
        const RadiatorHistoryMobilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _openAddRadiator,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Tambah Radiator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: -130,
            child: _buildGlow(
              color: accent,
              size: 300,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -150,
            child: _buildGlow(
              color: const Color(0xff64b5f6),
              size: 300,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: accent,
              backgroundColor:
              const Color(0xff1a1a1a),
              child: CustomScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent:
                  BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      120,
                    ),
                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(height: 18),
                          _buildSummary(),
                          const SizedBox(height: 16),
                          _buildActions(),
                          const SizedBox(height: 18),
                          _buildSearchField(),
                          const SizedBox(height: 13),
                          _buildFilters(),
                          const SizedBox(height: 22),
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
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: accent,
                backgroundColor:
                Colors.transparent,
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
            onTap: () =>
                Navigator.maybePop(context),
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
                'Stock Radiator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola stok, ukuran dan barcode radiator',
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
      borderRadius:
      BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color:
            Colors.white.withOpacity(0.035),
            borderRadius:
            BorderRadius.circular(24),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryItem(
                      title: 'Jenis Radiator',
                      value: _radiators.length,
                      icon: Icons
                          .inventory_2_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _summaryItem(
                      title: 'Total Stok',
                      value: _totalStock,
                      icon: Icons
                          .warehouse_outlined,
                      color: greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _summaryItem(
                      title: 'Stok Menipis',
                      value: _lowStockCount,
                      icon: Icons
                          .warning_amber_rounded,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _summaryItem(
                      title: 'Stok Kosong',
                      value: _emptyStockCount,
                      icon:
                      Icons.remove_shopping_cart_outlined,
                      color: redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            title: 'Stock In',
            icon: Icons.login_rounded,
            color: greenAccent,
            onTap: () => _openStockForm(
              isStockIn: true,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _actionButton(
            title: 'Stock Out',
            icon: Icons.logout_rounded,
            color: redAccent,
            onTap: () => _openStockForm(
              isStockIn: false,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _actionButton(
            title: 'History',
            icon: Icons.history_rounded,
            color: const Color(0xff64b5f6),
            onTap: _openHistory,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 7,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius:
            BorderRadius.circular(17),
            border: Border.all(
              color: color.withOpacity(0.18),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textInputAction:
      TextInputAction.search,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText:
        'Cari kode, nama, ukuran atau lokasi...',
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 11,
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
          onPressed: () {
            _searchController.clear();
            _onSearchChanged('');
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white38,
            size: 20,
          ),
        ),
        filled: true,
        fillColor:
        Colors.white.withOpacity(0.045),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide(
            color:
            Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide(
            color: accent.withOpacity(0.70),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 39,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
        const BouncingScrollPhysics(),
        itemCount: _stockFilters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter =
          _stockFilters[index];

          final selected =
              _selectedFilter == filter;

          final color = filter == 'Kosong'
              ? redAccent
              : filter == 'Menipis'
              ? accent
              : filter == 'Tersedia'
              ? greenAccent
              : Colors.white;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _changeFilter(filter),
              borderRadius:
              BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.16)
                      : Colors.white
                      .withOpacity(0.035),
                  borderRadius:
                  BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? color.withOpacity(0.45)
                        : Colors.white
                        .withOpacity(0.08),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected
                        ? color
                        : Colors.white38,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Radiator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Tekan card untuk melihat detail',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: accent.withOpacity(0.17),
            ),
          ),
          child: Text(
            '${_filteredRadiators.length} data',
            style: const TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
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
        _radiators.isEmpty) {
      return _buildError();
    }

    if (_filteredRadiators.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: List.generate(
        _filteredRadiators.length,
            (index) {
          final radiator =
          _filteredRadiators[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom:
              index <
                  _filteredRadiators
                      .length -
                      1
                  ? 11
                  : 0,
            ),
            child:
            _buildRadiatorCard(radiator),
          );
        },
      ),
    );
  }

  Widget _buildRadiatorCard(
      Radiator radiator,
      ) {
    final stockColor =
    _stockColor(radiator);

    final hasImage =
        radiator.radiatorImage != null &&
            radiator.radiatorImage!
                .trim()
                .isNotEmpty;

    final imageUrl =
        'https://api.api-nusantaradiesel.tech'
        '${radiator.radiatorImage ?? ''}';

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                _openDetail(radiator),
            borderRadius:
            BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                Colors.white.withOpacity(0.035),
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
                    offset:
                    const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(17),
                        child: SizedBox(
                          width: 76,
                          height: 76,
                          child: hasImage
                              ? Image.network(
                            imageUrl,
                            fit:
                            BoxFit.cover,
                            loadingBuilder: (
                                context,
                                child,
                                progress,
                                ) {
                              if (progress ==
                                  null) {
                                return child;
                              }

                              return Container(
                                color: Colors
                                    .white
                                    .withOpacity(
                                  0.04,
                                ),
                                alignment:
                                Alignment
                                    .center,
                                child:
                                const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child:
                                  CircularProgressIndicator(
                                    color:
                                    accent,
                                    strokeWidth:
                                    2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (
                                context,
                                error,
                                stackTrace,
                                ) {
                              return _buildImagePlaceholder();
                            },
                          )
                              : _buildImagePlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 13),
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
                              style:
                              const TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              radiator.namaRadiator,
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight:
                                FontWeight
                                    .w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              radiator.ukuranText,
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors.white38,
                                fontSize: 9,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: stockColor
                              .withOpacity(0.12),
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                          border: Border.all(
                            color: stockColor
                                .withOpacity(0.33),
                          ),
                        ),
                        child: Text(
                          _stockLabel(radiator),
                          style: TextStyle(
                            color: stockColor,
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
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
                        child: _infoItem(
                          icon: Icons
                              .inventory_2_outlined,
                          label: 'Stok',
                          value:
                          '${radiator.stok} pcs',
                          color: stockColor,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _infoItem(
                          icon:
                          Icons.location_on_outlined,
                          label: 'Lokasi',
                          value: _safeText(
                            radiator.lokasi,
                          ),
                          color:
                          Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _infoItem(
                          icon:
                          Icons.grid_view_outlined,
                          label:
                          'Model Sarang',
                          value: _safeText(
                            radiator.modelSarang,
                          ),
                          color:
                          Colors.white54,
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

  Widget _buildImagePlaceholder() {
    return Container(
      color:
      Colors.white.withOpacity(0.045),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white24,
        size: 31,
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.025),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.055),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: 230,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.025),
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: accent,
            strokeWidth: 3,
          ),
          SizedBox(height: 15),
          Text(
            'Mengambil data radiator...',
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
        borderRadius:
        BorderRadius.circular(24),
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
            'Gagal mengambil data radiator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () {
              _fetchRadiators();
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
            const Text('Cob Lagi'),
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
        color:
        Colors.white.withOpacity(0.025),
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons
                .inventory_2_outlined,
            color: Colors.white24,
            size: 43,
          ),
          SizedBox(height: 13),
          Text(
            'Data radiator tidak ditemukan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Coba ubah pencarian atau filter stok',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}