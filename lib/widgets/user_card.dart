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
    // Menginisialisasi state switch berdasarkan data dari API
    _isStatusActive = widget.user.status == '1';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.user.jabatan,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Mengganti Container dengan Switch
                Row(
                  children: [
                    Text(_isStatusActive ? 'Active' : 'Inactive'),
                    Switch(
                      value: _isStatusActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isStatusActive = value;
                        });
                        // TODO: Di sini, Anda dapat menambahkan logic untuk memanggil API
                        // guna memperbarui status pengguna di server.
                      },
                      activeColor: Colors.blue,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16, thickness: 1),
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
            const Divider(height: 16, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Aksi edit
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Aksi delete
                  },
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Lebar label yang tetap
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
