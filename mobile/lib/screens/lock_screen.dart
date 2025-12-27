import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  String _pin = '';
  String?  _error;
  bool _isBiometricLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Try biometric after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricOnStart();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh biometric status when app resumes
      context.read<AuthProvider>().refreshBiometricStatus();
    }
  }

  Future<void> _tryBiometricOnStart() async {
    final authProvider = context.read<AuthProvider>();
    
    // Only try biometric if it's enabled and available
    if (authProvider.useBiometric && authProvider.isBiometricAvailable) {
      await _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    if (_isBiometricLoading) return;
    
    final authProvider = context.read<AuthProvider>();
    
    if (! authProvider.useBiometric || !authProvider.isBiometricAvailable) {
      if (mounted) {
        SnackHelper.warning(context, 'Biometrik tidak tersedia');
      }
      return;
    }

    setState(() => _isBiometricLoading = true);
    
    try {
      final success = await authProvider.authenticateWithBiometric();
      
      if (! success && mounted) {
        setState(() {
          _error = 'Autentikasi biometrik gagal';
        });
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
      if (mounted) {
        setState(() {
          _error = 'Terjadi kesalahan';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBiometricLoading = false);
      }
    }
  }

  void _onKeyPressed(String key) {
    if (_pin.length < 6) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin += key;
        _error = null;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = await context.read<AuthProvider>().authenticateWithPin(_pin);
    if (!success && mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _pin = '';
        _error = 'PIN salah, coba lagi';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child:  ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child:  IntrinsicHeight(
                  child:  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: isSmallScreen ? 16 : 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        
                        // Lock Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: isSmallScreen ? 48 : 56,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 28),
                        
                        // Title
                        const Text(
                          'Masukkan PIN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Untuk membuka aplikasi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 28 : 36),
                        
                        // PIN Indicators - 6 digits
                        _buildPinIndicators(),
                        
                        // Error message
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _error != null ? 40 : 0,
                          child: _error != null
                              ? Center(
                                  child: Text(
                                    _error! ,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 36),
                        
                        // Keypad
                        _buildKeypad(screenWidth, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 20 : 28),
                        
                        // Biometric Button
                        if (authProvider.useBiometric && authProvider.isBiometricAvailable)
                          _buildBiometricButton(),
                        
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _isBiometricLoading ?  null : _tryBiometric,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBiometricLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              )
            else
              Icon(
                Icons.fingerprint_rounded,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            const SizedBox(width: 10),
            Text(
              _isBiometricLoading ?  'Memverifikasi...' : 'Gunakan Sidik Jari',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Theme.of(context).primaryColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? Theme.of(context).primaryColor : Colors.grey[400]!,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad(double screenWidth, bool isSmallScreen) {
    final keySize = ((screenWidth - 80) / 3).clamp(56.0, 72.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeypadRow(['1', '2', '3'], keySize, isSmallScreen),
        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildKeypadRow(['4', '5', '6'], keySize, isSmallScreen),
        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildKeypadRow(['7', '8', '9'], keySize, isSmallScreen),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:  [
            SizedBox(width: keySize, height: keySize),
            _buildKey('0', keySize, isSmallScreen),
            SizedBox(
              width: keySize,
              height: keySize,
              child: IconButton(
                onPressed: _onBackspace,
                icon: Icon(
                  Icons.backspace_outlined,
                  size:  isSmallScreen ? 22 : 26,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys, double keySize, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key, keySize, isSmallScreen)).toList(),
    );
  }

  Widget _buildKey(String value, double keySize, bool isSmallScreen) {
    return SizedBox(
      width: keySize,
      height: keySize,
      child: Material(
        color: Colors.grey[100],
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _onKeyPressed(value),
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 22 : 26,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}