import 'dart:ui';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import '../master_barang/master_barang_page.dart';
import '../master/master_supplier_page.dart';
import '../transaksi/barang_masuk_page.dart';
import '../transaksi/surat_jalan_page.dart';
import '../auth/login_page.dart';
import '../../core/auth_storage.dart';
import '../transaksi/history_surat_jalan_page.dart';
import '../report/daily_report_page.dart';
import 'package:ndp_inventory_app/features/report/weekly_report_page.dart';
import 'package:ndp_inventory_app/features/report/monthly_report_page.dart';

class MainLayout extends StatefulWidget {
  final String role;
  

  const MainLayout({
    super.key,
    required this.role,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

void logout(BuildContext context) async {
  await AuthStorage.logout();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

String username = "";


@override
void initState() {
  super.initState();
  loadUser();
}

void loadUser() async {
  final user = await AuthStorage.getUser();
  setState(() {
    username = user?['username'] ?? '';
  });
}


  void handleNavigation(int index) {
    setState(() => selectedIndex = index);
  }

  List<Widget> get pages => [
        const DashboardPage(),
        const MasterBarangPage(),
        const MasterSupplierPage(),
        BarangMasukPage(onSuccess: () => setState(() => selectedIndex = 1)),
        const SuratJalanPage(),
        const Center(child: Text("Barcode")),
        const DailyReportPage(),
        const WeeklyReportPage(),
        const MonthlyReportPage(),
        const Center(child: Text("Laporan Bulanan")),
        const Center(child: Text("User Role")),
        const Center(child: Text("System Gudang")),
        const HistorySuratJalanPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: Row(
        children: [
          sidebar(),
          Expanded(
            child: Column(
              children: [
                topBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: Container(
                      key: ValueKey(selectedIndex),
                      color: const Color(0xff0f172a),
                      child: pages[selectedIndex],
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

  Widget sidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(14),
      decoration: glassBox(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              brand(),
              const SizedBox(height: 28),

              sidebarItem("Dashboard", Icons.dashboard_rounded, 0),

              const SidebarTitle("MASTER"),
              sidebarItem("Master Barang", Icons.inventory_2_rounded, 1),
              if (widget.role == "masterUser")
                sidebarItem("Master Supplier", Icons.store_rounded, 2),

              const SidebarTitle("TRANSAKSI"),
              sidebarItem("Barang Masuk", Icons.add_box_rounded, 3),
              sidebarItem("Surat Jalan", Icons.local_shipping_rounded, 4),
              sidebarItem("History Surat Jalan", Icons.history_rounded, 12),

              const SidebarTitle("REPORT"),
              sidebarItem("Laporan Harian", Icons.analytics_rounded, 6),
              sidebarItem("Laporan Mingguan", Icons.bar_chart_rounded, 7),
              sidebarItem("Laporan Bulanan", Icons.insert_chart_rounded, 8),

              const SidebarTitle("SYSTEM"),
              if (widget.role == "masterUser")
                sidebarItem("User Role", Icons.manage_accounts_rounded, 9),
              if (widget.role == "masterUser")
                sidebarItem("System Gudang", Icons.settings_rounded, 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget brand() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xff38bdf8).withOpacity(0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xff38bdf8).withOpacity(0.25)),
          ),
          child: const Icon(Icons.warehouse_rounded, color: Color(0xff38bdf8)),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "NDP Inventory",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Stock Management",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget topBar() {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(0, 14, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: glassBox(radius: 24),
      child: Row(
        children: [
          quickButton("Masuk", Icons.add_rounded, 3),
          const SizedBox(width: 10),
          quickButton("History", Icons.history_rounded, 12),
          const SizedBox(width: 10),
          quickButton("Surat Jalan", Icons.local_shipping_rounded, 4),
          const SizedBox(width: 10),
          quickButton("Report", Icons.analytics_rounded, 6),
          const Spacer(),
         Text(
            username.isEmpty ? widget.role : "$username (${widget.role})",
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(width: 12),
          
            PopupMenuButton<String>(
              color: const Color(0xff111827),
              offset: const Offset(0, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            onSelected: (value) {
              if (value == 'logout') logout(context);
            },

            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget quickButton(String title, IconData icon, int index) {
    bool hover = false;
    final active = selectedIndex == index;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setHover(() => hover = true),
          onExit: (_) => setHover(() => hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, hover ? -3 : 0, 0),
            child: ElevatedButton.icon(
              onPressed: () => handleNavigation(index),
              icon: Icon(icon, size: 16),
              label: Text(title, style: const TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: active
                    ? const Color(0xff38bdf8)
                    : Colors.white.withOpacity(hover ? 0.12 : 0.06),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sidebarItem(String title, IconData icon, int index) {
    bool hover = false;
    final active = selectedIndex == index;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setHover(() => hover = true),
          onExit: (_) => setHover(() => hover = false),
          child: GestureDetector(
            onTap: () => handleNavigation(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: active
                    ? const Color(0xff38bdf8).withOpacity(0.18)
                    : hover
                        ? Colors.white.withOpacity(0.07)
                        : Colors.transparent,
                border: Border.all(
                  color: active
                      ? const Color(0xff38bdf8).withOpacity(0.45)
                      : Colors.white.withOpacity(hover ? 0.08 : 0),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xff38bdf8).withOpacity(0.18),
                          blurRadius: 24,
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: active ? const Color(0xff38bdf8) : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.white60,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (active)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xff38bdf8),
                        shape: BoxShape.circle,
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

  BoxDecoration glassBox({double radius = 28}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.075),
          Colors.white.withOpacity(0.025),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.10)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff38bdf8).withOpacity(0.07),
          blurRadius: 35,
        ),
      ],
    );
  }
}

class SidebarTitle extends StatelessWidget {
  final String title;

  const SidebarTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 22, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 1.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}