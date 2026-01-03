import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../state/toko_controller.dart';

class PilihTokoPopup extends StatelessWidget {
  const PilihTokoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final tokoCtrl = context.watch<TokoController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Pilih Toko untuk Transaksi",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List toko
              if (tokoCtrl.items.isEmpty)
                Text(
                  "Belum ada toko tersedia",
                  style: GoogleFonts.poppins(),
                )
              else
                ...tokoCtrl.items.map((toko) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () async {
                        // Set toko yang dipilih
                        tokoCtrl.setSelectedToko(toko);

                        // Simpan toko yang dipilih ke SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt("toko_id", toko.id!);
                        // Tutup popup
                        if (context.mounted) {
                          Navigator.of(context).pop(toko);
                        }
                      },
                      child: Text(
                        toko.namaToko,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 12),

              // Cancel
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  "Batal",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
