import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:paten/widgets/user_card.dart';

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

  // Data dummy untuk mengetes tampilan
  final List<User> _allUsers = [
    User(
      id: 1,
      nik: "367111067660003",
      nama: "ABAYUDIN",
      jabatan: "Ketua RT",
      alamat: "GG ANNUR RT.1 RW.5 KEL. NEROGTOG KEC.PINANG",
      kecamatan: "PINANG",
      kelurahan: "NEROGTOG",
      rw: 5,
      rt: 1,
      status: "Active",
    ),
    User(
      id: 2,
      nik: "367111170870007",
      nama: "AGAPITUS SUTADI",
      jabatan: "Ketua RT",
      alamat: "TAMAN PINANG INDAH BLOK C NO 24",
      kecamatan: "PINANG",
      kelurahan: "NEROGTOG",
      rw: 4,
      rt: 1,
      status: "Active",
    ),
    User(
      id: 3,
      nik: "3671111406950004",
      nama: "AKMAL",
      jabatan: "Ketua RT",
      alamat: "GG H PENDEK RT",
      kecamatan: "PINANG",
      kelurahan: "NEROGTOG",
      rw: 5,
      rt: 5,
      status: "Active",
    ),
    User(
      id: 4,
      nik: "367406221176003",
      nama: "ALI ASHARI",
      jabatan: "Ketua RT",
      alamat: "JL. KH HASYIM GG KIJAN RIDI",
      kecamatan: "PINANG",
      kelurahan: "NEROGTOG",
      rw: 5,
      rt: 3,
      status: "Active",
    ),
    User(
      id: 5,
      nik: "367111709840006",
      nama: "ARIP YANTO",
      jabatan: "Ketua RT",
      alamat: "GG. AMBON",
      kecamatan: "PINANG",
      kelurahan: "NEROGTOG",
      rw: 6,
      rt: 3,
      status: "Active",
    ),
  ];

  late List<User> _filteredUsers;

  @override
  void initState() {
    super.initState();
    // Inisialisasi _filteredUsers dengan semua data dummy
    _filteredUsers = List.from(_allUsers);
  }

  // Method untuk melakukan filter pada data dummy
  void _applyFilter() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchKecamatan =
            _selectedKecamatan == null ||
            _selectedKecamatan == 'Semua' ||
            user.kecamatan == _selectedKecamatan;

        final matchKelurahan =
            _selectedKelurahan == null ||
            _selectedKelurahan == 'Semua' ||
            user.kelurahan == _selectedKelurahan;

        final rwInput = int.tryParse(_rwController.text);
        final matchRW = rwInput == null || user.rw == rwInput;

        final rtInput = int.tryParse(_rtController.text);
        final matchRT = rtInput == null || user.rt == rtInput;

        return matchKecamatan && matchKelurahan && matchRW && matchRT;
      }).toList();
    });
  }

  // Method untuk mereset semua filter
  void _resetFilters() {
    setState(() {
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _rwController.clear();
      _rtController.clear();
      _filteredUsers = List.from(_allUsers);
    });
  }

  @override
  void dispose() {
    _rwController.dispose();
    _rtController.dispose();
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
              // Aksi untuk pencarian
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
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
                  onPressed:
                      _resetFilters, // Tombol refresh sekarang berfungsi sebagai reset filter
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(
                    child: Text('Tidak ada data yang cocok dengan filter.'),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: _filteredUsers[index]);
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
          const Text(
            'Advanced Filter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            label: 'Kecamatan',
            items: ['Semua', 'PINANG', 'KECAMATAN LAIN'],
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
            items: ['Semua', 'NEROGTOG', 'KELURAHAN LAIN'],
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
                  _applyFilter(); // Terapkan filter ke data dummy
                  setState(() {
                    _isFilterVisible = false;
                  });
                },
                child: const Text('Terapkan Filter'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _resetFilters(); // Reset filter
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
