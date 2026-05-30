import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  DateTime selectedMonth = DateTime.now();

  Map<String, dynamic>? summary;
  List transactions = [];
  bool loading = false;

  final baseUrl = "http://localhost:3000/api";

  String get monthText {
    return "${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}";
  }

  Future<void> fetchReport() async {
    setState(() => loading = true);

    try {
      final url = "$baseUrl/report/monthly?month=$monthText";
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);

      setState(() {
        summary = data['summary'];
        transactions = data['transactions'] ?? [];
      });
    } catch (e) {
      debugPrint("MONTHLY REPORT ERROR: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "Pilih Bulan",
    );

    if (picked != null) {
      setState(() => selectedMonth = picked);
    }
  }

  BoxDecoration glassBox({double radius = 24}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.025),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.10)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 35,
        ),
      ],
    );
  }

  Widget glassButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.10),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(text),
    );
  }

  Widget card(String title, dynamic value) {
    return Expanded(
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: glassBox(radius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white54)),
            const Spacer(),
            Text(
              "$value",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionRow(dynamic t) {
    final tipe = t['tipe']?.toString() ?? '-';
    final isMasuk = tipe.toLowerCase() == 'masuk';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: glassBox(radius: 18),
      child: Row(
        children: [
          Icon(
            isMasuk ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: isMasuk ? Colors.greenAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['nama_barang'] ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${t['tanggal']} | ${t['jam']} | $tipe | ${t['merk'] ?? '-'}",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Text(
            "Qty: ${t['qty']}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff0f172a),
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: glassBox(radius: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Laporan Bulanan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    glassButton(monthText, pickMonth),
                    const SizedBox(width: 12),
                    glassButton(loading ? "Loading..." : "Load", fetchReport),
                  ],
                ),

                const SizedBox(height: 24),

                if (summary != null)
                  Row(
                    children: [
                      card("Masuk", summary!['barang_masuk_qty']),
                      card("Keluar", summary!['barang_keluar_qty']),
                      card("Transaksi", summary!['total_transaksi']),
                      card("Low Stock", summary!['low_stock']),
                    ],
                  ),

                const SizedBox(height: 24),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: glassBox(radius: 24),
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada data laporan bulanan",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (_, i) =>
                                transactionRow(transactions[i]),
                          ),
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