// file: lib/thl_user_list_screen.dart

import 'package:flutter/material.dart';
import 'package:paten/services/api_service.dart';
import 'package:paten/models/user_thl.dart';
import 'package:paten/models/user_pns.dart';

class THLUserListScreen extends StatefulWidget {
  const THLUserListScreen({super.key});

  @override
  State<THLUserListScreen> createState() => _THLUserListScreenState();
}

class _THLUserListScreenState extends State<THLUserListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<UserTHL> _allUsers = [];
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
    _searchController.dispose();
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
    if (_isFetchingMore && !isInitialLoad) return;

    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _page = 1;
        _allUsers.clear();
        _users.clear();
      });
    } else {
      setState(() {
        _isFetchingMore = true;
      });
    }

    try {
      final fetchedUsers = await _apiService.getThlUsers(
        kode_unor_pegawai: '07.01',
        page: _page,
        limit: _limit,
      );

      setState(() {
        _allUsers.addAll(fetchedUsers);
        _filterUsers(_searchController.text);
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

  void _filterUsers(String query) {
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
    setState(() {
      _users = results;
    });
  }

  void _showAddDataDialog() {
    final TextEditingController nikController = TextEditingController();
    UserPNS? foundUser;
    bool isSearching = false;
    bool dataFound = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            void handleSearch() async {
              if (nikController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('NIK tidak boleh kosong.')),
                );
                return;
              }

              setStateSB(() {
                isSearching = true;
                dataFound = false;
                foundUser = null;
              });

              try {
                final user = await _apiService.findUserByNik(
                  nikController.text,
                );
                setStateSB(() {
                  isSearching = false;
                  if (user != null) {
                    foundUser = user;
                    dataFound = true;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data tidak ditemukan.')),
                    );
                  }
                });
              } catch (e) {
                setStateSB(() {
                  isSearching = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }

            void handleSave() async {
              if (foundUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon cari data terlebih dahulu.'),
                  ),
                );
                return;
              }

              final String nip = foundUser!.nik;
              final String namaUser = foundUser!.nama ?? '';
              final String idPegawai = '71009';
              final String kodeUnor = '07.01';
              final String statusKepegawaian = 'thl';

              try {
                await _apiService.saveNewTHLUser({
                  'nip': nip,
                  'nama_user': namaUser,
                  'id_pegawai': idPegawai,
                  'kode_unor': kodeUnor,
                  'status_kepegawaian': statusKepegawaian,
                });

                if (mounted) {
                  Navigator.of(context).pop();
                  _fetchUsers(isInitialLoad: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil disimpan!')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyimpan data: ${e.toString()}'),
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Form Tambah Data'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nikController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Cari NIK ...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSearching ? null : handleSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: isSearching
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Cari'),
                        ),
                      ],
                    ),
                    if (dataFound) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Data ditemukan',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('NIK', foundUser!.nik),
                      _buildDetailRow('Nama', foundUser!.nama),
                      _buildDetailRow('Jabatan', foundUser!.jabatan),
                      _buildDetailRow(
                        'Pada',
                        '${foundUser!.namaKelurahan}, Kec. ${foundUser!.namaKecamatan}',
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: dataFound ? handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(UserTHL user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Gunakan dialogContext di sini
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Anda yakin ingin menghapus data "${user.nama ?? 'Pengguna'}"?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                try {
                  // Perbaiki: Panggil API dan tangani hasilnya sebelum pop
                  await _apiService.deleteThlUser(user.id!);

                  // Pop dialog setelah API berhasil
                  Navigator.of(dialogContext).pop();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil dihapus.')),
                    );

                    // Refresh data setelah penghapusan
                    _fetchUsers(isInitialLoad: true);
                  }
                } catch (e) {
                  if (mounted) {
                    // Pop dialog jika API gagal
                    Navigator.of(dialogContext).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus data: ${e.toString()}'),
                      ),
                    );
                  }
                }
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

  Widget _buildUserCard(UserTHL user, int index) {
    final bool isActive = user.status == '1';
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.nama ?? 'Nama tidak ditemukan',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive ? Colors.blue[900] : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'NIP: ${user.nip ?? ''}',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: <Widget>[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Kecamatan', user.namaKecamatan),
                _buildDetailRow('Kelurahan', user.namaKelurahan),
                _buildDetailRow('Status', user.status),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Status Aktivasi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isActive,
                          onChanged: (bool value) async {
                            final String currentStatus = user.status;
                            try {
                              await _apiService.updateUserThl(
                                user.id!,
                                currentStatus,
                              );

                              if (mounted) {
                                setState(() {
                                  _users[index].status = value ? '1' : '0';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status berhasil diubah.'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _users[index].status = isActive ? '1' : '0';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Gagal mengubah status: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(user),
                    ),
                  ],
                ),
              ],
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
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              _filterUsers('');
            },
            icon: const Icon(Icons.clear),
          ),
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
                      onPressed: _showAddDataDialog,
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
                    onPressed: () => _fetchUsers(isInitialLoad: true),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Nama atau NIP...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: _filterUsers,
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
                          return _buildUserCard(user, index);
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
