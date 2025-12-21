import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money_report_monthly/models/user_profile.dart';
import 'package:money_report_monthly/screens/onboarding/welcome_animation_screen.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/variants/options_bottom_sheet.dart';

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

  late AnimationController _mainController;
  late AnimationController _avatarBounceController;
  late AnimationController _shimmerController;

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
      duration: const Duration(milliseconds: 1200),
    );

    _avatarBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

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
    _avatarBounceController.dispose();
    _shimmerController.dispose();
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
      }
    } catch (e) {
      debugPrint('Pick image error: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();

    final userBox = Hive.box<UserProfile>('user_profile');
    final appState = Hive.box('app_state');

    await userBox.add(
      UserProfile(
        name: _nameController.text.trim(),
        photoPath: _photo?.path,
      ),
    );

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
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showImagePicker() async {
    if (_isPickingImage) return;

    HapticFeedback.selectionClick();

    // Unfocus keyboard first
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
          iconColor: Color(0xFF2196F3),
          value: ImageSource.camera,
        ),
        BottomSheetOption(
          title: 'Pilih dari Galeri',
          subtitle: 'Pilih foto yang sudah ada',
          icon: Icons.photo_library_rounded,
          iconColor: Color(0xFF9C27B0),
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
    // Check if keyboard is visible
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        // Prevent resize when keyboard appears
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                // Main scrollable content
                Positioned.fill(
                  bottom: 100, // Space for button
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Progress indicator
                        AnimatedBuilder(
                          animation: _mainController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _progressOpacity.value.clamp(0.0, 1.0),
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
                                opacity: _headerOpacity.value.clamp(0.0, 1.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Siapa kamu?',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A2E),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Buat profilmu untuk memulai',
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

                        const SizedBox(height: 40),

                        // Avatar
                        AnimatedBuilder(
                          animation: Listenable.merge(
                              [_mainController, _avatarBounceController]),
                          builder: (context, child) {
                            final bounceValue =
                                _avatarBounceController.value.clamp(0.0, 1.0);
                            final bounce = _photo == null
                                ? 1.0 + (0.03 * bounceValue)
                                : 1.0;
                            final scaleValue = _avatarScale.value
                                .clamp(0.0, 2.0); // elasticOut can overshoot

                            return Transform.scale(
                              scale: scaleValue * bounce,
                              child: _buildAvatar(),
                            );
                          },
                        ),

                        const SizedBox(height: 36),

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

                        // Extra space at bottom for scrolling
                        SizedBox(height: keyboardVisible ? 250 : 100),
                      ],
                    ),
                  ),
                ),

                // Fixed button at bottom
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: 32,
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _buttonSlide,
                        child: Opacity(
                          opacity: _buttonOpacity.value.clamp(0.0, 1.0),
                          child: _SaveButton(
                            onPressed: _saveProfile,
                            isEnabled: _isNameValid,
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

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF1A1A2E).withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Avatar content
            Center(
              child: ClipOval(
                child: Container(
                  width: 122,
                  height: 122,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: _photo != null
                      ? Image.file(
                          _photo!,
                          fit: BoxFit.cover,
                          width: 122,
                          height: 122,
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                ),
              ),
            ),
            // Camera badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1A2E).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
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
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          labelText: 'Nama kamu',
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: Colors.grey[400],
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF1A1A2E),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const _SaveButton({
    required this.onPressed,
    required this.isEnabled,
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
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: widget.isEnabled ? const Color(0xFF1A1A2E) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A1A2E)
                        .withOpacity(_isPressed ? 0.2 : 0.35),
                    blurRadius: _isPressed ? 15 : 25,
                    offset: Offset(0, _isPressed ? 6 : 12),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lanjutkan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isEnabled ? Colors.white : Colors.grey[500],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(widget.isEnabled ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.isEnabled ? Colors.white : Colors.grey[500],
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
