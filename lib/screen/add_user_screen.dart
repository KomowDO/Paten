import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paten/providers/add_user_provider.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddUserProvider(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Tambah Pengguna RT/RW'),
        ),
        body: Consumer<AddUserProvider>(
          builder: (context, provider, child) {
            return _buildForm(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddUserProvider provider) {
    final _formKey = GlobalKey<FormState>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<DomisiliStatus>(
                      title: const Text('Dalam Kota'),
                      value: DomisiliStatus.dalamKota,
                      groupValue: provider.domisiliStatus,
                      onChanged: provider.setDomisiliStatus,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<DomisiliStatus>(
                      title: const Text('Luar Kota'),
                      value: DomisiliStatus.luarKota,
                      groupValue: provider.domisiliStatus,
                      onChanged: provider.setDomisiliStatus,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: provider.nikController,
                      label: 'NIK',
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  if (provider.domisiliStatus == DomisiliStatus.dalamKota)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final result = await provider.checkNik();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ??
                                          'Pesan tidak diketahui.',
                                    ),
                                    backgroundColor: result['success'] == true
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                );
                              },
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Cek NIK'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),

              _buildTextField(
                controller: provider.namaController,
                label: 'Nama',
                isRequired: true,
              ),
              const SizedBox(height: 16.0),

              _buildTextField(
                controller: provider.alamatController,
                label: 'Alamat',
                isRequired: true,
                maxLines: 2,
              ),
              const SizedBox(height: 16.0),

              _buildTextField(
                controller: provider.teleponController,
                label: 'No. Telp/WA',
                isRequired: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16.0),

              provider.isJabatanLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (provider.jabatanOptions.isEmpty
                        ? const Text('Tidak ada opsi jabatan tersedia.')
                        : _buildDropdownField(
                            label: 'Jabatan',
                            options: provider.jabatanOptions,
                            selectedValue: provider.selectedNamaJabatan,
                            onChanged: provider.setSelectedJabatan,
                          )),
              const SizedBox(height: 16.0),

              _buildTextField(
                controller: provider.wilayahRtController,
                label: 'Wilayah RT',
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              _buildTextField(
                controller: provider.wilayahRwController,
                label: 'Wilayah RW',
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              _buildDateField(
                controller: provider.jabatanMulaiController,
                label: 'Jabatan Mulai',
                onTap: () => provider.selectDate(context, true),
              ),
              const SizedBox(height: 16.0),

              _buildDateField(
                controller: provider.jabatanAkhirController,
                label: 'Jabatan Akhir',
                onTap: () => provider.selectDate(context, false),
              ),
              const SizedBox(height: 32.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF03038E),
                      side: const BorderSide(
                        color: Color(0xFF03038E),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final result = await provider.simpanData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ??
                                          'Pesan tidak diketahui',
                                    ),
                                    backgroundColor: result['success'] == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                                if (result['success'] == true) {
                                  Navigator.of(context).pop(true);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03038E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: 'Masukkan $label',
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: 'Pilih $label',
      ),
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: 'Pilih $label',
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
