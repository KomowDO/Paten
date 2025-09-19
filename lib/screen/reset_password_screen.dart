// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Admin Panel',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const ResetPasswordScreen(),
//     );
//   }
// }

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nikController = TextEditingController();

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nikController.dispose();
//     super.dispose();
//   }

//   // Fungsi untuk mensimulasikan proses reset password oleh admin
//   void _resetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true; // Menampilkan loading indicator
//       });

//       // Anda bisa menentukan password default di sini.
//       // Contoh: menggunakan tanggal lahir pengguna atau string standar.
//       const String defaultPassword =
//           'password123'; // Password default yang akan diterapkan

//       try {
//         // --- SIMULASI PEMANGGILAN BACKEND UNTUK RESET PASSWORD ---
//         // Di sini Anda akan memanggil API atau service backend Anda.
//         // Kirimkan NIK ke backend dan biarkan backend mereset password ke default.
//         print(
//           'Simulasi admin mereset password untuk NIK: ${_nikController.text} ke password default: $defaultPassword',
//         );
//         await Future.delayed(
//           const Duration(seconds: 2),
//         ); // Simulasi penundaan jaringan

//         // --- Tampilkan Dialog Konfirmasi Sukses ---
//         _showSuccessDialog(_nikController.text, defaultPassword);
//       } catch (e) {
//         // Tangani kesalahan jika reset password gagal (misalnya NIK tidak ditemukan)
//         print('Error simulasi reset password: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Terjadi kesalahan saat mereset password: ${e.toString()}. Pastikan NIK benar.',
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false; // Menyembunyikan loading indicator
//         });
//       }
//     }
//   }

//   // Fungsi untuk menampilkan dialog sukses setelah reset
//   void _showSuccessDialog(String nik, String defaultPass) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // User harus menekan OK
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Reset Password Berhasil!'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Password untuk NIK $nik telah berhasil direset.'),
//               const SizedBox(height: 8),
//               Text('Password default baru adalah: "$defaultPass"'),
//               const SizedBox(height: 16),
//               const Text(
//                 'Harap informasikan kepada pengguna untuk segera mengganti password default ini.',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Tutup dialog
//                 _nikController.clear(); // Bersihkan input NIK
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Reset Password',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF03038E), // Warna biru gelap
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ), // Warna ikon kembali
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF03038E)),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: <Widget>[
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Masukkan NIK pengguna yang passwordnya ingin direset.',
//                       style: TextStyle(fontSize: 16.0, color: Colors.black87),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32),
//                     TextFormField(
//                       controller: _nikController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Nomor Induk Kependudukan (NIK)',
//                         hintText: 'Cth: 36xxxxxxxxxxxxxx',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF03038E),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF03038E),
//                             width: 2,
//                           ),
//                         ),
//                         prefixIcon: const Icon(
//                           Icons.credit_card,
//                           color: Color(0xFF03038E),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 16.0,
//                           horizontal: 16.0,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'NIK tidak boleh kosong';
//                         }
//                         if (value.length != 16) {
//                           return 'NIK harus terdiri dari 16 digit';
//                         }
//                         if (int.tryParse(value) == null) {
//                           return 'NIK harus berupa angka';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 40),
//                     // Tombol Reset Password
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _resetPassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(
//                             0xFF03038E,
//                           ), // Warna biru gelap
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16.0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           elevation: 5,
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.5,
//                                 ),
//                               )
//                             : const Text('Reset Password'),
//                       ),
//                     ),
//                     const SizedBox(height: 16.0),
//                     // Tombol Batal
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.of(
//                             context,
//                           ).pop(); // Kembali ke halaman sebelumnya
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: const Color(0xFF03038E),
//                           backgroundColor: Colors.white,
//                           side: const BorderSide(
//                             color: Color(0xFF03038E),
//                             width: 2,
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16.0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Text('Batal'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
