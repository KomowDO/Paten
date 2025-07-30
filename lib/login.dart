import "package:flutter/material.dart";

class GridBackground extends CustomPainter {
  final Color gridColor;
  final double spacing;

  GridBackground({
    this.gridColor = const Color(0xFFE0E7FF),
    this.spacing = 20.0,
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
    return false; // Only repaint if properties change
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

  void _login() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login berhasil!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tambahkan gambar di atas form login
            Image.asset(
              'lib/img/logo-paten.png', // Path sesuai struktur folder Anda
              height: 120,
            ),
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
                  backgroundColor: const Color(
                    0xFF03038E,
                  ), // Solid dark blue background
                  foregroundColor: Colors.white, // Set text/icon color to white
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 255, 255, 255),
                      )
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
