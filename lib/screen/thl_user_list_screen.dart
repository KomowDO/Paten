import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paten/providers/thl_user_provider.dart';
import 'package:paten/models/user_thl.dart';
import 'package:paten/models/user_pns.dart';
import 'package:paten/services/api_service.dart';
import 'package:paten/widgets/thl_user_card.dart';
import 'package:paten/screen/thl_user_detail_screen.dart';

class THLUserListScreen extends StatefulWidget {
  const THLUserListScreen({super.key});

  @override
  State<THLUserListScreen> createState() => _THLUserListScreenState();
}

class _THLUserListScreenState extends State<THLUserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

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

  // ---------------- FORM TAMBAH DATA ----------------
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
            Future<void> handleSearch() async {
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
                setStateSB(() => isSearching = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }

            Future<void> handleSave() async {
              if (foundUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon cari data terlebih dahulu.'),
                  ),
                );
                return;
              }

              final provider = Provider.of<THLUserProvider>(
                context,
                listen: false,
              );
              final userData = {
                'nip': foundUser!.nik,
                'nama_user': foundUser!.nama ?? '',
                'id_pegawai': foundUser!.id ?? '',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menyimpan data: $e')),
                );
              }
            }

            return AlertDialog(
              title: const Text('Tambah User THL'),
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
                              hintText: 'Masukkan NIK...',
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
                          ),
                          child: isSearching
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Cari'),
                        ),
                      ],
                    ),
                    if (dataFound && foundUser != null) ...[
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
                        'Lokasi',
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  // ---------------- MAIN BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna THL'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                  Expanded(
                    // <-- Perbaikan ada di sini
                    child: ElevatedButton.icon(
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
                onChanged: (q) => Provider.of<THLUserProvider>(
                  context,
                  listen: false,
                ).filterUsers(q),
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
                        child: Text('Tidak ada data pengguna THL.'),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          provider.users.length +
                          (provider.isFetchingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == provider.users.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final user = provider.users[i];
                        return THLUserCard(
                          user: user,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => THLDetailScreen(user: user),
                              ),
                            );
                          },
                        );
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
