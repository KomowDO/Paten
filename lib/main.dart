import 'package:flutter/material.dart';
import 'package:paten/screen/login.dart';
// import 'package:paten/screen/add_user_screen.dart';
//import 'package:paten/screen/edit_user_screen.dart';
//import 'package:paten/screen/reset_password_screen.dart';
//import 'package:paten/screen/user_list_screen.dart';
import 'package:paten/services/api_service.dart'; // Penting: Import ApiService

void main() {
  // Pastikan Flutter binding diinisialisasi sebelum menggunakan service seperti shared_preferences
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi interceptor Dio untuk logging dan debugging API
  // Ini harus dipanggil sekali di awal aplikasi
  ApiService().addInterceptors();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi PATEN',
      debugShowCheckedModeBanner: false, // Menghilangkan banner "DEBUG"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF03038E), // Warna AppBar solid biru
          foregroundColor: Colors.white, // Warna teks AppBar
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: LoginPage(), // Halaman awal aplikasi Anda
      //home: AddUserScreen(),
      // home: EditUserScreen(),
      // home: ResetPasswordScreen(),
      //home: UserListScreen(),
    );
  }
}
