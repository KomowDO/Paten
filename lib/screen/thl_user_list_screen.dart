import 'package:flutter/material.dart';
import 'package:paten/services/api_service.dart';
import 'package:paten/models/user_thl.dart'; // Pastikan Anda mengimpor model yang benar

class THLUserListScreen extends StatefulWidget {
  const THLUserListScreen({super.key});

  @override
  State<THLUserListScreen> createState() => _THLUserListScreenState();
}

class _THLUserListScreenState extends State<THLUserListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // Perbaikan: Ubah tipe data dari List<User> menjadi List<UserTHL>
  List<UserTHL> _users = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _page = 1;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchUsers(isInitialLoad: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      _fetchUsers(isInitialLoad: false);
    }
  }

  Future<void> _fetchUsers({required bool isInitialLoad}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (isInitialLoad) {
        _isLoading = true;
      } else {
        _isFetchingMore = true;
      }
    });

    try {
      // Panggilan ke API menggunakan model UserTHL
      final fetchedUsers = await _apiService.getThlUsers(
        kode_unor_pegawai: '07.13.09.03',
        page: _page,
        limit: _limit,
      );

      setState(() {
        if (isInitialLoad) {
          _users = fetchedUsers;
        } else {
          _users.addAll(fetchedUsers);
        }

        if (fetchedUsers.isNotEmpty) {
          _page++;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  // Perbaikan: Ubah tipe parameter menjadi UserTHL
  void _showUserDetailsDialog(UserTHL user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            user.nama ?? 'Detail Pengguna',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                  'NIP',
                  user.nip,
                ), // Menggunakan properti nip dari UserTHL
                _buildDetailRow(
                  'Nama Pengguna',
                  user.nama,
                ), // Menggunakan properti nama dari UserTHL
                _buildDetailRow('Status', user.status),
                _buildDetailRow(
                  'Kecamatan',
                  user.namaKecamatan,
                ), // Menggunakan properti namaKecamatan
                _buildDetailRow(
                  'Kelurahan',
                  user.namaKelurahan,
                ), // Menggunakan properti namaKelurahan
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna THL'),
        actions: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 16.0)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03038E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _page = 1;
                      _fetchUsers(isInitialLoad: true);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Parameter Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  // Logika pencarian data di sini
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _users.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text(
                          'Tidak ada data pengguna THL.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _users.length + (_isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _users.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final user = _users[index];
                          final bool isActive = user.status == '1';

                          return InkWell(
                            onTap: () => _showUserDetailsDialog(user),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user.nama ?? 'Nama tidak ditemukan',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Status',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? Colors.blue[100]
                                                    : Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                isActive
                                                    ? 'Active'
                                                    : 'Inactive',
                                                style: TextStyle(
                                                  color: isActive
                                                      ? Colors.blue[900]
                                                      : Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Switch(
                                              value: isActive,
                                              onChanged: (bool value) {
                                                // Tambahkan logika API
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'NIP: ${user.nip ?? ''}', // Menggunakan properti nip dari UserTHL
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kecamatan: ${user.namaKecamatan ?? 'N/A'}', // Menggunakan properti namaKecamatan
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kelurahan: ${user.namaKelurahan ?? 'N/A'}', // Menggunakan properti namaKelurahan
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
