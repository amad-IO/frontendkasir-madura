import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../widgets/dialog_confirm.dart';
import '../../data/models/product.dart';
import '../../state/product_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/humberger.dart';
import '../widgets/search_field.dart';
import '../../../core/app_routes.dart';
import '../widgets/cart_bar.dart';
import '../../state/cart_controller.dart';
import '../widgets/notif_popup.dart';
import '../widgets/admin_only_widget.dart';
import '../../state/toko_controller.dart';
import 'PilihTokoPopup.dart';

class DashboardPage extends StatefulWidget {
  final bool showLoginSuccess;

  const DashboardPage({super.key, this.showLoginSuccess = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _username = '';
  String _role = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _initLoadProducts();
    });
  }

  void _showLoginSuccessIfNeeded() {
    if (!mounted || !widget.showLoginSuccess) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (ctx) => NotifPopup.success(ctx, 'Login berhasil!'),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }


// Load produk sesuai role & toko
  Future<void> _initLoadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'KASIR';
    final tokoId = prefs.getInt('toko_id');

    if (role == 'KASIR') {
      // =========================
      // KASIR
      // =========================
      if (tokoId != null) {
        context.read<TokoController>().setSelectedTokoById(tokoId);
        await context.read<ProductController>().loadProducts();

        _showLoginSuccessIfNeeded();
        // [BARU] Login popup BOLEH langsung
      }
      return;
    }

    // =========================
    // ADMIN
    // =========================
    if (tokoId == null) {
      // [PENTING] WAJIB nunggu admin pilih toko
      final selectedToko = await _showPilihTokoIfNeeded();

      if (selectedToko == null) {
        // Admin pencet BATAL → jangan ke mana2
        return;
      }

      context.read<TokoController>().setSelectedToko(selectedToko);
      await prefs.setInt('toko_id', selectedToko.id!);
    }

    await context.read<ProductController>().loadProducts();

    _showLoginSuccessIfNeeded();
    // [BARU] LOGIN POPUP MUNCUL SETELAH TOKO FIX
  }



  // ============================================================
  // CEK & TAMPILKAN POPUP PILIH TOKO UNTUK ADMIN
  // ============================================================
  Future<dynamic> _showPilihTokoIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    final tokoId = prefs.getInt('toko_id');
    // [DIUBAH] Hanya cek 'toko_id'

    if (!mounted) return null;

    if (role != 'ADMIN') return null;
    // [PENTING] BUKAN ADMIN → STOP

    if (tokoId != null) return null;
    // [PENTING] TOKO SUDAH DIPILIH → JANGAN MUNCUL LAGI

    final tokoCtrl = context.read<TokoController>();
    await tokoCtrl.loadToko();
    // [PENTING] Ambil daftar toko sebelum popup

    if (!mounted || tokoCtrl.items.isEmpty) return null;

    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      // [BARU] Biar gak ketutup popup lain (login)
      builder: (_) => const PilihTokoPopup(),
    );
  }


  // ============================================================
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _role = prefs.getString('role') ?? 'KASIR';
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryCream,
      body: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            final topPad = MediaQuery.of(context).padding.top;
            const double headerBase = 220;
            final double headerH = headerBase + topPad;

            return Stack(
              children: [
                // ===== LIST PRODUK =====
                Positioned.fill(
                  top: headerH,
                  child: Consumer<ProductController>(
                      builder: (context, ctrl, _) {
                        final filteredItems = _searchQuery.isEmpty
                            ? ctrl.items
                            : ctrl.items.where((product) {
                          final query = _searchQuery.toLowerCase();
                          return product.nama
                              .toLowerCase()
                              .contains(query);
                        }).toList();

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<ProductController>()
                                .loadProducts();
                          },
                          child: filteredItems.isEmpty
                              ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'Tidak ada produk'
                                  : 'Produk tidak ditemukan',
                              style: GoogleFonts.poppins(),
                            ),
                          )
                              : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 8, 16, 120),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (_, i) => ProductCard(
                              product: filteredItems[i],
                            ),
                          ),
                        );
                      }),
                ),

                // ===== HEADER =====
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: headerH,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -80,
                          top: topPad - 50,
                          child: Opacity(
                            opacity: 0.35,
                            child: Image.asset(
                              'assets/images/logo3.png',
                              width: 280,
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 20),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Profile
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration:
                                        const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 38,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            _username.toUpperCase(),
                                            style:
                                            GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            _role == 'ADMIN'
                                                ? 'Owner'
                                                : 'Kasir',
                                            style:
                                            GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Search
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 85, right: 20),
                                  child: ConstrainedBox(
                                    constraints:
                                    const BoxConstraints(
                                        maxWidth: 250),
                                    child: SearchField(
                                      hintText: 'Cari',
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                      onClear: () {
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Hamburger menu
                        Positioned(
                          left: 20,
                          top: topPad + 100,
                          child: GestureDetector(
                            onTap: () async {
                              showHamburgerMenu(
                                context,
                                onLaporan: () async {
                                  Navigator.pop(context);
                                  final allowed =
                                  await checkRoleBeforeNavigate(
                                    context,
                                    feature:
                                    'laporan_penjualan',
                                    adminOnly: true,
                                  );
                                  if (allowed &&
                                      context.mounted) {
                                    Navigator.pushNamed(context,
                                        AppRoutes.laporanPenjualan);
                                  }
                                },
                                onTambahToko: () async {
                                  Navigator.pop(context);
                                  final allowed =
                                  await checkRoleBeforeNavigate(
                                    context,
                                    feature: 'tambah_toko',
                                    adminOnly: true,
                                  );
                                  if (allowed &&
                                      context.mounted) {
                                    Navigator.pushNamed(context,
                                        AppRoutes.tambahToko);
                                  }
                                },
                                onEditProduk: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context,
                                      AppRoutes.editProduk);
                                },
                                onTambahPengguna: () async {
                                  Navigator.pop(context);
                                  final allowed =
                                  await checkRoleBeforeNavigate(
                                    context,
                                    feature:
                                    'tambah_pengguna',
                                    adminOnly: true,
                                  );
                                  if (allowed &&
                                      context.mounted) {
                                    Navigator.pushNamed(context,
                                        AppRoutes.tambahPengguna);
                                  }
                                },
                                onLogout: () async {
                                  final result =
                                  await showLogoutConfirmDialog(
                                      context);
                                  if (result == true) {
                                    final prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    await prefs.clear();
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      AppRoutes.login,
                                          (route) => false,
                                    );
                                  }
                                },
                              );
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== CART BAR =====
                AnimatedPositioned(
                  duration:
                  const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  left: 0,
                  right: 0,
                  bottom: context
                      .watch<CartController>()
                      .isEmpty
                      ? -120
                      : 0,
                  child: CartBar(
                    itemCount: context
                        .watch<CartController>()
                        .cartCount,
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.checkoutPage);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
