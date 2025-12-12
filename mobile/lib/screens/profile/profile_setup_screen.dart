import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_button.dart';

// Import widgets
import 'widgets/profile_header.dart';
import 'widgets/name_field.dart';
import 'widgets/daily_limit_section.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isFirstTime;

  const ProfileSetupScreen({super.key, this.isFirstTime = true});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  bool _enableDailyLimit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final provider = context.read<UserProvider>();
    if (provider.profile != null) {
      _nameController.text = provider.userName;
      _limitController.text = provider.dailyLimit.toInt().toString();
      setState(() {
        _enableDailyLimit = provider.isDailyLimitEnabled;
      });
    } else {
      _limitController.text = '100000';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ProfileHeader(isFirstTime: widget.isFirstTime),

                const SizedBox(height: 48),

                // Name Field
                NameField(controller: _nameController),

                const SizedBox(height: 32),

                // Daily Limit Section
                DailyLimitSection(
                  isEnabled: _enableDailyLimit,
                  onToggle: (value) {
                    setState(() => _enableDailyLimit = value);
                  },
                  limitController: _limitController,
                ),

                const SizedBox(height: 48),

                // Save Button using global CustomButton
                CustomButton(
                  text: widget.isFirstTime ? 'Mulai Sekarang' : 'Simpan',
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                  icon: widget.isFirstTime
                      ? Icons.rocket_launch_rounded
                      : Icons.check_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final limitValue = double.tryParse(_limitController.text) ?? 100000.0;
      final limit = _enableDailyLimit ? limitValue : 100000.0;

      await context.read<UserProvider>().setProfile(
            name: name,
            dailyLimit: limit,
            isDailyLimitEnabled: _enableDailyLimit,
          );

      // Set nama untuk notifikasi
      NotificationService().setUserName(name);

      if (mounted) {
        if (widget.isFirstTime) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil disimpan! '),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
