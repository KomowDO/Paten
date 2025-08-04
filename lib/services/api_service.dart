import 'package:dio/dio.dart';
import 'dart:convert';

class ApiService {
  final Dio _dio;

  final String _jabatanApiUrl =
      'https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLiSt4bPhW8QIfEakvSkorTbO5FA3X7ZYneP2cHiuiTi5F2y7Mf3DxwazdIGK4PyfCF05E1Mc4CvvgHAM4N5SyjXOAfCdzhRn_Jy7npxsYFz41sMlC5u6raDOFdARDfRr2OkBKlJLO3X7iKCMEApT6RAXZ8f0nnSm2TjqKwnXC7ULvW6UpSC6fXXdgBZZRU9PlAz69IDx5VIhBiFwWLoljY6iQ6hPNk8ZSVg1g3m90IA0IWZrzInEwnff0MdJo52tv9y2W6BgFubAE1cNjv1bACokJ2VKw&lib=M_AeKjZaFOlawafwJcLPaaIaJ-zFb6PIO';

  // URL utama untuk otentikasi (login/token) - URL /exec yang terbukti di Postman
  final String _authApiUrl =
      //'https://script.google.com/macros/s/AKfycbybS_Jf4KMFNPz5t2hwf-0kvTI69BnnjpwT4nAt6UVw77UzQ7W72X42379ja8V21-Voeg/exec';
      'https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLgekkkSATV52bTnXseW56rzF-umV3NAaF__O_X6qR4ueaSZNhIElG9gawACgo8OR5TjnBmP5Ql_GUvxzf4Ah8imwKY1RZ6AnHRYolNTKIdVvh16YGPtk1p6qPnOFpu0AZJkjAbDhh7Mg2NfDWhDDcfpdwJ7P5T4SVf5dOIrmmToM0H5k8wlGfZ0R-bgLywC0_nfAXdqoSJBV5Mb8UJq7hC3RJe8DStem3aACdhMAnp28CNf8OUAdP_eWDpQ_LIwfzWaAxli7hZ7OCmmq3PEwRUamQCH1YCN9r2x2OE8&lib=MmAaqttzDCabCIYbIYlXhGuvRNnNj0k7b';

  ApiService() : _dio = Dio();

