import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/screens/home/home_screen.dart';

class WelcomeAnimationScreen extends StatefulWidget {
  final String name;
  final String? photoPath;

  const WelcomeAnimationScreen({
    super.key,
    required this.name,
    this.photoPath,
  });

  @override
  State<WelcomeAnimationScreen> createState() => _WelcomeAnimationScreenState();
}

class _WelcomeAnimationScreenState extends State<WelcomeAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _checkController;
  late AnimationController _loadingController;

  late Animation<double> _avatarScale;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _checkScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _badgeScale;
  late Animation<double> _loadingProgress;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Generate celebration particles
    for (int i = 0; i < 16; i++) {
      _particles.add(_Particle(
        angle: (math.pi * 2 / 16) * i,
        distance: 90 + math.Random().nextDouble() * 50,
        size: 6 + math.Random().nextDouble() * 6,
        delay: math.Random().nextDouble() * 0.2,
      ));
    }

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Avatar scale
    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Ring animations
    _ringScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );

    // Checkmark
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.elasticOut,
      ),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Badge
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.85, curve: Curves.elasticOut),
      ),
    );

    // Loading progress
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _mainController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.mediumImpact();
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.forward();

    // Navigate to home
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _checkController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Particles
            ..._buildParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with rings
                  _buildAvatarSection(),

                  const SizedBox(height: 40),

                  // Text content
                  _buildTextContent(),

                  const SizedBox(height: 48),

                  // Loading indicator
                  _buildLoadingSection(),
                ],
              ),
            ),

            // Bottom branding
            _buildBottomBranding(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(_particles.length, (index) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final particle = _particles[index];
          final progress = ((_particleController.value - particle.delay) /
                  (1 - particle.delay))
              .clamp(0.0, 1.0);
          final curvedProgress = Curves.easeOutCubic.transform(progress);

          final centerX = MediaQuery.of(context).size.width / 2;
          final centerY = MediaQuery.of(context).size.height / 2 - 60;

          return Positioned(
            left: centerX +
                math.cos(particle.angle) * particle.distance * curvedProgress -
                particle.size / 2,
            top: centerY +
                math.sin(particle.angle) * particle.distance * curvedProgress -
                particle.size / 2,
            child: Opacity(
              opacity: (1 - curvedProgress).clamp(0.0, 1.0) * 0.6,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A2E).withOpacity(0.3),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildAvatarSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _checkController]),
      builder: (context, child) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: _ringScale.value * 1.15,
                child: Opacity(
                  opacity: _ringOpacity.value * 0.3,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1A1A2E).withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Middle ring
              Transform.scale(
                scale: _ringScale.value,
                child: Opacity(
                  opacity: _ringOpacity.value * 0.5,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1A1A2E).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Avatar
              Transform.scale(
                scale: _avatarScale.value,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF1A1A2E).withOpacity(0.1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1A2E).withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.photoPath != null
                        ? Image.file(
                            File(widget.photoPath!),
                            fit: BoxFit.cover,
                            width: 106,
                            height: 106,
                          )
                        : Container(
                            color: const Color(0xFFF5F5F5),
                            child: Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
              ),

              // Checkmark badge
              Positioned(
                bottom: 25,
                right: 25,
                child: Transform.scale(
                  scale: _checkScale.value,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextContent() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: Opacity(
            opacity: _textOpacity.value,
            child: Column(
              children: [
                // Success badge
                Transform.scale(
                  scale: _badgeScale.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Profil berhasil dibuat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome text
                Text(
                  'Selamat datang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 6),

                // Name
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        size: 16,
                        color: const Color(0xFF1A1A2E).withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Siap kelola keuanganmu! ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _loadingController]),
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Column(
            children: [
              SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress.value,
                    backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF1A1A2E).withOpacity(0.5),
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menyiapkan dashboard...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBranding() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Opacity(
            opacity: _textOpacity.value * 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 6),
                Text(
                  'Dompetku',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}
