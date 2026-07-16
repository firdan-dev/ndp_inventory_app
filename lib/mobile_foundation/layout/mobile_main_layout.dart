import 'package:flutter/material.dart';

import '../dashboard/dashboard_mobile_page.dart';
import '../inventory/inventory_mobile_page.dart';
import '../profile/profile_mobile_page.dart';
import '../report/report_mobile_page.dart';
import '../transaction/transaction_mobile_page.dart';


class MobileMainLayout extends StatefulWidget {
  final String role;

  const MobileMainLayout({
    super.key,
    required this.role,
  });

  @override
  State<MobileMainLayout> createState() => _MobileMainLayoutState();
}

class _MobileMainLayoutState extends State<MobileMainLayout> {
  static const Color accent = Color(0xffff6a00);

  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      DashboardMobilePage(role: widget.role),
      InventoryMobilePage(role: widget.role),
      TransactionMobilePage(role: widget.role),
      ReportMobilePage(role: widget.role),
      ProfileMobilePage(role: widget.role),
    ];
  }

  void _changePage(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xff151515).withOpacity(0.97),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavigationItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Dashboard',
              ),
              _buildNavigationItem(
                index: 1,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                label: 'Inventory',
              ),
              _buildNavigationItem(
                index: 2,
                icon: Icons.swap_horiz_rounded,
                activeIcon: Icons.swap_horizontal_circle_rounded,
                label: 'Transaksi',
              ),
              _buildNavigationItem(
                index: 3,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Report',
              ),
              _buildNavigationItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool selected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _changePage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: Icon(
                    selected ? activeIcon : icon,
                    color: selected ? accent : Colors.white38,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? accent : Colors.white38,
                    fontSize: 9,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}