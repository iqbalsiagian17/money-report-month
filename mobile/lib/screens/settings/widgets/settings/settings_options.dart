import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_report_monthly/config/routes.dart';
import 'package:hive/hive.dart';
import 'package:money_report_monthly/models/category.dart';
import 'package:money_report_monthly/models/custom_notification.dart';
import 'package:money_report_monthly/models/recurring_transaction.dart';
import 'package:money_report_monthly/models/saving_goal.dart';
import 'package:money_report_monthly/models/todo.dart';
import 'package:money_report_monthly/models/transaction.dart';
import 'package:money_report_monthly/models/user_profile.dart';
import 'package:money_report_monthly/models/wallet.dart';
import 'package:money_report_monthly/screens/settings/widgets/settings/reset_success_screen.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import '../../../../widgets/bottom_sheet/variants/info_bottom_sheet.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SettingsOptions {
  SettingsOptions._();

  // ================= APPEARANCE =================
  static void showAppearance(
      BuildContext context, ThemeProvider themeProvider) {
    final colors = [
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.teal,
      Colors.cyan,
    ];

    AppBottomSheet.show(
      context: context,
      title: 'Tampilan',
      subtitle: 'Personalisasi aplikasi kamu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Toggle
          _buildThemeToggle(context, themeProvider),
          const SizedBox(height: 24),

          // Color Picker
          Text(
            'Warna Tema',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              final isSelected =
                  themeProvider.primaryColor.value == color.value;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  themeProvider
                      .setPrimaryColor(color); // Fixed: gunakan setPrimaryColor
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget _buildThemeToggle(
      BuildContext context, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ThemeButton(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: !isDark,
            onTap: () {
              if (isDark) themeProvider.toggleTheme();
            },
          ),
          _ThemeButton(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: isDark,
            onTap: () {
              if (!isDark) themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  // ================= SECURITY =================
  static Future<void> showSecurity(
      BuildContext context, AuthProvider authProvider) async {
    if (!authProvider.isLockEnabled) {
      _showSetPinForm(context, authProvider);
      return;
    }

    final action = await AppBottomSheet.showOptions<String>(
      context: context,
      title: 'Keamanan',
      subtitle:
          'PIN:  Aktif ${authProvider.useBiometric ? "• Biometrik:  Aktif" : ""}',
      options: [
        BottomSheetOption(
          title: authProvider.useBiometric
              ? 'Nonaktifkan Biometrik'
              : 'Aktifkan Biometrik',
          subtitle: 'Gunakan sidik jari / face ID',
          icon: Icons.fingerprint_rounded,
          iconColor: Colors.purple,
          value: 'biometric',
        ),
        const BottomSheetOption(
          title: 'Ubah PIN',
          subtitle: 'Ganti PIN kunci aplikasi',
          icon: Icons.password_rounded,
          iconColor: Colors.blue,
          value: 'change_pin',
        ),
        const BottomSheetOption(
          title: 'Nonaktifkan Kunci',
          subtitle: 'Hapus PIN dan kunci aplikasi',
          icon: Icons.lock_open_rounded,
          iconColor: Colors.red,
          isDestructive: true,
          value: 'remove',
        ),
      ],
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case 'biometric':
        authProvider.setUseBiometric(!authProvider.useBiometric);
        _showSuccess(
            context,
            authProvider.useBiometric
                ? 'Biometrik diaktifkan'
                : 'Biometrik dinonaktifkan');
        break;
      case 'change_pin':
        _showSetPinForm(context, authProvider);
        break;
      case 'remove':
        final confirm = await AppBottomSheet.showConfirm(
          context: context,
          title: 'Nonaktifkan Kunci?',
          message:
              'Aplikasi tidak akan terkunci lagi. Siapapun dapat mengakses data keuangan kamu.',
          isDanger: true,
          confirmText: 'Ya, Nonaktifkan',
        );
        if (confirm == true) {
          authProvider.removePin();
          if (context.mounted)
            _showSuccess(context, 'Kunci aplikasi dinonaktifkan');
        }
        break;
    }
  }

  // Ganti method _showSetPinForm di settings_options.dart dengan ini:

  static void _showSetPinForm(BuildContext context, AuthProvider authProvider) {
    String pin = '';
    String confirmPin = '';
    bool isConfirming = false;

    AppBottomSheet.show(
      context: context,
      title: authProvider.isLockEnabled ? 'Ubah PIN' : 'Buat PIN',
      subtitle: 'Masukkan 6 digit PIN',
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PIN Display - 6 digits
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final currentPin = isConfirming ? confirmPin : pin;
                  final isFilled = index < currentPin.length;
                  return Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isFilled
                        ? const Icon(Icons.circle,
                            color: Colors.white, size: 10)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                isConfirming ? 'Konfirmasi PIN' : 'Masukkan PIN baru',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Numpad - Responsive
              _buildNumpad(
                onNumber: (num) {
                  HapticFeedback.lightImpact();
                  if (isConfirming) {
                    if (confirmPin.length < 6) {
                      setState(() => confirmPin += num);
                      if (confirmPin.length == 6) {
                        if (pin == confirmPin) {
                          authProvider.setPin(pin);
                          Navigator.pop(context);
                          _showSuccess(context, 'PIN berhasil disimpan');
                        } else {
                          _showError(context, 'PIN tidak cocok');
                          setState(() {
                            confirmPin = '';
                            isConfirming = false;
                            pin = '';
                          });
                        }
                      }
                    }
                  } else {
                    if (pin.length < 6) {
                      setState(() => pin += num);
                      if (pin.length == 6) {
                        setState(() => isConfirming = true);
                      }
                    }
                  }
                },
                onDelete: () {
                  HapticFeedback.lightImpact();
                  if (isConfirming && confirmPin.isNotEmpty) {
                    setState(() => confirmPin =
                        confirmPin.substring(0, confirmPin.length - 1));
                  } else if (!isConfirming && pin.isNotEmpty) {
                    setState(() => pin = pin.substring(0, pin.length - 1));
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildNumpad({
    required Function(String) onNumber,
    required VoidCallback onDelete,
  }) {
    final numbers = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'del'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final item = numbers[index];
        if (item.isEmpty) return const SizedBox();

        return GestureDetector(
          onTap: item == 'del' ? onDelete : () => onNumber(item),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: item == 'del'
                  ? const Icon(Icons.backspace_rounded)
                  : Text(
                      item,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ================= PROFILE =================
  static void showProfile(BuildContext context, UserProvider userProvider) {
    final nameController =
        TextEditingController(text: userProvider.profile?.name);

    File? selectedImage;

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Edit Profil',
      subtitle: 'Ubah informasi profil kamu',
      submitText: 'Simpan',
      builder: (context, setState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final photoPath = userProvider.profile?.photoPath;

        return Column(
          children: [
            // ===== AVATAR =====
            GestureDetector(
              onTap: () async {
                final source = await AppBottomSheet.showOptions<ImageSource>(
                  context: context,
                  title: 'Foto Profil',
                  options: const [
                    BottomSheetOption(
                      title: 'Ambil dari Kamera',
                      icon: Icons.camera_alt_rounded,
                      value: ImageSource.camera,
                    ),
                    BottomSheetOption(
                      title: 'Pilih dari Galeri',
                      icon: Icons.photo_library_rounded,
                      value: ImageSource.gallery,
                    ),
                  ],
                );

                if (source == null) return;

                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: source,
                  imageQuality: 75,
                );

                if (picked != null) {
                  setState(() {
                    selectedImage = File(picked.path);
                  });
                }
              },
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : photoPath != null
                              ? Image.file(
                                  File(photoPath),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== NAME FIELD =====
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama kamu',
                prefixIcon: const Icon(Icons.person_rounded),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        );
      },
      onSubmit: () async {
        if (nameController.text.trim().isEmpty) {
          _showError(context, 'Nama tidak boleh kosong');
          return null;
        }

        // update nama
        await userProvider.setName(nameController.text.trim());

        // update foto (jika ada)
        if (selectedImage != null) {
          await userProvider.setPhotoPath(selectedImage!.path);
        }

        if (context.mounted) {
          _showSuccess(context, 'Profil berhasil diupdate');
        }
        return true;
      },
    );
  }

  // ================= ABOUT =================
  static void showAbout(BuildContext context) {
    AppBottomSheet.showInfo(
      context: context,
      title: 'Dompetku',
      message:
          'Dompetku adalah aplikasi pencatatan keuangan pribadi yang simpel dan mudah digunakan.\n\nVersi 1.0.0\n\nDibuat dengan ❤️.\n\nAplikasi ini masih dalam tahap pengembangan aktif. Beberapa fitur tambahan akan hadir di update selanjutnya.',
      type: InfoType.info,
      icon: Icons.info_rounded,
    );
  }

// ================= RESET DATA (ROBUST) =================
  static Future<void> showResetConfirm(BuildContext context) async {
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Reset Semua Data? ',
      message:
          'Semua data termasuk transaksi, dompet, kategori, dan pengaturan akan dihapus secara permanen.  Tindakan ini TIDAK DAPAT dibatalkan.',
      isDanger: true,
      confirmText: 'Ya, Reset Semua',
      cancelText: 'Batal',
    );

    if (confirmed == true && context.mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Menghapus semua data...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Clear all typed boxes
        await _clearAllTypedBoxes();

        // Small delay
        await Future.delayed(const Duration(milliseconds: 300));

        if (!context.mounted) return;

        // Close loading dialog
        Navigator.of(context).pop();

        // Navigate to reset success screen with countdown
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return ResetSuccessScreen(
                onComplete: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.onboarding,
                    (route) => false,
                  );
                },
              );
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      } catch (e) {
        debugPrint('Reset error: $e');
        if (context.mounted) {
          Navigator.of(context).pop();
          _showError(context, 'Gagal mereset data:  $e');
        }
      }
    }
  }

// Clear all boxes with correct types
  static Future<void> _clearAllTypedBoxes() async {
    // Clear generic/untyped boxes
    await _safeClearGenericBox('settings');
    await _safeClearGenericBox('app_state');

    // Clear typed boxes with their correct types
    await _safeClearTypedBox<UserProfile>('user_profile');
    await _safeClearTypedBox<Wallet>('wallets');
    await _safeClearTypedBox<TransactionModel>('transactions');
    await _safeClearTypedBox<SavingGoal>('saving_goal');
    await _safeClearTypedBox<CategoryModel>('categories');
    await _safeClearTypedBox<Todo>('todo');
    await _safeClearTypedBox<RecurringTransaction>('recurring');
    await _safeClearTypedBox<CustomNotification>('custom_notifications');
  }

// Safe clear for typed boxes
  static Future<bool> _safeClearTypedBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<T>(boxName);
        await box.clear();
        debugPrint('✓ Cleared typed box: $boxName');
        return true;
      } else {
        debugPrint('⚠ Typed box "$boxName" not open, skipping');
        return true;
      }
    } catch (e) {
      debugPrint('✗ Error clearing typed box "$boxName": $e');
      return false;
    }
  }

// Safe clear for generic/untyped boxes
  static Future<bool> _safeClearGenericBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.clear();
        debugPrint('✓ Cleared generic box:  $boxName');
        return true;
      } else {
        debugPrint('⚠ Generic box "$boxName" not open, skipping');
        return true;
      }
    } catch (e) {
      debugPrint('✗ Error clearing generic box "$boxName": $e');
      return false;
    }
  }

  // ================= SNACKBAR HELPERS =================
  static void _showSuccess(BuildContext context, String message) {
    SnackHelper.success(context, message);
  }

  static void _showError(BuildContext context, String message) {
    SnackHelper.error(context, message);
  }
}

// ================= THEME BUTTON =================
class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
