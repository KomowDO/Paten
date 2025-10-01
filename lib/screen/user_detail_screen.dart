import 'package:flutter/material.dart';
import 'package:paten/models/user.dart'; // Pastikan path model User Anda sudah benar
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late bool _isUserActive;

  @override
  void initState() {
    super.initState();
    _isUserActive = widget.user.status == '1';
  }

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
    final String initial =
        widget.user.nama != null && widget.user.nama!.isNotEmpty
        ? widget.user.nama![0].toUpperCase()
        : '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Pengguna RT/RW'),

        titleTextStyle: const TextStyle(
          color: Color.fromARGB(221, 255, 255, 255),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        backgroundColor: Color(0xFF083C7C),
        elevation: 1,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(221, 255, 255, 255),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Info Pengguna (Avatar, Nama, NIP) ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user.nama?.toUpperCase() ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Kartu Informasi Detail ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Detail',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Status',
                      (widget.user.status == '1') ? 'Aktif' : 'Tidak Aktif',
                    ),
                    _buildInfoRow('NIK', widget.user.nik ?? '-'),
                    _buildInfoRow('Alamat', widget.user.alamat ?? '-'),
                    _buildInfoRow('Kecamatan', widget.user.kecamatan ?? '-'),
                    _buildInfoRow('Kelurahan', widget.user.kelurahan ?? '-'),
                    _buildInfoRow(
                      'RT / RW',
                      'RT ${widget.user.rt ?? '-'} / RW ${widget.user.rw ?? '-'}',
                    ),
                    _buildInfoRow('No. WhatsApp', widget.user.no_wa ?? '-'),
                    _buildInfoRow(
                      'Jabatan Mulai',
                      _formatDateForDisplay(widget.user.jabatan_mulai),
                    ),
                    _buildInfoRow(
                      'Jabatan Akhir',
                      _formatDateForDisplay(widget.user.jabatan_akhir),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Bagian Pengaturan ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'PENGATURAN',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- Kartu Pengaturan ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Status Pengguna'),
                    subtitle: Text(_isUserActive ? 'Aktif' : 'Tidak Aktif'),
                    value: _isUserActive,
                    onChanged: (bool value) {
                      setState(() {
                        _isUserActive = value;
                        // TODO: Tambahkan logika untuk update status di sini
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue.shade700),
                    title: Text(
                      'Edit Pengguna',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    onTap: () {
                      // TODO: Tambahkan logika untuk edit pengguna
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.lock_reset,
                      color: Colors.orange.shade800,
                    ),
                    title: Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                    onTap: () {
                      // TODO: Tambahkan logika untuk reset password
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Hapus Pengguna',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      // TODO: Tambahkan logika untuk hapus pengguna di sini
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
