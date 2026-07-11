import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserRolePage extends StatefulWidget {
  const UserRolePage({super.key});

  @override
  State<UserRolePage> createState() => _UserRolePageState();
}

class _UserRolePageState extends State<UserRolePage> {
  static const Color accent = Color(0xffff6a00);

  final baseUrl = "https://api.api-nusantaradiesel.tech/api";

  List users = [];
  bool loading = false;

  final usernameC = TextEditingController();
  final passwordC = TextEditingController();
  final namaPicC = TextEditingController();

  String role = "staff";
  String status = "active";
  int? editId;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    usernameC.dispose();
    passwordC.dispose();
    namaPicC.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/users"));

      if (!mounted) return;

      setState(() {
        users = jsonDecode(res.body);
      });
    } catch (e) {
      debugPrint("FETCH USERS ERROR: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> saveUser() async {
    final body = {
      "username": usernameC.text.trim(),
      "password": passwordC.text.trim(),
      "role": role,
      "nama_pic": namaPicC.text.trim(),
      "status": status,
    };

    try {
      if (editId == null) {
        await http.post(
          Uri.parse("$baseUrl/users"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        await http.put(
          Uri.parse("$baseUrl/users/$editId"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }

      clearForm();
      fetchUsers();
    } catch (e) {
      debugPrint("SAVE USER ERROR: $e");
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await http.delete(Uri.parse("$baseUrl/users/$id"));
      fetchUsers();
    } catch (e) {
      debugPrint("DELETE USER ERROR: $e");
    }
  }

    void clearForm() {
    usernameC.clear();
    passwordC.clear();
    namaPicC.clear();

    setState(() {
      role = "staff";
      status = "active";
      editId = null;
    });
  }

  void editUser(dynamic u) {
    setState(() {
      editId = u['id'];
      usernameC.text = u['username'] ?? '';
      passwordC.text = u['password'] ?? '';
      namaPicC.text = u['nama_pic'] ?? '';
      role = u['role'] ?? 'staff';
      status = u['status'] ?? 'active';
    });
  }

  BoxDecoration glassBox({double radius = 24}) {
    return BoxDecoration(
      color: const Color(0xff111111).withOpacity(.94),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.55),
          blurRadius: 38,
        ),
      ],
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(.045),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accent),
      ),
    );
  }

  Widget input(String label, TextEditingController c, {bool password = false}) {
    return TextField(
      controller: c,
      obscureText: password,
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration(label),
    );
  }

    Widget dropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xff111111),
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration(''),
      iconEnabledColor: accent,
      items: items.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget userRow(dynamic u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: glassBox(radius: 18),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: accent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "${u['nama_pic'] ?? '-'} | ${u['username']} | ${u['role']} | ${u['status'] ?? 'active'}",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () => editUser(u),
            icon: const Icon(Icons.edit_rounded, color: Colors.amber),
          ),
          IconButton(
            onPressed: () => deleteUser(u['id']),
            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff050505),
            Color(0xff0b0b0b),
            Color(0xff111111),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "User Role Management",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: glassBox(radius: 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: input("Nama PIC", namaPicC)),
                      const SizedBox(width: 12),
                      Expanded(child: input("Username", usernameC)),
                      const SizedBox(width: 12),
                      Expanded(child: input("Password", passwordC, password: true)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: dropdown(
                          value: role,
                          items: const ["masterUser", "adminStok", "staff", "viewer"],
                          onChanged: (v) => setState(() => role = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: dropdown(
                          value: status,
                          items: const ["active", "inactive"],
                          onChanged: (v) => setState(() => status = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: saveUser,
                        icon: Icon(editId == null ? Icons.add_rounded : Icons.save_rounded),
                        label: Text(editId == null ? "Tambah User" : "Update"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: glassBox(radius: 28),
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: accent))
                  : users.isEmpty
                      ? const Center(
                          child: Text("Belum ada user", style: TextStyle(color: Colors.white54)),
                        )
                      : Column(
                          children: users.map((u) => userRow(u)).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}