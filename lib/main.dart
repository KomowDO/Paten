import 'package:flutter/material.dart';
import 'package:paten/screen/user_list_screen.dart';
import 'package:provider/provider.dart'; // Import the provider package
// import 'package:paten/screen/thl_user_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Import all your provider classes
import 'package:paten/providers/add_user_provider.dart';
import 'package:paten/providers/thl_list_provider.dart';
import 'package:paten/providers/user_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      // Use MultiProvider to register all providers
      providers: [
        ChangeNotifierProvider(
          create: (_) => THLUserProvider(),
        ), // Use the correct class name
        ChangeNotifierProvider(create: (_) => AddUserProvider()),
        // Add other providers here if you have them
        ChangeNotifierProvider(create: (_) => UserListProvider()),
      ],
      child: MaterialApp(
        title: 'Aplikasi PATEN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF062B96),
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
        // home: const THLUserListScreen(),
        home: const UserListScreen(),
      ),
    );
  }
}
