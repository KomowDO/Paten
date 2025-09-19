import 'package:flutter/material.dart';
import 'package:paten/services/api_service.dart';
import 'package:paten/models/user_thl.dart';
import 'package:paten/models/user_pns.dart';

class THLUserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<UserTHL> _allUsers = [];
  List<UserTHL> _users = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _page = 1;
  static const int _limit = 10;

  // Expose state variables through getters
  List<UserTHL> get users => _users;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  // Constructor to fetch data on initialization
  THLUserProvider() {
    fetchUsers(isInitialLoad: true);
  }

  // Fetch users from the API
  Future<void> fetchUsers({required bool isInitialLoad}) async {
    if (_isFetchingMore && !isInitialLoad) return;

    if (isInitialLoad) {
      _isLoading = true;
      _page = 1;
      _allUsers.clear();
      _users.clear();
      notifyListeners(); // Notify listeners to show loading indicator
    } else {
      _isFetchingMore = true;
      notifyListeners(); // Notify listeners to show fetching more indicator
    }

    try {
      final fetchedUsers = await _apiService.getThlUsers(
        kode_unor_pegawai: '07.01',
        page: _page,
        limit: _limit,
      );

      _allUsers.addAll(fetchedUsers);
      filterUsers(''); // Corrected line
      if (fetchedUsers.isNotEmpty) {
        _page++;
      }
    } catch (e) {
      // You can handle error state here if needed
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners(); // Notify listeners after data is fetched
    }
  }

  // Filter users based on a query
  void filterUsers(String query) {
    List<UserTHL> results = [];
    if (query.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers.where((user) {
        final namaLower = user.nama?.toLowerCase() ?? '';
        final nipLower = user.nip?.toLowerCase() ?? '';
        final queryLower = query.toLowerCase();
        return namaLower.contains(queryLower) || nipLower.contains(queryLower);
      }).toList();
    }
    _users = results;
    notifyListeners();
  }

  // Save a new user
  Future<void> saveNewUser(Map<String, dynamic> userData) async {
    try {
      await _apiService.saveNewTHLUser(userData);
      fetchUsers(isInitialLoad: true); // Refresh data after saving
    } catch (e) {
      debugPrint('Error saving user: $e');
      rethrow;
    }
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    try {
      await _apiService.deleteThlUser(id);
      fetchUsers(isInitialLoad: true); // Refresh data after deletion
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  // Update a user's status
  Future<void> updateUserStatus(String id, String currentStatus) async {
    try {
      await _apiService.updateUserThl(id, currentStatus);
      final index = _allUsers.indexWhere((user) => user.id == id);
      if (index != -1) {
        _allUsers[index].status = currentStatus == '1' ? '0' : '1';
      }
      filterUsers(''); // Re-filter to update the UI
    } catch (e) {
      debugPrint('Error updating user status: $e');
      rethrow;
    }
  }
}
