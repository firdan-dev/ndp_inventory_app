import 'package:flutter/material.dart';
import '../../../services/service_customer_api.dart';

class ServiceCustomerFormPage extends StatefulWidget {
  const ServiceCustomerFormPage({super.key});

  @override
  State<ServiceCustomerFormPage> createState() =>
      _ServiceCustomerFormPageState();
}

class _ServiceCustomerFormPageState extends State<ServiceCustomerFormPage> {
  final customerC = TextEditingController();
  final jenisBarangC = TextEditingController();
  final typeUnitC = TextEditingController();
  final partNoC = TextEditingController();

  DateTime tanggalIn = DateTime.now();
  DateTime tanggalDikerjakan = DateTime.now();

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xff050505),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tambah Service Customer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xff111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  input("Nama Customer", customerC),
                  input("Jenis Barang", jenisBarangC),
                  input("Type Unit", typeUnitC),
                  input("Part No", partNoC),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ServiceCustomerApi.create({
                          "tanggal_in": tanggalIn.toIso8601String(),
                          "tanggal_dikerjakan": tanggalDikerjakan.toIso8601String(),
                          "nama_customer": customerC.text,
                          "jenis_barang": jenisBarangC.text,
                          "type_unit": typeUnitC.text,
                          "part_no": partNoC.text,
                          "status": "Waiting",
                        });

                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text("Simpan Service"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}