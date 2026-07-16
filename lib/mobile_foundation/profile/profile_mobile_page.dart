import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/auth_storage.dart';

class ProfileMobilePage extends StatefulWidget {
  final String role;

  const ProfileMobilePage({
    super.key,
    required this.role,
  });

  @override
  State<ProfileMobilePage> createState() =>
      _ProfileMobilePageState();
}

class _ProfileMobilePageState extends State<ProfileMobilePage> {
  static const Color accent = Color(0xffff6a00);

  String _name = 'Pengguna';
  String _username = '-';
  String _branch = '-';

  bool _loading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await AuthStorage.getUser();

      if (!mounted) return;

      final namaPic = user?['nama_pic']?.toString().trim();
      final username = user?['username']?.toString().trim();

      final branch =
          user?['cabang']?.toString().trim() ??
              user?['nama_cabang']?.toString().trim();

      setState(() {
        _name = namaPic != null && namaPic.isNotEmpty
            ? namaPic
            : username != null && username.isNotEmpty
            ? username
            : 'Pengguna';

        _username =
        username != null && username.isNotEmpty ? username : '-';

        _branch =
        branch != null && branch.isNotEmpty ? branch : '-';

        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  bool get _isAdmin {
    final role = widget.role.toLowerCase();

    return role.contains('admin') ||
        role.contains('master') ||
        role.contains('administrator');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: -130,
            child: _buildBackgroundGlow(
              color: accent,
              size: 290,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -150,
            child: _buildBackgroundGlow(
              color: const Color(0xff64b5f6),
              size: 300,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: accent,
              backgroundColor: const Color(0xff181818),
              onRefresh: _loadProfile,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      115,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          _buildProfileHeader(),
                          const SizedBox(height: 26),
                          _buildSectionHeader(
                            title: 'Pengaturan Akun',
                            subtitle:
                            'Kelola informasi dan keamanan akun',
                          ),
                          const SizedBox(height: 14),
                          _buildAccountMenus(),
                          if (_isAdmin) ...[
                            const SizedBox(height: 26),
                            _buildSectionHeader(
                              title: 'Administrator',
                              subtitle:
                              'Pengelolaan pengguna aplikasi',
                            ),
                            const SizedBox(height: 14),
                            _buildAdminMenu(),
                          ],
                          const SizedBox(height: 26),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loggingOut) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow({
    required Color color,
    required double size,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.025),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 130,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.025),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(0.42),
                          accent.withOpacity(0.13),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: accent.withOpacity(0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.20),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: accent,
                      size: 39,
                    ),
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration:
                          const Duration(milliseconds: 250),
                          child: Text(
                            _loading ? 'Memuat...' : _name,
                            key: ValueKey(
                              _loading ? 'loading' : _name,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _loading ? '...' : '@$_username',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.13),
                            borderRadius:
                            BorderRadius.circular(30),
                            border: Border.all(
                              color: accent.withOpacity(0.24),
                            ),
                          ),
                          child: Text(
                            _formatRole(widget.role),
                            style: const TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Divider(
                height: 1,
                color: Colors.white.withOpacity(0.07),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildProfileInfo(
                      icon: Icons.account_circle_outlined,
                      label: 'Username',
                      value: _loading ? '...' : _username,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 43,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    color: Colors.white.withOpacity(0.07),
                  ),
                  Expanded(
                    child: _buildProfileInfo(
                      icon: Icons.business_outlined,
                      label: 'Cabang',
                      value: _loading ? '...' : _branch,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountMenus() {
    const menus = <_ProfileMenuItem>[
      _ProfileMenuItem(
        title: 'Informasi Akun',
        subtitle: 'Lihat informasi pengguna dan role',
        icon: Icons.badge_outlined,
        color: Color(0xff64b5f6),
      ),
      _ProfileMenuItem(
        title: 'Keamanan',
        subtitle: 'Kelola password dan keamanan akun',
        icon: Icons.lock_outline_rounded,
        color: Color(0xffffb74d),
      ),
      _ProfileMenuItem(
        title: 'Tentang Aplikasi',
        subtitle: 'Versi aplikasi dan informasi developer',
        icon: Icons.info_outline_rounded,
        color: Color(0xffb58cff),
      ),
    ];

    return Column(
      children: List.generate(
        menus.length,
            (index) {
          final item = menus[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < menus.length - 1 ? 11 : 0,
            ),
            child: _ProfileGlassCard(
              item: item,
              onTap: () => _openProfileMenu(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminMenu() {
    const item = _ProfileMenuItem(
      title: 'Master User',
      subtitle: 'Kelola akun admin dan mekanik',
      icon: Icons.manage_accounts_outlined,
      color: Color(0xff43d17b),
    );

    return _ProfileGlassCard(
      item: item,
      badge: 'ADMIN',
      onTap: () => _openProfileMenu(item),
    );
  }

  void _openProfileMenu(_ProfileMenuItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
        const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) {
          return _ProfilePlaceholderPage(
            title: item.title,
            subtitle: item.subtitle,
            icon: item.icon,
            color: item.color,
          );
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loggingOut ? null : _showLogoutConfirmation,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xffff5252).withOpacity(0.14),
                const Color(0xffff5252).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xffff5252).withOpacity(0.28),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xffff6b6b),
                size: 23,
              ),
              SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Keluar dari Akun',
                  style: TextStyle(
                    color: Color(0xffff7b7b),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xffff6b6b),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 25),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 18,
                sigmaY: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xff181818)
                      .withOpacity(0.94),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.09),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xffff5252)
                            .withOpacity(0.13),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xffff6b6b),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Keluar dari akun?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Anda harus login kembali untuk mengakses aplikasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                                false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                color:
                                Colors.white.withOpacity(0.10),
                              ),
                              minimumSize:
                              const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                                true,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xffff5252),
                              foregroundColor: Colors.white,
                              minimumSize:
                              const Size.fromHeight(48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
    });

    try {
      // Ganti nama method ini jika AuthStorage milikmu berbeda.
      await AuthStorage.logout();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loggingOut = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Logout gagal. Silakan coba kembali.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff222222),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
    }
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.68),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xff191919),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: accent,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Keluar dari akun...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRole(String role) {
    if (role.trim().isEmpty) return 'User';

    final spaced = role.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
    );

    return spaced
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }
}

