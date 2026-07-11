import 'dart:async';
import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class LoginSuccessPage extends StatefulWidget {
  final String username;
  final String role;

  const LoginSuccessPage({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  State<LoginSuccessPage> createState() => _LoginSuccessPageState();
}

class _LoginSuccessPageState extends State<LoginSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fade;
  late Animation<Offset> slide;
  late Animation<double> scale;

  static const Color accent = Color(0xffff6a00);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    slide = Tween<Offset>(
      begin: const Offset(0, .25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    scale = Tween<double>(begin: .85, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );

    controller.forward();

    Timer(const Duration(milliseconds: 5000), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainLayout(role: widget.role),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(.12),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(.45),
                          blurRadius: 80,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: accent,
                      size: 72,
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                Text(
                  "Holaa, ${widget.username} 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Selamat datang di\nNDP Inventory",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Enjoy For This Day!!! ✨",
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: 260,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 4600),
                    builder: (_, value, __) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(20),
                        backgroundColor: Colors.white.withOpacity(.08),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(accent),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Loading Dashboard...",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}