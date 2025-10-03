import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:paten/services/api_service.dart';

class UserListProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String _kodeUnorPegawai = '07.13.09.03';

  // --- State Management ---
  List<User> _users = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;

  // --- Filters ---
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  String? _rw;
  String? _rt;
  String? _keyword;

  // --- Getters ---
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMoreData => _hasMoreData;

  String? get selectedKecamatan => _selectedKecamatan;
  String? get selectedKelurahan => _selectedKelurahan;
  String? get rw => _rw;
  String? get rt => _rt;
  String? get keyword => _keyword;

  // --- Constructor ---
  UserListProvider() {
    fetchUsers(isInitialLoad: true);
  }

  // --- Fetch Users (dengan pagination & filter) ---
  Future<void> fetchUsers({required bool isInitialLoad}) async {
    if (_isFetchingMore) return;

    if (isInitialLoad) {
      _isLoading = true;
      _users = [];
      _currentPage = 1;
      notifyListeners();
    } else {
      _isFetchingMore = true;
      notifyListeners();
    }

    try {
      final fetchedUsers = await _apiService.getUsers(
        page: _currentPage,
        limit: _pageSize,
        kode_unor_pegawai: _kodeUnorPegawai,
        filter_kecamatan: _selectedKecamatan,
        filter_kelurahan: _selectedKelurahan,
        filter_no_rw: _rw,
        filter_no_rt: _rt,
        keyword: _keyword,
      );

      _users.addAll(fetchedUsers);
      _currentPage++;
      _hasMoreData = fetchedUsers.length == _pageSize;
    } catch (e) {
      debugPrint('Gagal memuat data: $e');
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // --- Filter Management ---
  void updateFilters({
    String? kecamatan,
    String? kelurahan,
    String? rw,
    String? rt,
    String? keyword,
  }) {
    _selectedKecamatan = kecamatan;
    _selectedKelurahan = kelurahan;
    _rw = rw;
    _rt = rt;
    _keyword = keyword;
    notifyListeners();
  }

  void resetFilters() {
    _selectedKecamatan = null;
    _selectedKelurahan = null;
    _rw = null;
    _rt = null;
    _keyword = null;
    fetchUsers(isInitialLoad: true);
  }

  // --- CRUD ---
  Future<Map<String, dynamic>> resetUserPassword(User user) async {
    try {
      final result = await _apiService.resetPassword(
        ApiService.jwtToken,
        user.nik ?? '',
      );
      return result;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return {'status': false, 'message': 'Gagal mereset password'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(User user) async {
    try {
      final result = await _apiService.deleteUser(
        ApiService.jwtToken,
        user.nik ?? '',
      );
      if (result['status'] == true) {
        _users.removeWhere((u) => u.nik == user.nik);
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return {'status': false, 'message': 'Gagal menghapus pengguna'};
    }
  }

  /// --- Update Status Aktif / Nonaktif RT-RW ---
  Future<void> updateUserRtRw(User user, bool isActive) async {
    try {
      final newStatus = isActive ? '1' : '0';

      await _apiService.updateUserRtRw(user.id ?? '', newStatus);

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index].status = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }
}
