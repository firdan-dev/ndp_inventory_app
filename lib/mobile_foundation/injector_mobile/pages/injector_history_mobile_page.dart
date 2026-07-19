import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ndp_inventory_app/services/injector_api.dart';

class InjectorHistoryMobilePage extends StatefulWidget {
  const InjectorHistoryMobilePage({
    super.key,
  });

  @override
  State<InjectorHistoryMobilePage> createState() =>
      _InjectorHistoryMobilePageState();
}

class _InjectorHistoryMobilePageState
    extends State<InjectorHistoryMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);

  final TextEditingController _searchController =
  TextEditingController();

  List<dynamic> _history = [];
  List<dynamic> _filteredHistory = [];

  bool _loading = true;
  bool _refreshing = false;

  String? _errorMessage;

  String _selectedFilter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Stock In',
    'Stock Out',
  ];

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadHistory({
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
      await InjectorApi.getHistory();

      if (!mounted) return;

      setState(() {
        _history = result;

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
    await _loadHistory(
      refresh: true,
    );
  }

  void _applyFilter() {
    final query =
    _searchController.text
        .trim()
        .toLowerCase();

    _filteredHistory =
        _history.where((item) {
          final type =
          _text(item['type'])
              .toUpperCase();

          final searchableText = [
            _text(item['injector_id']),
            _text(item['kode_injector']),
            _text(item['nama']),
            _text(item['type']),
            _text(item['notes']),
          ].join(' ').toLowerCase();

          final matchesSearch =
              query.isEmpty ||
                  searchableText.contains(
                    query,
                  );

          bool matchesFilter;

          switch (_selectedFilter) {
            case 'Stock In':
              matchesFilter =
                  type == 'IN';
              break;

            case 'Stock Out':
              matchesFilter =
                  type == 'OUT';
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

  String _formatDate(
      dynamic value,
      ) {
    final raw =
    _text(value);

    if (raw.isEmpty) {
      return '-';
    }

    try {
      final date =
      DateTime.parse(
        raw,
      ).toLocal();

      return DateFormat(
        'dd MMM yyyy, HH:mm',
        'id_ID',
      ).format(
        date,
      );
    } catch (_) {
      return raw;
    }
  }

  Color _typeColor(
      String type,
      ) {
    return type.toUpperCase() ==
        'IN'
        ? greenAccent
        : redAccent;
  }

  String _typeLabel(
      String type,
      ) {
    return type.toUpperCase() ==
        'IN'
        ? 'STOCK IN'
        : 'STOCK OUT';
  }

  IconData _typeIcon(
      String type,
      ) {
    return type.toUpperCase() ==
        'IN'
        ? Icons.login_rounded
        : Icons.logout_rounded;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      background,
      appBar: AppBar(
        backgroundColor:
        background,
        foregroundColor:
        Colors.white,
        elevation: 0,
        title:
        const Text(
          'History Injector',
          style:
          TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh:
            _refresh,
            color:
            accent,
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
                  const EdgeInsets
                      .fromLTRB(
                    18,
                    8,
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
                          height: 16,
                        ),

                        _buildSummary(),

                        const SizedBox(
                          height: 16,
                        ),

                        _buildSearch(),

                        const SizedBox(
                          height: 12,
                        ),

                        _buildFilters(),

                        const SizedBox(
                          height: 20,
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

          if (_refreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:
              LinearProgressIndicator(
                color:
                accent,
                backgroundColor:
                Colors.transparent,
                minHeight: 2,
              ),
            ),
        ],
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
        children: [
          Icon(
            Icons.history_rounded,
            color:
            accent,
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
                  'Riwayat Pergerakan Stok',
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
                  height: 4,
                ),

                Text(
                  'Pantau semua transaksi stock in dan stock out injector.',
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

  Widget _buildSummary() {
    final total =
        _history.length;

    final stockIn =
        _history.where((item) {
          return _text(
            item['type'],
          ).toUpperCase() ==
              'IN';
        }).length;

    final stockOut =
        _history.where((item) {
          return _text(
            item['type'],
          ).toUpperCase() ==
              'OUT';
        }).length;

    return Row(
      children: [
        Expanded(
          child:
          _summaryCard(
            label:
            'Total',
            value:
            total,
            icon:
            Icons.receipt_long_outlined,
            color:
            Colors.white,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
          _summaryCard(
            label:
            'Stock In',
            value:
            stockIn,
            icon:
            Icons.login_rounded,
            color:
            greenAccent,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
          _summaryCard(
            label:
            'Stock Out',
            value:
            stockOut,
            icon:
            Icons.logout_rounded,
            color:
            redAccent,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          0.06,
        ),
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        border:
        Border.all(
          color:
          color.withOpacity(
            0.11,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color:
            color,
            size: 20,
          ),

          const SizedBox(
            height: 7,
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
            style:
            const TextStyle(
              color:
              Colors.white30,
              fontSize: 8,
            ),
          ),
        ],
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
        color:
        Colors.white,
        fontSize: 13,
      ),
      decoration:
      InputDecoration(
        hintText:
        'Cari injector, kode atau catatan...',
        hintStyle:
        const TextStyle(
          color:
          Colors.white30,
          fontSize: 10,
        ),
        prefixIcon:
        const Icon(
          Icons.search_rounded,
          color:
          accent,
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
            Icons.close_rounded,
            color:
            Colors.white38,
          ),
        ),
        filled:
        true,
        fillColor:
        Colors.white.withOpacity(
          0.045,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            17,
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
            17,
          ),
          borderSide:
          const BorderSide(
            color:
            accent,
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
          filter ==
              'Stock In'
              ? greenAccent
              : filter ==
              'Stock Out'
              ? redAccent
              : Colors.white;

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
                  170,
                ),
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration:
                BoxDecoration(
                  color: selected
                      ? color.withOpacity(
                    0.14,
                  )
                      : Colors.white
                      .withOpacity(
                    0.035,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    30,
                  ),
                  border:
                  Border.all(
                    color: selected
                        ? color.withOpacity(
                      0.35,
                    )
                        : Colors.white
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
                'Aktivitas Terbaru',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                'Urutan transaksi terbaru',
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
            BorderRadius.circular(
              20,
            ),
          ),
          child: Text(
            '${_filteredHistory.length} transaksi',
            style:
            const TextStyle(
              color:
              accent,
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
            color:
            accent,
          ),
        ),
      );
    }

    if (_errorMessage != null &&
        _history.isEmpty) {
      return _buildError();
    }

    if (_filteredHistory
        .isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children:
      List.generate(
        _filteredHistory.length,
            (index) {
          return Padding(
            padding:
            EdgeInsets.only(
              bottom: index <
                  _filteredHistory
                      .length -
                      1
                  ? 11
                  : 0,
            ),
            child:
            _buildHistoryCard(
              _filteredHistory[
              index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
      dynamic item,
      ) {
    final type =
    _text(
      item['type'],
    ).toUpperCase();

    final color =
    _typeColor(
      type,
    );

    final qty =
    _toInt(
      item['qty'],
    );

    final stockBefore =
    _toInt(
      item['stock_before'],
    );

    final stockAfter =
    _toInt(
      item['stock_after'],
    );

    final name =
    _text(
      item['nama'],
    );

    final injectorId =
    _text(
      item['injector_id'],
    );

    final code =
    _text(
      item['kode_injector'],
    );

    final notes =
    _text(
      item['notes'],
    );

    final createdAt =
    _formatDate(
      item['created_at'],
    );

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white.withOpacity(
          0.035,
        ),
        borderRadius:
        BorderRadius.circular(
          21,
        ),
        border:
        Border.all(
          color:
          color.withOpacity(
            0.17,
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
                width: 46,
                height: 46,
                decoration:
                BoxDecoration(
                  color:
                  color.withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  _typeIcon(
                    type,
                  ),
                  color:
                  color,
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty
                          ? 'Injector'
                          : name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      [
                        if (injectorId
                            .isNotEmpty)
                          injectorId,
                        if (code.isNotEmpty)
                          code,
                      ].join(' • '),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Colors.white30,
                        fontSize: 9,
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
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color:
                  color.withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  _typeLabel(
                    type,
                  ),
                  style:
                  TextStyle(
                    color:
                    color,
                    fontSize: 8,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.white.withOpacity(
                0.025,
              ),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                  _transactionValue(
                    label:
                    'Qty',
                    value:
                    '$qty pcs',
                    color:
                    color,
                  ),
                ),

                Container(
                  width: 1,
                  height: 34,
                  color:
                  Colors.white.withOpacity(
                    0.07,
                  ),
                ),

                Expanded(
                  child:
                  _transactionValue(
                    label:
                    'Sebelum',
                    value:
                    '$stockBefore',
                    color:
                    Colors.white70,
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_rounded,
                  color:
                  Colors.white24,
                  size: 17,
                ),

                Expanded(
                  child:
                  _transactionValue(
                    label:
                    'Sesudah',
                    value:
                    '$stockAfter',
                    color:
                    color,
                  ),
                ),
              ],
            ),
          ),

          if (notes.isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  color:
                  Colors.white30,
                  size: 17,
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    notes,
                    style:
                    const TextStyle(
                      color:
                      Colors.white54,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .schedule_rounded,
                color:
                Colors.white24,
                size: 15,
              ),

              const SizedBox(
                width: 6,
              ),

              Text(
                createdAt,
                style:
                const TextStyle(
                  color:
                  Colors.white24,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionValue({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color:
            Colors.white24,
            fontSize: 8,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
          TextStyle(
            color:
            color,
            fontSize: 12,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 230,
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color:
              Colors.redAccent,
              size: 40,
            ),

            const SizedBox(
              height: 11,
            ),

            Text(
              _errorMessage ??
                  'Gagal mengambil history',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color:
                Colors.white38,
                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextButton.icon(
              onPressed:
              _loadHistory,
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
      height: 230,
      child: Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .history_toggle_off_rounded,
              color:
              Colors.white24,
              size: 46,
            ),

            SizedBox(
              height: 12,
            ),

            Text(
              'Belum ada riwayat transaksi',
              style:
              TextStyle(
                color:
                Colors.white54,
                fontSize: 13,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            SizedBox(
              height: 5,
            ),

            Text(
              'Transaksi stock in dan stock out akan muncul di sini.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                Colors.white24,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}