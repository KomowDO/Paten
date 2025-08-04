class User {
  final String id;
  final String nik;
  final String nama;
  final String jabatan;
  final String alamat;
  final String kecamatan;
  final String kelurahan;
  final int rw;
  final int rt;
  final String no_wa;
  final String jabatanMulai; // Properti baru
  final String jabatanAkhir; // Properti baru
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
    required this.no_wa,
    required this.jabatanMulai,
    required this.jabatanAkhir,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic rwValue = json['wilayah_rw'];
    final dynamic rtValue = json['wilayah_rt'];

    return User(
      id: json['id']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      jabatan: json['nama_jabatan']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      kecamatan: json['wilayah_nama_kec']?.toString() ?? '',
      kelurahan: json['wilayah_nama_kel']?.toString() ?? '',
      rw: int.tryParse(rwValue?.toString() ?? '') ?? 0,
      rt: int.tryParse(rtValue?.toString() ?? '') ?? 0,
      no_wa: json['no_tlp']?.toString() ?? '',
      jabatanMulai:
          json['jabatan_mulai']?.toString() ?? '-', // Mapping properti baru
      jabatanAkhir:
          json['jabatan_akhir']?.toString() ?? '-', // Mapping properti baru
      status: json['status']?.toString() ?? '',
    );
  }
}
