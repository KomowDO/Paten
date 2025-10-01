import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paten/models/user_thl.dart';
import 'package:paten/providers/thl_user_provider.dart';

class THLDetailScreen extends StatefulWidget {
  final UserTHL user;
  const THLDetailScreen({super.key, required this.user});

  @override
  State<THLDetailScreen> createState() => _THLDetailScreenState();
}

class _THLDetailScreenState extends State<THLDetailScreen> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = (widget.user.status == '1');
  }

  // --- LOGIC FUNCTIONS ---
  Future<void> _toggleStatus() async {
    final provider = Provider.of<THLUserProvider>(context, listen: false);
    final newStatus = _isActive ? '0' : '1';
    try {
      await provider.updateUserStatus(widget.user.id!, newStatus);
      setState(() {
        _isActive = !_isActive;
        widget.user.status = _isActive ? '1' : '0';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diubah.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser() async {
    final provider = Provider.of<THLUserProvider>(context, listen: false);
    try {
      await provider.deleteUser(widget.user.id!);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengguna berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pengguna: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Tindakan ini tidak dapat diurungkan. Apakah Anda yakin ingin menghapus pengguna ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGET BUILDERS ---
  Widget _buildHeader() {
    final u = widget.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Perbaikan posisi tengah
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            (u.nama?.isNotEmpty == true ? u.nama!.substring(0, 1) : "?")
                .toUpperCase(),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          u.nama ?? 'Nama Tidak Tersedia',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "NIP: ${u.nip ?? '-'}",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final u = widget.user;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Detail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _infoRow('ID Pegawai', u.idPegawai),
            _infoRow('Kode Unor', u.kodeUnor),
            _infoRow('Kecamatan', u.namaKecamatan),
            _infoRow('Kelurahan', u.namaKelurahan),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Status Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _isActive ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  color: _isActive
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
              value: _isActive,
              onChanged: (val) => _toggleStatus(),
              activeColor: Colors.green,
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
              title: Text(
                'Hapus Pengguna',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _showDeleteConfirmationDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Pengguna THL'),
        backgroundColor: Color(0xFF083C7C),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'PENGATURAN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }
}
