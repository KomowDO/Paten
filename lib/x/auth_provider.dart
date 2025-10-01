import 'package:flutter/material.dart';
import 'package:paten/services/api_service.dart';
import 'package:paten/x/token_manager.dart';

class SessionUser {
  final int idPegawai;
  final String namaPegawai;
  final String? nip;
  final String? kodeUnor;
  final String? kodeUnorPegawai;

  SessionUser({
    required this.idPegawai,
    required this.namaPegawai,
    this.nip,
    this.kodeUnor,
    this.kodeUnorPegawai,
  });

  // ==========================================================
  // == PERBAIKAN UTAMA ADA DI FUNGSI DI BAWAH INI ==
  // ==========================================================
  factory SessionUser.fromJson(Map<String, dynamic> json) {
    // Solusi Jangka Pendek: Jika 'kode_unor_pegawai' tidak ada di JSON,
    // kita berikan nilai default yang kita tahu benar.
    String? unorPegawai = json['kode_unor_pegawai'] ?? json['kode_unor'];
    if (unorPegawai == null || unorPegawai.isEmpty) {
      // Anda bisa menambahkan logika lain jika ada user berbeda,
      // contoh: if (json['nip'] == 'egov') { ... }
      unorPegawai = '07.13.09.03';
      print("💡 Fallback: Menggunakan kode_unor_pegawai default '07.13.09.03'");
    }

    return SessionUser(
      idPegawai: int.tryParse(json['id_pegawai']?.toString() ?? '0') ?? 0,
      namaPegawai: json['nama_pegawai'] ?? 'Tanpa Nama',
      nip: json['nip'],
      kodeUnor: json['unor']?['kode_unor'],
      kodeUnorPegawai: unorPegawai, // Gunakan nilai yang sudah diperbaiki
    );
  }
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final TokenManager _tokenManager = TokenManager();

  SessionUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  SessionUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._apiService) {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    final storedUserData = await _tokenManager.getUserData();
    if (storedUserData != null) {
      _user = SessionUser.fromJson(storedUserData);
      print(
        "✅ Session restored for user: ${_user?.namaPegawai} with Unor: ${_user?.kodeUnorPegawai}",
      );
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response['success'] == true && response['data'] != null) {
        await _tokenManager.saveUserData(response['data']);

        _user = SessionUser.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login gagal.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await _tokenManager.clearAuthData();
    notifyListeners();
  }
}
