import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paten/providers/thl_list_provider.dart';
import 'package:paten/models/user_thl.dart';
import 'package:paten/models/user_pns.dart';
import 'package:paten/services/api_service.dart';

class THLUserListScreen extends StatefulWidget {
  const THLUserListScreen({super.key});

  @override
  State<THLUserListScreen> createState() => _THLUserListScreenState();
}

class _THLUserListScreenState extends State<THLUserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService(); // Still needed for search dialog

  @override
  void initState() {
    super.initState();
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
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<THLUserProvider>(context, listen: false);
      provider.fetchUsers(isInitialLoad: false);
    }
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NIK tidak boleh kosong.')),
                  );
                }
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
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data tidak ditemukan.')),
                      );
                    }
                  }
                });
              } catch (e) {
                setStateSB(() {
                  isSearching = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            }

            void handleSave() async {
              if (foundUser == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon cari data terlebih dahulu.'),
                    ),
                  );
                }
                return;
              }

              final provider = Provider.of<THLUserProvider>(
                context,
                listen: false,
              );
              final userData = {
                'nip': foundUser!.nik,
                'nama_user': foundUser!.nama ?? '',
                'id_pegawai': '71009',
                'kode_unor': '07.01',
                'status_kepegawaian': 'thl',
              };

              try {
                await provider.saveNewUser(userData);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil disimpan!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan data: ${e.toString()}'),
                    ),
                  );
                }
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
    final provider = Provider.of<THLUserProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                  await provider.deleteUser(user.id!);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil dihapus.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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
    final provider = Provider.of<THLUserProvider>(context, listen: false);
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
                              await provider.updateUserStatus(
                                user.id!,
                                currentStatus,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status berhasil diubah.'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
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
        automaticallyImplyLeading: false,
        actions: [
          // IconButton(
          //   onPressed: () {
          //     // ... (kode lainnya)
          //   },
          //   icon: const Icon(Icons.clear),
          // ),
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
                    onPressed: () {
                      final provider = Provider.of<THLUserProvider>(
                        context,
                        listen: false,
                      );
                      _searchController.clear();
                      provider.fetchUsers(isInitialLoad: true);
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
                onChanged: (query) {
                  final provider = Provider.of<THLUserProvider>(
                    context,
                    listen: false,
                  );
                  provider.filterUsers(query);
                },
              ),
              const SizedBox(height: 16),
              Consumer<THLUserProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (provider.users.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'Tidak ada data pengguna THL.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          provider.users.length +
                          (provider.isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.users.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final user = provider.users[index];
                        return _buildUserCard(user, index);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
