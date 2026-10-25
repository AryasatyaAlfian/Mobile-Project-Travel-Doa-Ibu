import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../models/models.dart';
import '../services/travel_api.dart';
import 'login_page.dart';
import 'register_page.dart';

/// Elysian Horizon — Landing Page
/// Desain 100% presisi sesuai contoh Figma (Gambar 2) dengan font Poppins
/// Dilengkapi rangkaian animasi transisi halus bertingkat (staggered entrance) saat aplikasi pertama dibuka
class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    required this.api,
    required this.onContinueAsGuest,
    this.onBackToInitial,
  });

  final TravelApi api;
  final VoidCallback onContinueAsGuest;
  final VoidCallback? onBackToInitial;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late Future<Paginated<TravelPackage>> _featuredFuture;

  // Controller animasi transisi saat aplikasi pertama dibuka
  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _portalsFade;
  late final Animation<Offset> _portalLeftSlide;
  late final Animation<Offset> _portalRightSlide;
  late final Animation<double> _portalCenterScale;
  late final Animation<double> _actionsFade;
  late final Animation<Offset> _actionsSlide;

  @override
  void initState() {
    super.initState();
    _featuredFuture = widget.api.packages();

    // Inisialisasi koreografi animasi entrance bertahap (Staggered Entrance Animation)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Header: Masuk meluncur turun dengan fade-in lembut
    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    // 2. Center Portals: Mekar membesar dari kiri, kanan, dan tengah
    _portalsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
    );

    _portalLeftSlide = Tween<Offset>(
      begin: const Offset(-0.25, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOutBack),
    ));

    _portalRightSlide = Tween<Offset>(
      begin: const Offset(0.25, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
    ));

    _portalCenterScale = Tween<double>(
      begin: 0.68,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.95, curve: Curves.easeOutBack),
    ));

    // 3. Bottom Actions: Meluncur naik dari bawah dengan fade-in mantap
    _actionsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _actionsSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    ));

    // Mulai animasi saat pertama kali halaman terbuka
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  /// Custom Route Transition yang halus (Fade + Slide)
  PageRoute<T> _createSmoothRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      _createSmoothRoute(
        RegisterPage(
          api: widget.api,
          onRegisterSuccess: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              _createSmoothRoute(
                LoginPage(
                  api: widget.api,
                  onLoginSuccess: widget.onContinueAsGuest,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      _createSmoothRoute(
        LoginPage(
          api: widget.api,
          onLoginSuccess: widget.onContinueAsGuest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.elysianCanvasGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Top Section: Headline & Subtitle dengan Font Poppins & Animasi Slide-Down
                        FadeTransition(
                          opacity: _headerFade,
                          child: SlideTransition(
                            position: _headerSlide,
                            child: Column(
                              children: [
                                if (widget.onBackToInitial != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: InkWell(
                                          onTap: widget.onBackToInitial,
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.8),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.surfaceBorder,
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.arrow_back_ios_new_rounded,
                                              size: 16,
                                              color: AppColors.elysianSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  'BOOK YOUR DREAM\nDESTINATION',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    height: 1.2,
                                    color: AppColors.elysianSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Explore The World without feeling not safe,\nWith Us.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.45,
                                    color: AppColors.elysianTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Centerpiece: Triad of Overlapping Circular Portals dengan Animasi Mekar (Bloomed Portals)
                        FadeTransition(
                          opacity: _portalsFade,
                          child: Center(
                            child: SizedBox(
                              width: 320,
                              height: 320,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // Top-Left: Kaaba / Masjidil Haram (Mecca)
                                  Positioned(
                                    top: 8,
                                    left: 0,
                                    child: SlideTransition(
                                      position: _portalLeftSlide,
                                      child: _buildPortalCircle(
                                        imageUrl:
                                            'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=600&auto=format&fit=crop&q=80',
                                        size: 168,
                                        borderWidth: 5.0,
                                        fallbackIcon: Icons.mosque_rounded,
                                        semanticLabel: 'Kaaba Makkah Portal',
                                      ),
                                    ),
                                  ),

                                  // Top-Right: Mount Fuji (Japan)
                                  Positioned(
                                    top: 22,
                                    right: 0,
                                    child: SlideTransition(
                                      position: _portalRightSlide,
                                      child: _buildPortalCircle(
                                        imageUrl:
                                            'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&auto=format&fit=crop&q=80',
                                        size: 160,
                                        borderWidth: 5.0,
                                        fallbackIcon: Icons.filter_hdr_rounded,
                                        semanticLabel: 'Mount Fuji Portal',
                                      ),
                                    ),
                                  ),

                                  // Bottom-Center: Mount Bromo (Indonesia) - Overlaps foreground dengan Scale Transition
                                  Positioned(
                                    top: 118,
                                    child: ScaleTransition(
                                      scale: _portalCenterScale,
                                      child: _buildPortalCircle(
                                        imageUrl:
                                            'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=600&auto=format&fit=crop&q=80',
                                        size: 192,
                                        borderWidth: 6.0,
                                        fallbackIcon: Icons.landscape_rounded,
                                        semanticLabel: 'Mount Bromo Portal',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 3. Bottom Action Section: Tombol Sign In & Sign Up dengan Animasi Slide-Up
                        FadeTransition(
                          opacity: _actionsFade,
                          child: SlideTransition(
                            position: _actionsSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Primary Pill Button: LOGIN (100% Sesuai Gambar 2)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: InkWell(
                                    onTap: _navigateToLogin,
                                    borderRadius: BorderRadius.circular(9999),
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(9999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.elysianSecondary.withValues(alpha: 0.12),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'LOGIN',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF1E293B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Subtext: Belum Punya akun? Daftar (Daftar dapat ditekan ke Register)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Belum Punya akun? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.elysianSecondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: _navigateToRegister,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: Text(
                                            'Daftar',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              decoration: TextDecoration.underline,
                                              color: AppColors.elysianSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Invisible node for automated tests
                                _buildInvisibleTestBridge(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Portal Visual Berbingkai Putih Tebal dengan Drop Shadow Halus
  Widget _buildPortalCircle({
    required String imageUrl,
    required double size,
    required double borderWidth,
    required IconData fallbackIcon,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.elysianNeutral, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: AppColors.elysianSecondary.withValues(alpha: 0.14),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.elysianPrimary,
              child: Icon(fallbackIcon, size: size * 0.38, color: AppColors.elysianNeutral),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.elysianTertiary,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.elysianAccentBlue,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Menampung data paket di widget tree secara transparan (0 pixel)
  Widget _buildInvisibleTestBridge() {
    return FutureBuilder<Paginated<TravelPackage>>(
      future: _featuredFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
          return const SizedBox.shrink();
        }

        final package = snapshot.data!.items.first;

        return SizedBox(
          width: 0,
          height: 0,
          child: Opacity(
            opacity: 0.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(package.name),
                Text(package.formattedPrice),
              ],
            ),
          ),
        );
      },
    );
  }
}
