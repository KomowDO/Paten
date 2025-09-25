import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:paten/screen/add_user_screen.dart';
import 'package:paten/screen/edit_user_screen.dart';
import 'package:paten/widgets/user_card.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paten/providers/user_list_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFilterVisible = false;

  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _rwController.dispose();
    _rtController.dispose();
    _keywordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<UserListProvider>(context, listen: false);
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !provider.isFetchingMore &&
        provider.hasMoreData) {
      provider.fetchUsers(isInitialLoad: false);
    }
  }

  Future<void> _onAddUser() async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );
    if (mounted && shouldRefresh == true) {
      Provider.of<UserListProvider>(
        context,
        listen: false,
      ).fetchUsers(isInitialLoad: true);
    }
  }

  Future<void> _onEditUser(User user) async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
    );
    if (mounted && shouldRefresh == true) {
      Provider.of<UserListProvider>(
        context,
        listen: false,
      ).fetchUsers(isInitialLoad: true);
    }
  }

  Future<void> _onResetPassword(User user) async {
    final provider = Provider.of<UserListProvider>(context, listen: false);
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
      final result = await provider.resetUserPassword(user);
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
    final provider = Provider.of<UserListProvider>(context, listen: false);
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

    if (mounted && isConfirmed == true) {
      final result = await provider.deleteUser(user);
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
    }
  }

  void _resetFilters() {
    final provider = Provider.of<UserListProvider>(context, listen: false);
    setState(() {
      _keywordController.clear();
      _rwController.clear();
      _rtController.clear();
      _isFilterVisible = false;
    });
    provider.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna RT/RW'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCollapsibleFilter(provider),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _onAddUser,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03038E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 12,
                    ),
                    minimumSize: const Size(160, 48),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchUsers(isInitialLoad: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    minimumSize: const Size(120, 48),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.users.isEmpty
                ? const Center(child: Text('Tidak ada data pengguna.'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.users.length +
                        (provider.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.users.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final user = provider.users[index];
                      return UserCard(
                        user: user,
                        onEdit: _onEditUser,
                        onResetPassword: _onResetPassword,
                        onDelete: _onDeleteUser,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleFilter(UserListProvider provider) {
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
                  ? _buildFilterInputs(provider)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterInputs(UserListProvider provider) {
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
              provider.updateFilters(keyword: value);
              provider.fetchUsers(isInitialLoad: true);
            },
          ),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            label: 'Kecamatan',
            items: const ['PINANG', 'KECAMATAN LAIN'],
            value: provider.selectedKecamatan,
            onChanged: (String? newValue) {
              provider.updateFilters(kecamatan: newValue, kelurahan: null);
              setState(() {}); // Update UI for the dropdown
            },
          ),
          const SizedBox(height: 8),
          _buildFilterDropdown(
            label: 'Kelurahan',
            items: const ['NEROKTOG', 'KELURAHAN LAIN'],
            value: provider.selectedKelurahan,
            onChanged: (String? newValue) {
              provider.updateFilters(kelurahan: newValue);
              setState(() {}); // Update UI for the dropdown
            },
          ),
          const SizedBox(height: 8),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  onChanged: (value) => provider.updateFilters(rw: value),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  onChanged: (value) => provider.updateFilters(rt: value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => provider.fetchUsers(isInitialLoad: true),
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
