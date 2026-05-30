import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

  @override
  State<DashboardPage> createState() => _DashboardPageState();


class _DashboardPageState extends State<DashboardPage> {
  int totalBarang = 0;
  int barangMasuk = 0;
  int barangKeluar = 0;
  int lowStock = 0;
  int barangMasukJenis = 0;
  int barangKeluarJenis = 0;

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() => isLoading = true);

      final summary = await ApiService.getDashboardSummary();
      final recent = await ApiService.getRecentTransactions();

      if (!mounted) return;

      setState(() {
        totalBarang = int.tryParse(summary['total_barang'].toString()) ?? 0;
        barangMasuk = int.tryParse(summary['barang_masuk_qty'].toString()) ?? 0;
        barangKeluar = int.tryParse(summary['barang_keluar_qty'].toString()) ?? 0;
        barangMasukJenis = int.tryParse(summary['barang_masuk_jenis'].toString()) ?? 0;
        barangKeluarJenis = int.tryParse(summary['barang_keluar_jenis'].toString()) ?? 0;
        lowStock = int.tryParse(summary['low_stock'].toString()) ?? 0;
        transactions = List<Map<String, dynamic>>.from(recent);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("DASHBOARD API ERROR: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          const SizedBox(height: 24),
         Row(
          children: [
            dashboardCard(
              "Total Barang",
              totalBarang.toString(),
              Icons.inventory_2_outlined,
              const Color(0xff38bdf8),
            ),
            const SizedBox(width: 18),

            dashboardCard(
              "Barang Masuk",
              barangMasuk.toString(),
              Icons.south_west_rounded,
              const Color(0xff22c55e),
              subtitle: "$barangMasukJenis jenis barang",
            ),
            const SizedBox(width: 18),

            dashboardCard(
              "Barang Keluar",
              barangKeluar.toString(),
              Icons.north_east_rounded,
              const Color(0xfff97316),
              subtitle: "$barangKeluarJenis jenis barang",
            ),
            const SizedBox(width: 18),

            dashboardCard(
              "Low Stock",
              lowStock.toString(),
              Icons.warning_amber_rounded,
              const Color(0xffef4444),
            ),
          ],
        ),
          const SizedBox(height: 26),
          Expanded(child: transactionTable()),
        ],
      ),
    );
  }

  Widget header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dashboard",
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          "Overview aktivitas stok & transaksi terbaru",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    bool isHover = false;

    return Expanded(
      child: StatefulBuilder(
        builder: (context, setHover) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setHover(() => isHover = true),
            onExit: (_) => setHover(() => isHover = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: isHover ? 155 : 145,
              transform: Matrix4.translationValues(0, isHover ? -6 : 0, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(isHover ? 0.28 : 0.18),
                    Colors.white.withOpacity(isHover ? 0.08 : 0.035),
                  ],
                ),
                border: Border.all(color: color.withOpacity(isHover ? 0.55 : 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isHover ? 0.42 : 0.20),
                    blurRadius: isHover ? 55 : 35,
                    spreadRadius: isHover ? 2 : 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Icon(icon, size: 78, color: color.withOpacity(0.16)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 28),
                      const Spacer(),
                      Text(
                        value,
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget transactionTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff020617).withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff38bdf8).withOpacity(0.10),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          rowHeader(),
          const Divider(color: Colors.white12, height: 26),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (transactions.isEmpty)
            const Expanded(
              child: Center(
                child: Text("Belum ada transaksi", style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final t = transactions[i];
                  return transactionRow(
                    t['tanggal']?.toString() ?? '-',
                    t['barang']?.toString() ?? '-',
                    t['part_no']?.toString() ?? '-',
                    t['qty']?.toString() ?? '0',
                    t['tipe']?.toString() ?? '-',
                    t['user']?.toString() ?? '-',
                    t['keterangan']?.toString() ?? '-',
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget rowHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: tableHeader("Tanggal")),
          Expanded(flex: 4, child: tableHeader("Barang")),
          Expanded(flex: 3, child: tableHeader("Part No")),
          Expanded(flex: 1, child: Center(child: tableHeader("Qty"))),
          Expanded(flex: 2, child: Center(child: tableHeader("Tipe"))),
          Expanded(flex: 2, child: Center(child: tableHeader("User"))),
          Expanded(flex: 3, child: tableHeader("Keterangan")),
        ],
      ),
    );
  }

  Widget tableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }

  Widget transactionRow(String date, String item, String partNumber, String qty, String type, String user, String note) {
    Color bgColor;
    Color textColor;

    switch (type.toLowerCase()) {
      case "masuk":
        bgColor = const Color(0xff22c55e).withOpacity(0.15);
        textColor = const Color(0xff22c55e);
        break;
      case "keluar":
        bgColor = const Color(0xffef4444).withOpacity(0.15);
        textColor = const Color(0xffef4444);
        break;
      default:
        bgColor = const Color(0xff3b82f6).withOpacity(0.15);
        textColor = const Color(0xff3b82f6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(date, style: const TextStyle(color: Colors.white70))),
          Expanded(flex: 4, child: Text(item, style: const TextStyle(color: Colors.white))),
          Expanded(flex: 3, child: Text(partNumber, style: const TextStyle(color: Colors.white54))),
          Expanded(flex: 1, child: Center(child: Text(qty, style: const TextStyle(color: Colors.white)))),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: textColor.withOpacity(0.3)),
                ),
                child: Text(type, style: TextStyle(color: textColor, fontSize: 12)),
              ),
            ),
          ),
          Expanded(flex: 2, child: Center(child: Text(user, style: const TextStyle(color: Colors.white70)))),
          Expanded(flex: 3, child: Text(note, style: const TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }
}