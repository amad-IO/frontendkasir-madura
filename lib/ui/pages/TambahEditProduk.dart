import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../core/image_validator.dart';
import '../../data/models/product.dart';
import '../../state/product_controller.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/notif_popup.dart';
import '../widgets/dialog_confirm.dart';

class TambahEditProduk extends StatefulWidget {
  final Product? product;
  const TambahEditProduk({super.key, this.product});

  @override
  State<TambahEditProduk> createState() => _TambahEditProdukState();
}

class _TambahEditProdukState extends State<TambahEditProduk> {
  late TextEditingController namaC;
  late TextEditingController hargaC;
  late TextEditingController stokC;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isValidatingImage = false;
  String? _imageError;
  String? _imageInfo;

  // Error messages for validation
  String? _namaError;
  String? _hargaError;
  String? _stokError;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.product?.nama ?? '');
    hargaC = TextEditingController(
      text: widget.product != null
          ? widget.product!.hargaJual.toInt().toString()
          : '',
    );
    stokC = TextEditingController(text: widget.product?.stok.toString() ?? '');
  }

  @override
  void dispose() {
    namaC.dispose();
    hargaC.dispose();
    stokC.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.primaryCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              "Validasi Gagal",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppTheme.primaryCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                isEdit ? 'Edit Produk' : 'Tambah Produk',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Produk
                  Text(
                    'Foto Produk',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF525252),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isValidatingImage
                        ? null
                        : () async {
                      final pickedFile = await _picker.pickImage(
                          source: ImageSource.gallery);

                      if (pickedFile != null) {
                        setState(() {
                          _isValidatingImage = true;
                          _imageError = null;
                          _imageInfo = null;
                        });

                        final file = File(pickedFile.path);

                        final validationResult =
                        await ImageValidator.validateImage(file);

                        setState(() {
                          _isValidatingImage = false;

                          if (validationResult.isValid) {
                            _imageFile = file;
                            final fileSize = ImageValidator.formatFileSize(
                                file.lengthSync());
                            _imageInfo = fileSize;
                            _imageError = null;
                          } else {
                            _imageFile = null;
                            _imageError = validationResult.errorMessage;
                          }
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                        border: _imageError != null
                            ? Border.all(color: Colors.red.shade300, width: 2)
                            : _imageFile != null
                            ? Border.all(
                            color: Colors.green.shade400, width: 2)
                            : Border.all(
                            color: Colors.grey.shade300, width: 2),
                      ),
                      child: _isValidatingImage
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryOrange),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Memvalidasi gambar...',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSubtle,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                          : _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : (widget.product != null &&
                          widget.product!.imageName.isNotEmpty)
                          ? FutureBuilder(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child:
                                CircularProgressIndicator());
                          }

                          final token = snap.data!
                              .getString("jwt_token") ??
                              "";
                          final url =
                              "http://localhost:8080/api/produk/gambar/${widget.product!.imageName}";

                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            headers: {
                              "Authorization": "Bearer $token",
                            },
                          );
                        },
                      )
                          : Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 50,
                              color: AppTheme.primaryOrange,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap untuk pilih gambar',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF525252),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG, PNG • Max 5 MB',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSubtle,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_imageInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _imageInfo!,
                            style: GoogleFonts.poppins(
                              color: Colors.green.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_imageError != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _imageError!,
                              style: GoogleFonts.poppins(
                                color: Colors.red.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),

                  if (isEdit)
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDeleteConfirmDialog(
                            context,
                            itemName: 'produk "${widget.product!.nama}"',
                          );

                          if (confirm == true) {
                            final ctrl = context.read<ProductController>();
                            final ok = await ctrl.delete(widget.product!.id);

                            if (ok) {
                              Navigator.pop(context);

                              Future.delayed(
                                  const Duration(milliseconds: 300), () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => NotifPopup.success(
                                      context, "Produk berhasil dihapus"),
                                );
                              });
                            }
                          }
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        label: Text(
                          'Hapus Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(
                            color: Colors.red.shade300,
                            width: 1.5,
                          ),
                          backgroundColor: Colors.red.shade50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Informasi Produk
                  Text(
                    'Informasi Produk',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF525252),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _InputField(
                    label: 'Nama Produk',
                    hint: 'Input nama produk anda',
                    icon: Icons.fastfood_rounded,
                    controller: namaC,
                    errorText: _namaError,
                  ),
                  const SizedBox(height: 20),

                  _InputField(
                    label: 'Harga Produk',
                    hint: 'Input harga produk',
                    icon: Icons.attach_money_rounded,
                    controller: hargaC,
                    keyboardType: TextInputType.number,
                    errorText: _hargaError,
                  ),
                  const SizedBox(height: 20),

                  _InputField(
                    label: 'Jumlah Stok',
                    hint: 'Input jumlah stok anda',
                    icon: Icons.inventory_2_rounded,
                    controller: stokC,
                    keyboardType: TextInputType.number,
                    errorText: _stokError,
                  ),
                  const SizedBox(height: 40),

                  // Tombol Simpan Produk
                  Center(
                    child: InkWell(
                      onTap: () async {
                        // Reset error messages
                        setState(() {
                          _namaError = null;
                          _hargaError = null;
                          _stokError = null;
                        });

                        final nama = namaC.text.trim();
                        final harga =
                            int.tryParse(hargaC.text.trim())?.toDouble() ?? 0;
                        final stok = int.tryParse(stokC.text.trim()) ?? 0;

                        bool hasError = false;

                        if (nama.isEmpty) {
                          setState(() {
                            _namaError = 'Nama produk tidak boleh kosong!';
                          });
                          hasError = true;
                        }

                        if (harga <= 0) {
                          setState(() {
                            _hargaError = 'Harga produk harus lebih dari 0!';
                          });
                          hasError = true;
                        }

                        if (stok < 0) {
                          setState(() {
                            _stokError = 'Stok tidak boleh negatif!';
                          });
                          hasError = true;
                        }

                        if (hasError) return;

                        // Ambil role & selected_toko_id dari SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        final role = prefs.getString("role") ?? "KASIR";
                        final tokoId = prefs.getInt("toko_id");

                        if (role == "ADMIN" && (tokoId == null || tokoId == 0)) {
                          _showErrorDialog("Toko belum dipilih");
                          return;
                        }

                        if (!isEdit && _imageFile == null) {
                          setState(() {
                            _imageError = 'Gambar produk wajib diisi!';
                          });
                          return;
                        }

                        final ctrl = context.read<ProductController>();
                        bool success = false;

                        if (isEdit) {
                          final updated = Product(
                            id: widget.product!.id,
                            nama: nama,
                            hargaJual: harga,
                            stok: stok,
                            satuan: widget.product!.satuan,
                            imageName: widget.product!.imageName,
                          );

                          success = await ctrl.update(
                            updated,
                            imageFile: _imageFile,
                          );


                        } else {
                          final baru = Product(
                            id: 0,
                            nama: nama,
                            hargaJual: harga,
                            stok: stok,
                            satuan: "pcs",
                            imageName: "",
                          );

                          success = await ctrl.add(baru, _imageFile!);
                        }

                        if (!success) return;

                        Navigator.pop(context);

                        Future.delayed(const Duration(milliseconds: 300), () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => NotifPopup.success(
                              context,
                              isEdit
                                  ? "Produk berhasil diperbarui"
                                  : "Produk berhasil ditambahkan",
                            ),
                          );
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isEdit ? 'Perbarui Produk' : 'Simpan Produk',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET INPUT FIELD
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF525252),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppTheme.textSubtle,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color:
              errorText != null ? Colors.red.shade400 : AppTheme.primaryOrange,
              size: 22,
            ),
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red.shade300
                    : AppTheme.primaryOrange.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1.5,
              ),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText!,
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
