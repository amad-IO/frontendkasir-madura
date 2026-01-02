import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animation: scale + fade
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Text animation: slide from bottom + fade
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // Button animation: scale + fade
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF4EA),
      body: Stack(
        children: [
          // ===== OVAL GRADIENT BAWAH =====
          Positioned(
            left: -w * 0.55,
            bottom: -w * 0.95,
            child: SizedBox(
              width: w * 2.05,
              height: w * 2.05,
              child: Stack(
                children: [
                  Container(
                    decoration: const ShapeDecoration(
                      color: AppTheme.primaryRed,
                      shape: OvalBorder(),
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-0.9, 0.9),
                        end: const Alignment(0.5, -0.1),
                        colors: [
                          AppTheme.primaryOrange.withOpacity(0.0),
                          AppTheme.primaryOrange,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      shape: const OvalBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== KONTEN =====
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: h * 0.12),

                // Logo dengan animasi
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: SizedBox(
                      width: 146,
                      height: 146,
                      child: Image.asset(
                        'assets/images/logo3.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Brand name
                FadeTransition(
                  opacity: _logoFade,
                  child: Text(
                    'Madura Store',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryRed,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.0,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.25),

                // Teks dengan animasi
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.12),
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: const Text(
                            'Solusi Kasir Moderen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.primaryWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: const Text(
                            'Transaksi cepat, laporan otomatis, jualan pun makin lancar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.primaryWhite,
                              fontSize: 17,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol dengan animasi
                      ScaleTransition(
                        scale: _buttonScale,
                        child: FadeTransition(
                          opacity: _buttonFade,
                          child: SizedBox(
                            width: w * 0.56,
                            height: 52,
                            child: ElevatedButton(
                              key: const Key('get_started_button'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFAB12F),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.3, 0),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          )),
                                          child: Builder(
                                            builder: (context) {
                                              Future.microtask(() {
                                                Navigator.pushReplacementNamed(
                                                    context, AppRoutes.login);
                                              });
                                              return const Scaffold(
                                                backgroundColor: Color(0xFFFBF4EA),
                                                body: Center(
                                                  child: CircularProgressIndicator(
                                                    color: AppTheme.primaryRed,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 500),
                                    reverseTransitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 20.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.06),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
