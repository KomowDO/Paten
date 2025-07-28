import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:dio/dio.dart'; // <--- HAPUS BARIS INI

class UbahDataScreen extends StatefulWidget {
  @override
  _UbahDataScreenState createState() => _UbahDataScreenState();
}

class _UbahDataScreenState extends State<UbahDataScreen> {
  final _formKey = GlobalKey<FormState>();
  // final ApiService _apiService = ApiService(); // <--- HAPUS BARIS INI

  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  String? _selectedJabatan;
  final TextEditingController _wilayahRtController = TextEditingController();
  final TextEditingController _wilayahRwController = TextEditingController();
  final TextEditingController _jabatanMulaiController = TextEditingController();
  final TextEditingController _jabatanAkhirController = TextEditingController();

  final List<String> _jabatanOptions = [
    'Pilih ...',
    'Ketua RW',
    'Wakil RW',
    'Sekretaris RW',
    'Bendahara RW',
    'Staff RW',
    'Ketua RT',
    'Wakil RT',
    'Sekretaris RT',
    'Bendahara RT',
    'Staff RT',
  ];

  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _apiService.addInterceptors(); // <--- HAPUS BARIS INI
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

      // ***** PERUBAHAN DI SINI: Ganti panggilan API dengan simulasi penundaan *****
      try {
        print(
          'Data yang akan "disimpan": $dataToUpdate',
        ); // Cetak data ke konsol
        await Future.delayed(Duration(seconds: 2));

        // Simulasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil "disimpan" secara lokal!')),
        );
        Navigator.of(context).pop();

        // throw Exception('Simulasi Kegagalan Penyimpanan');
      } catch (e) {
        print('Error simulasi penyimpanan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat "menyimpan": ${e.toString()}',
            ),
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Form Ubah Data'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    SizedBox(height: 16.0),
                    _buildTextField(_namaController, 'Nama', isRequired: true),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      _alamatController,
                      'Alamat',
                      isRequired: true,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      _teleponController,
                      'No. Telp/WA',
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.0),
                    _buildDropdownField(
                      'Jabatan',
                      _jabatanOptions,
                      _selectedJabatan,
                      (String? newValue) {
                        setState(() {
                          _selectedJabatan = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      _wilayahRtController,
                      'Wilayah RT',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      _wilayahRwController,
                      'Wilayah RW',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    _buildDateField(
                      _jabatanMulaiController,
                      'Jabatan Mulai',
                      true,
                    ),
                    SizedBox(height: 16.0),
                    _buildDateField(
                      _jabatanAkhirController,
                      'Jabatan Akhir',
                      false,
                    ),
                    SizedBox(height: 32.0),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text('Batal'),
                        ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _simpanData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
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
        suffixIcon: Icon(Icons.calendar_today),
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
