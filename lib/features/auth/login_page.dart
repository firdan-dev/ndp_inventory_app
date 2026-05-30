import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../core/auth_storage.dart';
import '../layout/main_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool isDark = true;
  bool isHoverLogin = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

 Future<void> handleLogin() async {
  final auth = AuthService();

  final user = await auth.login(
    usernameController.text.trim(),
    passwordController.text.trim(),
  );

  if (user != null) {
    await AuthStorage.saveUser(user); // 🔥 simpan session

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainLayout(role: user['role']),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login gagal")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xff020617),
                    const Color(0xff07111f),
                    const Color(0xff0f172a),
                  ]
                : [Colors.grey.shade200, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: DeliveryTruckPainter(controller.value),
                );
              },
            ),

            Positioned(
              top: -130,
              left: -90,
              child: blurCircle(const Color(0xff2563eb), 280),
            ),
            Positioned(
              bottom: -150,
              right: -120,
              child: blurCircle(const Color(0xff06b6d4), 320),
            ),

            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: glassLoginCard(textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget glassLoginCard(Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.075)
                : Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff38bdf8).withOpacity(0.22),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final pulse = sin(controller.value * pi * 2);
                  return Transform.translate(
                    offset: Offset(0, pulse * 5),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff38bdf8).withOpacity(0.38),
                            blurRadius: 30 + (pulse.abs() * 25),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/ndp_logo.png',
                        height: 95,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              Text(
                "NDP Inventory",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Smart Warehouse Management System",
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.62),
                ),
              ),

              const SizedBox(height: 32),

              inputField(
                controller: usernameController,
                label: "Username",
                icon: Icons.person_outline,
                textColor: textColor,
              ),

              const SizedBox(height: 16),

              inputField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                textColor: textColor,
                obscure: true,
              ),

              const SizedBox(height: 28),

              MouseRegion(
                onEnter: (_) => setState(() => isHoverLogin = true),
                onExit: (_) => setState(() => isHoverLogin = false),
                child: AnimatedScale(
                  scale: isHoverLogin ? 1.035 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff38bdf8)
                              .withOpacity(isHoverLogin ? 0.55 : 0.25),
                          blurRadius: isHoverLogin ? 35 : 18,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563eb),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dark_mode,
                      size: 18, color: textColor.withOpacity(0.65)),
                  Switch(
                    value: isDark,
                    onChanged: (v) => setState(() => isDark = v),
                  ),
                  Icon(Icons.light_mode,
                      size: 18, color: textColor.withOpacity(0.65)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget blurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 130,
            spreadRadius: 45,
          ),
        ],
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: textColor.withOpacity(0.65)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.065),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.13)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xff38bdf8), width: 1.5),
        ),
      ),
    );
  }
}
    



class DeliveryTruckPainter extends CustomPainter {
  final double progress;
  DeliveryTruckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final neon = Paint()
      ..color = const Color(0xff38bdf8).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = const Color(0xff38bdf8).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = const Color(0xff38bdf8).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final t = progress;
    final x = -180 + (size.width + 360) * t;
    final y = size.height * 0.72 + sin(t * pi * 2) * 6;

    canvas.save();
    canvas.translate(x, y);

    for (int i = 0; i < 5; i++) {
      final trailPaint = Paint()
        ..color = const Color(0xff38bdf8).withOpacity(0.12 - i * 0.018)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(-120 - i * 18, 18 + i * 3),
        Offset(-55 - i * 12, 18),
        trailPaint,
      );
    }

    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-70, -28, 95, 42),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, glow);
    canvas.drawRRect(body, neon);

    final cabin = Path()
      ..moveTo(25, -28)
      ..lineTo(60, -28)
      ..lineTo(78, -8)
      ..lineTo(78, 14)
      ..lineTo(25, 14)
      ..close();

    canvas.drawPath(cabin, fill);
    canvas.drawPath(cabin, glow);
    canvas.drawPath(cabin, neon);

    final boxY = -44 + sin(t * pi * 8) * 3;
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(-48, boxY, 28, 24),
      const Radius.circular(4),
    );
    canvas.drawRRect(box, fill);
    canvas.drawRRect(box, neon);
    canvas.drawLine(Offset(-34, boxY), Offset(-34, boxY + 24), neon);
    canvas.drawLine(Offset(-48, boxY + 12), Offset(-20, boxY + 12), neon);

    final wheelPaint = Paint()
      ..color = const Color(0xff38bdf8).withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(const Offset(-42, 18), 10, wheelPaint);
    canvas.drawCircle(const Offset(48, 18), 10, wheelPaint);

    final angle = t * pi * 10;
    canvas.drawLine(
      const Offset(-42, 18),
      Offset(-42 + cos(angle) * 8, 18 + sin(angle) * 8),
      wheelPaint,
    );
    canvas.drawLine(
      const Offset(48, 18),
      Offset(48 + cos(angle) * 8, 18 + sin(angle) * 8),
      wheelPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DeliveryTruckPainter oldDelegate) => true;
}