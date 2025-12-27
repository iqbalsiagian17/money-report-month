import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'onboarding_profile_setup_screen.dart';

class OnboardingInfoScreen extends StatefulWidget {
  const OnboardingInfoScreen({super.key});

  @override
  State<OnboardingInfoScreen> createState() => _OnboardingInfoScreenState();
}

class _OnboardingInfoScreenState extends State<OnboardingInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  late List<AnimationController> _featureControllers;

  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  final List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.arrow_downward_rounded,
      title: 'Catat Pemasukan',
      subtitle: 'Pantau uang masuk dengan mudah',
      gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
    ),
    _FeatureData(
      icon: Icons.arrow_upward_rounded,
      title: 'Catat Pengeluaran',
      subtitle: 'Kelola pengeluaran harian',
      gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    ),
    _FeatureData(
      icon: Icons.analytics_rounded,
      title: 'Analisis Keuangan',
      subtitle: 'Lihat grafik dan ringkasan',
      gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
    ),
    _FeatureData(
      icon: Icons.lock_rounded,
      title: 'Aman & Offline',
      subtitle: 'Data tersimpan aman di perangkat',
      gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _featureControllers = List.generate(
      _features.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _mainController.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    for (int i = 0; i < _featureControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) {
        _featureControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToNext() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const OnboardingProfileSetupScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
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
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Stack(
          children: [
            // Background gradient orbs
            _buildBackgroundOrbs(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Progress indicator
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _headerOpacity.value.clamp(0.0, 1.0),
                          child: _buildProgressIndicator(1),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Header
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _headerSlide,
                          child: Opacity(
                            opacity: _headerOpacity.value.clamp(0.0, 1.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF6366F1),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Apa yang bisa\nkamu lakukan?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F2937),
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Fitur-fitur yang akan membantumu',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // Features list
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _features.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _featureControllers[index],
                            builder: (context, child) {
                              final slideValue = CurvedAnimation(
                                parent: _featureControllers[index],
                                curve: Curves.easeOutBack,
                              ).value;

                              final opacityValue = CurvedAnimation(
                                parent: _featureControllers[index],
                                curve: Curves.easeOut,
                              ).value.clamp(0.0, 1.0);

                              return Transform.translate(
                                offset: Offset(60 * (1 - slideValue), 0),
                                child: Opacity(
                                  opacity: opacityValue,
                                  child: _FeatureCard(
                                    data: _features[index],
                                    index: index,
                                    floatingController: _floatingController,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Button
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _buttonSlide,
                          child: Opacity(
                            opacity: _buttonOpacity.value.clamp(0.0, 1.0),
                            child: _ContinueButton(
                              onPressed: _navigateToNext,
                              shimmerController: _shimmerController,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = _floatingController.value;
        return Stack(
          children: [
            Positioned(
              top: -50 + (offset * 20),
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.12),
                      const Color(0xFF6366F1).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100 - (offset * 30),
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentStep;
        final isPast = index < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            gradient: (isActive || isPast)
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  )
                : null,
            color: (!isActive && !isPast)
                ? const Color(0xFF6366F1).withOpacity(0.15)
                : null,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  final int index;
  final AnimationController floatingController;

  const _FeatureCard({
    required this.data,
    required this.index,
    required this.floatingController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        final offset =
            math.sin((floatingController.value + index * 0.3) * math.pi) * 3;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: data.gradient[0].withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: data.gradient[0].withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: data.gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: data.gradient[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: data.gradient[0],
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;
  final AnimationController shimmerController;

  const _ContinueButton({
    required this.onPressed,
    required this.shimmerController,
  });

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFF6366F1).withOpacity(_isPressed ? 0.3 : 0.5),
              blurRadius: _isPressed ? 15 : 30,
              offset: Offset(0, _isPressed ? 6 : 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer
            AnimatedBuilder(
              animation: widget.shimmerController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0),
                        ],
                        stops: [
                          (widget.shimmerController.value - 0.3)
                              .clamp(0.0, 1.0),
                          widget.shimmerController.value,
                          (widget.shimmerController.value + 0.3)
                              .clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.white.withOpacity(0.1)),
                  ),
                );
              },
            ),
            // Content
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
