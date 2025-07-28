import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TambahPenggunaScreen extends StatefulWidget {
  @override
  _TambahPenggunaScreenState createState() => _TambahPenggunaScreenState();
}

class _TambahPenggunaScreenState extends State<TambahPenggunaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap input field (kosong secara default)
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  String? _selectedJabatan; // Ini akan dimulai sebagai null
  final TextEditingController _wilayahRtController = TextEditingController();
  final TextEditingController _wilayahRwController = TextEditingController();
  final TextEditingController _jabatanMulaiController = TextEditingController();
  final TextEditingController _jabatanAkhirController = TextEditingController();

  final List<String> _jabatanOptions = [
    'Pilih Jabatan',
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

  bool _isLoading = false; // Untuk simulasi loading UI

  @override
  void dispose() {
    // Penting untuk membuang controller saat widget tidak lagi digunakan
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

  // Fungsi untuk menampilkan DatePicker
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isStartDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Mulai dari tanggal hari ini
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

  // Fungsi untuk "menyimpan" data (simulasi tanpa API)
  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading true saat proses dimulai
      });

      // Siapkan data untuk dicetak ke konsol
      final Map<String, dynamic> newData = {
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
        print(
          'Data pengguna baru yang akan "disimpan": $newData',
        ); // Cetak data ke konsol
        await Future.delayed(
          Duration(seconds: 2),
        ); // Simulasi penundaan jaringan 2 detik

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengguna baru berhasil "ditambahkan" secara lokal!'),
          ),
        );
        // Opsi: Kembali ke halaman sebelumnya setelah sukses
        Navigator.of(context).pop();

        // Atau, reset form jika ingin tetap di halaman ini setelah submit
        // _formKey.currentState!.reset();
        // _nikController.clear();
        // _namaController.clear();
        // ... (clear semua controller)
        // setState(() { _selectedJabatan = null; });
      } catch (e) {
        print('Error simulasi penyimpanan: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat "menambahkan" pengguna: ${e.toString()}',
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Set loading false setelah proses selesai
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
            Navigator.of(context).pop(); // Aksi tombol kembali
          },
        ),
        title: Text('Tambah Pengguna RT/RW'), // Judul AppBar
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indikator loading
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Input field untuk NIK
                    _buildTextField(
                      _nikController,
                      'NIK',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    // Input field untuk Nama
                    _buildTextField(_namaController, 'Nama', isRequired: true),
                    SizedBox(height: 16.0),
                    // Input field untuk Alamat
                    _buildTextField(
                      _alamatController,
                      'Alamat',
                      isRequired: true,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.0),
                    // Input field untuk No. Telp/WA
                    _buildTextField(
                      _teleponController,
                      'No. Telp/WA',
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.0),
                    // Dropdown untuk Jabatan
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
                    // Input field untuk Wilayah RT
                    _buildTextField(
                      _wilayahRtController,
                      'Wilayah RT',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    // Input field untuk Wilayah RW
                    _buildTextField(
                      _wilayahRwController,
                      'Wilayah RW',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    // Field tanggal untuk Jabatan Mulai
                    _buildDateField(
                      _jabatanMulaiController,
                      'Jabatan Mulai',
                      true,
                    ),
                    SizedBox(height: 16.0),
                    // Field tanggal untuk Jabatan Akhir
                    _buildDateField(
                      _jabatanAkhirController,
                      'Jabatan Akhir',
                      false,
                    ),
                    SizedBox(height: 32.0),
                    // Baris untuk tombol Batal dan Simpan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Aksi Batal: kembali
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

  // Helper function untuk membangun TextFormField
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

  // Helper function untuk membangun DropdownButtonFormField
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

  // Helper function untuk membangun field tanggal dengan DatePicker
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
