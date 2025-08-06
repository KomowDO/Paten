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

  String? _selectedKecamatan;
  String? _selectedKelurahan;
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  final String _kodeUnorPegawai = '07.13.09.03';

  // Data list asli dari API
  late Future<List<User>> _allUsersFuture;
  List<User> _allUsers = [];

  // Data list yang akan ditampilkan setelah difilter
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchAndFilterUsers();
  }

  void _fetchAndFilterUsers() {
    setState(() {
      _allUsersFuture = ApiService().getUsers(
        kode_unor_pegawai: _kodeUnorPegawai,
        // Mengambil semua data tanpa filter tambahan
        filter_kecamatan: '',
        filter_kelurahan: '',
        filter_no_rw: '',
        filter_no_rt: '',
        keyword: '',
      );
    });
    // Setelah data diambil, baru kita filter
    _allUsersFuture
        .then((users) {
          _allUsers = users;
          _applyFilters();
        })
        .catchError((error) {
          // Menangani error jika fetch gagal
          print('Fetch Error: $error');
        });
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchKecamatan =
            _selectedKecamatan == null ||
            _selectedKecamatan!.isEmpty ||
            user.kecamatan.toLowerCase() == _selectedKecamatan!.toLowerCase();

        final matchKelurahan =
            _selectedKelurahan == null ||
            _selectedKelurahan!.isEmpty ||
            user.kelurahan.toLowerCase() == _selectedKelurahan!.toLowerCase();

        final rwInput = _rwController.text.trim();
        final matchRW = rwInput.isEmpty || user.rw.toString() == rwInput;

        final rtInput = _rtController.text.trim();
        final matchRT = rtInput.isEmpty || user.rt.toString() == rtInput;

        final keywordInput = _keywordController.text.trim();
        final matchKeyword =
            keywordInput.isEmpty ||
            user.nama.toLowerCase().contains(keywordInput.toLowerCase()) ||
            user.nik.toLowerCase().contains(keywordInput.toLowerCase()) ||
            user.alamat.toLowerCase().contains(keywordInput.toLowerCase());

        return matchKecamatan &&
            matchKelurahan &&
            matchRW &&
            matchRT &&
            matchKeyword;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _rwController.clear();
      _rtController.clear();
      _keywordController.clear();
    });
    _applyFilters();
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
      appBar: AppBar(title: const Text('Daftar Pengguna RT/RW'), actions: [
],
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
                  onPressed: () {
                    // Aksi tambah data
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Data'),
                ),
                TextButton.icon(
                  onPressed:
                      _fetchAndFilterUsers, // Memuat ulang data dari API dan filter
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _allUsersFuture,
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
                } else {
                  if (_filteredUsers.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data pengguna.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: _filteredUsers[index]);
                    },
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
              _applyFilters();
            },
          ),
          const SizedBox(height: 8),
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
            items: ['NEROKTOG', 'KELURAHAN LAIN'],
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
                onPressed: () {
                  _applyFilters();
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
