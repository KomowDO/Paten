import 'package:flutter/material.dart';
//import 'package:paten/add_user_screen.dart';
//import 'package:paten/reset_pw_screen.dart';
//import 'package:paten/edit_screen.dart';
import 'package:paten/login.dart';

void main() {
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
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF03038E), // biru solid (#0A33AA)
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          labelStyle: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: LoginPage(),
      //home: TambahPenggunaScreen(),
      //home: UbahDataScreen(),
      //home: ResetPasswordScreen(),
    );
  }
}
