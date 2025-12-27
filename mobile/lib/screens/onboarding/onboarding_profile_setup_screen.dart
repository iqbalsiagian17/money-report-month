import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money_report_monthly/models/user_profile.dart';
import 'package:money_report_monthly/providers/wallet_provider.dart';
import 'package:money_report_monthly/providers/category_provider.dart';
import 'package:money_report_monthly/screens/onboarding/welcome_animation_screen.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class OnboardingProfileSetupScreen extends StatefulWidget {
  const OnboardingProfileSetupScreen({super.key});

  @override
  State<OnboardingProfileSetupScreen> createState() =>
      _OnboardingProfileSetupScreenState();
}

class _OnboardingProfileSetupScreenState
    extends State<OnboardingProfileSetupScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  File? _photo;
  bool _isPickingImage = false;
  bool _isNameValid = false;
  bool _isSaving = false;

  late AnimationController _mainController;
  late AnimationController _avatarPulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;

  late Animation<double> _progressOpacity;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _avatarScale;
  late Animation<double> _formOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
      ),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.55, curve: Curves.elasticOut),
      ),
    );

    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _nameController.addListener(_validateName);
    _mainController.forward();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _avatarPulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;

    try {
      _isPickingImage = true;
      HapticFeedback.lightImpact();

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (picked != null && mounted) {
        setState(() {
          _photo = File(picked.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      debugPrint('Pick image error: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final userBox = Hive.box<UserProfile>('user_profile');
      final appState = Hive.box('app_state');

      await userBox.add(
        UserProfile(
          name: _nameController.text.trim(),
          photoPath: _photo?.path,
        ),
      );

      if (mounted) {
        await context.read<WalletProvider>().initDefaultWallets();
        await context.read<CategoryProvider>().initDefaultCategories();
      }

      await appState.put('has_onboarded', true);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => WelcomeAnimationScreen(
            name: _nameController.text.trim(),
            photoPath: _photo?.path,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('Save profile error:  $e');
      if (mounted) {
        setState(() => _isSaving = false);
        SnackHelper.error(context, 'Gagal menyimpan profil:  $e');
      }
    }
  }

  void _showImagePicker() async {
    if (_isPickingImage) return;

    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    final source = await AppBottomSheet.showOptions<ImageSource>(
      context: context,
      title: 'Foto Profil',
      subtitle: 'Pilih sumber foto',
      options: const [
        BottomSheetOption(
          title: 'Ambil dari Kamera',
          subtitle: 'Gunakan kamera untuk foto baru',
          icon: Icons.camera_alt_rounded,
          iconColor: Color(0xFF3B82F6),
          value: ImageSource.camera,
        ),
        BottomSheetOption(
          title: 'Pilih dari Galeri',
          subtitle: 'Pilih foto yang sudah ada',
          icon: Icons.photo_library_rounded,
          iconColor: Color(0xFF8B5CF6),
          value: ImageSource.gallery,
        ),
      ],
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background orbs
            _buildBackgroundOrbs(),

            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Stack(
                  children: [
                    // Scrollable content
                    Positioned.fill(
                      bottom: 110,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),

                            // Progress
                            AnimatedBuilder(
                              animation: _mainController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity:
                                      _progressOpacity.value.clamp(0.0, 1.0),
                                  child: _buildProgressIndicator(2),
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
                                    opacity:
                                        _headerOpacity.value.clamp(0.0, 1.0),
                                    child: _buildHeader(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 44),

                            // Avatar
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _mainController,
                                _avatarPulseController,
                                _floatingController,
                              ]),
                              builder: (context, child) {
                                final floatOffset = math.sin(
                                      _floatingController.value * math.pi,
                                    ) *
                                    6;
                                final pulseValue = 1.0 +
                                    (_avatarPulseController.value *
                                        0.03 *
                                        (_photo == null ? 1 : 0));
                                final scaleValue =
                                    _avatarScale.value.clamp(0.0, 2.0);

                                return Transform.translate(
                                  offset: Offset(0, floatOffset),
                                  child: Transform.scale(
                                    scale: scaleValue * pulseValue,
                                    child: _buildAvatar(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 40),

                            // Name input
                            AnimatedBuilder(
                              animation: _mainController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _formSlide,
                                  child: Opacity(
                                    opacity: _formOpacity.value.clamp(0.0, 1.0),
                                    child: _buildNameInput(),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: keyboardVisible ? 280 : 120),
                          ],
                        ),
                      ),
                    ),

                    // Fixed button
                    Positioned(
                      left: 32,
                      right: 32,
                      bottom: 36,
                      child: AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _buttonSlide,
                            child: Opacity(
                              opacity: _buttonOpacity.value.clamp(0.0, 1.0),
                              child: _SaveButton(
                                onPressed: _saveProfile,
                                isEnabled: _isNameValid && !_isSaving,
                                isLoading: _isSaving,
                                shimmerController: _shimmerController,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
              top: -80 + (offset * 30),
              left: -60,
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
              bottom: 50 - (offset * 40),
              right: -100,
              child: Container(
                width: 320,
                height: 320,
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Color(0xFF6366F1),
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Siapa kamu?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Buat profilmu untuk memulai',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Stack(
        children: [
          // Outer glow ring
          AnimatedBuilder(
            animation: _avatarPulseController,
            builder: (context, child) {
              final pulse = 1.0 + (_avatarPulseController.value * 0.1);
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.2),
                        const Color(0xFF6366F1).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Main avatar container
          Positioned.fill(
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _photo != null
                      ? Image.file(
                          _photo!,
                          fit: BoxFit.cover,
                          width: 134,
                          height: 134,
                        )
                      : Container(
                          color: const Color(0xFFF3F4F6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap untuk foto',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Camera badge
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _focusNode.hasFocus
                ? const Color(0xFF6366F1).withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          labelText: 'Nama kamu',
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Masukkan nama kamu',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: _focusNode.hasFocus
                    ? const Color(0xFF6366F1)
                    : Colors.grey[500],
                size: 22,
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.15),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color(0xFF6366F1),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;
  final AnimationController shimmerController;

  const _SaveButton({
    required this.onPressed,
    required this.isEnabled,
    this.isLoading = false,
    required this.shimmerController,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed();
            }
          : null,
      onTapCancel:
          widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          gradient: widget.isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[300]!],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: widget.isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1)
                        .withOpacity(_isPressed ? 0.3 : 0.5),
                    blurRadius: _isPressed ? 15 : 30,
                    offset: Offset(0, _isPressed ? 6 : 15),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Shimmer
            if (widget.isEnabled)
              AnimatedBuilder(
                animation: widget.shimmerController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
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
              child: widget.isLoading
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: widget.isEnabled
                                ? Colors.white
                                : Colors.grey[500],
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(widget.isEnabled ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: widget.isEnabled
                                ? Colors.white
                                : Colors.grey[500],
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
