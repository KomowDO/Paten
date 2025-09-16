// Perbarui model UserPNS agar sesuai dengan respons API
class UserPNS {
  final String? id;
  final String? idPegawai;
  final String? nip;
  final String nik; // nip_baru di API adalah NIK
  final String nama; // nama_pegawai di API adalah nama
  final String? jabatan;
  final String? kodeUnor;
  final String? namaUnor;
  final String? statusKepegawaian;

  // Tambahkan properti lain yang mungkin Anda butuhkan
  final String? namaKecamatan;
  final String? namaKelurahan;
  final String? nomorHp;

  UserPNS({
    this.id,
    this.idPegawai,
    this.nip,
    required this.nik,
    required this.nama,
    this.jabatan,
    this.kodeUnor,
    this.namaUnor,
    this.statusKepegawaian,

    this.namaKecamatan,
    this.namaKelurahan,
    this.nomorHp,
  });

  factory UserPNS.fromJson(Map<String, dynamic> json) {
    return UserPNS(
      id: json['id']?.toString(),
      idPegawai: json['id_pegawai']?.toString(),
      nip: json['nip']?.toString(),
      nik: json['nip_baru']?.toString() ?? '', // Gunakan 'nip_baru' untuk NIK
      nama:
          json['nama_pegawai']?.toString() ??
          '', // Gunakan 'nama_pegawai' untuk nama
      jabatan: json['nomenklatur_jabatan']
          ?.toString(), // Sesuaikan dengan key jabatan yang ada
      kodeUnor: json['kode_unor']?.toString(),
      namaUnor: json['nama_unor']?.toString(),
      statusKepegawaian: json['status_kepegawaian']?.toString(),

      // Data kecamatan dan kelurahan tidak ada di respons ini.
      // Anda harus mendapatkan data ini dari API lain atau mengosongkannya.
      namaKecamatan: json['nama_kecamatan']?.toString(),
      namaKelurahan: json['nama_kelurahan']?.toString(),
      nomorHp: json['nomor_hp']?.toString(),
    );
  }
}
