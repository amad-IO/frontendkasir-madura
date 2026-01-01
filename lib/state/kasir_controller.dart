import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/kasir.dart';
import '../data/services/toko_service.dart';
import '../../core/api_config.dart';

class KasirController extends ChangeNotifier {
  late Dio _dio;

  KasirController() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.resolvedBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // AUTO PASANG JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("jwt_token");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  List<Kasir> items = [];
  bool loading = false;

  // =====================================================
  // GET ALL USERS + JOIN TOKO
  // =====================================================
  Future<void> load() async {
    loading = true;
    notifyListeners();

    items.clear();

    try {
      final res = await _dio.get("/api/users");
      print("HASIL API USERS: ${res.data}");

      final users = (res.data as List)
          .map((e) => Kasir.fromJson(e))
          .toList();

      final tokoService = TokoService();

      // LOOP semua user
      for (final user in users) {
        // Jika BUKAN kasir, langsung masukkan
        if (user.role != "KASIR" || user.id == null) {
          items.add(user);
          continue;
        }

        // Jika KASIR → ambil tokonya
        final toko = await tokoService.getTokoByKasir(user.id!);

        if (toko != null) {
          // Buat kasir baru (join toko)
          final updatedKasir = Kasir(
            id: user.id,
            username: user.username,
            phone: user.phone,
            role: user.role,

            // ini data toko
            tokoId: toko.id,
            namaToko: toko.namaToko,
            alamatToko: toko.alamat,
          );

          items.add(updatedKasir);
        } else {
          // Kasir BELUM punya toko
          items.add(user);
        }
      }

    } catch (e) {
      print("Load error: $e");
    }

    loading = false;
    notifyListeners();
  }

  // =====================================================
  // ADD KASIR
  // =====================================================
  Future<bool> tambahKasir(String nama, String phone, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) throw Exception("Token tidak ditemukan");

      final res = await _dio.post(
        "/api/users/add",
        data: {
          "username": nama,
          "phone": phone,
          "password": password,
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      items.add(Kasir.fromJson(res.data));
      notifyListeners();
      return true;

    } catch (e) {
      print("TambahKasir ERROR: $e");
      return false;
    }
  }

  Future<bool> deleteKasir(int kasirId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      await _dio.delete(
        "/api/users/delete/$kasirId",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      await load(); // reload ulang list
      return true;

    } catch (e) {
      print("Delete kasir error: $e");
      return false;
    }
  }

  Future<bool> updateKasir(int id, String nama, String telp) async {
    try {
      loading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      final response = await _dio.put(
        "/api/users/update/$id",
        data: {
          "username": nama,
          "phone": telp,
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        await load(); // refresh daftar kasir
        return true;
      }
      return false;
    } catch (e) {
      print("Update kasir error: $e");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }





}