import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late List<AnimationController> _featureControllers;
  late List<Animation<double>> _featureAnimations;

  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  final List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.arrow_downward_rounded,
      title: 'Catat Pemasukan',
      subtitle: 'Pantau uang masuk dengan mudah',
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF4CAF50),
    ),
    _FeatureData(
      icon: Icons.arrow_upward_rounded,
      title: 'Catat Pengeluaran',
      subtitle: 'Kelola pengeluaran harian',
      iconBgColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFFF9800),
    ),
    _FeatureData(
      icon: Icons.analytics_rounded,
      title: 'Analisis Keuangan',
      subtitle: 'Lihat grafik dan ringkasan',
      iconBgColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF2196F3),
    ),
    _FeatureData(
      icon: Icons.lock_rounded,
      title: 'Aman & Offline',
      subtitle: 'Data tersimpan aman di perangkat',
      iconBgColor: const Color(0xFFF3E5F5),
      iconColor: const Color(0xFF9C27B0),
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
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Create staggered controllers for each feature
    _featureControllers = List.generate(
      _features.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    // Create animations with proper curves (no overshoot for opacity)
    _featureAnimations = _featureControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();

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
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _featureControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
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
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const OnboardingProfileSetupScreen(),
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
                            const Text(
                              'Apa yang bisa\nkamu lakukan?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Fitur-fitur yang akan membantumu',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[500],
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
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _featureControllers[index],
                        builder: (context, child) {
                          // Use separate animation for slide (can overshoot)
                          final slideAnimation = CurvedAnimation(
                            parent: _featureControllers[index],
                            curve: Curves.easeOutBack,
                          );

                          // Use clamped value for opacity (cannot overshoot)
                          final opacityValue =
                              _featureAnimations[index].value.clamp(0.0, 1.0);

                          return Transform.translate(
                            offset: Offset(50 * (1 - slideAnimation.value), 0),
                            child: Opacity(
                              opacity: opacityValue,
                              child: _FeatureCard(data: _features[index]),
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
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1A1A2E)
                : const Color(0xFF1A1A2E).withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
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
  final Color iconBgColor;
  final Color iconColor;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: data.iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              data.icon,
              color: data.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    height: 1.3,
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
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFF1A1A2E).withOpacity(_isPressed ? 0.2 : 0.35),
              blurRadius: _isPressed ? 15 : 25,
              offset: Offset(0, _isPressed ? 6 : 12),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Lanjutkan',
                style: TextStyle(
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
      ),
    );
  }
}
