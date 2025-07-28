import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:paten/api_service.dart';

class UbahDataScreen extends StatefulWidget {
  const UbahDataScreen({super.key});

  @override
  _UbahDataScreenState createState() => _UbahDataScreenState();
}

class _UbahDataScreenState extends State<UbahDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _nikController = TextEditingController(
    text: '3671071106720007',
  );
  final TextEditingController _namaController = TextEditingController(
    text: 'ABIDIN',
  );
  final TextEditingController _alamatController = TextEditingController(
    text: 'CIBODAS KECIL',
  );
  final TextEditingController _teleponController = TextEditingController(
    text: '089614710009',
  );
  String? _selectedJabatan;
  final TextEditingController _wilayahRtController = TextEditingController(
    text: '4',
  );
  final TextEditingController _wilayahRwController = TextEditingController(
    text: '3',
  );
  final TextEditingController _jabatanMulaiController = TextEditingController(
    text: '02/11/2023',
  );
  final TextEditingController _jabatanAkhirController = TextEditingController(
    text: '02/11/2026',
  );

  List<String> _jabatanOptions = [];
  bool _isJabatanLoading = true;

  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService.addInterceptors();
    _apiService.removeBearerToken();
    print('[_UbahDataScreenState] initState dipanggil.');
    _fetchJabatanOptions();

    if (_jabatanMulaiController.text.isNotEmpty) {
      try {
        _jabatanMulaiDate = DateFormat(
          'dd/MM/yyyy',
        ).parse(_jabatanMulaiController.text);
      } catch (e) {
        print("Error parsing Jabatan Mulai date in initState: $e");
      }
    }
    if (_jabatanAkhirController.text.isNotEmpty) {
      try {
        _jabatanAkhirDate = DateFormat(
          'dd/MM/yyyy',
        ).parse(_jabatanAkhirController.text);
      } catch (e) {
        print("Error parsing Jabatan Akhir date in initState: $e");
      }
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

  Future<void> _fetchJabatanOptions() async {
    print('[_UbahDataScreenState] _fetchJabatanOptions dipanggil.');
    setState(() {
      _isJabatanLoading = true;
    });
    try {
      final fetchedOptions = await _apiService.fetchJabatanOptions();
      print('[_UbahDataScreenState] Data jabatan diterima: $fetchedOptions');
      setState(() {
        _jabatanOptions = fetchedOptions;
        if (_selectedJabatan == null && _jabatanOptions.isNotEmpty) {
          if (_jabatanOptions.contains('Ketua RT')) {
            _selectedJabatan = 'Ketua RT';
          } else {
            _selectedJabatan = _jabatanOptions.first;
          }
        } else if (_selectedJabatan != null &&
            !_jabatanOptions.contains(_selectedJabatan)) {
          _selectedJabatan = null;
        }
      });
      print(
        '[_UbahDataScreenState] _jabatanOptions setelah update: ${_jabatanOptions.length} item',
      );
    } catch (e) {
      print('[_UbahDataScreenState] Error saat memuat jabatan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar jabatan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isJabatanLoading = false;
        print('[_UbahDataScreenState] _isJabatanLoading diatur ke false.');
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
      initialDate:
          (isStartDate ? _jabatanMulaiDate : _jabatanAkhirDate) ??
          DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _jabatanMulaiDate = picked;
          controller.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _jabatanAkhirDate = picked;
          controller.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> dataToUpdate = {
        'nik': _nikController.text,
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'telepon': _teleponController.text,
        'jabatan': _selectedJabatan,
        'wilayah_rt': int.tryParse(_wilayahRtController.text) ?? 0,
        'wilayah_rw': int.tryParse(_wilayahRwController.text) ?? 0,
        'jabatan_mulai': _jabatanMulaiController.text,
        'jabatan_akhir': _jabatanAkhirController.text,
      };

      try {
        final response = await _apiService.updateUserData(dataToUpdate);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil disimpan!')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan data: ${response.statusMessage}'),
            ),
          );
        }
      } on DioException catch (e) {
        String errorMessage = 'Terjadi kesalahan jaringan atau server.';
        if (e.response != null) {
          errorMessage =
              'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage ?? 'Unknown error'}. Detail: ${e.response?.data?.toString() ?? ''}';
        } else {
          errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda. ${e.message}';
        }
        print('Error Dio: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        print('Error saat panggilan API: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan tidak terduga: ${e.toString()}'),
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
        title: const Text('Form Ubah Data'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // START: Wrapper SafeArea ditambahkan di sini
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
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _simpanData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      // END: Wrapper SafeArea
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
