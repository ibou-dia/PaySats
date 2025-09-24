import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/otp_service.dart';
import '../theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  String? _phoneNumber;
  String? _firstName;
  String? _lastName;
  OtpType? _otpType;
  String? _registrationToken;
  String? _nextRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
      _startResendTimer();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _loadArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phoneNumber = args['phoneNumber'] as String?;
      _firstName = args['firstName'] as String?;
      _lastName = args['lastName'] as String?;
      _otpType = args['type'] as OtpType?;
      _registrationToken = args['registrationToken'] as String?;
      _nextRoute = args['nextRoute'] as String?;
    }
  }

  void _startResendTimer() {
    final otpService = Provider.of<OtpService>(context, listen: false);
    if (_phoneNumber != null) {
      _resendCountdown = otpService.getResendTimeRemaining(_phoneNumber!);

      if (_resendCountdown > 0) {
        _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _resendCountdown--;
          });

          if (_resendCountdown <= 0) {
            timer.cancel();
          }
        });
      }
    }
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all digits are entered
    if (_otpCode.length == 4) {
      _verifyOtp();
    }

    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 4 || _phoneNumber == null) {
      setState(() {
        _errorMessage = 'Veuillez entrer le code à 4 chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otpService = Provider.of<OtpService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final isValid = await otpService.verifyOtp(_phoneNumber!, _otpCode);

      if (isValid) {
        // OTP valide - continuer selon le type
        if (_otpType == OtpType.registration) {
          // Finaliser l'inscription
          final userId = DateTime.now().millisecondsSinceEpoch.toString();
          await authService.completeRegistration(userId);

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              _nextRoute ?? '/seed-backup',
            );
          }
        } else if (_otpType == OtpType.recovery) {
          // Récupération de compte - aller à la réinitialisation du PIN
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/pin-setup');
          }
        } else {
          // Vérification téléphone standard
          if (mounted) {
            Navigator.pushReplacementNamed(context, _nextRoute ?? '/home');
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Code incorrect. Veuillez réessayer.';
        });
        _clearOtpFields();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _clearOtpFields();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    if (_phoneNumber == null || _otpType == null || _resendCountdown > 0) {
      return;
    }

    try {
      final otpService = Provider.of<OtpService>(context, listen: false);
      final success = await otpService.resendOtp(_phoneNumber!);

      if (success) {
        _startResendTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code renvoyé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTitle() {
    switch (_otpType) {
      case OtpType.registration:
        return 'Vérification d\'inscription';
      case OtpType.recovery:
        return 'Récupération de compte';
      case OtpType.phoneVerification:
        return 'Vérification téléphone';
      default:
        return 'Vérification';
    }
  }

  String _getDescription() {
    final maskedPhone =
        _phoneNumber != null
            ? '${_phoneNumber!.substring(0, 3)}***${_phoneNumber!.substring(_phoneNumber!.length - 2)}'
            : '';

    switch (_otpType) {
      case OtpType.registration:
        return 'Entrez le code de vérification envoyé au $maskedPhone pour finaliser votre inscription';
      case OtpType.recovery:
        return 'Entrez le code de récupération envoyé au $maskedPhone pour réinitialiser votre accès';
      case OtpType.phoneVerification:
        return 'Entrez le code de vérification envoyé au $maskedPhone';
      default:
        return 'Entrez le code de vérification reçu par SMS';
    }
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
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
                            color: AppTheme.bitcoinOrange.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.sms_outlined,
                            size: 40,
                            color: AppTheme.bitcoinOrange,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _getDescription(),
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

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 55,
                        height: 55,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
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
                              borderSide: BorderSide(
                                color: AppTheme.bitcoinOrange,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => _onDigitChanged(index, value),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

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

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading || _otpCode.length != 4
                              ? null
                              : _verifyOtp,
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Vérifier'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Resend code
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Vous n\'avez pas reçu le code ?',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _resendCountdown > 0 ? null : _resendOtp,
                          child: Text(
                            _resendCountdown > 0
                                ? 'Renvoyer dans ${_resendCountdown}s'
                                : 'Renvoyer le code',
                            style: TextStyle(
                              color:
                                  _resendCountdown > 0
                                      ? AppTheme.textSecondary
                                      : AppTheme.bitcoinOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
