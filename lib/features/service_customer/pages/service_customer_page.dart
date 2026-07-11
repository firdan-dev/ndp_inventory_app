import 'package:flutter/material.dart';
import '../../../models/service_customer_model.dart';
import '../../../services/service_customer_api.dart';
import 'service_customer_form_page.dart';
import 'package:ndp_inventory_app/features/service_customer/pages/service_customer_detail_page.dart';

class ServiceCustomerPage extends StatefulWidget {
  const ServiceCustomerPage({super.key});

  @override
  State<ServiceCustomerPage> createState() => _ServiceCustomerPageState();
}

class _ServiceCustomerPageState extends State<ServiceCustomerPage> {
  late Future<List<ServiceCustomer>> futureData;
  String search = "";

  static const Color accentOrange = Color(0xffff6a00);

  @override
  void initState() {
    super.initState();
    futureData = ServiceCustomerApi.getAll();
  }

  void refreshData() {
    setState(() {
      futureData = ServiceCustomerApi.getAll();
    });
  }

  Color statusColor(String? status) {
    switch (status) {
      case "Finished":
        return Colors.greenAccent;
      case "On Progress":
        return Colors.lightBlueAccent;
      default:
        return accentOrange;
    }
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return "-";
    return value.split("T").first;
  }

  List<ServiceCustomer> filterData(List<ServiceCustomer> data) {
    if (search.isEmpty) return data;
    return data.where((e) {
      final text =
          "${e.serviceNo} ${e.namaCustomer} ${e.jenisBarang} ${e.status}"
              .toLowerCase();
      return text.contains(search.toLowerCase());
    }).toList();
  }

  
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xff050505),
    body: Padding(
      padding: const EdgeInsets.all(22),
      child: FutureBuilder<List<ServiceCustomer>>(
        future: futureData,
        builder: (context, snapshot) {
          final rawData = snapshot.data ?? [];
          final data = filterData(rawData);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(rawData),
              const SizedBox(height: 18),
              searchBar(),
              const SizedBox(height: 18),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                        ? Center(
                            child: Text(
                              "Error: ${snapshot.error}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          )
                        : data.isEmpty
                            ? emptyState()
                            : ListView.separated(
                                itemCount: data.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  return serviceCard(data[index]);
                                },
                              )
              ),
            ],
          );
        },
      ),
    ),
  );
}

  Widget header(List<ServiceCustomer> data) {
    final waiting = data.where((e) => e.status == "Waiting").length;
    final progress = data.where((e) => e.status == "On Progress").length;
    final finished = data.where((e) => e.status == "Finished").length;

    return glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Service Customer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Kelola data barang customer, mekanik, dan pergantian part",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceCustomerFormPage(),
                    ),
                  );
                  if (result == true) refreshData();
                },

                icon: const Icon(Icons.add_rounded),
                label: const Text("Tambah Service"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              statBox("Total Service", data.length, Colors.white),
              statBox("Waiting", waiting, accentOrange),
              statBox("On Progress", progress, Colors.lightBlueAccent),
              statBox("Finished", finished, Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          icon: Icon(Icons.search_rounded, color: Colors.white38),
          hintText: "Cari no service, customer, barang, status...",
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

 Widget serviceCard(ServiceCustomer item) {
  final color = statusColor(item.status);

  return glassCard(
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: accentOrange.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentOrange.withOpacity(0.35)),
          ),
          child: const Icon(
            Icons.build_circle_rounded,
            color: accentOrange,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: infoBlock("No Service", item.serviceNo ?? "-")),
        Expanded(flex: 2, child: infoBlock("Tanggal In", formatDate(item.tanggalIn))),
        Expanded(flex: 3, child: infoBlock("Customer", item.namaCustomer ?? "-")),
        Expanded(flex: 3, child: infoBlock("Barang", item.jenisBarang ?? "-")),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.45)),
          ),
          child: Text(
            item.status ?? "Waiting",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 14),
        IconButton(
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => ServiceCustomerDetailPage(service: item),
            );
            if (result == true) refreshData();
          },
          icon: const Icon(Icons.visibility_rounded),
          color: accentOrange,
        ),
      ],
    ),
  );
}

  Widget infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 5),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget statBox(String title, int value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Text(
            "$value",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  Widget emptyState() {
    return glassCard(
      child: const Center(
        child: Text(
          "Belum ada data service customer",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xff111111).withOpacity(0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}