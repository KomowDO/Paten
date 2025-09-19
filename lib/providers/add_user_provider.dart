import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paten/services/api_service.dart';
import 'package:flutter/foundation.dart';

enum DomisiliStatus { dalamKota, luarKota }

class AddUserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController wilayahRtController = TextEditingController();
  final TextEditingController wilayahRwController = TextEditingController();
  final TextEditingController jabatanMulaiController = TextEditingController();
  final TextEditingController jabatanAkhirController = TextEditingController();

  DomisiliStatus _domisiliStatus = DomisiliStatus.dalamKota;
  bool _isLoading = false;
  bool _isJabatanLoading = false;
  List<Map<String, dynamic>> _allJabatanData = [];
  List<String> _jabatanOptions = [];
  String? _selectedNamaJabatan;
  String? _jabatanValue;
  String? _jenisJabatanValue;
  int? _idJabatanValue;
  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;

  DomisiliStatus get domisiliStatus => _domisiliStatus;
  bool get isLoading => _isLoading;
  bool get isJabatanLoading => _isJabatanLoading;
  List<String> get jabatanOptions => _jabatanOptions;
  String? get selectedNamaJabatan => _selectedNamaJabatan;

  AddUserProvider() {
    _fetchJabatanData();
  }

  void setDomisiliStatus(DomisiliStatus? status) {
    if (status != null) {
      _domisiliStatus = status;
      if (status == DomisiliStatus.luarKota) {
        namaController.clear();
        alamatController.clear();
        teleponController.clear();
      }
      notifyListeners();
    }
  }

  void selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isStartDate) {
        _jabatanMulaiDate = picked;
        jabatanMulaiController.text = DateFormat('dd/MM/yyyy').format(picked);
      } else {
        _jabatanAkhirDate = picked;
        jabatanAkhirController.text = DateFormat('dd/MM/yyyy').format(picked);
      }
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> checkNik() async {
    if (nikController.text.length != 16) {
      return {'success': false, 'message': 'NIK harus 16 digit.'};
    }

    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> apiResponse;
    try {
      final nikData = await _apiService.checkNik(nikController.text);

      if (kDebugMode) {
        print('Respons API dari service: $nikData');
      }

      // Perbaikan di sini untuk menyatukan logika pengambilan data
      Map<String, dynamic>? userData;
      if (nikData != null &&
          nikData['success'] == true &&
          nikData['data'] != null) {
        if (nikData['data'] is List && (nikData['data'] as List).isNotEmpty) {
          userData = nikData['data'][0] as Map<String, dynamic>;
        } else if (nikData['data'] is Map) {
          userData = nikData['data'] as Map<String, dynamic>;
        }
      }

      if (userData != null) {
        namaController.text = userData['nama']?.toString() ?? '';
        alamatController.text = userData['alamat']?.toString() ?? '';
        teleponController.text = userData['no_telp']?.toString() ?? '';
        apiResponse = {
          'success': true,
          'message':
              nikData?['message'] ?? 'Data ditemukan dan terisi otomatis.',
        };
      } else {
        namaController.clear();
        alamatController.clear();
        teleponController.clear();
        apiResponse = {
          'success': false,
          'message': nikData?['message'] ?? 'Data tidak ditemukan.',
        };
      }
    } catch (e) {
      namaController.clear();
      alamatController.clear();
      teleponController.clear();
      apiResponse = {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return apiResponse;
  }

  Future<void> _fetchJabatanData() async {
    _isJabatanLoading = true;
    notifyListeners();
    try {
      final fetchedData = await _apiService.fetchJabatanData();
      final List<String> options = fetchedData
          .map((item) => item['nama_jabatan'].toString())
          .toList();
      _allJabatanData = fetchedData;
      _jabatanOptions = options;
    } finally {
      _isJabatanLoading = false;
      notifyListeners();
    }
  }

  void setSelectedJabatan(String? newValue) {
    _selectedNamaJabatan = newValue;
    if (newValue != null) {
      final selectedData = _allJabatanData.firstWhere(
        (item) => item['nama_jabatan'] == newValue,
        orElse: () => {},
      );
      if (selectedData.isNotEmpty) {
        _idJabatanValue = selectedData['id_jabatan_rt_rw'] as int?;
        final parts = selectedData['nama_jabatan'].toString().split(' ');
        _jenisJabatanValue = parts.last;
        _jabatanValue = parts.sublist(0, parts.length - 1).join(' ');
      }
    } else {
      _idJabatanValue = null;
      _jabatanValue = null;
      _jenisJabatanValue = null;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> simpanData() async {
    _isLoading = true;
    notifyListeners();

    // Validasi awal untuk mencegah panggilan API yang tidak perlu
    if (nikController.text.isEmpty ||
        namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        teleponController.text.isEmpty ||
        _idJabatanValue == null ||
        _jabatanMulaiDate == null ||
        _jabatanAkhirDate == null) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Semua kolom yang wajib diisi harus lengkap.',
      };
    }

    if (_jabatanAkhirDate!.isBefore(_jabatanMulaiDate!)) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Tanggal akhir jabatan harus setelah tanggal mulai.',
      };
    }

    try {
      final tglMulai = DateFormat('dd/MM/yyyy').format(_jabatanMulaiDate!);
      final tglSelesai = DateFormat('dd/MM/yyyy').format(_jabatanAkhirDate!);

      final result = await _apiService.addUserRtRw(
        nik: nikController.text,
        nama: namaController.text,
        alamat: alamatController.text,
        telepon: teleponController.text,
        idJabatan: _idJabatanValue!,
        wilayahRt: int.tryParse(wilayahRtController.text) ?? 0,
        wilayahRw: int.tryParse(wilayahRwController.text) ?? 0,
        tglMulai: tglMulai,
        tglSelesai: tglSelesai,
        idPegawaiSession: 40797,
        kodeUnorSession: '07.13.09',
        kodeUnorPegawaiSession: '07.13.09.03',
        jabatan: _jabatanValue!,
        jenis_jabatan: _jenisJabatanValue!,
      );

      if (result['status'] == true || result['success'] == true) {
        return {
          'success': true,
          'message': result['message'] ?? 'Berhasil menyimpan data',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Gagal menyimpan data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nikController.dispose();
    namaController.dispose();
    alamatController.dispose();
    teleponController.dispose();
    wilayahRtController.dispose();
    wilayahRwController.dispose();
    jabatanMulaiController.dispose();
    jabatanAkhirController.dispose();
    super.dispose();
  }
}
