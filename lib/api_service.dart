import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final String _jabatanApiUrl =
      'https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLiSt4bPhW8QIfEakvSkorTbO5FA3X7ZYneP2cHiuiTi5F2y7Mf3DxwazdIGK4PyfCF05E1Mc4CvvgHAM4N5SyjXOAfCdzhRn_Jy7npxsYFz41sMlC5u6raDOFdARDfRr2OkBKlJLO3X7iKCMEApT6RAXZ8f0nnSm2TjqKwnXC7ULvW6UpSC6fXXdgBZZRU9PlAz69IDx5VIhBiFwWLoljY6iQ6hPNk8ZSVg1g3m90IA0IWZrzInEwnff0MdJo52tv9y3W6BgFubAE1cNjv1bACokJ2VKw&lib=M_AeKjZaFOlawafwJcLPaaIaJ-zFb6PIO';

  ApiService() : _dio = Dio();

  void addInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          print(obj);
        },
      ),
    );
  }

  Future<Response> updateUserData(Map<String, dynamic> data) async {
    print("Simulasi: Mengirim data ke API update: $data");
    await Future.delayed(Duration(seconds: 1));
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {"message": "Simulasi update berhasil"},
    );
  }

  // Metode untuk mengambil daftar jabatan dari API baru
  Future<List<String>> fetchJabatanOptions() async {
    try {
      // Tambahkan User-Agent agar request mirip browser
      _dio.options.headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
      print('Headers sebelum request: ${_dio.options.headers}');

      final response = await _dio.get(_jabatanApiUrl);

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> dataList = jsonResponse['data'];
          return dataList
              .map((item) => item['nama_jabatan'].toString())
              .toList();
        } else {
          throw Exception(
            'Respons API tidak mengandung kunci "data" yang valid.',
          );
        }
      } else {
        throw Exception(
          'Gagal memuat daftar jabatan. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Error Dio fetching jabatan: $e');
      if (e.response != null) {
        print('Error Response Data: ${e.response?.data}');
      }
      throw Exception('Kesalahan jaringan saat memuat jabatan: ${e.message}');
    } catch (e) {
      print('Error tak terduga fetching jabatan: $e');
      throw Exception('Terjadi kesalahan tak terduga: $e');
    }
  }

  /// Hapus Bearer token dari header Authorization
  void removeBearerToken() {
    _dio.options.headers.remove('Authorization');
    print(_dio.options.headers);
  }
}
