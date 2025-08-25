import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:paten/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  String? _selectedJabatan;
  final TextEditingController _wilayahRtController = TextEditingController();
  final TextEditingController _wilayahRwController = TextEditingController();
  final TextEditingController _jabatanMulaiController = TextEditingController();
  final TextEditingController _jabatanAkhirController = TextEditingController();

  List<String> _jabatanOptions = [];
  Map<String, int> _jabatanIdMap = {};
  bool _isJabatanLoading = true;

  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService.addInterceptors();
    _fetchJabatanOptions();
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

  Future<void> _fetchJabatanOptions() async {
    setState(() {
      _isJabatanLoading = true;
    });

    try {
      _apiService.removeBearerToken();
      final fetchedJabatanData = await _apiService.fetchJabatanData();
      final List<String> options = fetchedJabatanData
          .map((item) => item['nama'].toString())
          .toList();
      final Map<String, int> idMap = Map.fromIterable(
        fetchedJabatanData,
        key: (item) => item['nama'].toString(),
        value: (item) => (item['id_jabatan'] as int?) ?? 0,
      );

      setState(() {
        _jabatanOptions = options;
        _jabatanIdMap = idMap;
      });
    } catch (e) {
      print('Error saat memuat jabatan: $e');
      if (_jabatanOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar jabatan: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() {
        _isJabatanLoading = false;
      });
    }
  }

  int? _getJabatanId(String? jabatanName) {
    if (jabatanName == null) return null;
    return _jabatanIdMap[jabatanName];
  }

  Future<Map<String, dynamic>> _addUserRtRw({
    required String jwtToken,
    required String nik,
    required String nama,
    required String alamat,
    required String telepon,
    required int idJabatan,
    required int wilayahRt,
    required int wilayahRw,
    required String tglMulai,
    required String tglSelesai,
    required int idPegawaiSession,
    required String kodeUnorSession,
    required String kodeUnorPegawaiSession,
  }) async {
    return _apiService.addUserRtRw(
      nik: nik,
      nama: nama,
      alamat: alamat,
      telepon: telepon,
      idJabatan: idJabatan,
      wilayahRt: wilayahRt,
      wilayahRw: wilayahRw,
      tglMulai: tglMulai,
      tglSelesai: tglSelesai,
      idPegawaiSession: idPegawaiSession,
      kodeUnorSession: kodeUnorSession,
      kodeUnorPegawaiSession: kodeUnorPegawaiSession,
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isStartDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _jabatanMulaiDate = picked;
        } else {
          _jabatanAkhirDate = picked;
        }
        controller.text = DateFormat('dd/MM/yyyy', 'id').format(picked);
      });
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final idJabatan = _getJabatanId(_selectedJabatan);
        if (idJabatan == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ID Jabatan tidak ditemukan. Silakan pilih jabatan yang valid.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final tglMulai = _formatDateForApi(_jabatanMulaiDate);
        final tglSelesai = _formatDateForApi(_jabatanAkhirDate);

        final result = await _addUserRtRw(
          jwtToken: ApiService.jwtToken,
          nik: _nikController.text,
          nama: _namaController.text,
          alamat: _alamatController.text,
          telepon: _teleponController.text,
          idJabatan: idJabatan,
          wilayahRt: int.tryParse(_wilayahRtController.text) ?? 0,
          wilayahRw: int.tryParse(_wilayahRwController.text) ?? 0,
          tglMulai: tglMulai,
          tglSelesai: tglSelesai,
          idPegawaiSession: 40797,
          kodeUnorSession: '07.13.09',
          kodeUnorPegawaiSession: '07.13.09.03',
        );

        final bool status = result['status'] == true;

        if (status) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Tambah Pengguna RT/RW'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTextField(
                        _nikController,
                        'NIK',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        _namaController,
                        'Nama',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        _alamatController,
                        'Alamat',
                        isRequired: true,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        _teleponController,
                        'No. Telp/WA',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16.0),
                      _isJabatanLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _jabatanOptions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tidak ada opsi jabatan tersedia.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  TextButton(
                                    onPressed: _fetchJabatanOptions,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            )
                          : _buildDropdownField(
                              'Jabatan',
                              _jabatanOptions,
                              _selectedJabatan,
                              (String? newValue) {
                                setState(() {
                                  _selectedJabatan = newValue;
                                });
                              },
                            ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        _wilayahRtController,
                        'Wilayah RT',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        _wilayahRwController,
                        'Wilayah RW',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      _buildDateField(
                        _jabatanMulaiController,
                        'Jabatan Mulai',
                        true,
                      ),
                      const SizedBox(height: 16.0),
                      _buildDateField(
                        _jabatanAkhirController,
                        'Jabatan Akhir',
                        false,
                      ),
                      const SizedBox(height: 32.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF03038E),
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFF03038E),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 16.0),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _simpanData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF03038E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Simpan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: 'Masukkan $label',
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: 'Pilih $label',
      ),
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    bool isStartDate,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: 'Pilih $label',
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context, controller, isStartDate),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
