import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:paten/models/user.dart';
import 'package:paten/models/user_thl.dart';
import 'package:paten/models/user_pns.dart';

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
      'https://script.google.com/macros/s/AKfycbwG-v3LTRy6GHhd1h930JSBcvRa3_6tSnqUvy2m4xBpLoSE2esNQIgkDcK2D0m8pRKisg/exec';

  final String _mainApiUrl =
      'https://script.google.com/macros/s/AKfycbxcQi5y7UiatE61MQgFl9TGA7Bli_u303NjpSvxbz7d-zKNPQb7AXiWCMT9dXpm6CTu/exec';

  final String _addUserRtRwApiUrl =
      'https://script.google.com/macros/s/AKfycbzw5Cozyzk7Hbz9qAXPmwkCm28FeNH5OLy5_onHRn2ptYdUTeL4l-S-myJ9qlZzdPkq/exec';

  final String _thlMainApiUrl =
      'https://script.google.com/macros/s/AKfycbzOyGK5H3niwfgrzFG4gMpNaBDmG76XVv_t9ddivEcYw4QyF1t4SeXYwZ50grEf8k0H/exec';

  final String _updateUserThlApiUrl =
      'https://script.google.com/macros/s/AKfycbyUJplsEvsX4cA-b5Vw1a_vUQEieyv0Mim2BOnUWs-dDesQeWkfvKfsfobFgG6ooDMr/exec';

  final String _updateUserRtRwApiUrl =
      'https://script.google.com/macros/s/AKfycbzUeW5Zx4OyLZiBx2xttLLBXAqdy9AqNllurCnxZULuI-0O4gRiffO9N6Grigytlm-X/exec';

  final String _deleteThlUserApiUrl =
      'https://script.google.com/macros/s/AKfycbyUJplsEvsX4cA-b5Vw1a_vUQEieyv0Mim2BOnUWs-dDesQeWkfvKfsfobFgG6ooDMr/exec';

  final String _checkNikApiUrl =
      'https://script.google.com/macros/s/AKfycbzTKCMvp25kFv_S64R6cBU_N-82xuGhobwG7u5tlY8gD8izo4ELfq7dQXbqOApOzouG/exec';

  final String _editUserRtRwApiUrl =
      'https://script.google.com/macros/s/AKfycbzKcbXUsz6Uf6tj0sdqldyCxmpjR7py7NO2t1E2JpizbmIbgtszVD-94sp71AhUip-9/exec';

  static const String jwtToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIzNzQxNyIsInVzZXJuYW1lIjoiZWdvdiIsImlkX3VzZXJfZ3JvdXAiOiIxIiwiaWRfcGVnYXdhaSI6IjY2NTYiLCJyZWYiOiJGYWl6IE11aGFtbWFkIFN5YW0gLSBDYWZld2ViIEluZG9uZXNpYSAtIDIwMjUiLCJBUElfVElNRSI6MTc1OTQ1NzAxNn0.YeNMPpfX2J9diEl7JRlki3saOnWHbJUl_pVMDHA--EQ';
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          print("✅ Final URL: ${response.realUri}");
          print("✅ Content-Type: ${response.headers.value('content-type')}");
          return handler.next(response);
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

  Future<UserPNS?> findUserByNik(String nik) async {
    try {
      final response = await _dio.get(
        _thlMainApiUrl,
        queryParameters: {
          'endpoint': 'find_user_thl',
          'jwt_token': jwtToken,
          'nik': nik,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return UserPNS.fromJson(jsonResponse['data']);
        } else {
          return null;
        }
      } else {
        throw Exception(
          'Gagal mencari NIK. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Kesalahan jaringan: ${e.message}');
    }
  }

  Future<void> saveNewTHLUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.get(
        _thlMainApiUrl,
        queryParameters: {
          'endpoint': 'add_user_thl',
          'jwt_token': jwtToken,
          'nip': userData['nip'],
          'id_pegawai': userData['id_pegawai'],
          'kode_unor': userData['kode_unor'],
          'nama_user': userData['nama_user'],
          'status_kepegawaian': userData['status_kepegawaian'],
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        if (jsonResponse['status'] != true) {
          throw Exception(
            jsonResponse['message'] ?? 'Gagal menyimpan data THL.',
          );
        }
      } else {
        throw Exception(
          'Gagal menyimpan data THL. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Kesalahan jaringan: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> checkNik(String nik) async {
    try {
      final response = await _publicDio.get(
        // Periksa apakah Anda menggunakan _publicDio atau _dio
        _checkNikApiUrl,
        queryParameters: {'endpoint': 'cek_nik', 'nik': nik},
        options: Options(
          validateStatus: (status) => true,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      // Langsung periksa dan kembalikan respons yang benar
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;

        // Logika di sini harus sesuai dengan respons Postman
        if (jsonResponse.containsKey('success') &&
            jsonResponse['success'] == true) {
          // Respons yang berhasil, mengembalikan data
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Data NIK ditemukan.',
            'data': jsonResponse['data'],
          };
        } else {
          // Respons gagal dari server (message tidak konsisten)
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Data tidak ditemukan.',
          };
        }
      } else {
        // Kesalahan pada status code
        return {
          'success': false,
          'message': 'Gagal memeriksa NIK. Status Code: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String message = 'Kesalahan jaringan: ${e.message}';
      if (e.response != null && e.response!.data != null) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan tak terduga: $e'};
    }
  }

  Future<void> updateUserThl(String userId, String newStatus) async {
    try {
      final Map<String, dynamic> params = {
        'endpoint': 'update_user_thl',
        'id': userId,
        'status': newStatus,
        'jwt_token': jwtToken,
      };

      final response = await _dio.get(
        _updateUserThlApiUrl,
        queryParameters: params,
        options: Options(
          validateStatus: (status) => true,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        if (jsonResponse['status'] != true) {
          throw Exception(
            jsonResponse['message'] ?? 'Gagal memperbarui status.',
          );
        }
      } else {
        throw Exception(
          'Gagal memperbarui status. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg =
            e.response!.data['message'] ?? e.response!.statusMessage;
        throw Exception('Gagal memperbarui status: $errorMsg');
      } else {
        throw Exception('Gagal memperbarui status: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error tidak terduga: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateUserRtRw(
    String userId,
    String newStatus,
  ) async {
    try {
      final Map<String, dynamic> params = {
        'endpoint': 'update_user_rt_rw',
        'id': userId,
        'status': newStatus,
        'jwt_token': jwtToken, // Pastikan jwtToken tersedia di scope ini
      };

      final response = await _dio.get(
        _updateUserRtRwApiUrl, // Pastikan URL ini benar
        queryParameters: params,
        options: Options(
          validateStatus: (status) =>
              true, // Selalu proses respons secara manual
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Pengecekan penting: pastikan respons adalah JSON (Map)
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> jsonResponse = response.data;
          final bool isSuccess = jsonResponse['status'] == true;
          final String message =
              jsonResponse['message'] ??
              (isSuccess
                  ? 'Status berhasil diperbarui.'
                  : 'Gagal memperbarui status.');

          return {'success': isSuccess, 'message': message};
        } else {
          // Jika respons bukan JSON (misal: halaman error HTML), lempar error
          throw Exception('Menerima format data yang tidak valid dari server.');
        }
      } else {
        throw Exception(
          'Gagal menghubungi server. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final errorMsg = e.response!.data['message'] ?? 'Error dari server.';
        throw Exception('Gagal memperbarui status: $errorMsg');
      } else {
        throw Exception('Masalah jaringan: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi error tidak terduga: ${e.toString()}');
    }
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
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0 (compatible; Flutter App)",
          },
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 500) {
        return {
          'success': false,
          'message':
              'Server mengalami error internal (500). Periksa Google Apps Script.',
        };
      }

      if (response.headers.value('content-type')?.contains('text/html') ==
          true) {
        return {
          'success': false,
          'message':
              'Google Apps Script mengembalikan error page. Periksa script di Google Console.',
        };
      }

      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> responseData;

        if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else if (response.data is String) {
          try {
            responseData = json.decode(response.data);
          } catch (e) {
            return {
              'success': false,
              'message': 'Response bukan JSON yang valid.',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Format response tidak dikenali.',
          };
        }

        bool isLoginSuccessful = false;

        if (responseData['success'] == true ||
            responseData['status'] == true ||
            responseData['message']?.toString().toLowerCase().contains(
                  'berhasil',
                ) ==
                true) {
          isLoginSuccessful = true;
        }

        if (isLoginSuccessful) {
          final userData = responseData['data'] ?? responseData;

          String? accessToken;

          if (responseData['access_token'] != null) {
            accessToken = responseData['access_token'].toString();
          } else if (userData != null && userData['access_token'] != null) {
            accessToken = userData['access_token'].toString();
          } else {
            accessToken = jwtToken;
          }

          return {
            'success': true,
            'message': responseData['message'] ?? 'Login berhasil',
            'data': userData,
            'user_data': userData,
            'token': accessToken,
            'access_token': accessToken,
            'user_id': userData?['user_id'],
            'id_pegawai': userData?['id_pegawai'],
            'nip': userData?['nip'],
            'nama_pegawai': userData?['nama_pegawai'],
            'status_kepegawaian': userData?['status_kepegawaian'],
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message'] ??
                'Login gagal - kredensial tidak valid.',
          };
        }
      }

      return {
        'success': false,
        'message': 'Login gagal. Status Code: ${response.statusCode}',
      };
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': 'Kesalahan jaringan: ${e.response!.statusMessage}',
        };
      } else {
        return {
          'success': false,
          'message': 'Kesalahan jaringan: ${e.message}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan tak terduga: $e'};
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

  Future<Map<String, dynamic>> editUserRtRw({
    required String id, // <-- TAMBAHKAN PARAMETER INI
    required String nik,
    required String nama,
    required String alamat,
    required String telepon,
    required int idJabatan,
    required String jabatan, // <-- TAMBAHKAN PARAMETER INI
    required String jenisJabatan, // <-- TAMBAHKAN PARAMETER INI
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
        'id': id, // <-- GUNAKAN ID DI SINI
        'endpoint': 'add_user_rt_rw', // Sesuai dokumentasi API Anda
        'jwt_token': jwtToken,
        'nik': nik,
        'nama': nama,
        'alamat': alamat,
        'no_telp': telepon,
        'id_jabatan': idJabatan.toString(),
        'jabatan': jabatan, // <-- KIRIM PARAMETER INI
        'jenis_jabatan': jenisJabatan, // <-- KIRIM PARAMETER INI
        'wilayah_rt': wilayahRt.toString(),
        'wilayah_rw': wilayahRw.toString(),
        'tgl_mulai': tglMulai,
        'tgl_selesai': tglSelesai,
        'id_pegawai_session': idPegawaiSession.toString(),
        'kode_unor_session': kodeUnorSession,
        'kode_unor_pegawai_session': kodeUnorPegawaiSession,
      };

      // GUNAKAN URL YANG BENAR UNTUK EDIT
      final response = await _dio
          .get(
            _editUserRtRwApiUrl,
            queryParameters: queryParams,
            options: Options(
              validateStatus: (status) => true, // Memproses semua status code
            ),
          )
          .timeout(const Duration(seconds: 30));

      // Logika respons bisa disederhanakan
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        return {
          'status': false,
          'message': 'Gagal memperbarui data. Status: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String message = 'Gagal memperbarui data: ${e.message}';
      return {'status': false, 'message': message};
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteThlUser(String id) async {
    try {
      final response = await _dio.get(
        _deleteThlUserApiUrl,
        queryParameters: {
          'endpoint': 'delete_user_thl',
          'jwt_token': jwtToken,
          'id': id,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> jsonResponse = response.data;
        if (jsonResponse['status'] == true) {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Data THL berhasil dihapus.',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Gagal menghapus data THL.',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Gagal menghapus data THL. Status Code: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      String message = 'Kesalahan jaringan: ${e.message}';
      if (e.response != null && e.response!.data != null) {
        message = e.response!.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan tak terduga: $e'};
    }
  }
}
