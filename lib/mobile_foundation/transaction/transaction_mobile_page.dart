import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ndp_inventory_app/mobile_foundation/transaction/pages/barang_masuk_mobile_page.dart';
import 'package:ndp_inventory_app/mobile_foundation/transaction/pages/surat_jalan_mobile_page.dart';

class TransactionMobilePage extends StatefulWidget {
  final String role;

  const TransactionMobilePage({
    super.key,
    required this.role,
  });

  @override
  State<TransactionMobilePage> createState() =>
      _TransactionMobilePageState();
}

class _TransactionMobilePageState
    extends State<TransactionMobilePage> {
  static const Color accent = Color(0xffff6a00);
  static const Color background = Color(0xff050505);

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  final List<_TransactionMenuItem> _transactionMenus = const [
    _TransactionMenuItem(
      title: 'Barang Masuk',
      subtitle: 'Catat dan kelola stok barang masuk',
      icon: Icons.add_box_outlined,
      color: Color(0xff43d17b),
    ),
    _TransactionMenuItem(
      title: 'Surat Jalan',
      subtitle: 'Kelola dokumen dan proses pengiriman',
      icon: Icons.local_shipping_outlined,
      color: Color(0xff5ea0ff),
    ),
    _TransactionMenuItem(
      title: 'History Surat Jalan',
      subtitle: 'Lihat riwayat dan status surat jalan',
      icon: Icons.history_rounded,
      color: Color(0xffffbd59),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_TransactionMenuItem> _filteredMenus() {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _transactionMenus;
    }

    return _transactionMenus.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final menus = _filteredMenus();

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: 90,
            right: -120,
            child: _buildBackgroundGlow(
              color: accent,
              size: 260,
            ),
          ),
          Positioned(
            bottom: 120,
            left: -140,
            child: _buildBackgroundGlow(
              color: const Color(0xff5ea0ff),
              size: 280,
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    115,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildHeaderCard(),
                        const SizedBox(height: 18),
                        _buildSearchField(),
                        const SizedBox(height: 25),
                        _buildSectionHeader(
                          resultCount: menus.length,
                        ),
                        const SizedBox(height: 14),
                        if (menus.isNotEmpty)
                          _buildMenuList(menus)
                        else
                          _buildEmptySearch(),
                      ],
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

  Widget _buildBackgroundGlow({
    required Color color,
    required double size,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.025),
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

  Widget _buildHeaderCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.14),
                Colors.white.withOpacity(0.045),
                Colors.white.withOpacity(0.025),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.34),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola transaksi barang masuk dan surat jalan',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.28),
                          accent.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                      BorderRadius.circular(20),
                      border: Border.all(
                        color:
                        accent.withOpacity(0.30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          accent.withOpacity(0.18),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons
                          .swap_horizontal_circle_rounded,
                      color: accent,
                      size: 31,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.apps_rounded,
                      label:
                      '${_transactionMenus.length} Modul',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoChip(
                      icon:
                      Icons.verified_user_outlined,
                      label:
                      _formatRole(widget.role),
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: accent,
            size: 17,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction:
      TextInputAction.search,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText:
        'Cari menu transaksi...',
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Colors.white38,
        ),
        suffixIcon:
        _searchQuery.isEmpty
            ? null
            : IconButton(
          tooltip:
          'Hapus pencarian',
          onPressed: () {
            _searchController
                .clear();

            setState(() {
              _searchQuery = '';
            });
          },
          icon: const Icon(
            Icons.close_rounded,
            color:
            Colors.white38,
          ),
        ),
        filled: true,
        fillColor:
        Colors.white.withOpacity(
          0.045,
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(19),
          borderSide: BorderSide(
            color:
            Colors.white.withOpacity(
              0.08,
            ),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(19),
          borderSide: BorderSide(
            color:
            accent.withOpacity(0.60),
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required int resultCount,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pilih transaksi yang ingin dikelola',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
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
            color:
            accent.withOpacity(0.10),
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color:
              accent.withOpacity(0.16),
            ),
          ),
          child: Text(
            '$resultCount menu',
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

  Widget _buildMenuList(
      List<_TransactionMenuItem> menus,
      ) {
    return Column(
      children: List.generate(
        menus.length,
            (index) {
          final item = menus[index];

          return TweenAnimationBuilder<
              double>(
            key: ValueKey(item.title),
            tween: Tween(
              begin: 0,
              end: 1,
            ),
            duration: Duration(
              milliseconds:
              320 + (index * 70),
            ),
            curve: Curves.easeOutCubic,
            builder:
                (
                context,
                value,
                child,
                ) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(
                    18 * (1 - value),
                    0,
                  ),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                bottom:
                index < menus.length - 1
                    ? 11
                    : 0,
              ),
              child:
              _TransactionGlassCard(
                item: item,
                onTap: () =>
                    _openMenu(item),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openMenu(
      _TransactionMenuItem item,
      ) {
    FocusScope.of(context).unfocus();

    Widget targetPage;

    if (item.title == 'Barang Masuk') {
      targetPage = const BarangMasukMobilePage();
    }  if (item.title == 'Surat Jalan') {
      targetPage = const SuratJalanMobilePage();
    } else {
      targetPage = _TransactionPlaceholderPage(
        title: item.title,
        subtitle: item.subtitle,
        icon: item.icon,
        color: item.color,
      );
    }



    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 380,
        ),
        pageBuilder: (
            _,
            animation,
            secondaryAnimation,
            ) {
          return targetPage;
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          final slide = Tween<Offset>(
            begin: const Offset(
              0.05,
              0,
            ),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Padding(
      padding:
      const EdgeInsets.only(
        top: 75,
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color:
              Colors.white.withOpacity(
                0.04,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                Colors.white.withOpacity(
                  0.05,
                ),
              ),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Colors.white24,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Menu tidak ditemukan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Coba gunakan kata pencarian lainnya',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRole(
      String role,
      ) {
    if (role.trim().isEmpty) {
      return 'User';
    }

    final spaced =
    role.replaceAllMapped(
      RegExp(
        r'([a-z])([A-Z])',
      ),
          (match) =>
      '${match.group(1)} ${match.group(2)}',
    );

    return spaced
        .split(' ')
        .where(
          (word) => word.isNotEmpty,
    )
        .map(
          (word) =>
      '${word[0].toUpperCase()}'
          '${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }
}

class _TransactionGlassCard
    extends StatefulWidget {
  final _TransactionMenuItem item;
  final VoidCallback onTap;

  const _TransactionGlassCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_TransactionGlassCard>
  createState() =>
      _TransactionGlassCardState();
}

class _TransactionGlassCardState
    extends State<_TransactionGlassCard> {
  bool _pressed = false;

  void _setPressed(
      bool value,
      ) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown: (_) =>
          _setPressed(true),
      onTapUp: (_) =>
          _setPressed(false),
      onTapCancel: () =>
          _setPressed(false),
      child: AnimatedScale(
        scale:
        _pressed ? 0.975 : 1,
        duration:
        const Duration(
          milliseconds: 120,
        ),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(22),
          child: BackdropFilter(
            filter:
            ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Material(
              color:
              Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius:
                BorderRadius.circular(
                  22,
                ),
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 180,
                  ),
                  height: 88,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      colors: [
                        widget.item.color
                            .withOpacity(
                          _pressed
                              ? 0.15
                              : 0.08,
                        ),
                        Colors.white
                            .withOpacity(
                          _pressed
                              ? 0.07
                              : 0.045,
                        ),
                        Colors.white
                            .withOpacity(
                          0.025,
                        ),
                      ],
                      begin:
                      Alignment.topLeft,
                      end:
                      Alignment
                          .bottomRight,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),
                    border: Border.all(
                      color:
                      _pressed
                          ? widget.item
                          .color
                          .withOpacity(
                        0.38,
                      )
                          : Colors.white
                          .withOpacity(
                        0.09,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration:
                        BoxDecoration(
                          color:
                          widget.item
                              .color
                              .withOpacity(
                            0.15,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            18,
                          ),
                          border:
                          Border.all(
                            color:
                            widget.item
                                .color
                                .withOpacity(
                              0.22,
                            ),
                          ),
                        ),
                        child: Icon(
                          widget
                              .item
                              .icon,
                          color:
                          widget
                              .item
                              .color,
                          size: 27,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              widget
                                  .item
                                  .title,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 14,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              widget
                                  .item
                                  .subtitle,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          widget.item
                              .color
                              .withOpacity(
                            0.14,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            30,
                          ),
                          border:
                          Border.all(
                            color:
                            widget.item
                                .color
                                .withOpacity(
                              0.28,
                            ),
                          ),
                        ),
                        child: Text(
                          'BUKA',
                          style: TextStyle(
                            color:
                            widget
                                .item
                                .color,
                            fontSize: 9,
                            fontWeight:
                            FontWeight
                                .w800,
                            letterSpacing:
                            0.7,
                          ),
                        ),
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
}

class _TransactionPlaceholderPage
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TransactionPlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xff050505),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        const Color(0xff050505),
        foregroundColor:
        Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration:
                BoxDecoration(
                  color:
                  color.withOpacity(
                    0.11,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    28,
                  ),
                  border: Border.all(
                    color:
                    color.withOpacity(
                      0.22,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 46,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                title,
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  color:
                  Colors.white38,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Halaman sedang dikembangkan',
                style: TextStyle(
                  color:
                  Colors.white24,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TransactionMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}