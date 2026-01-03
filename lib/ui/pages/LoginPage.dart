import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
import '../../data/services/auth_service.dart';
import '../../ui/pages/dashboardPage.dart';
import '../widgets/button.dart';
import '../widgets/notif_popup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  OutlineInputBorder _rounded(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: c, width: 1),
  );

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    required Color iconColor,
    Widget? suffix,
    required Color fieldFill,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: _rounded(Colors.transparent),
      enabledBorder: _rounded(Colors.transparent),
      focusedBorder: _rounded(Colors.transparent),
      errorBorder: _rounded(AppTheme.error),
      focusedErrorBorder: _rounded(AppTheme.error),
    );
  }

  String? _vUsername(String? v) {
    final x = v?.trim() ?? '';
    if (x.isEmpty) return 'Username tidak boleh kosong';
    final re = RegExp(
        r'^(?=.{3,20}$)(?![._-])(?!.*[._-]{2})[a-zA-Z0-9._-]+(?<![._-])$');
    if (!re.hasMatch(x)) {
      return 'Gunakan 3–20 karakter: huruf/angka . _ - (tidak boleh diawali/diakhiri simbol)';
    }
    return null;
  }

  String? _vPass(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final request = LoginRequest(
      username: _username.text.trim(),
      password: _pass.text.trim(),
    );

    try {
      final LoginResponse response = await _authService.login(request);

      if (response.token != null && response.token!.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", response.token!);
        await prefs.setString("role", response.role ?? "");

        // ===== Simpan selected_toko_id untuk KASIR =====
        if ((response.role ?? "").toLowerCase() == "kasir") {
          await prefs.setInt("toko_id", response.tokoId!);
        } else if ((response.role ?? "").toLowerCase() == "admin") {
          await prefs.remove("toko_id"); // biar popup pilih toko muncul
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(showLoginSuccess: true),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau password salah.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal login: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    final topH = size.height * 0.42;

    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ===== HEADER MERAH =====
            Container(
              height: topH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.primaryRed.withOpacity(0.95),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),

            // ===== PANEL LOGO =====
            Positioned(
              top: 64,
              left: 20,
              right: 20,
              child: SizedBox(
                height: 314,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    color: AppTheme.primaryCream.withOpacity(.45),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        const Positioned(
                          top: 0,
                          child: SizedBox(
                            width: 146,
                            height: 146,
                            child: Image(
                              image: AssetImage('assets/images/logo3.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 146,
                          child: Text(
                            'Kasir maadura',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryRed,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== PANEL KREM (FORM LOGIN) =====
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryCream,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(38),
                    topRight: Radius.circular(38),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        Text(
                          'Username',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: Key('login_username_field'),
                          controller: _username,
                          decoration: _dec(
                            hint: 'Enter your Username',
                            icon: Icons.person_outline_rounded,
                            iconColor: AppTheme.textPrimary,
                            fieldFill: cs.surface,
                          ),
                          validator: _vUsername,
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Password',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: Key('login_password_field'),
                          controller: _pass,
                          obscureText: _obscure,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: _dec(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            iconColor: AppTheme.textPrimary,
                            fieldFill: cs.surface,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          validator: _vPass,
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.forgot),
                            child: Text(
                              'Forgot your password?',
                              style: text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Button(
                          key: Key('login_button'), // ← tambahkan di sini
                          label: 'Login',
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                "Don’t have an account?",
                                style: text.bodyMedium?.copyWith(color: cs.onSurface),
                              ),
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                  child: Text(
                                    "Sign Up",
                                    style: text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
