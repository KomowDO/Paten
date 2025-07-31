import "package:flutter/material.dart";
import 'package:paten/api_service.dart';
import 'home_page.dart'; // Pastikan path ini benar
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan token (opsional)

// CustomPainter untuk background grid
class GridBackground extends CustomPainter {
  final Color gridColor;
  final double spacing;

  GridBackground({
    this.gridColor = const Color(0xFFE0E7FF),
    this.spacing = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines (perbaikan typo sebelumnya)
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Hanya repaint jika properti berubah
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = ''; // Variabel untuk menampilkan pesan error di UI

  void _login() async {
    // Reset pesan error dan set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Bersihkan pesan error sebelumnya
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    final apiService = ApiService();
    // Panggil metode login dari ApiService
    final result = await apiService.login(username, password);

    // Setelah request selesai, set loading state kembali false
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Login berhasil, Anda bisa mengakses access_token di sini
      final String? accessToken = result['access_token'];
      if (accessToken != null) {
        print('Login berhasil! Access Token: $accessToken');
        // Contoh: Menyimpan token menggunakan shared_preferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          print('Access Token berhasil disimpan.');
        } catch (e) {
          print('Gagal menyimpan Access Token: $e');
        }
      } else {
        print(
          'Login berhasil, tapi Access Token tidak ditemukan dalam respons.',
        );
      }

      // Tampilkan SnackBar sukses dan navigasi ke halaman berikutnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login berhasil!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      // Login gagal atau ada error, tampilkan pesan error
      setState(() {
        _errorMessage = result['message'] ?? 'Login gagal. Silakan coba lagi.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF03038E), // Warna AppBar
        foregroundColor: Colors.white, // Warna teks AppBar
      ),
      body: CustomPaint(
        painter: GridBackground(), // Gunakan painter untuk background grid
        child: SafeArea(
          // Memastikan konten tidak tumpang tindih dengan area sistem
          child: SingleChildScrollView(
            // Memungkinkan scrolling jika konten melebihi layar
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/img/logo-paten.png', height: 120),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03038E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login'),
                    ),
                  ),
                  // Menampilkan pesan error di UI utama
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ), // Memberikan sedikit ruang di bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
