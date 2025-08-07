import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paten/home_page.dart';
import 'package:paten/screen/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');
    final String? username = prefs.getString('username');

    // Introduce a slight delay to make the splash screen visible
    await Future.delayed(const Duration(seconds: 2));

    if (accessToken != null && username != null) {
      // If an access token and username are found, navigate to the HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      // If no token is found, navigate to the LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // You can add a logo or a progress indicator here
        child: CircularProgressIndicator(),
      ),
    );
  }
}
