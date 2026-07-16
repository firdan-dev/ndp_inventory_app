import 'dart:async';

import 'package:flutter/material.dart';

import '../../layout/mobile_main_layout.dart';

class LoginSuccessMobilePage extends StatefulWidget {
  final String username;
  final String role;

  const LoginSuccessMobilePage({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  State<LoginSuccessMobilePage> createState() =>
      _LoginSuccessMobilePageState();
}

class _LoginSuccessMobilePageState extends State<LoginSuccessMobilePage>
    with TickerProviderStateMixin {
  static const Color accent = Color(0xffff6a00);

  late final AnimationController _introController;
  late final AnimationController _ringController;
  late final AnimationController _progressController;

  late final Animation<double> _checkScale;
  late final Animation<double> _checkFade;
  late final Animation<double> _ringRotation;
  late final Animation<double> _ringScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _loadingFade;
  late final Animation<double> _progress;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4300),
    );

    _checkScale = Tween<double>(
      begin: 0.15,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0,
          0.38,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _checkFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0,
        0.25,
        curve: Curves.easeOut,
      ),
    );

    _ringRotation = Tween<double>(
      begin: -0.35,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: Curves.easeOutCubic,
      ),
    );

    _ringScale = Tween<double>(
      begin: 0.75,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: Curves.easeOutBack,
      ),
    );

    _textFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.35,
        0.78,
        curve: Curves.easeOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0.35,
          0.82,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _loadingFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.68,
        1,
        curve: Curves.easeOut,
      ),
    );

    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 120),
    );

    if (!mounted) return;

    _introController.forward();
    _ringController.forward();

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    _progressController.forward();

    _navigationTimer = Timer(
      const Duration(milliseconds: 4700),
      _openMainLayout,
    );
  }

  void _openMainLayout() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, secondaryAnimation) {
          return MobileMainLayout(role: widget.role);
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _ringController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff030303),
              Color(0xff090909),
              Color(0xff111111),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -130,
              child: _buildBlurCircle(
                size: 290,
                opacity: 0.055,
              ),
            ),
            Positioned(
              bottom: -170,
              left: -140,
              child: _buildBlurCircle(
                size: 320,
                opacity: 0.04,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSuccessIcon(),
                      const SizedBox(height: 38),
                      _buildWelcomeText(),
                      const SizedBox(height: 42),
                      _buildLoadingSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _introController,
        _ringController,
      ]),
      builder: (_, __) {
        return FadeTransition(
          opacity: _checkFade,
          child: ScaleTransition(
            scale: _checkScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _ringRotation,
                  child: ScaleTransition(
                    scale: _ringScale,
                    child: CustomPaint(
                      size: const Size(150, 150),
                      painter: SuccessRingPainter(
                        progress: _ringController.value,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.12),
                    border: Border.all(
                      color: accent.withOpacity(0.38),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.20),
                        blurRadius: 45,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: accent,
                    size: 58,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return SlideTransition(
      position: _textSlide,
      child: FadeTransition(
        opacity: _textFade,
        child: Column(
          children: [
            const Text(
              'Login berhasil',
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Selamat datang,\n${widget.username}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                height: 1.25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'NDP Inventory siap digunakan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return FadeTransition(
      opacity: _loadingFade,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffff8a00),
                          Color(0xffff5c00),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progress,
            builder: (_, __) {
              final progress = _progress.value;

              String message;

              if (progress < 0.35) {
                message = 'Menyiapkan sesi...';
              } else if (progress < 0.70) {
                message = 'Memuat data aplikasi...';
              } else if (progress < 0.96) {
                message = 'Menyiapkan dashboard...';
              } else {
                message = 'Selesai';
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  message,
                  key: ValueKey(message),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle({
    required double size,
    required double opacity,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withOpacity(opacity),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(opacity * 1.7),
              blurRadius: 130,
              spreadRadius: 42,
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessRingPainter extends CustomPainter {
  final double progress;

  SuccessRingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 8;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = const Color(0xffff6a00).withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -1.5708,
      6.28318 * progress,
      false,
      progressPaint,
    );

    final secondRingPaint = Paint()
      ..color = const Color(0xffff6a00).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(
      center,
      radius - 13,
      secondRingPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant SuccessRingPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}