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
import 'package:ndp_inventory_app/features/master/user_role_page.dart';
import 'package:ndp_inventory_app/features/master/system_gudang_page.dart';
import '../service_customer/pages/service_customer_page.dart';
import 'package:ndp_inventory_app/features/radiator/pages/radiator_page.dart';
import 'package:ndp_inventory_app/features/injector/pages/injector_page.dart';
import 'package:ndp_inventory_app/features/fip/fip_pages.dart';
import '../master/mechanic_management_page.dart';

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
  String username = "";

  static const Color accentOrange = Color(0xffff6a00);

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

  void logout(BuildContext context) async {
    await AuthStorage.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  void handleNavigation(int index) {
    setState(() => selectedIndex = index);
  }

  List<Widget> get pages => [
        DashboardPage(
  onOpenServiceCustomer: () {
    setState(() {
      selectedIndex = 13;
    });
  },
  onOpenSuratJalan: () {
    setState(() {
      selectedIndex = 4;
    });
  },
),

        const MasterBarangPage(),
        const MasterSupplierPage(),
        BarangMasukPage(
          onSuccess: () => setState(() => selectedIndex = 1),
        ),
        const SuratJalanPage(),
        const Center(child: Text("Barcode")),
        const DailyReportPage(),
        const WeeklyReportPage(),
        const MonthlyReportPage(),
        const MechanicManagementPage(),
        const UserRolePage(),
        const SystemGudangPage(),
        const HistorySuratJalanPage(),
        const ServiceCustomerPage(),
        const RadiatorPage(),
        const InjectorPage(),
        const FipPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff020202),
              Color(0xff070707),
              Color(0xff0d0d0d),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
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
                        color: Colors.transparent,
                        child: pages[selectedIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              brand(),
              const SizedBox(height: 28),

              sidebarItem(
                "Dashboard",
                Icons.dashboard_rounded,
                0,
              ),

              const SidebarTitle("MASTER"),

              sidebarItem(
                "Master Barang",
                Icons.inventory_2_rounded,
                1,
              ),

              if (widget.role == "masterUser")
                sidebarItem(
                  "Master Supplier",
                  Icons.store_rounded,
                  2,
                ),
                sidebarItem(
                  "Service Customer",
                  Icons.build_circle_rounded,
                  13,
                ),
                sidebarItem(
                  "Radiator",
                  Icons.ac_unit,
                  14,
                ),

                sidebarItem(
                  "Injector", 
                  Icons.settings_input_component, 
                  15,
                  ),

                sidebarItem(
                  "Fuel Injection",
                  Icons.local_gas_station_rounded,
                  16,
                  ),


              const SidebarTitle("TRANSAKSI"),

              sidebarItem(
                "Barang Masuk",
                Icons.add_box_rounded,
                3,
              ),

              sidebarItem(
                "Surat Jalan",
                Icons.local_shipping_rounded,
                4,
              ),

              sidebarItem(
                "History Surat Jalan",
                Icons.history_rounded,
                12,
              ),

              const SidebarTitle("REPORT"),

              sidebarItem(
                "Laporan Harian",
                Icons.analytics_rounded,
                6,
              ),

              sidebarItem(
                "Laporan Mingguan",
                Icons.bar_chart_rounded,
                7,
              ),

              sidebarItem(
                "Laporan Bulanan",
                Icons.insert_chart_rounded,
                8,
              ),

              const SidebarTitle("SYSTEM"),

              if (widget.role == "masterUser")
                sidebarItem(
                  "User Role",
                  Icons.manage_accounts_rounded,
                  10,
                ),

              if (widget.role == "masterUser")
                sidebarItem(
                  "Mechanic Management",
                  Icons.engineering_rounded,
                  9,
                ),

              if (widget.role == "masterUser")
                sidebarItem(
                  "System Gudang",
                  Icons.settings_rounded,
                  11,
                ),
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
            color: accentOrange.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentOrange.withOpacity(0.28),
            ),
          ),
          child: const Icon(
            Icons.warehouse_rounded,
            color: accentOrange,
          ),
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
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
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
            color: const Color(0xff151515),
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
                    ? accentOrange.withOpacity(0.22)
                    : Colors.white.withOpacity(hover ? 0.10 : 0.055),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: active
                        ? accentOrange.withOpacity(0.35)
                        : Colors.white.withOpacity(0.08),
                  ),
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
                    ? accentOrange.withOpacity(0.18)
                    : hover
                        ? Colors.white.withOpacity(0.07)
                        : Colors.transparent,
                border: Border.all(
                  color: active
                      ? accentOrange.withOpacity(0.38)
                      : Colors.white.withOpacity(hover ? 0.08 : 0),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.22),
                          blurRadius: 24,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: active ? accentOrange : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.white60,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (active)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: accentOrange,
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
      color: const Color(0xff111111).withOpacity(0.92),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 40,
          spreadRadius: 2,
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