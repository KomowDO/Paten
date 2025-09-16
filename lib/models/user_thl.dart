// file: lib/models/user_thl.dart
import 'package:flutter/foundation.dart';

class UserTHL {
  final String? id;
  final String? nip;
  final String? idPegawai;
  final String? kodeUnor;
  final String? kodeUnorKhusus;
  final String? nama;
  final String? statusKepegawaian;

  // Hapus 'final' di sini agar 'status' bisa diubah
  String status;

  final String? namaKecamatan;
  final String? namaKelurahan;
  final String? createdAt;
  final String? updatedAt;

  UserTHL({
    this.id,
    this.nip,
    this.idPegawai,
    this.kodeUnor,
    this.kodeUnorKhusus,
    this.nama,
    this.statusKepegawaian,
    required this.status,
    this.namaKecamatan,
    this.namaKelurahan,
    this.createdAt,
    this.updatedAt,
  });

  factory UserTHL.fromJson(Map<String, dynamic> json) {
    return UserTHL(
      id: json['id']?.toString(),
      nip: json['nip']?.toString(),
      idPegawai: json['id_pegawai']?.toString(),
      kodeUnor: json['kode_unor']?.toString(),
      kodeUnorKhusus: json['kode_unor_khusus']?.toString(),
      nama: json['nama_user']?.toString(),
      statusKepegawaian: json['status_kepegawaian']?.toString(),
      status: json['status']?.toString() ?? 'Inactive',
      namaKecamatan: json['nama_kecamatan']?.toString(),
      namaKelurahan: json['nama_kelurahan']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
