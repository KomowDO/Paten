import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paten/models/user.dart';
import 'package:paten/services/api_service.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({super.key, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _wilayahRtController = TextEditingController();
  final _wilayahRwController = TextEditingController();
  final _jabatanMulaiController = TextEditingController();
  final _jabatanAkhirController = TextEditingController();

  final ApiService _apiService = ApiService();

  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;
  String? _selectedJabatan;
  List<String> _jabatanOptions = [];

  @override
  void initState() {
    super.initState();
    _apiService.addInterceptors();
    _apiService.removeBearerToken();

    final user = widget.user;

    _nikController.text = user.nik;
    _namaController.text = user.nama;
    _alamatController.text = user.alamat;
    _teleponController.text = user.no_wa;
    _wilayahRtController.text = user.rt.toString();
    _wilayahRwController.text = user.rw.toString();
    _jabatanMulaiController.text = user.jabatanMulai;
    _jabatanAkhirController.text = user.jabatanAkhir;
    _selectedJabatan = user.jabatan;

    // Parse tanggal jika valid
    try {
      _jabatanMulaiDate = DateFormat('dd/MM/yyyy').parse(user.jabatanMulai);
    } catch (_) {}

    try {
      _jabatanAkhirDate = DateFormat('dd/MM/yyyy').parse(user.jabatanAkhir);
    } catch (_) {}

    _fetchJabatanOptions();
  }

  Future<void> _fetchJabatanOptions() async {
    try {
      final jabatanList = await _apiService.fetchJabatanOptions();
      setState(() {
        _jabatanOptions = jabatanList;
      });
    } catch (e) {
      print("Error fetching jabatan: $e");
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _wilayahRtController.dispose();
    _wilayahRwController.dispose();
    _jabatanMulaiController.dispose();
    _jabatanAkhirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(labelText: 'NIK'),
              ),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextFormField(
                controller: _teleponController,
                decoration: InputDecoration(labelText: 'No. WA'),
              ),
              TextFormField(
                controller: _wilayahRtController,
                decoration: InputDecoration(labelText: 'RT'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _wilayahRwController,
                decoration: InputDecoration(labelText: 'RW'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _selectedJabatan,
                items: _jabatanOptions.map((jabatan) {
                  return DropdownMenuItem(value: jabatan, child: Text(jabatan));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJabatan = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Jabatan'),
              ),
              TextFormField(
                controller: _jabatanMulaiController,
                decoration: InputDecoration(
                  labelText: 'Jabatan Mulai (dd/MM/yyyy)',
                ),
              ),
              TextFormField(
                controller: _jabatanAkhirController,
                decoration: InputDecoration(
                  labelText: 'Jabatan Akhir (dd/MM/yyyy)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Simpan perubahan
                    print("Data disimpan");
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
