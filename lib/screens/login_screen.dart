import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl     = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (_nameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Nama dan password wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await AuthService().login(_nameCtrl.text.trim(), _passwordCtrl.text);
    if (result == null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      setState(() { _loading = false; _error = result; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -80,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // App Icon + Name
                      Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 20),
                      Text('ASFOR', style: GoogleFonts.inter(
                        fontSize: 30, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary, letterSpacing: 3,
                      )),
                      const SizedBox(height: 4),
                      Text('Sistem Rekap Lab & Divisi', style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500,
                      )),

                      SizedBox(height: size.height * 0.06),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.07),
                              blurRadius: 40,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Selamat Datang 👋', style: GoogleFonts.inter(
                              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                            )),
                            const SizedBox(height: 4),
                            Text('Masuk ke akun Anda untuk melanjutkan', style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted,
                            )),
                            const SizedBox(height: 24),

                            // Nama/NIM
                            _label('Nama / NIM'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan nama atau NIM',
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                              ),
                              style: GoogleFonts.inter(fontSize: 14),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _label('Password'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                hintText: 'Masukkan password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 20, color: AppColors.textMuted,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              style: GoogleFonts.inter(fontSize: 14),
                              onSubmitted: (_) => _login(),
                            ),

                            // Error
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_error!, style: GoogleFonts.inter(
                                    fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w500,
                                  ))),
                                ]),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Login button
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: _loading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                    : Text('Masuk', style: GoogleFonts.inter(
                                        fontSize: 15, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Demo accounts
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.badge_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('Akun Demo (password: password)', style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary,
                              )),
                            ]),
                            const SizedBox(height: 10),
                            _demoRow('⭐ Admin',    'admin'),
                            _demoRow('💻 IT Support', 'budi · alvy · nando'),
                            _demoRow('👥 Hubmas',   'saddam · ditta'),
                            _demoRow('💼 B. Usaha', 'annifa'),
                            _demoRow('🎓 Training', 'steven · azizah'),
                            _demoRow('🖥️ Pemrog',   'firly · luluk'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
  ));

  Widget _demoRow(String label, String users) => GestureDetector(
    onTap: () => setState(() => _nameCtrl.text = users.split('·')[0].trim()),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(width: 96, child: Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        ))),
        Expanded(child: Text(users, style: GoogleFonts.inter(
          fontSize: 11, color: AppColors.textMuted,
        ))),
      ]),
    ),
  );
}
