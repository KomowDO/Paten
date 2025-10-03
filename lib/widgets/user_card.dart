import 'package:flutter/material.dart';
import 'package:paten/models/user.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap; // untuk navigasi ke detail

  const UserCard({super.key, required this.user, this.onTap});

  // Format tanggal
  String _formatDateForDisplay(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == '0000-00-00') {
      return '-';
    }

    try {
      final dateOnly = dateString.substring(0, 10);
      final dateTime = DateFormat('yyyy-MM-dd').parse(dateOnly);
      return DateFormat('dd/MM/yyyy', 'id').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Launch WhatsApp
  Future<void> _launchWhatsApp(String phone) async {
    final formattedPhone = formatPhoneNumberForWA(phone);
    final phoneForUrl = formattedPhone.replaceAll('+', '');
    final waUrl = Uri.parse(
      'https://wa.me/$phoneForUrl?text=${Uri.encodeComponent('Halo, saya ingin menghubungi Anda.')}',
    );

    if (!await launchUrl(waUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = user.status == "1";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // --- Bagian Kiri (Info Utama User) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nama ?? "Tidak ada nama",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text("${user.nik ?? '-'}", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.nama_jabatan ?? '-'} ",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Expanded(
                          child: Text(
                            "(${_formatDateForDisplay(user.jabatan_mulai)} - ${_formatDateForDisplay(user.jabatan_akhir)})",
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "RT ${user.rt ?? '-'} / RW ${user.rw ?? '-'}",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Kec. ${user.kecamatan ?? '-'}, Kel. ${user.kelurahan ?? '-'}",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    if (user.no_wa != null && user.no_wa!.isNotEmpty)
                      InkWell(
                        onTap: () => _launchWhatsApp(user.no_wa!),
                        child: Row(
                          children: [
                            Text(user.no_wa!, style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                      )
                    else
                      Text("WA: -", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // --- Bagian Kanan (Status Chip) ---
              Chip(
                avatar: Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 16,
                ),
                label: Text(
                  isActive ? "Aktif" : "Nonaktif",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: isActive
                    ? Colors.green.shade600
                    : Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper untuk format nomor WA jadi +62
String formatPhoneNumberForWA(String rawPhone) {
  var phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

  if (phone.startsWith('0')) {
    phone = '+62${phone.substring(1)}';
  } else if (phone.startsWith('62')) {
    phone = '+$phone';
  }

  return phone;
}
