import 'package:flutter/material.dart';
import '../dashboard/dashboard_page.dart';
import '../master_barang/master_barang_page.dart';
import '../transaksi/barang_masuk_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),
    const MasterBarangPage(), // ✅ FIX
    const Center(child: Text("Master Supplier")),
    BarangMasukPage(dataBarang: []), // sementara
    const Center(child: Text("Barang Keluar")),
    const Center(child: Text("Surat Jalan")),
    const Center(child: Text("Barcode")),
    const Center(child: Text("Laporan Mingguan")),
    const Center(child: Text("Laporan Bulanan")),
    const Center(child: Text("Laporan Tahunan")),
    const Center(child: Text("User Role")),
    const Center(child: Text("System Gudang")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 240,
            color: const Color(0xff020617),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "NDP Inventory",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),

                sidebarItem("Dashboard", 0),

                const SidebarTitle("MASTER"),
                sidebarItem("Master Barang", 1),
                sidebarItem("Master Supplier", 2),

                const SidebarTitle("TRANSAKSI"),
                sidebarItem("Barang Masuk", 3),
                sidebarItem("Barang Keluar", 4),
                sidebarItem("Surat Jalan", 5),

                const SidebarTitle("UTILITY"),
                sidebarItem("Barcode", 6),

                const SidebarTitle("REPORT"),
                sidebarItem("Laporan Mingguan", 7),
                sidebarItem("Laporan Bulanan", 8),
                sidebarItem("Laporan Tahunan", 9),

                const SidebarTitle("SYSTEM"),
                sidebarItem("User Role", 10),
                sidebarItem("System Gudang", 11),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: Column(
              children: [
                // TOPBAR
                Container(
                  height: 60,
                  color: const Color(0xff020617),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search...",
                            hintStyle:
                                const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xff0f172a),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      )
                    ],
                  ),
                ),

                // PAGE CONTENT
                Expanded(
                  child: Container(
                    color: const Color(0xff0f172a),
                    child: pages[selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 SIDEBAR ITEM
  Widget sidebarItem(String title, int index) {
    final isActive = selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
        tileColor: isActive ? Colors.white10 : Colors.transparent,
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

// 🔹 TITLE SIDEBAR
class SidebarTitle extends StatelessWidget {
  final String title;
  const SidebarTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}