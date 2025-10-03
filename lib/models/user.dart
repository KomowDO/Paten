// File: lib/models/user.dart
import 'package:flutter/foundation.dart';

class User {
  final String? id;
  final String? nik;
  final String? nama;
  final String? jabatan;
  final String? alamat;
  final String? kecamatan;
  final String? kelurahan;
  final int? rw;
  final int? rt;
  final String? no_wa;
  final String? jabatan_mulai; // Nama properti yang benar
  final String? jabatan_akhir; // Nama properti yang benar
  String? status;
  final String? nama_jabatan;

  User({
    this.id,
    this.nik,
    this.nama,
    this.jabatan,
    this.alamat,
    this.kecamatan,
    this.kelurahan,
    this.rw,
    this.rt,
    this.no_wa,
    this.jabatan_mulai,
    this.jabatan_akhir,
    this.status,
    this.nama_jabatan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      nik: json['nik']?.toString(),
      nama: json['nama']?.toString(),
      jabatan: json['jabatan']?.toString(),
      alamat: json['alamat']?.toString(),
      kecamatan: json['wilayah_nama_kec']?.toString(),
      kelurahan: json['wilayah_nama_kel']?.toString(),
      rw: int.tryParse(json['wilayah_rw']?.toString() ?? ''),
      rt: int.tryParse(json['wilayah_rt']?.toString() ?? ''),
      no_wa: json['no_tlp']?.toString(),
      jabatan_mulai: json['jabatan_mulai']?.toString(),
      jabatan_akhir: json['jabatan_akhir']?.toString(),
      status: json['status']?.toString() ?? 'Inactive',
      nama_jabatan: json['nama_jabatan']?.toString(),
    );
  }
}
