import 'package:flutter/material.dart';
import 'package:paten/models/user.dart'; // Pastikan path model User Anda sudah benar
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:paten/providers/user_list_provider.dart';
import 'package:paten/providers/edit_user_provider.dart';
import 'package:paten/screen/edit_user_screen.dart';

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
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF083C7C),
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
            // --- Bagian Info Pengguna (Avatar, Nama) ---
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
                    _buildInfoRow('Jabatan', widget.user.nama_jabatan ?? '-'),
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
                    _buildInfoRow(
                      'No. WhatsApp',
                      widget.user.no_wa ?? '-',
                      isWhatsApp: true,
                    ),
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
                    onChanged: (bool value) async {
                      final provider = Provider.of<UserListProvider>(
                        context,
                        listen: false,
                      );
                      final newStatus = value ? '1' : '0';

                      try {
                        await provider.updateUserRtRw(widget.user, value);
                        setState(() {
                          _isUserActive = value;
                          widget.user.status = newStatus;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status berhasil diubah.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // rollback kalau gagal
                        setState(() {
                          _isUserActive = !_isUserActive;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal mengubah status: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => EditUserProvider(
                              user: widget.user,
                            ), // 👈 kirim user ke provider
                            child:
                                const EditUserScreen(), // 👈 UI EditUserScreen
                          ),
                        ),
                      );

                      if (result == true) {
                        setState(() {}); // refresh detail setelah edit berhasil
                      }
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
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Konfirmasi"),
                          content: Text(
                            "Apakah Anda yakin ingin mereset password pengguna ini (${widget.user.nama})?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Batal"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Ya, Reset"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final result = await Provider.of<UserListProvider>(
                          context,
                          listen: false,
                        ).resetUserPassword(widget.user);

                        if (result['status'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Password berhasil direset"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Gagal mereset password',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SafeArea(
                    minimum: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text(
                            'Hapus Pengguna',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            // TODO: Tambahkan logika hapus pengguna
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isWhatsApp = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isWhatsApp && value != '-') ...[
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: 18,
                    ),
                    onPressed: () async {
                      final formattedPhone = formatPhoneNumberForWA(value);
                      final phoneForUrl = formattedPhone.replaceAll('+', '');
                      final waUrl = Uri.parse(
                        'https://wa.me/$phoneForUrl?text=${Uri.encodeComponent('Halo, saya ingin menghubungi Anda.')}',
                      );

                      if (!await launchUrl(
                        waUrl,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw Exception('Could not launch WhatsApp');
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatPhoneNumberForWA(String rawPhone) {
  var phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
  if (phone.startsWith('0')) {
    phone = '+62${phone.substring(1)}';
  } else if (phone.startsWith('62')) {
    phone = '+$phone';
  }
  return phone;
}
