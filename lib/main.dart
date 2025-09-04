import 'package:flutter/material.dart';
import 'package:paten/screen/user_list_screen.dart'; // Import yang benar

// Import ini tidak lagi dibutuhkan, tapi bisa disimpan jika Anda ingin kembali ke halaman login
// import 'package:paten/screen/login.dart';
import 'package:paten/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().addInterceptors();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi PATEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF062B96),
          foregroundColor: Colors.white,
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
      // Navigasi dimulai dari halaman THLUserListScreen
      home: const UserListScreen(),
    );
  }
}
