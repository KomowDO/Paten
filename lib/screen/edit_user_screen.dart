import 'package:flutter/material.dart';
import 'package:paten/providers/edit_user_provider.dart';
import 'package:provider/provider.dart';

class EditUserScreen extends StatelessWidget {
  const EditUserScreen({super.key});

  // Helper method untuk dekorasi input
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditUserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Pengguna RT/RW'),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            centerTitle: true,
          ),
          body: provider.isDataLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Form(
                    key: provider.formKey,
                    child: ListView(
                      children: [
                        // -- SEMUA KOLOM ISIAN --
                        TextFormField(
                          controller: provider.nikController,
                          decoration: _inputDecoration('NIK'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.namaController,
                          decoration: _inputDecoration('Nama'),
                          validator: (v) =>
                              v!.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.alamatController,
                          decoration: _inputDecoration('Alamat'),
                          validator: (v) =>
                              v!.isEmpty ? 'Alamat wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.teleponController,
                          decoration: _inputDecoration('No. WA'),
                          validator: (v) =>
                              v!.isEmpty ? 'No. WA wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.wilayahRtController,
                          decoration: _inputDecoration('RT'),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'RT wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.wilayahRwController,
                          decoration: _inputDecoration('RW'),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'RW wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: provider.selectedJabatan,
                          decoration: _inputDecoration('Jabatan'),
                          items: provider.jabatanOptions.map((jabatan) {
                            return DropdownMenuItem(
                              value: jabatan,
                              child: Text(jabatan),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              provider.setSelectedJabatan(value),
                          validator: (v) =>
                              v == null ? 'Jabatan wajib dipilih' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.jabatanMulaiController,
                          decoration: _inputDecoration(
                            'Jabatan Mulai (dd/MM/yyyy)',
                          ),
                          readOnly: true,
                          onTap: () => provider.selectDate(context, true),
                          validator: (v) =>
                              v!.isEmpty ? 'Tanggal mulai wajib diisi' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: provider.jabatanAkhirController,
                          decoration: _inputDecoration(
                            'Jabatan Akhir (dd/MM/yyyy)',
                          ),
                          readOnly: true,
                          onTap: () => provider.selectDate(context, false),
                          validator: (v) =>
                              v!.isEmpty ? 'Tanggal akhir wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => provider.simpanData(
                                  context,
                                  () => Navigator.of(context).pop(true),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF03038E,
                            ), // Warna biru gelap
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Simpan'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
