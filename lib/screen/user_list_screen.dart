// File: lib/screen/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:paten/screen/add_user_screen.dart';
import 'package:paten/screen/edit_user_screen.dart';
import 'package:paten/widgets/user_card.dart';
import 'package:paten/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isFilterVisible = false;

  String? _selectedKecamatan;
  String? _selectedKelurahan;
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  final String _kodeUnorPegawai = '07.13.09.03';

  late Future<List<User>> _usersFuture;
  int _currentPage = 1;
  final int _pageSize = 10;
  List<User> _currentUsers = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _rwController.dispose();
    _rtController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _fetchUsers() {
    setState(() {
      _usersFuture = _apiService.getUsers(
        page: _currentPage,
        limit: _pageSize,
        kode_unor_pegawai: _kodeUnorPegawai,
        filter_kecamatan: _selectedKecamatan,
        filter_kelurahan: _selectedKelurahan,
        filter_no_rw: _rwController.text,
        filter_no_rt: _rtController.text,
        keyword: _keywordController.text,
      );
    });
  }

  void _onNextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchUsers();
  }

  void _onPreviousPage() {
    setState(() {
      _currentPage--;
    });
    _fetchUsers();
  }

  Future<void> _onAddUser() async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );
    if (shouldRefresh == true) {
      _fetchUsers();
    }
  }

  Future<void> _onEditUser(User user) async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
    );
    if (shouldRefresh == true) {
      _fetchUsers();
    }
  }

  Future<void> _onResetPassword(User user) async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Text(
            'Apakah Anda yakin ingin mereset password untuk ${user.nama ?? 'pengguna ini'}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      final result = await _apiService.resetPassword(
        ApiService.jwtToken,
        user.nik ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Password berhasil direset'),
            backgroundColor: result['status'] == true
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onDeleteUser(User user) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengguna ${user.nama ?? 'ini'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      final result = await _apiService.deleteUser(
        ApiService.jwtToken,
        user.nik ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Pengguna berhasil dihapus'),
            backgroundColor: result['status'] == true
                ? Colors.green
                : Colors.red,
          ),
        );
      }
      _fetchUsers();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _rwController.clear();
      _rtController.clear();
      _keywordController.clear();
      _currentPage = 1;
    });
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna RT/RW'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCollapsibleFilter(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _onAddUser,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Data'),
                ),
                TextButton.icon(
                  onPressed: _fetchUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Gagal mengambil data: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data pengguna.'));
                } else {
                  final users = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return UserCard(
                              user: users[index],
                              onEdit: _onEditUser,
                              onResetPassword: _onResetPassword,
                              onDelete: _onDeleteUser,
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _currentPage > 1
                                ? _onPreviousPage
                                : null,
                            child: const Text('Previous'),
                          ),
                          Text('Halaman $_currentPage'),
                          TextButton(
                            onPressed: users.length == _pageSize
                                ? _onNextPage
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleFilter() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Advanced Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(
                    _isFilterVisible
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _isFilterVisible
                  ? _buildFilterInputs()
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInputs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: [
          TextField(
            controller: _keywordController,
            decoration: const InputDecoration(
              hintText: 'Cari berdasarkan nama, NIK, atau alamat',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              _fetchUsers();
            },
          ),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            label: 'Kecamatan',
            items: const ['PINANG', 'KECAMATAN LAIN'],
            value: _selectedKecamatan,
            onChanged: (String? newValue) {
              setState(() {
                _selectedKecamatan = newValue;
                _selectedKelurahan = null;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            label: 'Kelurahan',
            items: const ['NEROKTOG', 'KELURAHAN LAIN'],
            value: _selectedKelurahan,
            onChanged: (String? newValue) {
              setState(() {
                _selectedKelurahan = newValue;
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rwController,
                  decoration: const InputDecoration(
                    labelText: 'No. RW',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _rtController,
                  decoration: const InputDecoration(
                    labelText: 'No. RT',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _fetchUsers,
                child: const Text('Terapkan Filter'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
        ),
        value: value,
        items: items.map((String e) {
          return DropdownMenuItem<String>(value: e, child: Text(e));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
