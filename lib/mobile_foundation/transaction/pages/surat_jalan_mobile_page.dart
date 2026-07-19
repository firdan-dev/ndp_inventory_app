import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:ndp_inventory_app/services/api_service.dart';
import 'package:ndp_inventory_app/mobile_foundation/transaction/pages/surat_jalan_form_mobile_page.dart';
import 'package:ndp_inventory_app/mobile_foundation/transaction/pages/surat_jalan_detail_mobile_page.dart';

class SuratJalanMobilePage extends StatefulWidget {
  const SuratJalanMobilePage({
    super.key,
  });

  @override
  State<SuratJalanMobilePage> createState() =>
      _SuratJalanMobilePageState();
}

class _SuratJalanMobilePageState extends State<SuratJalanMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);
  static const Color blueAccent = Color(0xff64b5f6);

  final TextEditingController _searchController =
  TextEditingController();

  List<dynamic> _suratJalan = [];
  List<dynamic> _filteredSuratJalan = [];

  bool _loading = true;
  bool _refreshing = false;

  String? _errorMessage;

  String _selectedFilter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Pending',
    'Approved',
    'Dikirim',
  ];

  @override
  void initState() {
    super.initState();
    _loadSuratJalan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuratJalan({
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
      await ApiService.getSuratJalan();

      if (!mounted) return;

      setState(() {
        _suratJalan = result;
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
    await _loadSuratJalan(
      refresh: true,
    );
  }

  void _applyFilter() {
    final query =
    _searchController.text
        .trim()
        .toLowerCase();

    _filteredSuratJalan =
        _suratJalan.where((item) {
          final status =
          _text(
            item['status'],
          );

          final searchableText = [
            _text(item['nomor_surat']),
            _text(item['tujuan_cabang']),
            _text(item['transaction_type']),
            _text(item['kepada']),
            _text(item['pic']),
            _text(item['keterangan']),
            status,
          ].join(' ').toLowerCase();

          final matchesSearch =
              query.isEmpty ||
                  searchableText.contains(query);

          final matchesFilter =
              _selectedFilter == 'Semua' ||
                  status == _selectedFilter;

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

  String _text(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final text =
    value.toString().trim();

    if (text.toLowerCase() ==
        'null') {
      return '';
    }

    return text;
  }

  int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  Color _statusColor(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'approved':
        return greenAccent;

      case 'dikirim':
        return blueAccent;

      case 'pending':
      default:
        return accent;
    }
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline_rounded;

      case 'dikirim':
        return Icons.local_shipping_outlined;

      case 'pending':
      default:
        return Icons.pending_actions_rounded;
    }
  }

  Future<void> _openCreate() async {
    final bool? result =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return const SuratJalanFormMobilePage();
        },
      ),
    );

    if (result == true &&
        mounted) {
      await _loadSuratJalan(
        refresh: true,
      );
    }
  }

  Future<void> _openDetail(
      dynamic item,
      ) async {
    final id =
    _toInt(
      item['id'],
    );

    if (id <= 0) {
      return;
    }

    final bool? result =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return SuratJalanDetailMobilePage(
            suratJalanId: id,
          );
        },
      ),
    );

    if (result == true &&
        mounted) {
      await _loadSuratJalan(
        refresh: true,
      );
    }
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
            top: 70,
            right: -130,
            child: _buildGlow(
              color: accent,
              size: 300,
            ),
          ),

          Positioned(
            bottom: 40,
            left: -160,
            child: _buildGlow(
              color: blueAccent,
              size: 320,
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: accent,
              backgroundColor:
              const Color(
                0xff1b1b1b,
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
                    const EdgeInsets.fromLTRB(
                      24,
                      18,
                      24,
                      110,
                    ),
                    sliver:
                    SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _buildHeader(),

                          const SizedBox(
                            height: 22,
                          ),

                          _buildSummary(),

                          const SizedBox(
                            height: 19,
                          ),

                          _buildCreateButton(),

                          const SizedBox(
                            height: 19,
                          ),

                          _buildSearch(),

                          const SizedBox(
                            height: 14,
                          ),

                          _buildFilters(),

                          const SizedBox(
                            height: 26,
                          ),

                          _buildListHeader(),

                          const SizedBox(
                            height: 14,
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
          color.withOpacity(
            0.015,
          ),
          boxShadow: [
            BoxShadow(
              color:
              color.withOpacity(
                0.08,
              ),
              blurRadius: 130,
              spreadRadius: 45,
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
            borderRadius:
            BorderRadius.circular(
              17,
            ),
            child: Container(
              width: 54,
              height: 54,
              decoration:
              BoxDecoration(
                color:
                Colors.white.withOpacity(
                  0.04,
                ),
                borderRadius:
                BorderRadius.circular(
                  17,
                ),
                border:
                Border.all(
                  color:
                  Colors.white.withOpacity(
                    0.09,
                  ),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Surat Jalan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Kelola pembuatan dan status surat jalan',
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

  Widget _buildSummary() {
    final total =
        _suratJalan.length;

    final pending =
        _suratJalan.where(
              (item) {
            return _text(
              item['status'],
            ) ==
                'Pending';
          },
        ).length;

    final approved =
        _suratJalan.where(
              (item) {
            return _text(
              item['status'],
            ) ==
                'Approved';
          },
        ).length;

    final dikirim =
        _suratJalan.where(
              (item) {
            return _text(
              item['status'],
            ) ==
                'Dikirim';
          },
        ).length;

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        26,
      ),
      child: BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          padding:
          const EdgeInsets.all(
            16,
          ),
          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              colors: [
                Colors.white
                    .withOpacity(
                  0.055,
                ),
                Colors.white
                    .withOpacity(
                  0.025,
                ),
              ],
              begin:
              Alignment.topLeft,
              end:
              Alignment.bottomRight,
            ),
            borderRadius:
            BorderRadius.circular(
              26,
            ),
            border:
            Border.all(
              color:
              Colors.white
                  .withOpacity(
                0.09,
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
                  icon:
                  Icons.description_outlined,
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
                  label: 'Pending',
                  value: pending,
                  icon:
                  Icons.pending_actions_rounded,
                  color: accent,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                _summaryItem(
                  label:
                  'Approved',
                  value:
                  approved,
                  icon:
                  Icons.check_circle_outline_rounded,
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
                  label:
                  'Dikirim',
                  value:
                  dikirim,
                  icon:
                  Icons.local_shipping_outlined,
                  color:
                  blueAccent,
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
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          0.055,
        ),
        borderRadius:
        BorderRadius.circular(
          17,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            value.toString(),
            style:
            const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color: Colors.white30,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
        _openCreate,
        style:
        ElevatedButton.styleFrom(
          backgroundColor:
          accent,
          foregroundColor:
          Colors.white,
          elevation: 0,
          minimumSize:
          const Size.fromHeight(
            58,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),
        ),
        icon:
        const Icon(
          Icons.add_rounded,
          size: 23,
        ),
        label:
        const Text(
          'Buat Surat Jalan',
          style:
          TextStyle(
            fontSize: 14,
            fontWeight:
            FontWeight.w800,
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
        'Cari nomor surat, tujuan, PIC atau penerima...',
        hintStyle:
        const TextStyle(
          color: Colors.white30,
          fontSize: 10,
        ),
        prefixIcon:
        const Icon(
          Icons.search_rounded,
          color: accent,
          size: 22,
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
            Icons.close_rounded,
            color:
            Colors.white38,
          ),
        ),
        filled: true,
        fillColor:
        Colors.white.withOpacity(
          0.04,
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 17,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            19,
          ),
          borderSide:
          BorderSide(
            color:
            Colors.white.withOpacity(
              0.09,
            ),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            19,
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
      height: 43,
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
          width: 9,
        ),
        itemBuilder:
            (context, index) {
          final filter =
          _filters[index];

          final selected =
              _selectedFilter ==
                  filter;

          final color =
          filter == 'Pending'
              ? accent
              : filter ==
              'Approved'
              ? greenAccent
              : filter ==
              'Dikirim'
              ? blueAccent
              : Colors
              .white;

          return Material(
            color:
            Colors.transparent,
            child: InkWell(
              onTap: () {
                _changeFilter(
                  filter,
                );
              },
              borderRadius:
              BorderRadius.circular(
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
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration:
                BoxDecoration(
                  color:
                  selected
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
                  BorderRadius.circular(
                    30,
                  ),
                  border:
                  Border.all(
                    color:
                    selected
                        ? color
                        .withOpacity(
                      0.45,
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
                    color:
                    selected
                        ? color
                        : Colors
                        .white38,
                    fontSize:
                    10,
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
            CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Surat Jalan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
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
            horizontal: 13,
            vertical: 8,
          ),
          decoration:
          BoxDecoration(
            color:
            accent.withOpacity(
              0.10,
            ),
            borderRadius:
            BorderRadius.circular(
              22,
            ),
            border:
            Border.all(
              color:
              accent.withOpacity(
                0.15,
              ),
            ),
          ),
          child: Text(
            '${_filteredSuratJalan.length} data',
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
        _suratJalan.isEmpty) {
      return _buildError();
    }

    if (_filteredSuratJalan
        .isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children:
      List.generate(
        _filteredSuratJalan.length,
            (index) {
          final item =
          _filteredSuratJalan[
          index];

          return Padding(
            padding:
            EdgeInsets.only(
              bottom:
              index <
                  _filteredSuratJalan
                      .length -
                      1
                  ? 14
                  : 0,
            ),
            child:
            _buildSuratJalanCard(
              item,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuratJalanCard(
      dynamic item,
      ) {
    final status =
    _text(
      item['status'],
    );

    final color =
    _statusColor(
      status,
    );

    final totalItem =
    _toInt(
      item['total_item'],
    );

    final nomorSurat =
    _text(
      item['nomor_surat'],
    );

    final tujuan =
    _text(
      item['tujuan_cabang'],
    );

    final kepada =
    _text(
      item['kepada'],
    );

    final pic =
    _text(
      item['pic'],
    );

    final transactionType =
    _text(
      item['transaction_type'],
    );

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(
        25,
      ),
      child: BackdropFilter(
        filter:
        ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Material(
          color:
          Colors.transparent,
          child: InkWell(
            onTap: () =>
                _openDetail(
                  item,
                ),
            child: Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.all(
                18,
              ),
              decoration:
              BoxDecoration(
                gradient:
                LinearGradient(
                  colors: [
                    color.withOpacity(
                      0.075,
                    ),
                    Colors.white
                        .withOpacity(
                      0.045,
                    ),
                    Colors.white
                        .withOpacity(
                      0.022,
                    ),
                  ],
                  begin:
                  Alignment.topLeft,
                  end:
                  Alignment.bottomRight,
                ),
                border:
                Border.all(
                  color:
                  color.withOpacity(
                    0.22,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    color.withOpacity(
                      0.035,
                    ),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration:
                        BoxDecoration(
                          gradient:
                          LinearGradient(
                            colors: [
                              color.withOpacity(
                                0.20,
                              ),
                              color.withOpacity(
                                0.08,
                              ),
                            ],
                            begin:
                            Alignment
                                .topLeft,
                            end:
                            Alignment
                                .bottomRight,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            19,
                          ),
                          border:
                          Border.all(
                            color:
                            color
                                .withOpacity(
                              0.27,
                            ),
                          ),
                        ),
                        child: Icon(
                          _statusIcon(
                            status,
                          ),
                          color:
                          color,
                          size: 29,
                        ),
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              nomorSurat
                                  .isEmpty
                                  ? '-'
                                  : nomorSurat,
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
                                15,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              kepada.isEmpty
                                  ? tujuan
                                  : kepada,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors
                                    .white70,
                                fontSize:
                                11,
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              transactionType
                                  .isEmpty
                                  ? tujuan
                                  : transactionType,
                              style:
                              TextStyle(
                                color:
                                color,
                                fontSize:
                                9,
                                fontWeight:
                                FontWeight
                                    .w700,
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          color.withOpacity(
                            0.12,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            25,
                          ),
                          border:
                          Border.all(
                            color:
                            color
                                .withOpacity(
                              0.32,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize
                              .min,
                          children: [
                            Icon(
                              _statusIcon(
                                status,
                              ),
                              color:
                              color,
                              size:
                              13,
                            ),
                            const SizedBox(
                              width:
                              5,
                            ),
                            Text(
                              status.isEmpty
                                  ? 'Pending'
                                  : status,
                              style:
                              TextStyle(
                                color:
                                color,
                                fontSize:
                                8,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Divider(
                    height: 1,
                    color:
                    Colors.white
                        .withOpacity(
                      0.07,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        _buildCardInfo(
                          icon:
                          Icons
                              .location_on_outlined,
                          label:
                          'Tujuan',
                          value:
                          tujuan
                              .isEmpty
                              ? '-'
                              : tujuan,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        _buildCardInfo(
                          icon:
                          Icons
                              .person_outline_rounded,
                          label:
                          'PIC',
                          value:
                          pic.isEmpty
                              ? '-'
                              : pic,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        _buildCardInfo(
                          icon:
                          Icons
                              .inventory_2_outlined,
                          label:
                          'Total Item',
                          value:
                          '$totalItem item',
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        _buildCardInfo(
                          icon:
                          Icons
                              .swap_horiz_rounded,
                          label:
                          'Jenis',
                          value:
                          transactionType
                              .isEmpty
                              ? '-'
                              : transactionType,
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

  Widget _buildCardInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.black.withOpacity(
          0.12,
        ),
        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
            BoxDecoration(
              color:
              Colors.white.withOpacity(
                0.04,
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color:
              Colors.white30,
              size: 16,
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  label,
                  style:
                  const TextStyle(
                    color:
                    Colors.white24,
                    fontSize: 7,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 9,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ??
                  'Gagal mengambil data Surat Jalan',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed:
              _loadSuratJalan,
              icon:
              const Icon(
                Icons.refresh_rounded,
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

  Widget _buildEmpty() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              color: Colors.white24,
              size: 44,
            ),
            SizedBox(height: 11),
            Text(
              'Surat Jalan tidak ditemukan',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuratJalanPlaceholderPage
    extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SuratJalanPlaceholderPage({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xff050505,
      ),
      appBar: AppBar(
        backgroundColor:
        const Color(
          0xff050505,
        ),
        foregroundColor:
        Colors.white,
        title: Text(
          title,
        ),
      ),
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            28,
          ),
          child: Text(
            subtitle,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}