import 'package:flutter/foundation.dart';
import '../data/models/product.dart';
import '../data/services/product_service.dart';
import 'dart:io';

class ProductController extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _items = [];
  List<Product> get items => _items;

  bool isLoading = false;

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      _items = await _service.getProducts();
    } catch (e) {
      print("Gagal load produk: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= ADD PRODUCT =================
  Future<bool> add(Product p, File imageFile) async {
    try {
      final ok = await _service.addProduct(
        imageFile: imageFile,
        nama: p.nama,
        hargaJual: p.hargaJual,
        stok: p.stok,
        satuan: p.satuan,
      );

      if (ok) {
        await loadProducts();
        return true;
      }

      print("Gagal tambah produk");
      return false;
    } catch (e) {
      print("Error add product: $e");
      return false;
    }
  }

  // ================= UPDATE PRODUCT =================
  Future<bool> update(Product p, {File? imageFile}) async {
    try {
      final ok = await _service.updateProduct(
        id: p.id,
        nama: p.nama,
        hargaJual: p.hargaJual,
        stok: p.stok,
        satuan: p.satuan,
        imageFile: imageFile,
      );

      if (ok) {
        await loadProducts();
        return true;
      }

      print("Gagal update produk");
      return false;
    } catch (e) {
      print("Error update: $e");
      return false;
    }
  }

  // ================= DELETE PRODUCT =================
  Future<bool> delete(int id) async {
    try {
      final ok = await _service.deleteProduct(id);

      if (ok) {
        _items.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }

      print("Gagal hapus produk");
      return false;
    } catch (e) {
      print("Error delete: $e");
      return false;
    }
  }
}
