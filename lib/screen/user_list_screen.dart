import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:paten/screen/add_user_screen.dart';
import 'package:paten/screen/edit_user_screen.dart';
import 'package:paten/screen/user_detail_screen.dart';
import 'package:paten/widgets/user_card.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paten/providers/user_list_provider.dart';
import 'package:paten/providers/edit_user_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserListProvider>(
        context,
        listen: false,
      ).fetchUsers(isInitialLoad: true);
    });
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
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => EditUserProvider(user: user),
          child: const EditUserScreen(),
        ),
      ),
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
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () => Navigator.of(context).pop(true),
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
        if (result['status'] == true) {
          provider.fetchUsers(isInitialLoad: true);
        }
      }
    }
  }

  Future<void> _navigateToDetail(User user) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
    );

    if (!mounted || result == null) return;

    switch (result) {
      case 'edit':
        _onEditUser(user);
        break;
      case 'reset':
        _onResetPassword(user);
        break;
      case 'delete':
        _onDeleteUser(user);
        break;
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
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCollapsibleFilter(provider),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onAddUser,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03038E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.fetchUsers(isInitialLoad: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.users.isEmpty
                ? const Center(child: Text('Tidak ada data pengguna.'))
                : RefreshIndicator(
                    onRefresh: () => provider.fetchUsers(isInitialLoad: true),
                    child: ListView.builder(
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
                          onTap: () => _navigateToDetail(user),
                        );
                      },
                    ),
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
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => provider.fetchUsers(isInitialLoad: true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Terapkan Filter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
