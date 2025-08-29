import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paten/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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
  String? _selectedNamaJabatan;
  final TextEditingController _wilayahRtController = TextEditingController();
  final TextEditingController _wilayahRwController = TextEditingController();
  final TextEditingController _jabatanMulaiController = TextEditingController();
  final TextEditingController _jabatanAkhirController = TextEditingController();

  List<Map<String, dynamic>> _allJabatanData = [];
  List<String> _jabatanOptions = [];
  bool _isJabatanLoading = true;

  String? _jabatanValue;
  String? _jenisJabatanValue;
  int? _idJabatanValue;

  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchJabatanData();
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

  Future<void> _fetchJabatanData() async {
    setState(() {
      _isJabatanLoading = true;
    });

    try {
      final fetchedData = await _apiService.fetchJabatanData();
      final List<String> options = fetchedData
          .map((item) => item['nama_jabatan'].toString())
          .toList();

      setState(() {
        _allJabatanData = fetchedData;
        _jabatanOptions = options;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saat memuat jabatan: $e');
      }
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
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });

      if (kDebugMode) {
        print(
          'Selected ${isStartDate ? "Start" : "End"} Date: ${DateFormat('dd/MM/yyyy').format(picked)}',
        );
        print('DateTime object: $picked');
      }
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      if (_jabatanMulaiDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal mulai jabatan harus dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_jabatanAkhirDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal akhir jabatan harus dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_jabatanAkhirDate!.isBefore(_jabatanMulaiDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal akhir harus setelah tanggal mulai'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        if (_idJabatanValue == null ||
            _jabatanValue == null ||
            _jenisJabatanValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Jabatan tidak valid. Silakan pilih jabatan dari daftar.',
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

        final result = await _apiService.addUserRtRw(
          nik: _nikController.text,
          nama: _namaController.text,
          alamat: _alamatController.text,
          telepon: _teleponController.text,
          idJabatan: _idJabatanValue!,
          wilayahRt: int.tryParse(_wilayahRtController.text) ?? 0,
          wilayahRw: int.tryParse(_wilayahRwController.text) ?? 0,
          tglMulai: tglMulai,
          tglSelesai: tglSelesai,
          idPegawaiSession: 40797,
          kodeUnorSession: '07.13.09',
          kodeUnorPegawaiSession: '07.13.09.03',
          jabatan: _jabatanValue!,
          jenis_jabatan: _jenisJabatanValue!,
        );

        final bool status =
            result['status'] == true || result['success'] == true;
        final String message =
            result['message'] ?? 'Tidak ada pesan dari server';

        if (status) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saat menyimpan: $e');
        }
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
                                    onPressed: _fetchJabatanData,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            )
                          : _buildDropdownField(
                              'Jabatan',
                              _jabatanOptions,
                              _selectedNamaJabatan,
                              (String? newValue) {
                                setState(() {
                                  _selectedNamaJabatan = newValue;
                                  if (newValue != null) {
                                    final selectedData = _allJabatanData
                                        .firstWhere(
                                          (item) =>
                                              item['nama_jabatan'] == newValue,
                                          orElse: () => {},
                                        );

                                    if (selectedData.isNotEmpty) {
                                      _idJabatanValue =
                                          selectedData['id_jabatan_rt_rw']
                                              as int?;
                                      final parts = selectedData['nama_jabatan']
                                          .toString()
                                          .split(' ');
                                      _jenisJabatanValue = parts.last;
                                      _jabatanValue = parts
                                          .sublist(0, parts.length - 1)
                                          .join(' ');
                                    } else {
                                      _idJabatanValue = null;
                                      _jabatanValue = null;
                                      _jenisJabatanValue = null;
                                    }
                                  } else {
                                    _idJabatanValue = null;
                                    _jabatanValue = null;
                                    _jenisJabatanValue = null;
                                  }
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
        errorStyle: const TextStyle(color: Colors.red),
      ),
      onTap: () => _selectDate(context, controller, isStartDate),
      validator: (value) {
        DateTime? dateToCheck = isStartDate
            ? _jabatanMulaiDate
            : _jabatanAkhirDate;

        if (dateToCheck == null || value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
