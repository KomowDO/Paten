import "package:flutter/material.dart";
import 'package:paten/services/api_service.dart';
import '../home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kelas CustomPainter untuk background grid
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

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Username dan password tidak boleh kosong.';
      });
      return;
    }

    final apiService = ApiService();

    try {
      final result = await apiService.login(username, password);

      if (result['success']) {
        final String? accessToken = result['access_token'];

        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('username', username);
          print('Login berhasil! Access Token disimpan.');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Login berhasil!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(username: username),
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                'Login berhasil, tapi Access Token tidak ditemukan.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              result['message'] ?? 'Login gagal. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Penting: Mematikan resizeToAvoidBottomInset untuk mencegah Scaffold mengubah ukuran.
      // Dengan begini, background dan footer akan tetap statis, dan kita akan menangani konten
      // login secara manual di dalam SingleChildScrollView.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background gambar
          Positioned.fill(
            child: Image.asset(
              'lib/img/bg-login-mobile.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -10,
            left: -50,
            child: Image.asset('lib/img/cover-pattern.png', fit: BoxFit.cover),
          ),
          // Konten halaman utama
          SafeArea(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Dapatkan tinggi keyboard
                  final keyboardHeight = MediaQuery.of(
                    context,
                  ).viewInsets.bottom;
                  // Hitung tinggi layar yang tersedia (dikurangi padding dan keyboard)
                  final availableHeight =
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      keyboardHeight;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          availableHeight, // Atur minHeight ke tinggi yang tersedia
                    ),
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
                          // Kolom password dengan toggle visibilitas
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
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
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text('Login'),
                            ),
                          ),
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
