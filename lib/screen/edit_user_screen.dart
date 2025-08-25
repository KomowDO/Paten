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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true, // membuat field lebih ramping
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengguna')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nikController,
                decoration: _inputDecoration('NIK'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration('Nama'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alamatController,
                decoration: _inputDecoration('Alamat'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _teleponController,
                decoration: _inputDecoration('No. WA'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wilayahRtController,
                decoration: _inputDecoration('RT'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wilayahRwController,
                decoration: _inputDecoration('RW'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJabatan,
                isDense: true,
                decoration: _inputDecoration('Jabatan'),
                items: _jabatanOptions.map((jabatan) {
                  return DropdownMenuItem(value: jabatan, child: Text(jabatan));
                }).toList(),
                onChanged: (value) => setState(() => _selectedJabatan = value),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jabatanMulaiController,
                decoration: _inputDecoration('Jabatan Mulai (dd/MM/yyyy)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jabatanAkhirController,
                decoration: _inputDecoration('Jabatan Akhir (dd/MM/yyyy)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Data disimpan");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
