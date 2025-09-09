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
  Map<String, int> _jabatanIdMap = {};

  bool _isLoading = false;
  bool _isDataLoading = true; // State baru untuk mengontrol loading data awal

  @override
  void initState() {
    super.initState();
    // Panggil fungsi inisialisasi yang terpusat
    _initializeData();
  }

  // Fungsi untuk memuat semua data yang dibutuhkan secara berurutan
  void _initializeData() async {
    // Atur state loading menjadi true
    setState(() {
      _isDataLoading = true;
    });

    try {
      // Panggil fungsi asinkron untuk mengambil opsi jabatan
      await _fetchJabatanOptions();

      // Setelah opsi jabatan siap, baru muat data user
      _loadUserData();
    } catch (e) {
      // Tangani kesalahan jika ada masalah saat memuat data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data awal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Matikan loading, terlepas dari keberhasilan atau kegagalan
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  // Fungsi ini memanggil API dan memproses data jabatan
  Future<void> _fetchJabatanOptions() async {
    try {
      final fetchedJabatanData = await _apiService.fetchJabatanData();

      // PERBAIKAN: Gunakan kunci 'nama_jabatan'
      final List<String> options = fetchedJabatanData
          .map((item) => item['nama_jabatan'].toString())
          .toSet() // Menghilangkan duplikasi
          .toList();

      // PERBAIKAN: Gunakan kunci 'id_jabatan_rt_rw'
      final Map<String, int> idMap = Map.fromIterable(
        fetchedJabatanData,
        key: (item) => item['nama_jabatan'].toString(),
        value: (item) => (item['id_jabatan_rt_rw'] as int?) ?? 0,
      );

      setState(() {
        _jabatanOptions = options;
        _jabatanIdMap = idMap;
      });
    } catch (e) {
      print("Error fetching jabatan: $e");
      // Menangani error secara lokal
      rethrow;
    }
  }

  void _loadUserData() {
    final user = widget.user;

    _nikController.text = user.nik ?? '';
    _namaController.text = user.nama ?? '';
    _alamatController.text = user.alamat ?? '';
    _teleponController.text = user.no_wa ?? '';
    _wilayahRtController.text = user.rt?.toString() ?? '';
    _wilayahRwController.text = user.rw?.toString() ?? '';

    _jabatanMulaiController.text = _formatDateForDisplay(user.jabatan_mulai);
    _jabatanAkhirController.text = _formatDateForDisplay(user.jabatan_akhir);

    // Cek apakah jabatan user ada di daftar opsi yang sudah dimuat
    if (_jabatanOptions.contains(user.jabatan)) {
      _selectedJabatan = user.jabatan;
    } else {
      _selectedJabatan = null;
    }

    try {
      if (user.jabatan_mulai != null && user.jabatan_mulai != '0000-00-00') {
        _jabatanMulaiDate = DateFormat('yyyy-MM-dd').parse(user.jabatan_mulai!);
      }
    } catch (_) {}
    try {
      if (user.jabatan_akhir != null && user.jabatan_akhir != '0000-00-00') {
        _jabatanAkhirDate = DateFormat('yyyy-MM-dd').parse(user.jabatan_akhir!);
      }
    } catch (_) {}
  }

  String _formatDateForDisplay(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == '0000-00-00') {
      return '';
    }
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd/MM/yyyy', 'id').format(dateTime);
    } catch (e) {
      return dateString ?? '';
    }
  }

  int? _getJabatanId(String? jabatanName) {
    if (jabatanName == null) return null;
    return _jabatanIdMap[jabatanName];
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
      setState(() => _isLoading = true);

      try {
        final idJabatan = _getJabatanId(_selectedJabatan);
        if (idJabatan == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jabatan belum dipilih.')),
          );
          return;
        }

        final tglMulai = _formatDateForApi(_jabatanMulaiDate);
        final tglSelesai = _formatDateForApi(_jabatanAkhirDate);

        final result = await _apiService.updateUserRtRw(
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
              content: Text(result['message']!),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']!),
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
        setState(() => _isLoading = false);
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengguna RT/RW'),
        centerTitle: true,
      ),
      // Tampilkan indikator loading saat _isDataLoading true
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nikController,
                      decoration: _inputDecoration('NIK'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaController,
                      decoration: _inputDecoration('Nama'),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _alamatController,
                      decoration: _inputDecoration('Alamat'),
                      validator: (value) =>
                          value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _teleponController,
                      decoration: _inputDecoration('No. WA'),
                      validator: (value) =>
                          value!.isEmpty ? 'Nomor WA tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _wilayahRtController,
                      decoration: _inputDecoration('RT'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'RT tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _wilayahRwController,
                      decoration: _inputDecoration('RW'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'RW tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedJabatan,
                      decoration: _inputDecoration('Jabatan'),
                      items: _jabatanOptions.map((jabatan) {
                        return DropdownMenuItem(
                          value: jabatan,
                          child: Text(jabatan),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedJabatan = value),
                      validator: (value) =>
                          value == null ? 'Jabatan tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _jabatanMulaiController,
                      decoration: _inputDecoration(
                        'Jabatan Mulai (dd/MM/yyyy)',
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _jabatanMulaiController, true),
                      validator: (value) => value!.isEmpty
                          ? 'Tanggal mulai tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _jabatanAkhirController,
                      decoration: _inputDecoration(
                        'Jabatan Akhir (dd/MM/yyyy)',
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(context, _jabatanAkhirController, false),
                      validator: (value) => value!.isEmpty
                          ? 'Tanggal akhir tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpanData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03038E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(fontSize: 14),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