  void addInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          print('DIO LOG: $obj');
        },
      ),
    );

    // Interceptor khusus untuk melacak rantai redirect (untuk debugging 302)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.redirects.isNotEmpty) {
            print('--- DIO REDIRECT CHAIN DETECTED ---');
            for (var redirect in response.redirects) {
              print('  ${redirect.statusCode} from ${redirect.location}');
            }
            print('--- END REDIRECT CHAIN ---');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response != null && e.response!.redirects.isNotEmpty) {
            print('--- DIO ERROR WITH REDIRECTS DETECTED ---');
            for (var redirect in e.response!.redirects) {
              print('  ${redirect.statusCode} from ${redirect.location}');
            }
            print('--- END ERROR REDIRECT CHAIN ---');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Metode simulasi untuk update data user (tidak terkait login)
  Future<Response> updateUserData(Map<String, dynamic> data) async {
    print("Simulasi: Mengirim data ke API update: $data");
    await Future.delayed(Duration(seconds: 1));
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {"message": "Simulasi update berhasil"},
    );
  }

  // Metode untuk mengambil daftar jabatan (sesuai permintaan, tidak diubah)
  Future<List<String>> fetchJabatanOptions() async {
    try {
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

  // Metode untuk menghapus Bearer token (jika digunakan untuk otentikasi setelah login)
  void removeBearerToken() {
    _dio.options.headers.remove('Authorization');
    print(_dio.options.headers);
  }

  // Metode untuk mendapatkan token secara terpisah (jika API menyediakan endpoint GET untuk ini)
  // Namun, access_token utama sudah didapat dari respons login POST.
  Future<String?> fetchBearerToken() async {
    try {
      final response = await _dio.get(
        _authApiUrl, // Menggunakan URL yang sama, tapi metode GET
        options: Options(
          headers: {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36",
          },
          validateStatus: (status) => true, // Izinkan semua status
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      print('DIO LOG (Token Fetch Final Status): ${response.statusCode}');
      print(
        'DIO LOG (Token Fetch Final Data Raw Type): ${response.data.runtimeType}',
      );
      print('DIO LOG (Token Fetch Final Data Raw): ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          try {
            final decoded = json.decode(response.data);
            if (decoded is Map<String, dynamic>) {
              responseData = decoded;
            } else {
              print(
                'Decoded token response is not a Map: ${decoded.runtimeType}',
              );
              return null;
            }
          } catch (e) {
            print('Failed to parse JSON string response for token: $e');
            return null;
          }
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          print(
            'Unexpected response data type for token: ${response.data.runtimeType}',
          );
          return null;
        }

        if (responseData.containsKey('token')) {
          return responseData['token'] as String;
        } else if (responseData.containsKey('access_token')) {
          return responseData['access_token'] as String;
        } else {
          print('Token not found in response: $responseData');
          return null;
        }
      } else {
        print('Failed to fetch token. Status Code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Error fetching token: $e');
      if (e.response != null) {
        print('Error Response Data (Token): ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('Unexpected error fetching token: $e');
      return null;
    }
  }

  // Metode utama untuk proses login
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Validasi input di sisi klien
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong.',
      };
    }

    try {
      final response = await _dio.post(
        _authApiUrl, // Menggunakan URL API login
        data: {
          // Mengirim body sebagai JSON raw
          "user": username,
          "password": password,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36", // Spoof User-Agent
          },
          validateStatus: (status) {
            return true; // Penting: Izinkan semua status untuk diteruskan ke handler
          },
          followRedirects: true, // Pastikan Dio mengikuti redirect
          maxRedirects: 5, // Batasi jumlah redirect
        ),
      );

      // Log detail respons akhir dari API
      print('DIO LOG (Login Final Status): ${response.statusCode}');
      print(
        'DIO LOG (Login Final Data Raw Type): ${response.data.runtimeType}',
      );
      print('DIO LOG (Login Final Data Raw): ${response.data}');

      // Analisis respons berdasarkan status code dan tipe data
      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> parsedResponse;

        if (response.data is String) {
          try {
            final decoded = json.decode(response.data);
            if (decoded is Map<String, dynamic>) {
              parsedResponse = decoded;
            } else {
              print(
                'Decoded login response is not a Map: ${decoded.runtimeType}',
              );
              return {
                'success': false,
                'message':
                    'Respon tidak valid dari server (bukan objek JSON akhir).',
              };
            }
          } catch (e) {
            print('Failed to parse JSON string response for login: $e');
            return {
              'success': false,
              'message':
                  'Respon tidak valid dari server (JSON parse error akhir).',
            };
          }
        } else if (response.data is Map<String, dynamic>) {
          parsedResponse = response.data;
        } else {
          print(
            'Unexpected response data type for login: ${response.data.runtimeType}',
          );
          return {
            'success': false,
            'message': 'Format respons akhir tidak dikenal.',
          };
        }

        // Periksa status 'success' dari JSON yang sudah di-parse (sesuai format Postman)
        if (parsedResponse.containsKey('success') &&
            parsedResponse['success'] == true) {
          String? accessToken;
          if (parsedResponse.containsKey('data') &&
              parsedResponse['data'] is Map<String, dynamic>) {
            final Map<String, dynamic> data = parsedResponse['data'];
            accessToken = data['access_token']
                ?.toString(); // Ekstrak access_token
          }

          return {
            'success': true,
            'message': parsedResponse['message'] ?? 'Login berhasil!',
            'user_data': parsedResponse, // Seluruh data user dari respons
            'access_token': accessToken, // Tambahkan access_token ke hasil
          };
        } else {
          // Login gagal berdasarkan respons JSON (misal, "Anda tidak memiliki akses")
          return {
            'success': false,
            'message':
                parsedResponse['message'] ??
                'Login gagal. Respon tidak lengkap dari server.',
          };
        }
      }
      // Penanganan khusus untuk HTTP 302 atau respons yang terlihat seperti HTML (indikasi redirect ke error page)
      else if (response.statusCode == 302 ||
          (response.data is String &&
              response.data.toString().contains('<html') &&
              response.data.toString().contains('</html>'))) {
        return {
          'success': false,
          'message': 'API ini mengalihkan Anda ke halaman HTML.',
        };
      }
      // Penanganan status code HTTP lainnya (misal 404, 405, 500)
      else {
        return {
          'success': false,
          'message': 'Login gagal. Status Code Akhir: ${response.statusCode}.',
        };
      }
    } on DioException catch (e) {
      print('Error Dio login: $e');
      if (e.response != null) {
        print('Error Response Data (Login): ${e.response?.data}');
        // Coba parse pesan error dari respons Dio jika tersedia
        if (e.response?.data is Map<String, dynamic>) {
          return {
            'success': false,
            'message': e.response?.data['message'] ?? 'Kesalahan dari server.',
          };
        } else if (e.response?.data is String) {
          try {
            final Map<String, dynamic> errorData = json.decode(
              e.response!.data,
            );
            return {
              'success': false,
              'message':
                  errorData['message'] ??
                  'Kesalahan dari server (JSON parse error).',
            };
          } catch (_) {
            return {
              'success': false,
              'message':
                  'Kesalahan dari server: ${e.response?.statusCode ?? ''} ${e.response?.statusMessage ?? ''}',
            };
          }
        } else {
          return {
            'success': false,
            'message':
                'Kesalahan dari server: ${e.response?.statusCode ?? ''} ${e.response?.statusMessage ?? ''}',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        };
      }
    } catch (e) {
      print('Error tak terduga login: $e');
      return {'success': false, 'message': 'Terjadi kesalahan tak terduga: $e'};
    }
  }
}
