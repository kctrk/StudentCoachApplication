// lib/core/services/auth_service.dart
//
// SharedPreferences tabanlı local Auth servisi.
// Firebase'e geçmek istersen bu sınıfı sadece
// FirebaseAuth çağrılarıyla değiştir, UI değişmez.

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyEmail    = 'auth_email';
  static const _keyName     = 'auth_name';

  // ── Oturum ────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  // ── Giriş ─────────────────────────────────────────────────
  // Şu an local validasyon. Firebase'e geçince burası değişir.

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return AuthResult.failure('E-posta ve şifre boş olamaz.');
    }
    if (!email.contains('@')) {
      return AuthResult.failure('Geçerli bir e-posta gir.');
    }
    if (password.length < 6) {
      return AuthResult.failure('Şifre en az 6 karakter olmalı.');
    }

    final prefs = await SharedPreferences.getInstance();
    final savedEmail    = prefs.getString('reg_email') ?? '';
    final savedPassword = prefs.getString('reg_password') ?? '';

    if (savedEmail.isEmpty) {
      // Hiç kayıt yoksa demo giriş izni ver
      await _saveSession(email: email, name: 'Öğrenci');
      return AuthResult.success();
    }

    if (email.trim().toLowerCase() == savedEmail && password == savedPassword) {
      final name = prefs.getString('reg_name') ?? 'Öğrenci';
      await _saveSession(email: email, name: name);
      return AuthResult.success();
    }

    return AuthResult.failure('E-posta veya şifre hatalı.');
  }

  // ── Kayıt ─────────────────────────────────────────────────

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) return AuthResult.failure('Ad Soyad boş olamaz.');
    if (!email.contains('@')) return AuthResult.failure('Geçerli bir e-posta gir.');
    if (password.length < 6) return AuthResult.failure('Şifre en az 6 karakter olmalı.');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reg_email',    email.trim().toLowerCase());
    await prefs.setString('reg_password', password);
    await prefs.setString('reg_name',     name.trim());

    await _saveSession(email: email, name: name.trim());
    return AuthResult.success();
  }

  // ── Çıkış ─────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
  }

  // ── Yardımcı ──────────────────────────────────────────────

  Future<void> _saveSession({
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyEmail, email.trim().toLowerCase());
    await prefs.setString(_keyName, name);
  }
}

// ── Sonuç Modeli ──────────────────────────────────────────────

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult._({required this.success, this.errorMessage});

  factory AuthResult.success() => const AuthResult._(success: true);
  factory AuthResult.failure(String msg) =>
      AuthResult._(success: false, errorMessage: msg);
}
