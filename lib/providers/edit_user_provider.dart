// file: providers/edit_user_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paten/models/user.dart'; // Sesuaikan path jika perlu
import 'package:paten/services/api_service.dart'; // Sesuaikan path jika perlu

class EditUserProvider extends ChangeNotifier {
  final User user;
  final _apiService = ApiService();

  // Constructor
  EditUserProvider({required this.user}) {
    _initializeData();
  }

  // Keys and Controllers
  final formKey = GlobalKey<FormState>();
  final nikController = TextEditingController();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final teleponController = TextEditingController();
  final wilayahRtController = TextEditingController();
  final wilayahRwController = TextEditingController();
  final jabatanMulaiController = TextEditingController();
  final jabatanAkhirController = TextEditingController();

  // State Variables
  DateTime? _jabatanMulaiDate;
  DateTime? _jabatanAkhirDate;
  String? _selectedJabatan;
  List<String> _jabatanOptions = [];
  Map<String, int> _jabatanIdMap = {};

  bool _isLoading = false;
  bool _isDataLoading = true;

  // Getters untuk UI
  String? get selectedJabatan => _selectedJabatan;
  List<String> get jabatanOptions => _jabatanOptions;
  bool get isLoading => _isLoading;
  bool get isDataLoading => _isDataLoading;

  // --- LOGIC METHODS ---

  void _initializeData() async {
    _isDataLoading = true;
    notifyListeners();

    try {
      await _fetchJabatanOptions();
      _loadUserData();
    } catch (e) {
      debugPrint('Gagal memuat data awal: ${e.toString()}');
    } finally {
      _isDataLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchJabatanOptions() async {
    try {
      final fetchedJabatanData = await _apiService.fetchJabatanData();
      final List<String> options = fetchedJabatanData
          .map((item) => item['nama_jabatan'].toString())
          .toSet()
          .toList();
      final Map<String, int> idMap = Map.fromIterable(
        fetchedJabatanData,
        key: (item) => item['nama_jabatan'].toString(),
        value: (item) => (item['id_jabatan_rt_rw'] as int?) ?? 0,
      );

      _jabatanOptions = options;
      _jabatanIdMap = idMap;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching jabatan: $e");
      rethrow;
    }
  }

  void _loadUserData() {
    nikController.text = user.nik ?? '';
    namaController.text = user.nama ?? '';
    alamatController.text = user.alamat ?? '';
    teleponController.text = user.no_wa ?? '';
    wilayahRtController.text = user.rt?.toString() ?? '';
    wilayahRwController.text = user.rw?.toString() ?? '';

    // Tampilkan tanggal dengan format dd/MM/yyyy
    jabatanMulaiController.text = _formatDateForDisplay(user.jabatan_mulai);
    jabatanAkhirController.text = _formatDateForDisplay(user.jabatan_akhir);

    // Simpan tanggal sebagai objek DateTime untuk pengiriman nanti
    try {
      if (user.jabatan_mulai != null && user.jabatan_mulai!.isNotEmpty) {
        _jabatanMulaiDate = DateFormat('yyyy-MM-dd').parse(user.jabatan_mulai!);
      }
      if (user.jabatan_akhir != null && user.jabatan_akhir!.isNotEmpty) {
        _jabatanAkhirDate = DateFormat('yyyy-MM-dd').parse(user.jabatan_akhir!);
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }

    // ✅ PERBAIKAN: Cocokkan 'nama_jabatan' milik user dengan daftar pilihan
    if (_jabatanOptions.contains(user.nama_jabatan)) {
      _selectedJabatan = user.nama_jabatan;
    } else {
      _selectedJabatan = null;
    }

    notifyListeners();
  }

  void setSelectedJabatan(String? value) {
    _selectedJabatan = value;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _jabatanMulaiDate ?? DateTime.now(),
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

  Future<void> simpanData(BuildContext context, VoidCallback onSuccess) async {
    if (!formKey.currentState!.validate()) return;

    if (user.id == null || user.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID Pengguna tidak valid. Tidak bisa mengedit.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final idJabatan = _getJabatanId(_selectedJabatan);
      if (idJabatan == null || _selectedJabatan == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Jabatan belum dipilih.')));
        _isLoading = false;
        notifyListeners();
        return;
      }

      final String jenisJabatan = _selectedJabatan!.contains('RT')
          ? 'RT'
          : 'RW';

      final result = await _apiService.editUserRtRw(
        id: user.id!,
        nik: nikController.text,
        nama: namaController.text,
        alamat: alamatController.text,
        telepon: teleponController.text,
        idJabatan: idJabatan,
        jabatan: _selectedJabatan!,
        jenisJabatan: jenisJabatan,
        wilayahRt: int.tryParse(wilayahRtController.text) ?? 0,
        wilayahRw: int.tryParse(wilayahRwController.text) ?? 0,
        tglMulai: _formatDateForApi(_jabatanMulaiDate),
        tglSelesai: _formatDateForApi(_jabatanAkhirDate),
        idPegawaiSession: 40797,
        kodeUnorSession: '07.13.09',
        kodeUnorPegawaiSession: '07.13.09.03',
      );

      final bool isSuccess = result['status'] == true;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Tidak ada pesan.'),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }

      if (isSuccess) {
        onSuccess();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan fatal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HELPER & DISPOSE METHODS ---

  String _formatDateForDisplay(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == '0000-00-00') {
      return '';
    }
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  int? _getJabatanId(String? jabatanName) {
    if (jabatanName == null) return null;
    return _jabatanIdMap[jabatanName];
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
