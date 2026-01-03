import 'dart:io' show Platform;

class ApiConfig {
  // ========================================
  // 🔥 TOGGLE INI SESUAI DEVICE YANG DIPAKAI
  // ========================================
  // true  = Emulator Android Studio (teman)
  // false = Real Device via USB (kamu)
  static const bool USE_EMULATOR = false;
  
  static const String baseUrl = String.fromEnvironment('BASE_URL');

  static String get resolvedBaseUrl {
    // PRIORITAS: jika diberikan dari --dart-define
    if (baseUrl.isNotEmpty) return baseUrl;

    try {
      // ANDROID
      if (Platform.isAndroid) {
        return USE_EMULATOR 
            ? "http://10.0.2.2:8080"       // Emulator (10.0.2.2)
            : "http://localhost:8080";     // Real device (localhost + adb reverse)
      }

      // iOS SIMULATOR
      if (Platform.isIOS) {
        return "http://localhost:8080";
      }

      // WINDOWS / MAC / LINUX (termasuk Flutter WEB)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return "http://localhost:8080";
      }
    } catch (_) {
      // KALAU WEB (tidak ada Platform)
      return "http://localhost:8080";
    }

    return "http://localhost:8080";
  }
}
