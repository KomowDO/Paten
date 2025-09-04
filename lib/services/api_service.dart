import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:paten/models/user.dart'; // Import model untuk user reguler
import 'package:paten/models/user_thl.dart'; // Import model untuk user THL

class ApiService {
  final Dio _dio;
  final Dio _publicDio;

  final String _jabatanApiUrl =
      'https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLiSt4bPhW8QIfEakvSkorTbO5FA3X7ZYneP2cHiuiTi5F2y7Mf3DxwazdIGK4PyfCF05E1Mc4CvvgHAM4N5SyjXOAfCdzhRn_Jy7npxsYFz41sMlC5u6raDOFdARDfRr2OkBKlJLO3X7iKCMEApT6RAXZ8f0nnSm2TjqKwnXC7ULvW6UpSC6fXXdgBZZRU9PlAz69IDx5VIhBiFwWLoljY6iQ6hPNk8ZSVg1g3m90IA0IWZrzInEwnff0MdJo52tv9y3W6BgFubAE1cNjv1bACokJ2VKw&lib=M_AeKjZaFOlawafwJcLPaaIaJ-zFb6PIO';

  final String _userListApiUrl =
      'https://script.google.com/macros/s/AKfycbz6i1pWIsHXwjbJVGrD3WFN8iNmFvEe23yZD0brdHCC-7zewdFHrIZ_r5QGORCtIAc00w/exec';

  final String _thlUserListApiUrl =
      'https://script.google.com/macros/s/AKfycbyTeVoqIQ3nYZc-_R3mdvEnPnGTdhJfB5PzRZ2Kdb3iETV3iD7hrPmHdBkUPaNynL_j/exec';

  final String _authApiUrl =
      'https://script.google.com/macros/s/AKfycbwG-v3LTRy6GHhd1h930JSBcvRa3_6tSnqUvy2m4xBpLoSE2esNQIgDcC2D0m8pRKisg/exec';

  final String _mainApiUrl =
      'https://script.google.com/macros/s/AKfycbxcQi5y7UiatE61MQgFl9TGA7Bli_u303NjpSvxbz7d-zKNPQb7AXiWCMT9dXpm6CTu/exec';

  final String _addUserRtRwApiUrl =
      'https://script.google.com/macros/s/AKfycbzw5Cozyzk7Hbz9qAXPmwkCm28FeNH5OLy5_onHRn2ptYdUTeL4l-S-myJ9qlZzdPkq/exec';

  static const String jwtToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIzNzQxNyIsInVzZXJuYW1lIjoiZWdvdiIsImlkX3VzZXJfZ3JvdXAiOiIxIiwiaWRfcGVnYXdhaSI6IjY2NTYiLCJyZWYiOiJGYWl6IE11aGFtbWFkIFN5YW0gLSBDYWZld2ViIEluZG9uZXNpYSAtIDIwMjUiLCJBUElfVElNRSI6MTc1Njk3Mzc2Nn0.HJoHlSzUZjYD22ay9prxEemroPXuac1BTo8YfEgwaiY';

  ApiService() : _dio = Dio(), _publicDio = Dio() {
    _addAuthenticatedInterceptors(_dio);
    _addPublicInterceptors(_publicDio);
  }

  void addInterceptors() {}

