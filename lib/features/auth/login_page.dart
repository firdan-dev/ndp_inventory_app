import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xff020617) : Colors.grey[200];
    final cardColor = isDark ? const Color(0xff0f172a) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "NDP Inventory",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 25),

              TextField(
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainLayout(),
                      ),
                    );
                  },
                  child: const Text("LOGIN"),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dark_mode, size: 18),
                  Switch(
                    value: isDark,
                    onChanged: (v) {
                      setState(() {
                        isDark = v;
                      });
                    },
                  ),
                  const Icon(Icons.light_mode, size: 18),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}