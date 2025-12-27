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
  late AnimationController _pulseController;
  late AnimationController _confettiController;

  late Animation<double> _avatarScale;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring3Scale;
  late Animation<double> _checkScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _badgeScale;
  late Animation<double> _loadingProgress;

  final List<_Particle> _particles = [];
  final List<_Confetti> _confetti = [];

  @override
  void initState() {
    super.initState();

    // Generate celebration particles
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        angle: (math.pi * 2 / 20) * i,
        distance: 100 + random.nextDouble() * 60,
        size: 6 + random.nextDouble() * 8,
        delay: random.nextDouble() * 0.3,
        color: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
          const Color(0xFFEC4899),
        ][random.nextInt(5)],
      ));
    }

    // Generate confetti
    for (int i = 0; i < 40; i++) {
      _confetti.add(_Confetti(
        x: random.nextDouble(),
        delay: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 1.0,
        size: 6 + random.nextDouble() * 10,
        rotation: random.nextDouble() * math.pi * 2,
        color: [
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
          const Color(0xFFEC4899),
          const Color(0xFF3B82F6),
        ][random.nextInt(6)],
      ));
    }

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Avatar
    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Ring animations (staggered)
    _ring1Scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _ring2Scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _ring3Scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Checkmark
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.elasticOut,
      ),
    );

    // Text
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
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

    // Loading
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
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    HapticFeedback.heavyImpact();
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _loadingController.forward();

    // Navigate to home
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
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
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Stack(
          children: [
            // Background gradient
            _buildBackgroundGradient(),

            // Confetti
            ..._buildConfetti(),

            // Celebration particles
            ..._buildParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar section
                  _buildAvatarSection(),

                  const SizedBox(height: 44),

                  // Text content
                  _buildTextContent(),

                  const SizedBox(height: 52),

                  // Loading
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

  Widget _buildBackgroundGradient() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.15),
                        const Color(0xFF6366F1).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Transform.scale(
                scale: 1.0 + ((1 - _pulseController.value) * 0.1),
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.12),
                        const Color(0xFF10B981).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildConfetti() {
    return _confetti.map((c) {
      return AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          final progress =
              ((_confettiController.value - c.delay) / (1 - c.delay))
                  .clamp(0.0, 1.0);
          final y = -100 +
              (MediaQuery.of(context).size.height + 200) * progress * c.speed;
          final rotation = c.rotation + progress * math.pi * 4;

          return Positioned(
            left: c.x * MediaQuery.of(context).size.width,
            top: y,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: (1 - progress).clamp(0.0, 1.0) * 0.8,
                child: Container(
                  width: c.size,
                  height: c.size * 0.6,
                  decoration: BoxDecoration(
                    color: c.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> _buildParticles() {
    return _particles.map((p) {
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final progress =
              ((_particleController.value - p.delay) / (1 - p.delay))
                  .clamp(0.0, 1.0);
          final curvedProgress = Curves.easeOutCubic.transform(progress);

          final centerX = MediaQuery.of(context).size.width / 2;
          final centerY = MediaQuery.of(context).size.height / 2 - 80;

          return Positioned(
            left: centerX +
                math.cos(p.angle) * p.distance * curvedProgress -
                p.size / 2,
            top: centerY +
                math.sin(p.angle) * p.distance * curvedProgress -
                p.size / 2,
            child: Opacity(
              opacity: (1 - curvedProgress).clamp(0.0, 1.0) * 0.8,
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.color,
                  boxShadow: [
                    BoxShadow(
                      color: p.color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildAvatarSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _checkController,
        _pulseController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring 3 (outermost)
              Transform.scale(
                scale: _ring3Scale.value * 1.3,
                child: Opacity(
                  opacity: (_ring3Scale.value - 0.5).clamp(0.0, 1.0) * 0.2,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Ring 2
              Transform.scale(
                scale: _ring2Scale.value * 1.15,
                child: Opacity(
                  opacity: (_ring2Scale.value - 0.5).clamp(0.0, 1.0) * 0.35,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Ring 1 (closest)
              Transform.scale(
                scale: _ring1Scale.value,
                child: Opacity(
                  opacity: (_ring1Scale.value - 0.5).clamp(0.0, 1.0) * 0.5,
                  child: Container(
                    width: 145,
                    height: 145,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Avatar
              Transform.scale(
                scale: _avatarScale.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.25),
                        blurRadius: 35,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.photoPath != null
                        ? Image.file(
                            File(widget.photoPath!),
                            fit: BoxFit.cover,
                            width: 114,
                            height: 114,
                          )
                        : Container(
                            color: const Color(0xFFF3F4F6),
                            child: Icon(
                              Icons.person_rounded,
                              size: 50,
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 26,
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
            opacity: _textOpacity.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Success badge
                Transform.scale(
                  scale: _badgeScale.value.clamp(0.0, 2.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.15),
                          const Color(0xFF059669).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Profil berhasil dibuat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Welcome text
                Text(
                  'Selamat datang',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 8),

                // Name
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 18),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Text(
                        'Siap kelola keuanganmu! ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1).withOpacity(0.9),
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
          opacity: _textOpacity.value.clamp(0.0, 1.0),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                child: Stack(
                  children: [
                    // Background track
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Progress
                    AnimatedBuilder(
                      animation: _loadingController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: _loadingProgress.value,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF6366F1).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Menyiapkan dashboard...',
                style: TextStyle(
                  fontSize: 13,
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
      bottom: 44,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Opacity(
            opacity: (_textOpacity.value * 0.6).clamp(0.0, 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dompetku',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
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
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.color,
  });
}

class _Confetti {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final double rotation;
  final Color color;

  _Confetti({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.color,
  });
}