  void _addAuthenticatedInterceptors(Dio dio) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          print('DIO AUTH LOG: $obj');
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $jwtToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.redirects.isNotEmpty) {
            print('--- DIO REDIRECT CHAIN DETECTED ---');
            for (var redirect in response.redirects) {
              print('   ${redirect.statusCode} from ${redirect.location}');
            }
            print('--- END REDIRECT CHAIN ---');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response != null && e.response!.redirects.isNotEmpty) {
            print('--- DIO ERROR WITH REDIRECTS DETECTED ---');
            for (var redirect in e.response!.redirects) {
              print('   ${redirect.statusCode} from ${redirect.location}');
            }
            print('--- END ERROR REDIRECT CHAIN ---');
          }
          return handler.next(e);
        },
      ),
    );
  }

  void _addPublicInterceptors(Dio dio) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          print('DIO PUBLIC LOG: $obj');
        },
      ),
    );
  }

  void removeBearerToken() {
    _dio.options.headers.remove('Authorization');
    print('Token bearer telah dilepas.');
  }

  Future<List<Map<String, dynamic>>> fetchJabatanData() async {
    try {
      final response = await _publicDio.get(
        _jabatanApiUrl,
        queryParameters: {'lib': 'M_AeKjZaFOlawafwJcLPaaIaJ-zFb6PIO'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> dataList = jsonResponse['data'];
          return dataList.map((item) => item as Map<String, dynamic>).toList();
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
      throw Exception('Kesalahan jaringan saat memuat jabatan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: $e');
    }
  }

  // Regular user list function (existing)
  Future<List<User>> getUsers({
    int page = 1,
    int limit = 45,
    required String kode_unor_pegawai,
    String? filter_kecamatan,
    String? filter_kelurahan,
    String? filter_no_rw,
    String? filter_no_rt,
    String? keyword,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        'jwt_token': jwtToken,
        'page': page,
        'limit': limit,
        'kode_unor_pegawai': kode_unor_pegawai,
      };

      if (filter_kecamatan != null && filter_kecamatan.isNotEmpty) {
        queryParameters['filter_kecamatan'] = filter_kecamatan;
      }
      if (filter_kelurahan != null && filter_kelurahan.isNotEmpty) {
        queryParameters['filter_kelurahan'] = filter_kelurahan;
      }
      if (filter_no_rw != null && filter_no_rw.isNotEmpty) {
        queryParameters['filter_no_rw'] = filter_no_rw;
      }
      if (keyword != null && keyword.isNotEmpty) {
        queryParameters['keyword'] = keyword;
      }

      final response = await _dio.get(
        _userListApiUrl,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          List<dynamic> data = jsonResponse['data'];
          // Parsing dengan model User
          return data.map((json) => User.fromJson(json)).toList();
        } else {
          throw Exception(
            'Invalid API response format: "data" key not found or not a list.',
          );
        }
      } else {
        throw Exception(
          'Failed to load users with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        errorMessage =
            'Failed to load users: ${e.response!.statusCode} - ${e.response!.statusMessage}';
      } else {
        errorMessage = 'Failed to connect to the server: $e';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- Fungsi Baru: `getThlUsers` dengan Model `UserTHL` ---
  Future<List<UserTHL>> getThlUsers({
    int page = 1,
    int limit = 10,
    required String kode_unor_pegawai,
    String? keyword,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        'endpoint': 'list_user_thl',
        'jwt_token': jwtToken,
        'page': page,
        'limit': limit,
        'kode_unor_pegawai': kode_unor_pegawai,
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParameters['keyword'] = keyword;
      }

      final response = await _publicDio.get(
        _thlUserListApiUrl,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) => true,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          List<dynamic> data = jsonResponse['data'];
          // Parsing dengan model UserTHL
          return data.map((json) => UserTHL.fromJson(json)).toList();
        } else if (jsonResponse.containsKey('status') &&
            jsonResponse['status'] == false) {
          throw Exception(
            jsonResponse['message'] ?? 'API returned error status',
          );
        } else {
          throw Exception(
            'Invalid API response format: "data" key not found or not a list.',
          );
        }
      } else {
        throw Exception(
          'Failed to load THL users with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage =
              errorData['message'] ??
              'Failed to load THL users: ${e.response!.statusCode} - ${e.response!.statusMessage}';
        } else {
          errorMessage =
              'Failed to load THL users: ${e.response!.statusCode} - ${e.response!.statusMessage}';
        }
      } else {
        errorMessage = 'Failed to connect to the server: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fungsi-fungsi lainnya tetap di sini

  Future<Response> updateUserData(Map<String, dynamic> data) async {
    print("Simulasi: Mengirim data ke API update: $data");
    await Future.delayed(const Duration(seconds: 1));
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {"message": "Simulasi update berhasil"},
    );
  }

  Future<String?> fetchBearerToken() async {
    return null;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong.',
      };
    }

    try {
      final response = await _publicDio.get(
        _authApiUrl,
        queryParameters: {"user": username, "password": password},
        options: Options(
          headers: {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36",
          },
          validateStatus: (status) {
            return true;
          },
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> parsedResponse;
        if (response.data is String) {
          try {
            final decoded = json.decode(response.data);
            if (decoded is Map<String, dynamic>) {
              parsedResponse = decoded;
            } else {
              return {
                'success': false,
                'message': 'Respon tidak valid dari server.',
              };
            }
          } catch (e) {
            return {
              'success': false,
              'message': 'Respon tidak valid dari server (JSON parse error).',
            };
          }
        } else if (response.data is Map<String, dynamic>) {
          parsedResponse = response.data;
        } else {
          return {'success': false, 'message': 'Format respons tidak dikenal.'};
        }

        if (parsedResponse.containsKey('success') &&
            parsedResponse['success'] == true) {
          String? accessToken;
          if (parsedResponse.containsKey('data') &&
              parsedResponse['data'] is Map<String, dynamic>) {
            final Map<String, dynamic> data = parsedResponse['data'];
            accessToken = data['access_token']?.toString();
          }
          return {
            'success': true,
            'message': parsedResponse['message'] ?? 'Login berhasil!',
            'user_data': parsedResponse,
            'access_token': accessToken,
          };
        } else {
          return {
            'success': false,
            'message':
                parsedResponse['message'] ??
                'Login gagal. Respon tidak lengkap.',
          };
        }
      } else if (response.statusCode == 302 ||
          (response.data is String &&
              response.data.toString().contains('<html'))) {
        return {
          'success': false,
          'message': 'API ini mengalihkan Anda ke halaman HTML.',
        };
      } else {
        return {
          'success': false,
          'message': 'Login gagal. Status Code: ${response.statusCode}.',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
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
      return {'success': false, 'message': 'Terjadi kesalahan tak terduga: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String jwtToken,
    String nik,
  ) async {
    try {
      final response = await _dio.get(
        _mainApiUrl,
        queryParameters: {
          'endpoint': 'reset_password',
          'jwt_token': jwtToken,
          'nik': nik,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }
    } on DioException catch (e) {
      String message = 'Failed to reset password: ${e.message}';
      if (e.response != null && e.response!.data != null) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String jwtToken, String nik) async {
    try {
      final response = await _dio.get(
        _mainApiUrl,
        queryParameters: {
          'endpoint': 'delete_user',
          'jwt_token': jwtToken,
          'nik': nik,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }
    } on DioException catch (e) {
      String message = 'Failed to delete user: ${e.message}';
      if (e.response != null && e.response!.data != null) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> addUserRtRw({
    required String nik,
    required String nama,
    required String alamat,
    required String telepon,
    required int idJabatan,
    required int wilayahRt,
    required int wilayahRw,
    required String tglMulai,
    required String tglSelesai,
    required int idPegawaiSession,
    required String kodeUnorSession,
    required String kodeUnorPegawaiSession,
    required String jabatan,
    required String jenis_jabatan,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'endpoint': 'add_user_rt_rw',
        'jwt_token': jwtToken,
        'nik': nik,
        'nama': nama,
        'alamat': alamat,
        'no_telp': telepon,
        'id_jabatan': idJabatan.toString(),
        'wilayah_rt': wilayahRt.toString(),
        'wilayah_rw': wilayahRw.toString(),
        'tgl_mulai': tglMulai,
        'tgl_selesai': tglSelesai,
        'id_pegawai_session': idPegawaiSession.toString(),
        'kode_unor_session': kodeUnorSession,
        'kode_unor_pegawai_session': kodeUnorPegawaiSession,
        'jabatan': jabatan,
        'jenis_jabatan': jenis_jabatan,
      };

      final response = await _dio
          .get(
            _addUserRtRwApiUrl,
            queryParameters: queryParams,
            options: Options(
              headers: {'Content-Type': 'application/json'},
              validateStatus: (status) => true,
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          try {
            return json.decode(response.data.toString());
          } catch (e) {
            return {'success': false, 'message': 'Invalid response format.'};
          }
        }
      } else {
        return {
          'success': false,
          'message': 'Gagal menambahkan user. Status: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String message = 'Gagal menambahkan user: ${e.message}';
      if (e.response != null && e.response!.data != null) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUserRtRw({
    required String nik,
    required String nama,
    required String alamat,
    required String telepon,
    required int idJabatan,
    required int wilayahRt,
    required int wilayahRw,
    required String tglMulai,
    required String tglSelesai,
    required int idPegawaiSession,
    required String kodeUnorSession,
    required String kodeUnorPegawaiSession,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'endpoint': 'update_user_rt_rw',
        'jwt_token': jwtToken,
        'nik': nik,
        'nama': nama,
        'alamat': alamat,
        'no_telp': telepon,
        'id_jabatan': idJabatan.toString(),
        'wilayah_rt': wilayahRt.toString(),
        'wilayah_rw': wilayahRw.toString(),
        'tgl_mulai': tglMulai,
        'tgl_selesai': tglSelesai,
        'id_pegawai_session': idPegawaiSession.toString(),
        'kode_unor_session': kodeUnorSession,
        'kode_unor_pegawai_session': kodeUnorPegawaiSession,
      };

      final response = await _dio
          .get(
            _addUserRtRwApiUrl,
            queryParameters: queryParams,
            options: Options(
              headers: {'Content-Type': 'application/json'},
              validateStatus: (status) => true,
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Data berhasil diperbarui',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal memperbarui data',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Gagal memperbarui data. Status: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String message = 'Gagal memperbarui data: ${e.message}';
      if (e.response != null && e.response!.data != null) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }
}