class _ProfileGlassCard extends StatefulWidget {
  final _ProfileMenuItem item;
  final VoidCallback onTap;
  final String badge;

  const _ProfileGlassCard({
    required this.item,
    required this.onTap,
    this.badge = 'BUKA',
  });

  @override
  State<_ProfileGlassCard> createState() =>
      _ProfileGlassCardState();
}

class _ProfileGlassCardState
    extends State<_ProfileGlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 180),
                  height: 88,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.item.color.withOpacity(
                          _pressed ? 0.15 : 0.08,
                        ),
                        Colors.white.withOpacity(
                          _pressed ? 0.07 : 0.045,
                        ),
                        Colors.white.withOpacity(0.025),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _pressed
                          ? widget.item.color.withOpacity(0.38)
                          : Colors.white.withOpacity(0.09),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.item.color.withOpacity(0.34),
                              widget.item.color.withOpacity(0.12),
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(18),
                          border: Border.all(
                            color: widget.item.color
                                .withOpacity(0.24),
                          ),
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: widget.item.color,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.item.subtitle,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: widget.item.color
                              .withOpacity(0.14),
                          borderRadius:
                          BorderRadius.circular(30),
                          border: Border.all(
                            color: widget.item.color
                                .withOpacity(0.28),
                          ),
                        ),
                        child: Text(
                          widget.badge,
                          style: TextStyle(
                            color: widget.item.color,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ProfilePlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff050505),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: color.withOpacity(0.22),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Halaman sedang dikembangkan',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ProfileMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}