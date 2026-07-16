import 'package:flutter/material.dart';

import '../../core/auth_storage.dart';
import '../../services/api_service.dart';

class DashboardMobilePage extends StatefulWidget {
  final String role;

  const DashboardMobilePage({
    super.key,
    required this.role,
  });

  @override
  State<DashboardMobilePage> createState() =>
      _DashboardMobilePageState();
}

class _DashboardMobilePageState extends State<DashboardMobilePage>
    with SingleTickerProviderStateMixin {
  static const Color accent = Color(0xffff6a00);

  String _username = 'Pengguna';
  bool _loading = true;

  bool _dashboardLoading = true;
  String? _dashboardError;

  Map<String, dynamic> _summary = {};
  List<dynamic> _recentTransactions = [];
  List<dynamic> _lowStockItems = [];

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -0.004,
      end: 0.004,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );

    _loadUser();
    _loadDashboard();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }




  Future<void> _loadUser() async {
    final user = await AuthStorage.getUser();

    if (!mounted) return;

    final namaPic = user?['nama_pic']?.toString().trim();
    final username = user?['username']?.toString().trim();

    setState(() {
      _username = namaPic != null && namaPic.isNotEmpty
          ? namaPic
          : username != null && username.isNotEmpty
          ? username
          : 'Pengguna';

      _loading = false;
    });
  }

  Future<void> _loadDashboard({
    bool showLoading = true,
  }) async {
    if (showLoading && mounted) {
      setState(() {
        _dashboardLoading = true;
        _dashboardError = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getDashboardSummary(),
        ApiService.getRecentTransactions(),
        ApiService.getLowStockItems(),
      ]);

      if (!mounted) return;

      setState(() {
        _summary = Map<String, dynamic>.from(results[0] as Map);
        _recentTransactions =
            List<dynamic>.from(results[1] as List).take(5).toList();
        _lowStockItems =
            List<dynamic>.from(results[2] as List).take(5).toList();

        _dashboardLoading = false;
        _dashboardError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _dashboardLoading = false;
        _dashboardError = error.toString();
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadUser(),
      _loadDashboard(showLoading: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: SafeArea(
        child: RefreshIndicator(
          color: accent,
          backgroundColor: const Color(0xff191919),
          onRefresh: _refreshDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildHeader(),
                      const SizedBox(height: 24),

                      AnimatedBuilder(
                        animation: _floatAnimation,
                        child: RepaintBoundary(
                          child: _buildMainSummary(),
                        ),
                        builder: (_, child) {
                          return FractionalTranslation(
                            translation: Offset(0, _floatAnimation.value),
                            child: child,
                          );
                        },
                      ),

                      const SizedBox(height: 26),

                      _buildSectionTitle(
                        title: 'Menu Cepat',
                        subtitle: 'Akses kebutuhan operasional',
                      ),
                      const SizedBox(height: 14),
                      _buildQuickActions(),
                      const SizedBox(height: 28),
                      _buildSectionTitle(
                        title: 'Aktivitas Terbaru',
                        subtitle: 'Pembaruan transaksi hari ini',
                        actionText: 'Lihat Semua',
                      ),
                      const SizedBox(height: 14),
                      _buildActivityList(),
                      const SizedBox(height: 28),
                      _buildSectionTitle(
                        title: 'Perlu Perhatian',
                        subtitle: 'Stok yang harus segera diperiksa',
                      ),
                      const SizedBox(height: 14),
                      _buildWarningSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _loading ? 'Memuat...' : _username,
                  key: ValueKey(_loading ? 'loading' : _username),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: accent.withOpacity(0.22),
                  ),
                ),
                child: Text(
                  _formatRole(widget.role),
                  style: const TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        _headerButton(
          icon: Icons.notifications_none_rounded,
          badge: true,
          onTap: () {
            _showMessage('Halaman notifikasi belum tersedia');
          },
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: const Color(0xff151515),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
        ),
        if (badge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff151515),
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff21130a),
            Color(0xff15100c),
            Color(0xff111111),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accent.withOpacity(0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.07),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Data operasional gudang',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: Colors.white.withOpacity(0.35),
              ),
            ],
          ),
          const SizedBox(height: 23),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: 'Total Jenis Barang',
                  value: _formatNumber(
                    _toInt(_summary['total_jenis_barang']),
                  ),
                  subtitle:
                  '${_formatNumber(_toInt(_summary['total_barang']))} unit total stok',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xff3d8bff),
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryItem(
                  title: 'Stok Menipis',
                  value: _formatNumber(_toInt(_summary['low_stock'])),
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xffffc107),
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.07),
          ),
          const SizedBox(height: 21),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  title: 'Barang Masuk',
                  value: _formatNumber(_toInt(_summary['barang_masuk_qty'])),
                  icon: Icons.south_west_rounded,
                  color: const Color(0xff43d17b),
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryItem(
                  title: 'Barang Keluar',
                  value: _formatNumber(_toInt(_summary['barang_keluar_qty'])),
                  icon: Icons.north_east_rounded,
                  color: const Color(0xff5ea0ff),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String title,

    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
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
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 43,
      margin: const EdgeInsets.symmetric(horizontal: 13),
      color: Colors.white.withOpacity(0.07),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    String? actionText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: () {
              _showMessage('$actionText belum tersedia');
            },
            child: Text(
              actionText,
              style: const TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = <_QuickAction>[
      const _QuickAction(
        title: 'Scan',
        icon: Icons.qr_code_scanner_rounded,
        color: accent,
      ),
      const _QuickAction(
        title: 'Barang Masuk',
        icon: Icons.move_to_inbox_outlined,
        color: Color(0xff43d17b),
      ),
      const _QuickAction(
        title: 'Barang Keluar',
        icon: Icons.outbox_outlined,
        color: Color(0xff5ea0ff),
      ),
      const _QuickAction(
        title: 'Inventory',
        icon: Icons.inventory_2_outlined,
        color: Color(0xffb58cff),
      ),
      const _QuickAction(
        title: 'Service',
        icon: Icons.build_outlined,
        color: Color(0xffffbd59),
      ),
      const _QuickAction(
        title: 'Surat Jalan',
        icon: Icons.local_shipping_outlined,
        color: Color(0xffff7f7f),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.94,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return Material(
          color: const Color(0xff131313),
          borderRadius: BorderRadius.circular(21),
          child: InkWell(
            borderRadius: BorderRadius.circular(21),
            onTap: () {
              _showMessage('${action.title} belum tersedia');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    action.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
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

  Widget _buildActivityList() {
    if (_dashboardLoading) {
      return _buildLoadingCard();
    }

    if (_dashboardError != null && _recentTransactions.isEmpty) {
      return _buildErrorCard();
    }

    if (_recentTransactions.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.history_rounded,
        title: 'Belum ada aktivitas',
        subtitle: 'Transaksi terbaru akan muncul di sini.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: ListView.separated(
        itemCount: _recentTransactions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: Colors.white.withOpacity(0.06),
        ),
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(
            _recentTransactions[index] as Map,
          );

          final type = item['type']?.toString().toLowerCase() ?? '';
          final isMasuk = type == 'masuk';

          final color = isMasuk
              ? const Color(0xff43d17b)
              : const Color(0xff5ea0ff);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withOpacity(0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isMasuk
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: color,
                size: 21,
              ),
            ),
            title: Text(
              '${isMasuk ? 'Barang masuk' : 'Barang keluar'}'
                  ' · ${item['kategori'] ?? '-'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${item['item_name'] ?? 'Tanpa nama'}'
                    ' · ${_toInt(item['qty'])} pcs',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ),
            trailing: Text(
              _formatTime(item['created_at']),
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 10,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarningSection() {
    if (_dashboardLoading) {
      return _buildLoadingCard();
    }

    if (_dashboardError != null && _lowStockItems.isEmpty) {
      return _buildErrorCard();
    }

    if (_lowStockItems.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.verified_rounded,
        title: 'Stok aman',
        subtitle: 'Tidak ada barang di bawah stok minimum.',
        color: const Color(0xff43d17b),
      );
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xff17130b),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffffc107).withOpacity(0.16),
        ),
      ),
      child: Column(
        children: List.generate(
          _lowStockItems.length,
              (index) {
            final item = Map<String, dynamic>.from(
              _lowStockItems[index] as Map,
            );

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        color: const Color(0xffffc107)
                            .withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xffffc107),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['item_name']?.toString() ??
                                'Tanpa nama',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_toInt(item['qty'])} tersisa'
                                ' · minimum ${_toInt(item['min_stock'])}'
                                ' · ${item['kategori'] ?? '-'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xffffc107),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < _lowStockItems.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: const CircularProgressIndicator(
        color: accent,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1a1010),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xffff6b6b),
          ),
          const SizedBox(height: 10),
          Text(
            _dashboardError ?? 'Gagal mengambil data',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          TextButton(
            onPressed: _loadDashboard,
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = Colors.white38,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 31),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
    );
  }

  String _formatTime(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return '--:--';

    final local = date.toLocal();

    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) return 'Selamat pagi 👋';
    if (hour < 15) return 'Selamat siang 👋';
    if (hour < 18) return 'Selamat sore 👋';

    return 'Selamat malam 👋';
  }

  String _formatRole(String role) {
    if (role.trim().isEmpty) return 'User';

    final spaced = role.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
    );

    return spaced
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff1d1d1d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(message),
        ),
      );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
  });
}
