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
                          widget.user.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.user.jabatan,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.user.rt}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ RW ${widget.user.rw}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Kecamatan ${widget.user.kecamatan}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Kelurahan ${widget.user.kelurahan}',
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
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
        _buildDataRow(context, 'NIK', widget.user.nik),
        _buildDataRow(context, 'Alamat', widget.user.alamat),
        _buildDataRow(context, 'Kecamatan', widget.user.kecamatan),
        _buildDataRow(context, 'Kelurahan', widget.user.kelurahan),
        _buildDataRow(context, 'RT', 'RT ${widget.user.rt}'),
        _buildDataRow(context, 'RW', 'RW ${widget.user.rw}'),
        _buildDataRow(context, 'No. WA', widget.user.no_wa),
        _buildDataRow(context, 'Jabatan Mulai', widget.user.jabatanMulai),
        _buildDataRow(context, 'Jabatan Akhir', widget.user.jabatanAkhir),
        const Divider(height: 6, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Aksi untuk mengedit data
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
            ElevatedButton.icon(
              onPressed: () {
                // Aksi untuk menghapus data
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
