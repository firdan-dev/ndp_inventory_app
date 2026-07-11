import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';



class DashboardPage extends StatefulWidget {
  final VoidCallback? onOpenServiceCustomer;
  final VoidCallback? onOpenSuratJalan;

  const DashboardPage({
    super.key,
    this.onOpenServiceCustomer,
    this.onOpenSuratJalan,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}



class _DashboardPageState extends State<DashboardPage> {
  static const Color accent = Color(0xffff6a00);

  DateTime now = DateTime.now();
  Timer? timer;

  bool isLoading = true;

  int totalJenisBarang = 0;
  int totalBarang = 0;
  int barangMasuk = 0;
  int barangKeluar = 0;
  int barangMasukJenis = 0;
  int barangKeluarJenis = 0;
  int lowStock = 0;
  int sjPending = 0;
  int sjApproved = 0;
  int sjDikirim = 0;
  int csPending = 0;
  int csProgress = 0;
  int csFinished = 0;
  

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> categorySummary = [];
  List<Map<String, dynamic>> lowStockItems = [];
  List<Map<String, dynamic>> customerServices = [];
  List<Map<String, dynamic>> stockMovement = [];
  List<Map<String, dynamic>> suratJalanList = [];

  double toDoubleValue(dynamic value) {
  return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
  

  Map<String, dynamic> getCategory(String kategori) {
  return categorySummary.firstWhere(
    (e) => e['kategori'] == kategori,
    orElse: () => {
      'kategori': kategori,
      'total_item': 0,
      'total_qty': 0,
    },
  );
}


String formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';

  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year} "
      "${date.hour.toString().padLeft(2, '0')}:"
      "${date.minute.toString().padLeft(2, '0')}";
}

  
  @override
  void initState() {
    super.initState();
    loadDashboard();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() => isLoading = true);

      final summary = await ApiService.getDashboardSummary();
      final recent = await ApiService.getRecentTransactions();
      final categories = await ApiService.getCategorySummary();
      final lowStockData = await ApiService.getLowStockItems();
      final csData = await ApiService.getCustomerServiceDashboard();
      final suratJalanData = await ApiService.getSuratJalanSummary();
      final suratJalanListData = await ApiService.getSuratJalanDashboard();
      final csSummary = await ApiService.getCustomerServiceSummary();
      
      

      if (!mounted) return;

      setState(() {
        totalBarang = int.tryParse(summary['total_barang']?.toString() ?? '0') ?? 0;
        totalJenisBarang =
            int.tryParse(summary['total_jenis_barang']?.toString() ?? '0') ??
                barangMasukJenis;
        

        barangMasuk =
            int.tryParse(summary['barang_masuk_qty']?.toString() ?? '0') ?? 0;
        barangKeluar =
            int.tryParse(summary['barang_keluar_qty']?.toString() ?? '0') ?? 0;

        barangMasukJenis =
            int.tryParse(summary['barang_masuk_jenis']?.toString() ?? '0') ?? 0;
        barangKeluarJenis =
            int.tryParse(summary['barang_keluar_jenis']?.toString() ?? '0') ?? 0;

        lowStock = int.tryParse(summary['low_stock']?.toString() ?? '0') ?? 0;
        transactions = List<Map<String, dynamic>>.from(recent);
        isLoading = false;
        categorySummary = List<Map<String, dynamic>>.from(categories);
        lowStockItems = List<Map<String, dynamic>>.from(lowStockData);
        customerServices = List<Map<String, dynamic>>.from(csData);
        sjPending = int.tryParse(suratJalanData['pending']?.toString() ?? '0') ?? 0;
        sjApproved = int.tryParse(suratJalanData['approved']?.toString() ?? '0') ?? 0;
        sjDikirim = int.tryParse(suratJalanData['delivered']?.toString() ?? '0') ?? 0;
        suratJalanList = List<Map<String, dynamic>>.from(suratJalanListData);
        csPending = int.tryParse(csSummary['pending'].toString()) ?? 0;
        csProgress = int.tryParse(csSummary['progress'].toString()) ?? 0;
        csFinished = int.tryParse(csSummary['finished'].toString()) ?? 0;
      });
    } catch (e) {
  debugPrint("DASHBOARD ERROR: $e");
  if (mounted) setState(() => isLoading = false);
}
  }

  String get clockText {
    return "${now.day.toString().padLeft(2, '0')} ${monthName(now.month)} ${now.year} • "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')} WIB";
  }

  String monthName(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff050505),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            const SizedBox(height: 24),

            Row(
              children: [
                summaryCard(
                  "Total Jenis Barang",
                  totalJenisBarang.toString(),
                  Icons.inventory_2_outlined,
                  const Color(0xff3b82f6),
                  subtitle: "$totalBarang unit total stock",
                ),
                const SizedBox(width: 18),
                summaryCard(
                  "Stock In",
                  barangMasuk.toString(),
                  Icons.south_west_rounded,
                  const Color(0xff22c55e),
                  subtitle: "$barangMasukJenis jenis barang",
                ),
                const SizedBox(width: 18),
                summaryCard(
                  "Stock Out",
                  barangKeluar.toString(),
                  Icons.north_east_rounded,
                  accent,
                  subtitle: "$barangKeluarJenis jenis barang",
                ),
                const SizedBox(width: 18),
                summaryCard(
                  "Low Stock",
                  lowStock.toString(),
                  Icons.warning_amber_rounded,
                  const Color(0xffef4444),
                  subtitle: "Butuh perhatian",
                ),
              ],
            ),

            const SizedBox(height: 24),
            categoryCards(),
            const SizedBox(height: 24),

            customerServicePanel(),

            const SizedBox(height: 24),

            Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: lowStockPanel()),
                  const SizedBox(width: 18),
                  Expanded(child: suratJalanPanel()),
                ],
              ),

              const SizedBox(height: 24),

              recentPanelFull(),
            ],
          ),

           
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard Nusantara Diesel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Warehouse Monitoring System",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: glassBox(),
          child: Text(
            clockText,
            style: const TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget summaryCard(
  String title,
  String value,
  IconData icon,
  Color color, {
  String? subtitle,
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
            curve: Curves.easeOut,
            height: isHover ? 175 : 165,
            transform: Matrix4.translationValues(0, isHover ? -6 : 0, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(isHover ? .35 : .25),
                  const Color(0xff111111),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: color.withOpacity(isHover ? .65 : .35),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isHover ? .38 : .22),
                  blurRadius: isHover ? 70 : 45,
                  spreadRadius: isHover ? 4 : 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  top: -8,
                  child: Icon(
                    icon,
                    size: isHover ? 90 : 82,
                    color: color.withOpacity(.16),
                  ),
                ),  

                
                

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const Spacer(),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(title, style: const TextStyle(color: Colors.white60)),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
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

  Widget categoryCards() {
  final master = getCategory("MASTER");
  final radiator = getCategory("RADIATOR");
  final injector = getCategory("INJECTOR");
  final fip = getCategory("FIP");

  return Row(
    children: [
      summaryCard(
        "MASTER",
        master['total_item'].toString(),
        Icons.inventory_rounded,
        const Color.fromARGB(255, 4, 46, 113),
        subtitle: "${master['total_qty']} unit stock",
      ),
      const SizedBox(width: 18),
      summaryCard(
        "RADIATOR",
        radiator['total_item'].toString(),
        Icons.ac_unit_rounded,
        const Color(0xff06b6d4),
        subtitle: "${radiator['total_qty']} unit stock",
      ),
      const SizedBox(width: 18),
      summaryCard(
        "INJECTOR",
        injector['total_item'].toString(),
        Icons.settings_input_component_rounded,
        const Color.fromARGB(255, 255, 247, 0),
        subtitle: "${injector['total_qty']} unit stock",
      ),
      const SizedBox(width: 18),
      summaryCard(
        "FIP",
        fip['total_item'].toString(),
        Icons.precision_manufacturing_rounded,
        accent,
        subtitle: "${fip['total_qty']} unit stock",
      ),
    ],
  );
}

 Widget customerServicePanel() {
  return InkWell(
    onTap: widget.onOpenServiceCustomer,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      height: 360,
      padding: const EdgeInsets.all(22),
      decoration: glassBox(glowColor: const Color(0xff22c55e)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Customer Service",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
              const Spacer(),
              csMiniCounter("Waiting", csPending, const Color(0xffef4444)),
              const SizedBox(width: 10),
              csMiniCounter("On Progress", csProgress, Colors.orange),
              const SizedBox(width: 10),
              csMiniCounter("Finished", csFinished, const Color(0xff22c55e)),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: customerServices.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada pekerjaan aktif",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: customerServices.length,
                    itemBuilder: (_, i) => customerJobItem(customerServices[i]),
                  ),
          ),
        ],
      ),
    ),
  );
}

  Widget csMiniCounter(String title, int value, Color color) {
  return Text(
    "$title: $value",
    style: TextStyle(
      color: color,
      fontSize: 13,
      fontWeight: FontWeight.bold,
    ),
  );
}


