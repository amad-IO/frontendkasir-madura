import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../core/app_routes.dart';
import '../../data/services/signup_service.dart';
import '../../data/models/user_request.dart';
import '../../data/models/signup_response.dart';
import '../widgets/notif_popup.dart';
import '../widgets/button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  final _signupService = SignupService();

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  // ================= VALIDASI INPUT =================

  String? _vUsername(String? v) {
    final x = v?.trim() ?? '';
    if (x.isEmpty) return 'Username tidak boleh kosong';
    final re = RegExp(
      r'^(?=.{3,20}$)(?![._-])(?!.*[._-]{2})[a-zA-Z0-9._-]+(?<![._-])$',
    );
    if (!re.hasMatch(x)) {
      return 'Gunakan 3–20 karakter: huruf/angka . _ - (tidak boleh diawali/diakhiri simbol)';
    }
    return null;
  }

  String? _vPhone(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Nomor handphone tidak boleh kosong';
    }
    final re = RegExp(r'^(?:\+62|0)[0-9]{9,13}$');
    if (!re.hasMatch(v.trim())) {
      return 'Nomor tidak valid (contoh: 08xxxxxxxxxx)';
    }
    return null;
  }

  String? _vPass(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 8) return 'Minimal 8 karakter';
    return null;
  }

  // ================= DEKORASI INPUT =================

  OutlineInputBorder _rounded(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: c, width: 1),
  );

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    Widget? suffix,
    required Color fieldFill,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textPrimary),
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

  // ================== SUBMIT (DAFTAR) ==================
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final request = UserRequest(
      username: _username.text.trim(),
      password: _pass.text.trim(),
      phone: _phone.text.trim(),
    );

    try {
      final SignupResponse response = await _signupService.signup(request);

      // ✅ Jika berhasil daftar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => NotifPopup.success(
          context,
          response.message.isNotEmpty
              ? response.message
              : 'Pendaftaran berhasil!',
        ),
      );

      // Tunggu popup selesai animasi
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      //  Jika gagal daftar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => NotifPopup.error(context, 'Pendaftaran gagal: $e'),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================== BUILD UI ==================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final topH = MediaQuery.of(context).size.height * 0.42;

    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background merah gradient
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

            // Logo dan Judul
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
                            'Kasir Madura',
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

            // FORM REGISTER
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
                  padding: EdgeInsets.fromLTRB(
                    24,
                    32,
                    24,
                    36 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Username
                        Text(
                          'Username',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _username,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: _dec(
                            hint: 'Enter your username',
                            icon: Icons.person_outline_rounded,
                            fieldFill: cs.surface,
                          ),
                          validator: _vUsername,
                        ),

                        const SizedBox(height: 20),

                        // Phone
                        Text(
                          'Nomor Handphone',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _dec(
                            hint: 'Enter your number',
                            icon: Icons.phone_outlined,
                            fieldFill: cs.surface,
                          ),
                          validator: _vPhone,
                        ),

                        const SizedBox(height: 20),

                        // Password
                        Text(
                          'Password',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _pass,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: _dec(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
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
                            fieldFill: cs.surface,
                          ),
                          validator: _vPass,
                        ),

                        const SizedBox(height: 28),

                        // button regis
                        Button(
                          label: 'Sing up',
                          onPressed: _isLoading ? null : _submit,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 16),

                        // Link ke Login
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                "Have an account?",
                                style: text.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    "Sign In",
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
                        const SizedBox(height: 16),
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
