import 'package:flutter/material.dart';
import 'package:paten/models/user_thl.dart';

class THLUserCard extends StatelessWidget {
  final UserTHL user;
  final VoidCallback? onTap; // untuk navigasi ke detail

  const THLUserCard({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isActive = user.status == "1";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ), // Margin disesuaikan sedikit
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // --- Bagian Kiri (Nama dan NIP) ---
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
                    Text(
                      "NIP: ${user.nip ?? '-'}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
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
