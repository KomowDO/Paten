import 'package:flutter/material.dart';
import 'package:paten/models/user.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart';

class UserCard extends StatefulWidget {
  final User user;
  final Function(User)? onEdit;
  final Function(User user)? onResetPassword;
  final Function(User)? onDelete;
  final VoidCallback? onTap; // ✅ Tambahkan properti onTap

  const UserCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onResetPassword,
    this.onDelete,
    this.onTap, // ✅ masukkan ke constructor
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool _isStatusActive;
  bool _isDetailsVisible = false;

  @override
  void initState() {
    super.initState();
    _isStatusActive = widget.user.status == '1';
  }

  void _onStatusChanged(bool value) {
    setState(() {
      _isStatusActive = value;
    });
    // TODO: Tambahkan logika untuk memanggil API update status di sini
  }

  // --- HANYA FUNGSI INI YANG DIPERBARUI ---
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
      print('Gagal mem-parsing tanggal: "$dateString", Error: $e');
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!(); // ✅ Navigasi ke detail jika onTap diberikan
          } else {
            setState(() {
              _isDetailsVisible = !_isDetailsVisible; // fallback toggle
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.nama ?? '-',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.user.nama_jabatan ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Jabatan : ${_formatDateForDisplay(widget.user.jabatan_mulai)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ' s/d ${_formatDateForDisplay(widget.user.jabatan_akhir)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'RT ${widget.user.rt ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '| RW ${widget.user.rw ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'NIK: ${widget.user.nik ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Kecamatan ${widget.user.kecamatan ?? '-'} | ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Kelurahan ${widget.user.kelurahan ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'No. WA: ${widget.user.no_wa ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
