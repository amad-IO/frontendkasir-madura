import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_request.dart';
import '../../core/auth_helper.dart';
import '../../core/api_config.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({required this.success, required this.message, this.data});
}

class UserService {
  String get baseUrl => '${ApiConfig.resolvedBaseUrl}/api/users';

  /// ==============================
  /// CREATE USER (AUTOMATIC KASIR)
  /// ==============================
  Future<ApiResponse> createUser(UserRequest request) async {
    final token = await AuthHelper.getToken() ?? "";

    final url = Uri.parse("$baseUrl/add"); // endpoint sesuai controller

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // WAJIB TOKEN
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return ApiResponse(
        success: true,
        message: "User berhasil ditambahkan",
        data: json,
      );
    }

    return ApiResponse(
      success: false,
      message: "Gagal menambah user (${response.statusCode}): ${response.body}",
    );
  }
}
