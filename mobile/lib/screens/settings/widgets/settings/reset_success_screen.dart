import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetSuccessScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const ResetSuccessScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<ResetSuccessScreen> createState() => _ResetSuccessScreenState();
}

class _ResetSuccessScreenState extends State<ResetSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _checkController;
  late AnimationController _rippleController;

  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _checkScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _countdownOpacity;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  int _countdown = 5;
  final List<_Particle> _particles = [];
  final List<_FloatingIcon> _floatingIcons = [];

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    _startSequence();
  }

  void _initParticles() {
    final random = math.Random();
    
    // Celebration particles
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        angle: (math.pi * 2 / 20) * i + random.nextDouble() * 0.5,
        distance: 100 + random.nextDouble() * 80,
        size: 4 + random.nextDouble() * 8,
        delay: random.nextDouble() * 0.3,
        color: [
          const Color(0xFF4CAF50),
          const Color(0xFF2196F3),
          const Color(0xFFFF9800),
          const Color(0xFFE91E63),
          const Color(0xFF9C27B0),
        ][random.nextInt(5)],
      ));
    }

    // Floating icons
    final icons = [
      Icons.refresh_rounded,
      Icons.auto_awesome,
      Icons.star_rounded,
      Icons.favorite_rounded,
      Icons.bolt_rounded,
    ];
    
    for (int i = 0; i < 8; i++) {
      _floatingIcons.add(_FloatingIcon(
        icon: icons[random.nextInt(icons.length)],
        startX: random.nextDouble(),
        startY: 1.0 + random.nextDouble() * 0.3,
        endY: -0.2 - random.nextDouble() * 0.3,
        size: 16 + random.nextDouble() * 12,
        delay: random.nextDouble() * 2,
        duration: 3 + random.nextDouble() * 2,
        opacity: 0.3 + random.nextDouble() * 0.4,
      ));
    }
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1500),
    );

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:  2000),
    )..repeat();

    // Icon animations
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Check animation
    _checkScale = Tween<double>(begin:  0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve:  Curves.elasticOut,
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

    // Countdown animations
    _countdownOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve:  Curves.easeInOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _countdownController,
        curve:  Curves.linear,
      ),
    );

    // Countdown listener
    _countdownController.addListener(() {
      final newCountdown = 5 - (_countdownController.value * 5).floor();
      if (newCountdown != _countdown && newCountdown >= 0) {
        setState(() => _countdown = newCountdown);
        if (newCountdown > 0) {
          HapticFeedback.lightImpact();
        }
      }
    });

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onComplete();
      }
    });
  }

  void _startSequence() async {
    // Start main animation
    _mainController.forward();
    _particleController.forward();

    // Haptic feedback
    await Future.delayed(const Duration(milliseconds: 300));
    HapticFeedback.mediumImpact();

    // Start check animation
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();

    // Start countdown after animations complete
    await Future.delayed(const Duration(milliseconds: 800));
    _countdownController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _countdownController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _checkController.dispose();
    _rippleController.dispose();
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
            // Background gradient
            _buildBackground(),
            
            // Floating icons
            ..._buildFloatingIcons(),
            
            // Particles
            ..._buildParticles(),
            
            // Ripple effect
            _buildRippleEffect(),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success icon with animations
                  _buildSuccessIcon(),
                  
                  const SizedBox(height: 40),
                  
                  // Text content
                  _buildTextContent(),
                  
                  const SizedBox(height: 48),
                  
                  // Countdown section
                  _buildCountdownSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation:  _mainController,
      builder:  (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.white,
                const Color(0xFF4CAF50).withOpacity(0.03 * _mainController.value),
                const Color(0xFF2196F3).withOpacity(0.02 * _mainController.value),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingIcons() {
    return _floatingIcons.map((icon) {
      return AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          final time = DateTime.now().millisecondsSinceEpoch / 1000;
          final progress = ((time - icon.delay) / icon.duration) % 1.0;
          
          if (_mainController.value < 0.5) return const SizedBox();
          
          final y = icon.startY + (icon.endY - icon.startY) * progress;
          final x = icon.startX + math.sin(progress * math.pi * 2) * 0.05;
          
          return Positioned(
            left: MediaQuery.of(context).size.width * x,
            top:  MediaQuery.of(context).size.height * y,
            child:  Opacity(
              opacity: icon.opacity * (1 - (progress - 0.7).clamp(0, 0.3) / 0.3),
              child: Transform.rotate(
                angle: progress * math.pi * 2,
                child: Icon(
                  icon.icon,
                  size: icon.size,
                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation:  _particleController,
        builder: (context, child) {
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
              opacity: (1 - curvedProgress).clamp(0.0, 1.0) * 0.8,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: particle.color,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation:  _rippleController,
      builder: (context, child) {
        if (_mainController.value < 0.5) return const SizedBox();
        
        return Center(
          child: Transform.translate(
            offset: const Offset(0, -60),
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(3, (index) {
                final delay = index * 0.3;
                final progress = ((_rippleController.value - delay) % 1.0).clamp(0.0, 1.0);
                
                return Opacity(
                  opacity:  (1 - progress) * 0.3,
                  child: Container(
                    width: 120 + (progress * 100),
                    height: 120 + (progress * 100),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2 * (1 - progress),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation:  Listenable.merge([_mainController, _checkController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScale.value * _pulseAnimation.value,
          child:  Opacity(
            opacity: _iconOpacity.value.clamp(0.0, 1.0),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius:  30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Transform.scale(
                scale: _checkScale.value.clamp(0.0, 1.5),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
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
          position:  _textSlide,
          child: Opacity(
            opacity:  _textOpacity.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Success badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color:  Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reset Berhasil! ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height:  20),
                
                // Title
                const Text(
                  'Semua Data Terhapus',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Aplikasi akan dimulai ulang\ndengan data yang fresh! ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownSection() {
    return AnimatedBuilder(
      animation:  Listenable.merge([_mainController, _countdownController, _pulseController]),
      builder: (context, child) {
        return Opacity(
          opacity: _countdownOpacity.value.clamp(0.0, 1.0),
          child: Column(
            children: [
              // Circular progress with countdown
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                    ),
                    
                    // Progress circle
                    SizedBox(
                      width:  100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _countdown <= 2 
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    
                    // Countdown number
                    Transform.scale(
                      scale: _countdown > 0 ? _pulseAnimation.value : 1.0,
                      child: Text(
                        _countdown > 0 ? '$_countdown' : '🚀',
                        style: TextStyle(
                          fontSize: _countdown > 0 ? 36 : 32,
                          fontWeight: FontWeight.w700,
                          color: _countdown <= 2 
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _countdown > 0 
                      ? 'Memulai ulang dalam $_countdown detik...'
                      : 'Memulai aplikasi...',
                  key: ValueKey(_countdown),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Skip button (optional)
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _countdownController.stop();
                  widget.onComplete();
                },
                child:  Text(
                  'Lewati',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper classes
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

class _FloatingIcon {
  final IconData icon;
  final double startX;
  final double startY;
  final double endY;
  final double size;
  final double delay;
  final double duration;
  final double opacity;

  _FloatingIcon({
    required this.icon,
    required this.startX,
    required this.startY,
    required this.endY,
    required this.size,
    required this.delay,
    required this.duration,
    required this.opacity,
  });
}