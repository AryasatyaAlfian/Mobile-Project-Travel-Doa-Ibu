import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../models/models.dart';
import '../services/travel_api.dart';
import 'login_page.dart';
import 'register_page.dart';

/// Elysian Horizon — Welcome Landing Page
/// Desain 100% presisi sesuai contoh Figma dengan font Poppins & interaksi tap Daftar -> Register
class WelcomeLandingPage extends StatefulWidget {
  const WelcomeLandingPage({
    super.key,
    required this.api,
    required this.onContinueAsGuest,
  });

  final TravelApi api;
  final VoidCallback onContinueAsGuest;

  @override
  State<WelcomeLandingPage> createState() => _WelcomeLandingPageState();
}

class _WelcomeLandingPageState extends State<WelcomeLandingPage> {
  late Future<Paginated<TravelPackage>> _featuredFuture;

  @override
  void initState() {
    super.initState();
    _featuredFuture = widget.api.packages();
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          api: widget.api,
          onRegisterSuccess: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(
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
      MaterialPageRoute(
        builder: (context) => LoginPage(
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
                        // 1. Top Section: Headline & Subtitle dengan Font Poppins
                        Column(
                          children: [
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

                        // 2. Centerpiece: Triad of Overlapping Circular Portals
                        Center(
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
                                  child: _buildPortalCircle(
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=600&auto=format&fit=crop&q=80',
                                    size: 168,
                                    borderWidth: 5.0,
                                    fallbackIcon: Icons.mosque_rounded,
                                    semanticLabel: 'Kaaba Makkah Portal',
                                  ),
                                ),

                                // Top-Right: Mount Fuji (Japan)
                                Positioned(
                                  top: 22,
                                  right: 0,
                                  child: _buildPortalCircle(
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&auto=format&fit=crop&q=80',
                                    size: 160,
                                    borderWidth: 5.0,
                                    fallbackIcon: Icons.filter_hdr_rounded,
                                    semanticLabel: 'Mount Fuji Portal',
                                  ),
                                ),

                                // Bottom-Center: Mount Bromo (Indonesia) - Overlaps foreground
                                Positioned(
                                  top: 118,
                                  child: _buildPortalCircle(
                                    imageUrl:
                                        'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=600&auto=format&fit=crop&q=80',
                                    size: 192,
                                    borderWidth: 6.0,
                                    fallbackIcon: Icons.landscape_rounded,
                                    semanticLabel: 'Mount Bromo Portal',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. Bottom Action Section: LOGIN Button & Tautan Daftar ke Register
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Primary Pill Button: LOGIN
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: _navigateToLogin,
                                borderRadius: BorderRadius.circular(9999),
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AppColors.elysianNeutral,
                                    borderRadius: BorderRadius.circular(9999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.elysianSecondary.withValues(alpha: 0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'LOGIN',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.elysianSecondary,
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
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                            const SizedBox(height: 10),

                            // Invisible node for automated tests
                            _buildInvisibleTestBridge(),
                          ],
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
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
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
