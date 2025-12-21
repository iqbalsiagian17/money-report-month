import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding_info_screen.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _breatheController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonOpacity;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Logo animations
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Title animations
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    // Subtitle animations
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );

    // Button animations
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    // Breathe animation
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _breatheController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const OnboardingInfoScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo Section
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_mainController, _breatheController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value * _breatheAnimation.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Title
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _titleSlide,
                      child: Opacity(
                        opacity: _titleOpacity.value,
                        child: Column(
                          children: [
                            const Text(
                              'Dompetku',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF1A1A2E).withOpacity(0.06),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'SMART FINANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Subtitle
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _subtitleSlide,
                      child: Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Text(
                          'Catat keuanganmu dengan rapi,\ntenang, dan mudah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),

                // Button
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _buttonSlide,
                      child: Opacity(
                        opacity: _buttonOpacity.value,
                        child: _PremiumButton(
                          onPressed: _navigateToNext,
                          label: 'Mulai Sekarang',
                          shimmerController: _shimmerController,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.04),
            blurRadius: 80,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final AnimationController shimmerController;

  const _PremiumButton({
    required this.onPressed,
    required this.label,
    required this.shimmerController,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
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
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A2E)
                    .withOpacity(_isPressed ? 0.2 : 0.35),
                blurRadius: _isPressed ? 15 : 25,
                offset: Offset(0, _isPressed ? 6 : 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect
              AnimatedBuilder(
                animation: widget.shimmerController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.15),
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
                      child: Container(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  );
                },
              ),
              // Content
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
