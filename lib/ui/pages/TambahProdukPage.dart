import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../data/models/product.dart';
import 'TambahEditProduk.dart';
import '../../state/product_controller.dart';
import '../widgets/search_field.dart';


class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final TextEditingController _searchC = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    // ambil controller setelah widget selesai build
    Future.microtask(() {
      final ctrl = context.read<ProductController>();
      ctrl.loadProducts();   // ⬅ WAJIB supaya produk dari backend muncul
    });
  }


  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryCream,
      body: Column(
        children: [
          // ===== HEADER MIRIP LAPORAN PENJUALAN =====
          PreferredSize(
            preferredSize: const Size.fromHeight(180),
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(50)),
              child: Container(
                decoration:
                const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 8,
                              top: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppTheme.primaryCream,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                'Produk',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryCream,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==== SEARCH ====
                      const SizedBox(height: 15),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: SearchField(
                          hintText: 'Cari',
                          controller: _searchC,
                          onChanged: (value) {
                            setState(() {
                              _query = value.trim().toLowerCase();
                            });
                          },
                          onClear: () {
                            setState(() {
                              _query = '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ======== LIST PRODUK =========
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryRed,
              onRefresh: () async {
                await context.read<ProductController>().loadProducts();
              },
              child: Consumer<ProductController>(
                builder: (context, ctrl, _) {
                  final all = ctrl.items;
                  final items = _query.isEmpty
                      ? all
                      : all.where((p) => p.nama.toLowerCase().contains(_query)).toList();

                  if (items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            _query.isEmpty
                                ? 'Belum ada produk'
                                : 'Produk tidak ditemukan',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppTheme.textSubtle,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      const _TableHeaderStrip(),
                      Expanded(
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(
                            color: AppTheme.border,
                            thickness: 1,
                            height: 16,
                          ),
                          itemBuilder: (_, i) {
                            final p = items[i];
                            return _ProductRow(
                              product: p,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => TambahEditProduk(product: p)),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ===== TOMBOL TAMBAH PRODUK =====
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: _PrimaryGradientButton(
              label: 'Tambah barang',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TambahEditProduk()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Header gradient seperti desain: ada tombol back, judul, dan search box.
class _HeaderArea extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  final VoidCallback onBack;
  final ValueChanged<String>? onChanged;

  const _HeaderArea({
    required this.title,
    required this.searchController,
    required this.onBack,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPad + 16, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Row back + title center
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppTheme.primaryWhite,
                ),
              ),
              Text(
                title,
                style: t.headlineSmall?.copyWith(
                  color: AppTheme.primaryWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search box
          TextField(
            controller: searchController,
            onChanged: onChanged,
            decoration: const InputDecoration(
              hintText: 'Cari',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}

/// Strip header tabel: Produk | Harga | Stok dengan bayangan halus di bawahnya.
class _TableHeaderStrip extends StatelessWidget {
  const _TableHeaderStrip();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.primaryCream,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 32.4,
            offset: Offset(0, 4),
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              'Produk',
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Harga',
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Stok',
              textAlign: TextAlign.right,
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 44), // ruang untuk tombol Edit
        ],
      ),
    );
  }
}

/// Baris produk sesuai desain, dengan tombol "Edit" merah di kanan.
/// Baris produk sesuai desain, dengan tombol "Edit" merah di kanan.
class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const _ProductRow({
    required this.product,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // PRODUK
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              product.nama,
              style: t.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ),

        // HARGA (tengah & tanpa .0)
        Expanded(
          flex: 3,
          child: Text(
            product.hargaJual.toInt().toString(),
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: AppTheme.textPrimary),
          ),
        ),

        // STOK (kanan)
        Expanded(
          flex: 2,
          child: Text(
            product.stok.toString(),
            textAlign: TextAlign.right,
            style: t.bodyMedium?.copyWith(color: AppTheme.textPrimary),
          ),
        ),

        const SizedBox(width: 8),

        // BUTTON EDIT
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_outlined,
                    size: 18, color: AppTheme.primaryRed),
                const SizedBox(width: 4),
                Text(
                  'Edit',
                  style: t.bodySmall?.copyWith(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


/// Empty state sederhana.
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Belum ada produk', style: t.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk pertama kamu dengan tombol di bawah.',
              style: t.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRefresh, child: const Text('Muat ulang')),
          ],
        ),
      ),
    );
  }
}

/// Tombol gradient utama (sesuai desain "Tambah barang")
class _PrimaryGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryGradientButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        child: Center(
          child: Text(
            label,
            style: t.titleMedium?.copyWith(
              color: AppTheme.primaryWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
