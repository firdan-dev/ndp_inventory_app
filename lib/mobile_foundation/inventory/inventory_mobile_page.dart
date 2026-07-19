import 'dart:ui';
import 'package:ndp_inventory_app/mobile_foundation/fip_mobile/pages/fip_mobile_page.dart';

import 'master_barang/master_barang_mobile_page.dart';
import 'package:flutter/material.dart';
import 'master_supplier/master_supplier_mobile_page.dart';
import '../service_customer_mobile/pages/service_customer_mobile_page.dart';
import '../radiator_mobile/pages/radiator_mobile_page.dart';
import '../injector_mobile/pages/injector_mobile_page.dart';
import '../fip_mobile/pages/fip_mobile_page.dart';


class InventoryMobilePage extends StatefulWidget {
  final String role;

  const InventoryMobilePage({
    super.key,
    required this.role,
  });

  @override
  State<InventoryMobilePage> createState() =>
      _InventoryMobilePageState();
}

class _InventoryMobilePageState extends State<InventoryMobilePage> {
  static const Color accent = Color(0xffff6a00);

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  final List<_InventoryMenuItem> _masterMenus = const [
    _InventoryMenuItem(
      title: 'Master Barang',
      subtitle: 'Kelola seluruh data barang',
      icon: Icons.inventory_2_outlined,
      color: Color(0xffff6a00),
    ),
    _InventoryMenuItem(
      title: 'Master Supplier',
      subtitle: 'Kelola data supplier',
      icon: Icons.store_outlined,
      color: Color(0xffb0b0b0),
    ),
    _InventoryMenuItem(
      title: 'Service Customer',
      subtitle: 'Kelola service customer',
      icon: Icons.build_circle_outlined,
      color: Color(0xff64b5f6),
    ),
    _InventoryMenuItem(
      title: 'Radiator',
      subtitle: 'Kelola service radiator',
      icon: Icons.ac_unit_rounded,
      color: Color(0xff81d4fa),
    ),
    _InventoryMenuItem(
      title: 'Injector',
      subtitle: 'Kelola service injector',
      icon: Icons.tune_rounded,
      color: Color(0xffffb74d),
    ),
    _InventoryMenuItem(
      title: 'Fuel Injection',
      subtitle: 'Kelola fuel injection',
      icon: Icons.local_gas_station_outlined,
      color: Color(0xffef9a9a),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_InventoryMenuItem> _filteredMenus() {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _masterMenus;
    }

    return _masterMenus.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final menus = _filteredMenus();

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Stack(
        children: [
          Positioned(
            top: 100,
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
              color: const Color(0xff64b5f6),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola seluruh master data',
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
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accent.withOpacity(0.30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.18),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: accent,
                      size: 29,
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
                      label: '${_masterMenus.length} Modul',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.verified_user_outlined,
                      label: _formatRole(widget.role),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
              overflow: TextOverflow.ellipsis,
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
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
        hintText: 'Cari menu inventory...',
        hintStyle: const TextStyle(
          color: Colors.white30,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Colors.white38,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
          tooltip: 'Hapus pencarian',
          onPressed: () {
            _searchController.clear();

            setState(() {
              _searchQuery = '';
            });
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white38,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.045),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(
            color: accent.withOpacity(0.60),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Master Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pilih modul yang ingin dikelola',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
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
              color: accent.withOpacity(0.16),
            ),
          ),
          child: Text(
            '$resultCount menu',
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

  Widget _buildMenuList(
      List<_InventoryMenuItem> menus,
      ) {
    return Column(
      children: List.generate(
        menus.length,
            (index) {
          final item = menus[index];

          return TweenAnimationBuilder<double>(
            key: ValueKey(item.title),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(
              milliseconds: 320 + (index * 70),
            ),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
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
                bottom: index < menus.length - 1 ? 11 : 0,
              ),
              child: _InventoryGlassCard(
                item: item,
                onTap: () => _openMenu(item),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openMenu(_InventoryMenuItem item) {
    FocusScope.of(context).unfocus();

    Widget destinationPage;

    switch (item.title) {
      case 'Master Barang':
        destinationPage = const MasterBarangMobilePage();
        break;

      case 'Master Supplier':
        destinationPage = const MasterSupplierMobilePage();
        break;

      case 'Service Customer':
        destinationPage = const ServiceCustomerMobilePage();
        break;

      case 'Radiator':
        destinationPage = const RadiatorMobilePage();
        break;
      case 'Injector':
        destinationPage = const InjectorMobilePage();
        break;
      case 'Fuel Injection':
        destinationPage = const FipMobilePage();
        break;

      default:
        destinationPage = _InventoryPlaceholderPage(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
          color: item.color,
        );
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) {
          return destinationPage;
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
            begin: const Offset(0.05, 0),
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
      padding: const EdgeInsets.only(top: 75),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
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
              fontWeight: FontWeight.w700,
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

  String _formatRole(String role) {
    if (role.trim().isEmpty) {
      return 'User';
    }

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
}

class _InventoryGlassCard extends StatefulWidget {
  final _InventoryMenuItem item;
  final VoidCallback onTap;

  const _InventoryGlassCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_InventoryGlassCard> createState() =>
      _InventoryGlassCardState();
}

class _InventoryGlassCardState
    extends State<_InventoryGlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 88,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.item.color.withOpacity(
                          _pressed ? 0.15 : 0.08,
                        ),
                        Colors.white.withOpacity(
                          _pressed ? 0.07 : 0.045,
                        ),
                        Colors.white.withOpacity(0.025),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _pressed
                          ? widget.item.color.withOpacity(0.38)
                          : Colors.white.withOpacity(0.09),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _pressed
                            ? widget.item.color.withOpacity(0.12)
                            : Colors.black.withOpacity(0.20),
                        blurRadius: _pressed ? 24 : 16,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.item.color.withOpacity(0.34),
                              widget.item.color.withOpacity(0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                            widget.item.color.withOpacity(0.24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              widget.item.color.withOpacity(0.13),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: widget.item.color,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.item.subtitle,
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
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.item.color.withOpacity(
                            _pressed ? 0.24 : 0.14,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: widget.item.color.withOpacity(
                              _pressed ? 0.50 : 0.28,
                            ),
                          ),
                        ),
                        child: Text(
                          'BUKA',
                          style: TextStyle(
                            color: widget.item.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
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

class _InventoryPlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InventoryPlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff050505),
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: color.withOpacity(0.22),
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Halaman sedang dikembangkan',
                style: TextStyle(
                  color: Colors.white24,
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

class _InventoryMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InventoryMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}