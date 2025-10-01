// lib/services/token_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';
  static const String _usernameKey = 'auth_username';
  static const String _userDataKey = 'auth_user_data'; // <-- KUNCI BARU

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Fungsi Token & Username (Tidak berubah) ---
  Future<void> saveToken(String token) async {
    await _init();
    await _prefs!.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    await _init();
    return _prefs!.getString(_tokenKey);
  }

  Future<void> saveUsername(String username) async {
    await _init();
    await _prefs!.setString(_usernameKey, username);
  }

  Future<String?> getUsername() async {
    await _init();
    return _prefs!.getString(_usernameKey);
  }

  // --- PERUBAHAN: Fungsi untuk menyimpan dan mengambil data user ---

  // Menyimpan seluruh data user sebagai string JSON
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _init();
    await _prefs!.setString(_userDataKey, jsonEncode(userData));
  }

  // Mengambil data user dan mengubahnya kembali menjadi Map
  Future<Map<String, dynamic>?> getUserData() async {
    await _init();
    final userDataString = _prefs!.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Meng-update clearAuthData untuk membersihkan semua data sesi
  Future<void> clearAuthData() async {
    await _init();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_usernameKey);
    await _prefs!.remove(_userDataKey); // <-- HAPUS DATA USER JUGA
    print("🗑️ All auth data cleared!");
  }
}
