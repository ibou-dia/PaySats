import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/auth_service.dart';
import '../services/otp_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bitcoin_logo.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _errorMessage;
  String _completePhoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      if (!_acceptedTerms) {
        setState(() {
          _errorMessage = 'Vous devez accepter les conditions d\'utilisation';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final otpService = Provider.of<OtpService>(context, listen: false);

      // Étape 1: Démarrer le processus d'inscription
      final registrationToken = await authService.startRegistration(
        _completePhoneNumber,
      );

      // Étape 2: Générer le wallet Bitcoin
      await authService.generateWallet();

      // Étape 3: Envoyer l'OTP pour vérification
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      final otpSent = await otpService.sendOtp(
        _completePhoneNumber,
        OtpType.registration,
        context: context,
        notificationService: notificationService,
      );

      if (otpSent && mounted) {
        // Naviguer vers l'écran de vérification OTP
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'phoneNumber': _completePhoneNumber,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'type': OtpType.registration,
            'registrationToken': registrationToken,
            'nextRoute': '/seed-backup',
          },
        );
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'envoi du code de vérification';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 2) {
      return 'Minimum 2 caractères';
    }
    return null;
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
              child: Form(
                key: _formKey,
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
                        const Expanded(
                          child: Text(
                            'Créer un compte',
                            style: TextStyle(
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
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // Logo and description
                    Center(
                      child: Column(
                        children: [
                          const BitcoinLogo(size: 60),
                          const SizedBox(height: 16),
                          Text(
                            'Votre wallet Bitcoin sera généré automatiquement',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // Form fields
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'SN', // Sénégal par défaut
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        if (phone.number.length < 7) {
                          return 'Numéro de téléphone trop court';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Terms and conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                              if (_acceptedTerms) _errorMessage = null;
                            });
                          },
                          activeColor: AppTheme.bitcoinOrange,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptedTerms = !_acceptedTerms;
                                if (_acceptedTerms) _errorMessage = null;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(text: 'J\'accepte les '),
                                    TextSpan(
                                      text: 'conditions d\'utilisation',
                                      style: TextStyle(
                                        color: AppTheme.bitcoinOrange,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' et la '),
                                    TextSpan(
                                      text: 'politique de confidentialité',
                                      style: TextStyle(
                                        color: AppTheme.bitcoinOrange,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
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
                    
                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Créer mon compte'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Login link
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          'Déjà un compte ? Se connecter',
                          style: TextStyle(
                            color: AppTheme.bitcoinOrange,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.02),
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