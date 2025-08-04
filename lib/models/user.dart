class User {
  final int id;
  final String nik;
  final String nama;
  final String jabatan;
  final String alamat;
  final String kecamatan;
  final String kelurahan;
  final int rw;
  final int rt;
  final String status;

  User({
    required this.id,
    required this.nik,
    required this.nama,
    required this.jabatan,
    required this.alamat,
    required this.kecamatan,
    required this.kelurahan,
    required this.rw,
    required this.rt,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nik: json['nik'] as String,
      nama: json['nama_pegawai'] as String,
      jabatan: json['jabatan'] as String,
      alamat: json['alamat'] as String,
      kecamatan: json['kecamatan'] as String,
      kelurahan: json['kelurahan'] as String,
      rw: json['rw'] as int,
      rt: json['rt'] as int,
      status: json['status'] as String,
    );
  }
}
