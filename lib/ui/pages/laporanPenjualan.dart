import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../data/services/laporan_service.dart';
import '../../data/models/laporan_harian.dart';
import '../widgets/laporan_card.dart';
import '../../core/role_helper.dart';

class LaporanPenjualanPage extends StatefulWidget {
  const LaporanPenjualanPage({super.key});

  @override
  State<LaporanPenjualanPage> createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  final LaporanService _service = LaporanService();

  List<DailyReport> _reports = [];
  List<String> _tokoList = [];

  bool _isLoading = false;
  String? _error;

  String? _selectedToko;
  DateTime? _selectedTanggal;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final isAdmin = await RoleHelper.isAdmin();
    if (!isAdmin && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses ditolak. Halaman ini khusus untuk Admin.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    _tokoList = await _service.fetchAllTokoNames();
    if (_tokoList.isNotEmpty) _selectedToko = _tokoList.first;

    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.fetchLaporan(
        tanggal: _selectedTanggal,
        tokoNama: _selectedToko,
      );
      setState(() => _reports = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedTanggal = picked);
      _fetchLaporan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryCream,

      // =====================
      // APP BAR (FINAL CLEAN)
      // =====================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),

        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.primaryCream,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Laporan Penjualan',
              style: GoogleFonts.poppins(
                color: AppTheme.primaryCream,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        // =====================
        // FILTER (TOKO + TANGGAL)
        // =====================
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                // Dropdown toko
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedToko,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _tokoList.map((toko) {
                      return DropdownMenuItem(
                        value: toko,
                        child: Text(toko),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedToko = val);
                      _fetchLaporan();
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Date picker
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTanggal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedTanggal != null
                            ? "${_selectedTanggal!.day.toString().padLeft(2, '0')}-"
                            "${_selectedTanggal!.month.toString().padLeft(2, '0')}-"
                            "${_selectedTanggal!.year}"
                            : "Pilih tanggal",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // =====================
      // BODY
      // =====================
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          "Gagal memuat laporan:\n$_error",
          textAlign: TextAlign.center,
          style: t.bodyMedium?.copyWith(color: Colors.red),
        ),
      )
          : _reports.isEmpty
          ? Center(
        child: Text(
          'Tidak ada laporan penjualan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.textSubtle,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchLaporan,
        child: ListView.builder(
          padding:
          const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: _reports.length,
          itemBuilder: (context, i) {
            final day = _reports[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day.tanggal,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Rp${day.totalHarian.toInt()}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...day.transaksi.map(
                      (trx) => LaporanCard(transaksi: trx),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}
