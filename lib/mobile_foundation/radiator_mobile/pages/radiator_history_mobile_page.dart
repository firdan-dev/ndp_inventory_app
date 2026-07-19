import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ndp_inventory_app/services/radiator_api.dart';

class RadiatorHistoryMobilePage extends StatefulWidget {
  const RadiatorHistoryMobilePage({
    super.key,
  });

  @override
  State<RadiatorHistoryMobilePage> createState() =>
      _RadiatorHistoryMobilePageState();
}

class _RadiatorHistoryMobilePageState
    extends State<RadiatorHistoryMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);
  static const Color greenAccent = Color(0xff69f0ae);
  static const Color redAccent = Color(0xffff5252);
  static const Color blueAccent = Color(0xff64b5f6);

  final TextEditingController _searchController =
  TextEditingController();

  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _filteredHistory = [];

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
      await RadiatorApi.getHistory();

      final converted = result.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }

        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }

        return <String, dynamic>{};
      }).where((item) {
        return item.isNotEmpty;
      }).toList();

      if (!mounted) return;

      setState(() {
        _history = converted;
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
    await _loadHistory(refresh: true);
  }

  void _applyFilter() {
    final query =
    _searchController.text.trim().toLowerCase();

    _filteredHistory =
        _history.where((item) {
          final type = _movementType(item);

          final searchableText = [
            _text(item['kode_radiator']),
            _text(item['nama_radiator']),
            _text(item['barcode']),
            _text(item['notes']),
            _text(item['no_surat_jalan']),
            _text(item['type']),
            _text(item['qty']),
          ].join(' ').toLowerCase();

          final matchesSearch =
              query.isEmpty ||
                  searchableText.contains(query);

          bool matchesFilter;

          switch (_selectedFilter) {
            case 'Stock In':
              matchesFilter = type == 'IN';
              break;

            case 'Stock Out':
              matchesFilter = type == 'OUT';
              break;

            case 'Semua':
            default:
              matchesFilter = true;
          }

          return matchesSearch && matchesFilter;
        }).toList();
  }

  void _onSearchChanged(String value) {
    setState(_applyFilter);
  }

  void _clearSearch() {
    _searchController.clear();

    setState(_applyFilter);
  }

  void _changeFilter(String value) {
    setState(() {
      _selectedFilter = value;
      _applyFilter();
    });
  }

  String _text(
      dynamic value, {
        String fallback = '-',
      }) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty ||
        text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  int _intValue(dynamic value) {
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

  String _movementType(
      Map<String, dynamic> item,
      ) {
    final type = _text(
      item['type'],
      fallback: '',
    ).toUpperCase();

    if (type == 'IN' ||
        type == 'STOCK IN' ||
        type == 'MASUK') {
      return 'IN';
    }

    if (type == 'OUT' ||
        type == 'STOCK OUT' ||
        type == 'KELUAR') {
      return 'OUT';
    }

    return type;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String _dateText(dynamic value) {
    final date = _parseDate(value);

    if (date == null) {
      return _text(value);
    }

    return DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(date.toLocal());
  }

  String _groupDate(dynamic value) {
    final date = _parseDate(value);

    if (date == null) {
      return 'Tanggal tidak diketahui';
    }

    final localDate = date.toLocal();
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final itemDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    final difference =
        today.difference(itemDate).inDays;

    if (difference == 0) {
      return 'Hari Ini';
    }

    if (difference == 1) {
      return 'Kemarin';
    }

    return DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(localDate);
  }

  Color _movementColor(
      Map<String, dynamic> item,
      ) {
    return _movementType(item) == 'IN'
        ? greenAccent
        : redAccent;
  }

  String _movementLabel(
      Map<String, dynamic> item,
      ) {
    return _movementType(item) == 'IN'
        ? 'Stock In'
        : 'Stock Out';
  }

  IconData _movementIcon(
      Map<String, dynamic> item,
      ) {
    return _movementType(item) == 'IN'
        ? Icons.login_rounded
        : Icons.logout_rounded;
  }

  List<_HistoryGroup> _groupedHistory() {
    final groups =
    <String, List<Map<String, dynamic>>>{};

    for (final item in _filteredHistory) {
      final key = _groupDate(
        item['created_at'],
      );

      groups.putIfAbsent(
        key,
            () => [],
      );

      groups[key]!.add(item);
    }

    return groups.entries.map((entry) {
      return _HistoryGroup(
        title: entry.key,
        items: entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: -130,
            child: _glow(
              color: accent,
              size: 290,
            ),
          ),
          Positioned(
            bottom: 50,
            left: -145,
            child: _glow(
              color: blueAccent,
              size: 290,
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
                      90,
                    ),
                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _buildHeader(),
                          const SizedBox(height: 18),
                          _buildSummary(),
                          const SizedBox(height: 16),
                          _buildSearch(),
                          const SizedBox(height: 12),
                          _buildFilters(),
                          const SizedBox(height: 21),
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

  Widget _glow({
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
                'History Radiator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Riwayat transaksi stock in dan stock out',
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
    final totalIn = _history.where((item) {
      return _movementType(item) == 'IN';
    }).length;

    final totalOut = _history.where((item) {
      return _movementType(item) == 'OUT';
    }).length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              label: 'Total Transaksi',
              value: _history.length,
              icon: Icons.history_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _summaryItem(
              label: 'Stock In',
              value: totalIn,
              icon: Icons.login_rounded,
              color: greenAccent,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _summaryItem(
              label: 'Stock Out',
              value: totalOut,
              icon: Icons.logout_rounded,
              color: redAccent,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withOpacity(0.13),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 7),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
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
        'Cari kode, nama, surat jalan atau catatan...',
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 10,
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
          onPressed: _clearSearch,
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white38,
            size: 20,
          ),
        ),
        filled: true,
        fillColor:
        Colors.white.withOpacity(0.045),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(17),
          borderSide: BorderSide(
            color:
            Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: accent,
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
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];

          final selected =
              filter == _selectedFilter;

          final color = filter == 'Stock In'
              ? greenAccent
              : filter == 'Stock Out'
              ? redAccent
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
                      ? color.withOpacity(0.15)
                      : Colors.white
                      .withOpacity(0.035),
                  borderRadius:
                  BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? color.withOpacity(0.42)
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

  Widget _buildContent() {
    if (_loading) {
      return _buildLoading();
    }

    if (_errorMessage != null &&
        _history.isEmpty) {
      return _buildError();
    }

    if (_filteredHistory.isEmpty) {
      return _buildEmpty();
    }

    final groups = _groupedHistory();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        for (int index = 0;
        index < groups.length;
        index++) ...[
          _buildGroup(groups[index]),
          if (index < groups.length - 1)
            const SizedBox(height: 22),
        ],
      ],
    );
  }

  Widget _buildGroup(
      _HistoryGroup group,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: accent,
              size: 15,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                group.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${group.items.length} transaksi',
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Column(
          children: List.generate(
            group.items.length,
                (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                  index <
                      group.items.length -
                          1
                      ? 10
                      : 0,
                ),
                child: _historyCard(
                  group.items[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _historyCard(
      Map<String, dynamic> item,
      ) {
    final color = _movementColor(item);
    final qty = _intValue(item['qty']);
    final stockBefore =
    _intValue(item['stock_before']);
    final stockAfter =
    _intValue(item['stock_after']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.17),
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
                  color: color.withOpacity(0.13),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  _movementIcon(item),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(
                        item['kode_radiator'],
                      ),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _text(
                        item['nama_radiator'],
                      ),
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius:
                  BorderRadius.circular(20),
                  border: Border.all(
                    color:
                    color.withOpacity(0.27),
                  ),
                ),
                child: Text(
                  _movementLabel(item),
                  style: TextStyle(
                    color: color,
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
                child: _infoBox(
                  label: 'Jumlah',
                  value:
                  '${_movementType(item) == 'IN' ? '+' : '-'}$qty pcs',
                  icon: Icons.numbers_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoBox(
                  label: 'Stok Sebelum',
                  value: '$stockBefore pcs',
                  icon:
                  Icons.inventory_outlined,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoBox(
                  label: 'Stok Sesudah',
                  value: '$stockAfter pcs',
                  icon:
                  Icons.inventory_2_outlined,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _metaRow(
            icon:
            Icons.schedule_rounded,
            label: 'Waktu',
            value: _dateText(
              item['created_at'],
            ),
          ),
          _metaRow(
            icon:
            Icons.description_outlined,
            label: 'Surat Jalan',
            value: _text(
              item['no_surat_jalan'],
            ),
          ),
          _metaRow(
            icon: Icons.notes_rounded,
            label: 'Catatan',
            value: _text(
              item['notes'],
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.11),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
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
    );
  }

  Widget _metaRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical: 9,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white30,
                size: 17,
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 75,
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
                    color: Colors.white60,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color:
            Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 240,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: accent,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 14),
          Text(
            'Mengambil history radiator...',
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
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: const Color(0xff1a1010),
        borderRadius: BorderRadius.circular(23),
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
            size: 38,
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal mengambil history',
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
          const SizedBox(height: 13),
          TextButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
            const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
        Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color:
          Colors.white.withOpacity(0.06),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: Colors.white24,
            size: 44,
          ),
          SizedBox(height: 12),
          Text(
            'History tidak ditemukan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Coba ubah pencarian atau filter transaksi',
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

class _HistoryGroup {
  final String title;
  final List<Map<String, dynamic>> items;

  const _HistoryGroup({
    required this.title,
    required this.items,
  });
}