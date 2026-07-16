import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/auth_storage.dart';
import '../../../features/auth/auth_service.dart';
import 'login_success_mobile_page.dart';

class LoginMobilePage extends StatefulWidget {
  const LoginMobilePage({super.key});

  @override
  State<LoginMobilePage> createState() => _LoginMobilePageState();
}

class _LoginMobilePageState extends State<LoginMobilePage>
    with SingleTickerProviderStateMixin {
  static const Color _orange = Color(0xffff6a00);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  late final AnimationController _animationController;

  bool _loading = false;
  bool _hidePassword = true;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_loading || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user == null) {
        _showMessage(
          'Username atau password salah',
          isError: true,
        );
        return;
      }

      await AuthStorage.saveUser(user);

      if (!mounted) return;

      final role = user['role']?.toString() ?? '';

      final namaPic = user['nama_pic']?.toString().trim();
      final username = namaPic != null && namaPic.isNotEmpty
          ? namaPic
          : user['username']?.toString() ??
          _usernameController.text.trim();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginSuccessMobilePage(
            username: username,
            role: role,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal terhubung ke server. Periksa koneksi internet.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(
      String message, {
        required bool isError,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          isError ? const Color(0xffb3261e) : const Color(0xff1b5e20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff030303),
              Color(0xff0b0b0b),
              Color(0xff121212),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: MobileDeliveryTruckPainter(
                        _animationController.value,
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              top: -110,
              left: -100,
              child: _blurCircle(
                const Color(0xff2a2a2a),
                240,
              ),
            ),

            Positioned(
              bottom: -130,
              right: -110,
              child: _blurCircle(
                const Color(0xff1f1f1f),
                270,
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 35 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildLoginCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cardWidth =
        availableWidth > 420 ? 420.0 : availableWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xff111111).withOpacity(0.90),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.65),
                    blurRadius: 55,
                    spreadRadius: 3,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: _orange.withOpacity(0.04),
                    blurRadius: 50,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedLogo(),
                    const SizedBox(height: 12),

                    const Text(
                      'NDP Inventory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Smart Warehouse Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username wajib diisi';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white54,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 26),

                    _buildLoginButton(),

                    const SizedBox(height: 22),

                    Text(
                      'PT Nusantara Diesel Pratama',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.38),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'NDP Inventory Mobile',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.24),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        final pulse = sin(
          _animationController.value * pi * 2,
        );

        return Transform.translate(
          offset: Offset(0, pulse * 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.10),
                  blurRadius: 22 + pulse.abs() * 18,
                ),
                BoxShadow(
                  color: _orange.withOpacity(0.08),
                  blurRadius: 30 + pulse.abs() * 15,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/ndp_logo.png',
              height: 88,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _orange.withOpacity(0.30),
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: _orange,
                    size: 42,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autocorrect: false,
      enableSuggestions: !obscureText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.55),
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.60),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xff1a1a1a),
        errorStyle: const TextStyle(
          color: Color(0xffff6b6b),
          fontSize: 11,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.38),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xffff6b6b),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xffff6b6b),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTapDown: _loading
          ? null
          : (_) {
        setState(() => _buttonPressed = true);
      },
      onTapUp: _loading
          ? null
          : (_) {
        setState(() => _buttonPressed = false);
      },
      onTapCancel: _loading
          ? null
          : () {
        setState(() => _buttonPressed = false);
      },
      child: AnimatedScale(
        scale: _buttonPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(
                  _buttonPressed ? 0.18 : 0.10,
                ),
                blurRadius: _buttonPressed ? 28 : 18,
              ),
              BoxShadow(
                color: _orange.withOpacity(0.10),
                blurRadius: 28,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xff1c1c1c),
              disabledBackgroundColor:
              const Color(0xff1c1c1c).withOpacity(0.65),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.13),
                ),
              ),
            ),
            child: _loading
                ? const SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _orange,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _blurCircle(
      Color color,
      double size,
      ) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 120,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class MobileDeliveryTruckPainter extends CustomPainter {
  final double progress;

  MobileDeliveryTruckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final neon = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final t = progress;
    final truckScale = size.width < 380 ? 0.72 : 0.82;
    final x = -150 + (size.width + 300) * t;
    final y = size.height * 0.82 + sin(t * pi * 2) * 5;

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(truckScale);

    for (int i = 0; i < 5; i++) {
      final opacity = max(0.0, 0.09 - i * 0.014);

      final trailPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
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

    final wheelPaint = Paint()
      ..color = Colors.white.withOpacity(0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;

    canvas.drawCircle(
      const Offset(-42, 18),
      10,
      wheelPaint,
    );

    canvas.drawCircle(
      const Offset(48, 18),
      10,
      wheelPaint,
    );

    final angle = t * pi * 10;

    canvas.drawLine(
      const Offset(-42, 18),
      Offset(
        -42 + cos(angle) * 8,
        18 + sin(angle) * 8,
      ),
      wheelPaint,
    );

    canvas.drawLine(
      const Offset(48, 18),
      Offset(
        48 + cos(angle) * 8,
        18 + sin(angle) * 8,
      ),
      wheelPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
      covariant MobileDeliveryTruckPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}