import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Cards
          Row(
            children: [
              dashboardCard("Total Barang", "120",
                  const Color(0xff0ea5e9), const Color(0xff22c55e), Icons.inventory),
              const SizedBox(width: 20),
              dashboardCard("Barang Masuk", "25",
                  const Color(0xff6366f1), const Color(0xff8b5cf6), Icons.arrow_downward),
              const SizedBox(width: 20),
              dashboardCard("Barang Keluar", "10",
                  const Color(0xfff97316), const Color(0xffef4444), Icons.arrow_upward),
              const SizedBox(width: 20),
              dashboardCard("Low Stock", "5",
                  const Color(0xffec4899), const Color(0xffa855f7), Icons.warning),
            ],
          ),

          const SizedBox(height: 30),

          transactionTable(),
        ],
      ),
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    Color c1,
    Color c2,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c1, c2]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 TABLE
  Widget transactionTable() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400), // 🔥 biar "mentok bawah feel"
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff111827),
            Color(0xff020617),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Transactions",
              textAlign: TextAlign.center,
              style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // HEADER
          Row(
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

          const SizedBox(height: 10),
          const Divider(color: Colors.white12),

          SizedBox(
            height: 300,
            child: ListView(
              children: [
                transactionRow("07/04", "Injector Pump", "101029-19191", "-2", "Keluar", "Admin", "Cabang A"),
                transactionRow("07/04", "Nozzle", "P7764", "-1", "Dipakai", "Mekanik", "Service"),
                transactionRow("07/04", "Filter Solar", "191929", "+5", "Masuk", "Admin", "Supplier"),
                transactionRow("06/04", "Plunger", "6470", "-3", "Dijual", "Kasir", "Customer"),
                transactionRow("07/04", "Injector Pump", "101029-19191", "-2", "Keluar", "Admin", "Cabang A"),
                transactionRow("07/04", "Nozzle", "P7764", "-1", "Dipakai", "Mekanik", "Service"),
                transactionRow("07/04", "Filter Solar", "191929", "+5", "Masuk", "Admin", "Supplier"),
                transactionRow("06/04", "Plunger", "6470", "-3", "Dijual", "Kasir", "Customer"),
                transactionRow("07/04", "Injector Pump", "101029-19191", "-2", "Keluar", "Admin", "Cabang A"),
                transactionRow("07/04", "Nozzle", "P7764", "-1", "Dipakai", "Mekanik", "Service"),
                transactionRow("07/04", "Filter Solar", "191929", "+5", "Masuk", "Admin", "Supplier"),
                transactionRow("06/04", "Plunger", "6470", "-3", "Dijual", "Kasir", "Customer"),
              ],
            ),
          )
        ],
      ),
    );
  }

  static Widget tableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // 🔥 ROW (SUDAH RAPII + HOVER)
  static Widget transactionRow(
    String date,
    String item,
    String partNumber,
    String qty,
    String type,
    String user,
    String note,
  ) {
    Color color;

    switch (type) {
      case "Masuk":
        color = Colors.green;
        break;
      case "Keluar":
        color = Colors.red;
        break;
      case "Dipakai":
        color = Colors.orange;
        break;
      case "Dijual":
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: Text(date, style: const TextStyle(color: Colors.white70))),

              Expanded(flex: 4, child: Text(item, style: const TextStyle(color: Colors.white))),

              Expanded(
                flex: 3,
                child: Text(
                  partNumber,
                  style: const TextStyle(color: Colors.white54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Expanded(
                flex: 1,
                child: Center(
                  child: Text(qty, style: const TextStyle(color: Colors.white)),
                ),
              ),

              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Center(
                  child: Text(user, style: const TextStyle(color: Colors.white70)),
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(note, style: const TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}