import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

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
                        user.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.jabatan,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.status == '1'
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.status == '1' ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.status == '1'
                          ? Colors.green[900]
                          : Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 1),
            _buildDataRow(context, 'NIK', user.nik),
            _buildDataRow(context, 'Alamat', user.alamat),
            _buildDataRow(context, 'Kecamatan', user.kecamatan),
            _buildDataRow(context, 'Kelurahan', user.kelurahan),
            _buildDataRow(context, 'RW/RT', 'RW ${user.rw} / RT ${user.rt}'),
            _buildDataRow(context, 'No. WA', user.no_wa),
            _buildDataRow(context, 'Jabatan Mulai', user.jabatanMulai),
            _buildDataRow(context, 'Jabatan Akhir', user.jabatanAkhir),
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
