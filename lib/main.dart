import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/auth_storage.dart';
import 'features/auth/login_page.dart';
import 'features/layout/main_layout.dart';
import 'mobile_foundation/auth/pages/login_mobile_page.dart';
import 'mobile_foundation/layout/mobile_main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>?> _getUser() async {
    return AuthStorage.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDP Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffff6a00),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff050505),
        useMaterial3: true,
      ),
      home: FutureBuilder<Map<String, dynamic>?>(
        future: _getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xffff6a00),
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile =
                  Theme.of(context).platform == TargetPlatform.android ||
                      constraints.maxWidth < 1000;
              final user = snapshot.data;

              if (user == null) {
                return isMobile
                    ? const LoginMobilePage()
                    : const LoginPage();
              }

              final role = user['role']?.toString() ?? '';

              return isMobile
                  ? MobileMainLayout(role: role)
                  : MainLayout(role: role);
            },
          );
        },
      ),
    );
  }
}