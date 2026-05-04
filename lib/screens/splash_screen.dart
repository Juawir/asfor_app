import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _logoScale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);

    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _logoCtrl.forward().then((_) => _textCtrl.forward());

    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  void _navigate() async {
    final isLoggedIn = await AuthService().checkAuth();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => isLoggedIn ? const MainScreen() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(top: -60, right: -60,
              child: Container(width: 220, height: 220,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06)),
              )),
            Positioned(bottom: -80, left: -40,
              child: Container(width: 260, height: 260,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05)),
              )),
            Positioned(bottom: 120, right: -30,
              child: Container(width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04)),
              )),

            // Center content
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Text
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(children: [
                      Text('ASFOR', style: GoogleFonts.inter(
                        fontSize: 36, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 6,
                      )),
                      const SizedBox(height: 8),
                      Text('Sistem Rekap Lab & Divisi', style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500,
                      )),
                    ]),
                  ),
                ),
              ]),
            ),

            // Loading indicator
            Positioned(
              bottom: 60, left: 0, right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(children: [
                  SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
