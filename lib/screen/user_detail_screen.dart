import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  String _formatDateForDisplay(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == '0000-00-00') {
      return '-';
    }
    try {
      final dateOnly = dateString.substring(0, 10);
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateOnly);
      return DateFormat('dd/MM/yyyy', 'id').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: (user.status == '1')
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      size: 45,
                      color: (user.status == '1')
                          ? Colors.green.shade800
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.nama ?? '-',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    user.nama_jabatan ?? '-',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildDetailRow(
              'Status',
              (user.status == '1') ? 'Aktif' : 'Tidak Aktif',
            ),
            _buildDetailRow('NIK', user.nik ?? '-'),
            _buildDetailRow('Alamat', user.alamat ?? '-'),
            _buildDetailRow('Kecamatan', user.kecamatan ?? '-'),
            _buildDetailRow('Kelurahan', user.kelurahan ?? '-'),
            _buildDetailRow(
              'RT / RW',
              'RT ${user.rt ?? '-'} / RW ${user.rw ?? '-'}',
            ),
            _buildDetailRow('No. WhatsApp', user.no_wa ?? '-'),
            _buildDetailRow(
              'Jabatan Mulai',
              _formatDateForDisplay(user.jabatan_mulai),
            ),
            _buildDetailRow(
              'Jabatan Akhir',
              _formatDateForDisplay(user.jabatan_akhir),
            ),
            const Divider(),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: 'Edit Pengguna',
              color: Colors.blue,
              onPressed: () => Navigator.pop(context, 'edit'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.lock_reset,
              label: 'Reset Password',
              color: Colors.orange,
              onPressed: () => Navigator.pop(context, 'reset'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.delete,
              label: 'Hapus Pengguna',
              color: Colors.red,
              onPressed: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
