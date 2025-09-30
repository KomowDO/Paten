// lib/main.dart

import 'package:flutter/material.dart';
import 'package:paten/screen/user_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Import untuk inisialisasi tanggal (PENTING)
import 'package:intl/date_symbol_data_local.dart';

// Import halaman login (dihidupkan kembali untuk logika login)
import 'package:paten/screen/login.dart';

// Import semua kelas provider Anda
import 'package:paten/providers/add_user_provider.dart';
import 'package:paten/providers/thl_list_provider.dart';
import 'package:paten/providers/user_list_provider.dart';

Future<void> main() async {
  // <-- Pastikan fungsi main sudah 'async'
  WidgetsFlutterBinding.ensureInitialized();

  // 1. INISIALISASI FORMAT TANGGAL (FIX UNTUK MASALAH TANGGAL)
  await initializeDateFormatting('id', null);

  // Cek apakah user sudah login sebelumnya
  final prefs = await SharedPreferences.getInstance();
  final savedUsername = prefs.getString('username'); // bisa juga cek token

  runApp(MyApp(isLoggedIn: savedUsername != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 3. PERBAIKAN NAMA PROVIDER (sesuaikan jika nama class Anda berbeda)
        ChangeNotifierProvider(create: (_) => THLUserProvider()),
        ChangeNotifierProvider(create: (_) => AddUserProvider()),
        ChangeNotifierProvider(create: (_) => UserListProvider()),
      ],
      child: MaterialApp(
        title: 'Aplikasi PATEN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF083C7C),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
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
        // 2. PERBAIKAN LOGIKA LOGIN
        home: isLoggedIn ? const UserListScreen() : const LoginPage(),
      ),
    );
  }
}
