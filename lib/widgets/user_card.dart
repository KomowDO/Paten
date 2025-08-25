// File: lib/widgets/user_card.dart
import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:intl/intl.dart';

class UserCard extends StatefulWidget {
  final User user;
  final Function(User)? onEdit;
  final Function(User user)? onResetPassword;
  final Function(User)? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onResetPassword,
    this.onDelete,
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

  String _formatDateForDisplay(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == '0000-00-00') {
      return '-';
    }
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd/MM/yyyy', 'id').format(dateTime);
    } catch (e) {
      try {
        final dateTime = DateFormat('dd/MM/yyyy').parse(dateString);
        return DateFormat('dd/MM/yyyy', 'id').format(dateTime);
      } catch (e) {
        print('Gagal memparsing tanggal: $dateString, Error: $e');
        return dateString;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isDetailsVisible = !_isDetailsVisible;
          });
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.user.nama_jabatan ?? '-',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'RT ${widget.user.rt ?? '-'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ RW ${widget.user.rw ?? '-'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Kecamatan ${widget.user.kecamatan ?? '-'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Kelurahan ${widget.user.kelurahan ?? '-'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isStatusActive
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isStatusActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isStatusActive
                                ? Colors.blue[900]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isStatusActive,
                        onChanged: _onStatusChanged,
                        activeColor: Colors.white,
                        inactiveTrackColor: Colors.grey[300],
                        activeTrackColor: Colors.blue,
                        thumbColor: MaterialStateProperty.all(Colors.white),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _isDetailsVisible
                      ? _buildDetailsContent()
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent() {
    return Column(
      children: [
        const Divider(height: 6, thickness: 1),
        _buildDataRow(context, 'NIK', widget.user.nik ?? '-'),
        _buildDataRow(context, 'Alamat', widget.user.alamat ?? '-'),
        _buildDataRow(context, 'Kecamatan', widget.user.kecamatan ?? '-'),
        _buildDataRow(context, 'Kelurahan', widget.user.kelurahan ?? '-'),
        _buildDataRow(context, 'RT', 'RT ${widget.user.rt ?? '-'}'),
        _buildDataRow(context, 'RW', 'RW ${widget.user.rw ?? '-'}'),
        _buildDataRow(context, 'No. WA', widget.user.no_wa ?? '-'),
        _buildDataRow(
          context,
          'Jabatan Mulai',
          _formatDateForDisplay(widget.user.jabatan_mulai),
        ),
        _buildDataRow(
          context,
          'Jabatan Akhir',
          _formatDateForDisplay(widget.user.jabatan_akhir),
        ),
        const Divider(height: 6, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onEdit != null) {
                  widget.onEdit!(widget.user);
                }
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size.zero,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text('Reset Password'),
              onPressed: () {
                if (widget.onResetPassword != null) {
                  widget.onResetPassword!(widget.user);
                }
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onDelete != null) {
                  widget.onDelete!(widget.user);
                }
              },
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Delete', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
