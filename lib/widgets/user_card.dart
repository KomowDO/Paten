import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';

class UserCard extends StatefulWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool _isStatusActive;

  @override
  void initState() {
    super.initState();
    _isStatusActive = widget.user.status == '1';
  }

  void _onStatusChanged(bool value) {
    setState(() {
      _isStatusActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.user.jabatan,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Menambahkan teks "Status" di sini
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
                      thumbColor: MaterialStateProperty.all(
                        _isStatusActive ? Colors.white : Colors.white,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 12, thickness: 1),
            _buildDataRow(context, 'NIK', widget.user.nik),
            _buildDataRow(context, 'Alamat', widget.user.alamat),
            _buildDataRow(context, 'Kecamatan', widget.user.kecamatan),
            _buildDataRow(context, 'Kelurahan', widget.user.kelurahan),
            _buildDataRow(
              context,
              'RW/RT',
              'RW ${widget.user.rw} / RT ${widget.user.rt}',
            ),
            _buildDataRow(context, 'No. WA', widget.user.no_wa),
            _buildDataRow(context, 'Jabatan Mulai', widget.user.jabatanMulai),
            _buildDataRow(context, 'Jabatan Akhir', widget.user.jabatanAkhir),
            const Divider(height: 12, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () {
                    // Aksi edit
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    // Aksi delete
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
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