Widget customerJobItem(Map<String, dynamic> job) {
  final customer = job['nama_customer']?.toString() ?? '-';
  final barang = job['jenis_barang']?.toString() ?? '-';
  final status = job['status']?.toString() ?? '-';

  final isDone = status.toLowerCase() == "finished" ||
      status.toLowerCase() == "selesai";

  final isProgress = status.toLowerCase() == "progress" ||
      status.toLowerCase() == "on progress";

  final color = isDone
      ? const Color(0xff22c55e)
      : isProgress
          ? Colors.orange
          : const Color(0xffef4444);

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(.25)),
    ),
    child: Row(
      children: [
        Icon(Icons.support_agent_rounded, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(barang,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}


 
  Widget recentPanelFull() {
  return Container(
    height: 420,
    padding: const EdgeInsets.all(22),
    decoration: glassBox(glowColor: accent),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: const [
              SizedBox(width: 40),
              Expanded(flex: 2, child: Text("Tanggal", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(flex: 3, child: Text("Kategori | Item", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(flex: 2, child: Text("Part No.", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(child: Text("Type", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(child: Text("Qty", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(flex: 2, child: Text("PIC", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(flex: 3, child: Text("Keterangan", style: TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
        ),

         const SizedBox(height: 20),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: accent))
              : transactions.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada transaksi",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )

                    
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (_, i) => recentItem(transactions[i]),
                    ),
        ),
      ],
    ),
  );
}


Widget recentItem(Map<String, dynamic> t) {
  bool isHover = false;

  return StatefulBuilder(
    builder: (context, setHover) {
      final type = t['type']?.toString() ?? '-';
      final isIn = type.toUpperCase() == 'IN' || type.toLowerCase() == 'masuk';
      final color = isIn ? const Color(0xff22c55e) : const Color(0xffef4444);

      TextStyle cellStyle({Color? customColor, FontWeight? weight}) {
        return TextStyle(
          color: customColor ?? (isHover ? Colors.white : Colors.white70),
          fontWeight: weight,
          fontSize: 13,
        );
      }

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setHover(() => isHover = true),
        onExit: (_) => setHover(() => isHover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isHover
                ? Colors.white.withOpacity(.075)
                : Colors.white.withOpacity(.045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHover ? color.withOpacity(.45) : Colors.white.withOpacity(.08),
            ),
            boxShadow: isHover
                ? [
                    BoxShadow(
                      color: color.withOpacity(.18),
                      blurRadius: 26,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color,
                size: isHover ? 30 : 26,
              ),
              const SizedBox(width: 14),

              Expanded(
                flex: 2,
                child: Text(formatDate(t['created_at']), style: cellStyle()),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "${t['kategori'] ?? '-'} | ${t['item_name'] ?? '-'}",
                  overflow: TextOverflow.ellipsis,
                  style: cellStyle(weight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(t['part_no']?.toString() ?? '-', style: cellStyle()),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  type.toUpperCase(),
                  style: cellStyle(customColor: color, weight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Qty ${t['qty'] ?? 0}",
                  style: cellStyle(customColor: color, weight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(t['pic']?.toString() ?? '-', style: cellStyle()),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  t['keterangan']?.toString() ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: cellStyle(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget lowStockPanel() {
  return panel(
    title: "Low Stock Alert",
    glowColor: const Color(0xffef4444),
    child: Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : lowStockItems.isEmpty
              ? const Center(
                  child: Text(
                    "Tidak ada barang low stock",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: lowStockItems.length,
                  itemBuilder: (_, i) => lowStockItem(lowStockItems[i]),
                ),
    ),
  );
}

Widget lowStockItem(Map<String, dynamic> item) {
  final kategori = item['kategori']?.toString() ?? '-';
  final nama = item['item_name']?.toString() ?? '-';
  final partNo = item['part_no']?.toString() ?? '-';
  final qty = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
  final minStock = int.tryParse(item['min_stock']?.toString() ?? '10') ?? 10;

  final percent = minStock == 0 ? 0.0 : (qty / minStock).clamp(0.0, 1.0);
  final isCritical = qty <= 0;

  final color = isCritical ? const Color(0xffef4444) : Colors.orange;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                partNo,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              isCritical ? "CRITICAL" : "WARNING",
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          "$kategori | $nama",
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              "Stock $qty / Min $minStock",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const Spacer(),
            Text(
              "${(percent * 100).toInt()}%",
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    ),
  );
}

Widget suratJalanPanel() {
  return Container(
    height: 260,
    padding: const EdgeInsets.all(22),
    decoration: glassBox(glowColor: const Color(0xff3b82f6)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Surat Jalan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: widget.onOpenSuratJalan,
              child: const Text(
                "View All >",
                style: TextStyle(
                  color: Color(0xff3b82f6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            statusBox("Pending", sjPending, Colors.orange),
            statusBox("Approved", sjApproved, Colors.blue),
            statusBox("Dikirim", sjDikirim, Colors.green),
          ],
        ),

        const SizedBox(height: 18),

        Expanded(
          child: suratJalanList.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada surat jalan terbaru",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: suratJalanList.length,
                  itemBuilder: (_, i) {
                    final item = suratJalanList[i];

                    return suratItem(
                      item['nomor_surat_jalan']?.toString() ?? '-',
                      item['tujuan']?.toString() ?? '-',
                      item['status']?.toString() ?? '-',
                    );
                  },
                ),
        ),
      ],
    ),
  );
}

Widget statusBox(String title, int value, Color color) {
  return Column(
    children: [
      Text(
        value.toString(),
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(title, style: const TextStyle(color: Colors.white54)),
    ],
  );
}


Widget suratItem(String nomor, String tujuan, String status) {
  return ListTile(
    title: Text(nomor, style: const TextStyle(color: Colors.white)),
    subtitle: Text(tujuan, style: const TextStyle(color: Colors.white54)),
    trailing: Text(
      status,
      style: TextStyle(
        color: status == "Dikirim" ? Colors.green : Colors.orange,
      ),
    ),
  );
}

  

        Widget panel({
        required String title,
        required Widget child,
        Color glowColor = accent,
      }) {
        return Container(
          height: 260,
          padding: const EdgeInsets.all(22),
          decoration: glassBox(glowColor: glowColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );
      }

    static BoxDecoration glassBox({Color glowColor = accent}) {
    return BoxDecoration(
      color: const Color(0xff111111).withOpacity(.94),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: glowColor.withOpacity(.18)),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(.12),
          blurRadius: 55,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(.50),
          blurRadius: 35,
        ),
      ],
    );
  }
}