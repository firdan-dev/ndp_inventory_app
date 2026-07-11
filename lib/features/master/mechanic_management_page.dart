import 'package:flutter/material.dart';
import '../../../models/mechanic_model.dart';
import '../../../services/service_customer_api.dart';

class MechanicManagementPage extends StatefulWidget {
  const MechanicManagementPage({super.key});

  @override
  State<MechanicManagementPage> createState() =>
      _MechanicManagementPageState();
}

class _MechanicManagementPageState
    extends State<MechanicManagementPage> {
  static const accentOrange = Color(0xffff6a00);

  late Future<List<Mechanic>> futureMechanics;
  final searchC = TextEditingController();
  String search = '';

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {
      futureMechanics =
          ServiceCustomerApi.getAllMechanics();
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showMechanicDialog({
    Mechanic? mechanic,
  }) async {
    final nameC = TextEditingController(
      text: mechanic?.namaMekanik ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff191919),
        title: Text(
          mechanic == null
              ? 'Tambah Mekanik'
              : 'Edit Mekanik',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameC,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nama Mekanik',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameC.text.trim();

              if (name.isEmpty) return;

              Navigator.pop(dialogContext, name);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nameC.dispose();

    if (result == null) return;

    try {
      if (mechanic == null) {
        await ServiceCustomerApi.addMechanic(result);
        showMessage('Mekanik berhasil ditambahkan');
      } else {
        await ServiceCustomerApi.updateMechanic(
          mechanic.id,
          result,
        );
        showMessage('Nama mekanik berhasil diperbarui');
      }

      refresh();
    } catch (e) {
      showMessage('Gagal menyimpan mekanik: $e');
    }
  }

  Future<void> changeStatus(Mechanic mechanic) async {
    final newStatus = mechanic.status == 'active'
        ? 'inactive'
        : 'active';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff191919),
        title: Text(
          newStatus == 'inactive'
              ? 'Nonaktifkan Mekanik?'
              : 'Aktifkan Mekanik?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          newStatus == 'inactive'
              ? '${mechanic.namaMekanik} tidak akan muncul lagi di dropdown assignment.'
              : '${mechanic.namaMekanik} akan muncul kembali di dropdown assignment.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ServiceCustomerApi.updateMechanicStatus(
        mechanic.id,
        newStatus,
      );

      showMessage(
        newStatus == 'active'
            ? 'Mekanik berhasil diaktifkan'
            : 'Mekanik berhasil dinonaktifkan',
      );

      refresh();
    } catch (e) {
      showMessage('Gagal mengubah status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d0d0d),
      appBar: AppBar(
        backgroundColor: const Color(0xff111111),
        title: const Text('Master Mekanik'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentOrange,
        onPressed: () => showMechanicDialog(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Mekanik'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: searchC,
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari mekanik...',
                hintStyle:
                    const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.search,
                  color: accentOrange,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Mechanic>>(
                future: futureMechanics,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  }

                  final mechanics = (snapshot.data ?? [])
                      .where(
                        (item) => item.namaMekanik
                            .toLowerCase()
                            .contains(search),
                      )
                      .toList();

                  if (mechanics.isEmpty) {
                    return const Center(
                      child: Text(
                        'Data mekanik tidak ditemukan',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: mechanics.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final mechanic = mechanics[index];
                      final active =
                          mechanic.status == 'active';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.04),
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: active
                                  ? Colors.green
                                      .withOpacity(0.15)
                                  : Colors.red
                                      .withOpacity(0.15),
                              child: Icon(
                                Icons.engineering_rounded,
                                color: active
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                mechanic.namaMekanik,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.green
                                        .withOpacity(0.15)
                                    : Colors.red
                                        .withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                active
                                    ? 'Active'
                                    : 'Inactive',
                                style: TextStyle(
                                  color: active
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: 'Edit nama',
                              onPressed: () =>
                                  showMechanicDialog(
                                mechanic: mechanic,
                              ),
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            IconButton(
                              tooltip: active
                                  ? 'Nonaktifkan'
                                  : 'Aktifkan',
                              onPressed: () =>
                                  changeStatus(mechanic),
                              icon: Icon(
                                active
                                    ? Icons
                                        .person_off_rounded
                                    : Icons
                                        .person_add_alt_rounded,
                                color: active
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}