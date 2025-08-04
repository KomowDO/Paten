import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:paten/widgets/user_card.dart';
import 'package:paten/services/api_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isFilterVisible = false;

  // State untuk menyimpan nilai filter
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  // Kode unik unit organisasi dan parameter API lainnya
  final String _kodeUnorPegawai = '07.13.09.03';
  final int _page = 1;
  final int _limit = 10;

  late Future<List<User>> _users;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Method untuk mengambil data dari API dengan filter
  void _fetchUsers() {
    setState(() {
      _users = ApiService().getUsers(
        kode_unor_pegawai: _kodeUnorPegawai,
        page: _page,
        limit: _limit,
        filter_kecamatan: _selectedKecamatan,
        filter_kelurahan: _selectedKelurahan,
        filter_no_rw: _rwController.text,
        filter_no_rt: _rtController.text,
        keyword: _keywordController.text,
      );
    });
  }

  // Method untuk mereset semua filter
  void _resetFilters() {
    setState(() {
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _rwController.clear();
      _rtController.clear();
      _keywordController.clear();
    });
    _fetchUsers();
  }

  @override
  void dispose() {
    _rwController.dispose();
    _rtController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna RT/RW'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Menjalankan pencarian langsung dengan keyword
              _fetchUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Menampilkan/menyembunyikan filter lanjutan
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterVisible) _buildAdvancedFilter(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Aksi tambah data
                  },
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
              future: _users,
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
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data pengguna.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: snapshot.data![index]);
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Tidak ada data yang tersedia.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _keywordController,
            decoration: const InputDecoration(
              hintText: 'Parameter Search...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              _fetchUsers();
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Advanced Filter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            label: 'Kecamatan',
            items: ['PINANG', 'KECAMATAN LAIN'],
            value: _selectedKecamatan,
            onChanged: (String? newValue) {
              setState(() {
                _selectedKecamatan = newValue;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            label: 'Kelurahan',
            items: ['NEROGTOG', 'KELURAHAN LAIN'],
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
                      horizontal: 12,
                      vertical: 8,
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
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _fetchUsers();
                  setState(() {
                    _isFilterVisible = false;
                  });
                },
                child: const Text('Terapkan Filter'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _resetFilters();
                },
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
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
