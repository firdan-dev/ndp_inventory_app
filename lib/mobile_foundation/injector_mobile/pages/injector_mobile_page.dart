import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:ndp_inventory_app/models/injector_model.dart';
import 'package:ndp_inventory_app/services/injector_api.dart';

import 'injector_detail_mobile_page.dart';
import 'injector_form_mobile_page.dart';
import 'injector_history_mobile_page.dart';
import 'injector_stock_form_mobile_page.dart';

class InjectorMobilePage extends StatefulWidget {
  const InjectorMobilePage({
    super.key,
  });

  @override
  State<InjectorMobilePage> createState() =>
      _InjectorMobilePageState();
}

class _InjectorMobilePageState
    extends State<InjectorMobilePage> {
  static const Color accent =
  Color(0xffff6a00);

  static const Color background =
  Color(0xff050505);

  static const Color greenAccent =
  Color(0xff69f0ae);

  static const Color redAccent =
  Color(0xffff5252);

  final TextEditingController
  _searchController =
  TextEditingController();

  List<Injector> _injectors = [];
  List<Injector> _filteredInjectors = [];

  bool _loading = true;
  bool _refreshing = false;

  String? _errorMessage;

  String _selectedFilter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Tersedia',
    'Menipis',
    'Kosong',
  ];

  @override
  void initState() {
    super.initState();

    _fetchInjectors();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _fetchInjectors({
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
      await InjectorApi.getInjectors();

      if (!mounted) return;

      setState(() {
        _injectors = result;

        _applyFilter();

        _loading = false;
        _refreshing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshing = false;

        _errorMessage =
            error.toString();
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchInjectors(
      refresh: true,
    );
  }

  void _applyFilter() {
    final query =
    _searchController.text
        .trim()
        .toLowerCase();

    _filteredInjectors =
        _injectors.where((injector) {
          final searchableText = [
            injector.injectorId,
            injector.kodeInjector,
            injector.nama,
            injector.merk,
            injector.partNo,
            injector.noSeri,
            injector.barcode,
            injector.lokasi,
          ].join(' ').toLowerCase();

          final matchesSearch =
              query.isEmpty ||
                  searchableText.contains(query);

          bool matchesFilter;

          switch (_selectedFilter) {
            case 'Tersedia':
              matchesFilter =
                  injector.qty >
                      injector.minStock;
              break;

            case 'Menipis':
              matchesFilter =
                  injector.qty > 0 &&
                      injector.qty <=
                          injector.minStock;
              break;

            case 'Kosong':
              matchesFilter =
                  injector.qty <= 0;
              break;

            case 'Semua':
            default:
              matchesFilter = true;
          }

          return matchesSearch &&
              matchesFilter;
        }).toList();
  }

  void _onSearchChanged(
      String value,
      ) {
    setState(_applyFilter);
  }

  void _changeFilter(
      String filter,
      ) {
    setState(() {
      _selectedFilter = filter;

      _applyFilter();
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(_applyFilter);
  }

  Color _stockColor(
      Injector injector,
      ) {
    if (injector.qty <= 0) {
      return redAccent;
    }

    if (injector.qty <=
        injector.minStock) {
      return accent;
    }

    return greenAccent;
  }

  String _stockLabel(
      Injector injector,
      ) {
    if (injector.qty <= 0) {
      return 'Kosong';
    }

    if (injector.qty <=
        injector.minStock) {
      return 'Menipis';
    }

    return 'Tersedia';
  }

  Future<void>
  _openAddInjector() async {
    final bool? result =
    await Navigator.of(context)
        .push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return const
          InjectorFormMobilePage();
        },
      ),
    );

    if (result == true &&
        mounted) {
      await _fetchInjectors(
        refresh: true,
      );
    }
  }

  Future<void> _openStockForm({
    required bool isStockIn,
  }) async {
    final bool? result =
    await Navigator.of(context)
        .push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return InjectorStockFormMobilePage(
            isStockIn: isStockIn,
          );
        },
      ),
    );

    if (result == true &&
        mounted) {
      await _fetchInjectors(
        refresh: true,
      );
    }
  }

  Future<void> _openDetail(
      Injector injector,
      ) async {
    final bool? result =
    await Navigator.of(context)
        .push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return InjectorDetailMobilePage(
            injector: injector,
          );
        },
      ),
    );

    if (result == true &&
        mounted) {
      await _fetchInjectors(
        refresh: true,
      );
    }
  }

  Future<void>
  _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) {
          return const
          InjectorHistoryMobilePage();
        },
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: 30,
            right: -120,
            child: _buildGlow(
              color: accent,
              size: 290,
            ),
          ),

          Positioned(
            bottom: 60,
            left: -150,
            child: _buildGlow(
              color:
              const Color(0xff00c9c9),
              size: 300,
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: accent,
              backgroundColor:
              const Color(
                0xff1a1a1a,
              ),
              child:
              CustomScrollView(
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
                    const EdgeInsets
                        .fromLTRB(
                      18,
                      14,
                      18,
                      100,
                    ),
                    sliver:
                    SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _buildHeader(),

                          const SizedBox(
                            height: 18,
                          ),

                          _buildSummary(),

                          const SizedBox(
                            height: 16,
                          ),

                          _buildQuickActions(),

                          const SizedBox(
                            height: 17,
                          ),

                          _buildSearch(),

                          const SizedBox(
                            height: 12,
                          ),

                          _buildFilters(),

                          const SizedBox(
                            height: 22,
                          ),

                          _buildListHeader(),

                          const SizedBox(
                            height: 12,
                          ),

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
              child:
              LinearProgressIndicator(
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
        decoration:
        BoxDecoration(
          shape:
          BoxShape.circle,
          color: color.withOpacity(
            0.02,
          ),
          boxShadow: [
            BoxShadow(
              color:
              color.withOpacity(
                0.08,
              ),
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
              Navigator.pop(context);
            },
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
                'Stock Injector',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Kelola stok dan data master injector',
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
            onTap: _openHistory,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.045),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Icon(
                Icons.history_rounded,
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
    final int total =
        _injectors.length;

    final int available =
        _injectors.where((i) {
          return i.qty >
              i.minStock;
        }).length;

    final int lowStock =
        _injectors.where((i) {
          return i.qty > 0 &&
              i.qty <=
                  i.minStock;
        }).length;

    final int empty =
        _injectors.where((i) {
          return i.qty <= 0;
        }).length;

    return Container(
      padding:
      const EdgeInsets.all(
        15,
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
      child: Row(
        children: [
          Expanded(
            child:
            _summaryItem(
              label: 'Total',
              value: total,
              icon: Icons
                  .precision_manufacturing_outlined,
              color:
              Colors.white,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
            _summaryItem(
              label: 'Tersedia',
              value:
              available,
              icon: Icons
                  .check_circle_outline_rounded,
              color:
              greenAccent,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
            _summaryItem(
              label: 'Menipis',
              value:
              lowStock,
              icon: Icons
                  .warning_amber_rounded,
              color: accent,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
            _summaryItem(
              label: 'Kosong',
              value: empty,
              icon: Icons
                  .error_outline_rounded,
              color:
              redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets
          .symmetric(
        vertical: 12,
        horizontal: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          0.06,
        ),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            value.toString(),
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 18,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow
                .ellipsis,
            style:
            const TextStyle(
              color:
              Colors.white30,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child:
          _actionButton(
            title:
            'Tambah',
            icon:
            Icons.add_rounded,
            color:
            accent,
            onTap:
            _openAddInjector,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
          _actionButton(
            title:
            'Stock In',
            icon: Icons
                .login_rounded,
            color:
            greenAccent,
            onTap: () {
              _openStockForm(
                isStockIn:
                true,
              );
            },
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
          _actionButton(
            title:
            'Stock Out',
            icon: Icons
                .logout_rounded,
            color:
            redAccent,
            onTap: () {
              _openStockForm(
                isStockIn:
                false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback
    onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        child: Container(
          padding:
          const EdgeInsets
              .symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          decoration:
          BoxDecoration(
            color:
            color.withOpacity(
              0.09,
            ),
            borderRadius:
            BorderRadius
                .circular(
              17,
            ),
            border:
            Border.all(
              color:
              color.withOpacity(
                0.19,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                title,
                maxLines: 1,
                style:
                TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller:
      _searchController,
      onChanged:
      _onSearchChanged,
      style:
      const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration:
      InputDecoration(
        hintText:
        'Cari injector, kode, merk atau part number...',
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
          ),
        ),
        filled: true,
        fillColor:
        Colors.white
            .withOpacity(
          0.045,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius
              .circular(
            17,
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
            17,
          ),
          borderSide:
          const BorderSide(
            color: accent,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 39,
      child:
      ListView.separated(
        scrollDirection:
        Axis.horizontal,
        physics:
        const BouncingScrollPhysics(),
        itemCount:
        _filters.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final filter =
          _filters[index];

          final selected =
              _selectedFilter ==
                  filter;

          final color =
          filter == 'Kosong'
              ? redAccent
              : filter ==
              'Menipis'
              ? accent
              : filter ==
              'Tersedia'
              ? greenAccent
              : Colors
              .white;

          return Material(
            color:
            Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _changeFilter(
                    filter,
                  ),
              borderRadius:
              BorderRadius
                  .circular(
                30,
              ),
              child:
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds:
                  180,
                ),
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal:
                  15,
                  vertical: 9,
                ),
                decoration:
                BoxDecoration(
                  color: selected
                      ? color
                      .withOpacity(
                    0.15,
                  )
                      : Colors
                      .white
                      .withOpacity(
                    0.035,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    30,
                  ),
                  border:
                  Border.all(
                    color: selected
                        ? color
                        .withOpacity(
                      0.40,
                    )
                        : Colors
                        .white
                        .withOpacity(
                      0.08,
                    ),
                  ),
                ),
                child: Text(
                  filter,
                  style:
                  TextStyle(
                    color: selected
                        ? color
                        : Colors
                        .white38,
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w700,
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
            CrossAxisAlignment
                .start,
            children: [
              Text(
                'Daftar Injector',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize: 17,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                'Tekan card untuk melihat detail',
                style:
                TextStyle(
                  color:
                  Colors.white30,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration:
          BoxDecoration(
            color:
            accent.withOpacity(
              0.10,
            ),
            borderRadius:
            BorderRadius
                .circular(
              20,
            ),
          ),
          child: Text(
            '${_filteredInjectors.length} data',
            style:
            const TextStyle(
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
      return const SizedBox(
        height: 230,
        child: Center(
          child:
          CircularProgressIndicator(
            color: accent,
          ),
        ),
      );
    }

    if (_errorMessage != null &&
        _injectors.isEmpty) {
      return _buildError();
    }

    if (_filteredInjectors
        .isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children:
      List.generate(
        _filteredInjectors
            .length,
            (index) {
          final injector =
          _filteredInjectors[
          index];

          return Padding(
            padding:
            EdgeInsets.only(
              bottom: index <
                  _filteredInjectors
                      .length -
                      1
                  ? 11
                  : 0,
            ),
            child:
            _buildInjectorCard(
              injector,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInjectorCard(
      Injector injector,
      ) {
    final stockColor =
    _stockColor(injector);

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        22,
      ),
      child:
      BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 14,
          sigmaY: 14,
        ),
        child: Material(
          color:
          Colors.transparent,
          child: InkWell(
            onTap: () =>
                _openDetail(
                  injector,
                ),
            child: Container(
              padding:
              const EdgeInsets
                  .all(
                15,
              ),
              decoration:
              BoxDecoration(
                color:
                Colors.white
                    .withOpacity(
                  0.035,
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
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration:
                    BoxDecoration(
                      color: accent
                          .withOpacity(
                        0.10,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        17,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .precision_manufacturing_outlined,
                      color: accent,
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
                          injector
                              .injectorId,
                          style:
                          const TextStyle(
                            color:
                            accent,
                            fontSize:
                            10,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          injector
                              .nama,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            Colors
                                .white,
                            fontSize:
                            14,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          '${injector.merk.isEmpty ? '-' : injector.merk}'
                              ' • '
                              '${injector.partNo.isEmpty ? '-' : injector.partNo}',
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            Colors
                                .white38,
                            fontSize:
                            9,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          injector
                              .lokasi
                              .isEmpty
                              ? 'Lokasi belum diatur'
                              : injector
                              .lokasi,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            Colors
                                .white24,
                            fontSize:
                            8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .end,
                    children: [
                      Text(
                        '${injector.qty} pcs',
                        style:
                        TextStyle(
                          color:
                          stockColor,
                          fontSize:
                          13,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal:
                          9,
                          vertical: 5,
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
                        ),
                        child: Text(
                          _stockLabel(
                            injector,
                          ),
                          style:
                          TextStyle(
                            color:
                            stockColor,
                            fontSize:
                            8,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
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

  Widget _buildError() {
    return Container(
      padding:
      const EdgeInsets.all(
        25,
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .cloud_off_rounded,
            color:
            Colors.redAccent,
            size: 38,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            _errorMessage ?? '',
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              Colors.white38,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextButton.icon(
            onPressed:
            _fetchInjectors,
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
    );
  }

  Widget _buildEmpty() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .inventory_2_outlined,
              color:
              Colors.white24,
              size: 44,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              'Injector tidak ditemukan',
              style:
              TextStyle(
                color:
                Colors.white54,
                fontSize: 13,
                fontWeight:
                FontWeight
                    .w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}