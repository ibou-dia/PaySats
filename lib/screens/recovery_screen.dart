import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/otp_service.dart';
import '../models/auth_state.dart';
import '../theme/app_theme.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Pre-fill phone number if available
    final authService = Provider.of<AuthService>(context, listen: false);
    final phoneNumber = authService.authState.phoneNumber;
    if (phoneNumber != null) {
      _phoneController.text = phoneNumber;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _currentOtp {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify when OTP is complete
    if (_currentOtp.length == 6) {
      _verifyOtp();
    }

    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _sendRecoveryOtp() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre numéro de téléphone';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final otpService = Provider.of<OtpService>(context, listen: false);

      // Vérifier que le numéro correspond à un compte existant
      final userPhoneNumber = authService.authState.phoneNumber;
      if (userPhoneNumber != phoneNumber) {
        throw Exception('Ce numéro ne correspond à aucun compte');
      }

      // Envoyer l'OTP de récupération
      await otpService.sendOtp(phoneNumber, OtpType.recovery);
      
      setState(() {
        _isOtpSent = true;
        _successMessage = 'Code de récupération envoyé par SMS';
      });

      _startResendCountdown();
      
      // Focus sur le premier champ OTP
      _otpFocusNodes[0].requestFocus();

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_currentOtp.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez entrer le code à 6 chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otpService = Provider.of<OtpService>(context, listen: false);
      
      final isValid = await otpService.verifyOtp(
        _phoneController.text.trim(),
        _currentOtp,
      );

      if (isValid) {
        setState(() {
          _isOtpVerified = true;
          _successMessage = 'Code vérifié avec succès';
        });

        // Démarrer le processus de récupération
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.startAccountRecovery(_phoneController.text.trim());

        // Naviguer vers l'écran de nouveau PIN
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/reset-pin',
            arguments: {
              'phoneNumber': _phoneController.text.trim(),
            },
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Code incorrect';
        });
        _clearOtpFields();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _clearOtpFields();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otpService = Provider.of<OtpService>(context, listen: false);
      await otpService.resendOtp(_phoneController.text.trim());
      
      setState(() {
        _successMessage = 'Nouveau code envoyé';
      });
      
      _startResendCountdown();
      _clearOtpFields();
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });
    
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_resendCountdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
          if (_resendCountdown > 0) {
            _updateCountdown();
          }
        }
      });
    }
  }

  void _goBack() {
    if (_isOtpSent && !_isOtpVerified) {
      setState(() {
        _isOtpSent = false;
        _errorMessage = null;
        _successMessage = null;
      });
      _clearOtpFields();
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro de téléphone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          enabled: !_isOtpSent,
          decoration: InputDecoration(
            hintText: '+33 6 12 34 56 78',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.bitcoinOrange,
                width: 2,
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Code de récupération',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.bitcoinOrange,
                      width: 2,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => _onOtpDigitChanged(index, value),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendCountdown > 0 ? null : _resendOtp,
            child: Text(
              _resendCountdown > 0
                  ? 'Renvoyer dans ${_resendCountdown}s'
                  : 'Renvoyer le code',
              style: TextStyle(
                color: _resendCountdown > 0 
                    ? Colors.grey 
                    : AppTheme.bitcoinOrange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: const AssetImage('assets/images/pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
                colorFilter: ColorFilter.mode(
                  AppTheme.bitcoinOrange.withValues(alpha: 0.2),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: _goBack,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Expanded(
                          child: Text(
                            'Récupération d\'accès',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    
                    SizedBox(height: size.height * 0.06),
                    
                    // Icon and description
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.bitcoinOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              _isOtpSent ? Icons.sms_outlined : Icons.lock_reset,
                              size: 40,
                              color: AppTheme.bitcoinOrange,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isOtpSent
                                ? 'Vérifiez vos SMS'
                                : 'Récupérer votre accès',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isOtpSent
                                ? 'Entrez le code de récupération reçu par SMS'
                                : 'Nous vous enverrons un code par SMS pour récupérer l\'accès à votre compte',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.06),
                    
                    // Input fields
                    if (!_isOtpSent) _buildPhoneInput(),
                    if (_isOtpSent) _buildOtpInput(),
                    
                    const SizedBox(height: 32),
                    
                    // Warning message
                    if (!_isOtpSent)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.amber.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Important',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cette récupération vous permettra de créer un nouveau PIN d\'accès. Votre seed phrase et vos bitcoins resteront en sécurité.',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Success message
                    if (_successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: TextStyle(color: Colors.green.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isOtpSent ? _verifyOtp : _sendRecoveryOtp),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isOtpSent ? 'Vérifier le code' : 'Envoyer le code'),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}