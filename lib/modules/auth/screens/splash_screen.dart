// lib/modules/auth/screens/splash_screen.dart
//
// Uygulama açılışında oturum kontrolü yapar.
// Giriş yaptıysa → Dashboard, yapmadıysa → Login

import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../study/screens/dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // En az 1.5 sn splash göster
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final loggedIn = await AuthService.instance.isLoggedIn();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn
            ? DashboardScreen(
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                onThemeChanged: (_) {},
              )
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6750A4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 48,
                color: Color(0xFF6750A4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Student Coach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Derslerini planla, hedeflerine ulaş.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
