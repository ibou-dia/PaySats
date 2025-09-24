import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final List<TextEditingController> _confirmControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _confirmFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isConfirmStep = false;
  String _firstPin = '';
  String? _phoneNumber;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Récupérer les arguments de navigation
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _phoneNumber = args?['phoneNumber'];
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _confirmControllers) {
      controller.dispose();
    }
    for (var focusNode in _confirmFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _currentPin {
    final controllers = _isConfirmStep ? _confirmControllers : _pinControllers;
    return controllers.map((controller) => controller.text).join();
  }

  void _onPinDigitChanged(int index, String value) {
    final focusNodes = _isConfirmStep ? _confirmFocusNodes : _pinFocusNodes;

    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Auto-proceed when PIN is complete
    if (_currentPin.length == 6) {
      if (_isConfirmStep) {
        _confirmPin();
      } else {
        _proceedToConfirm();
      }
    }

    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _proceedToConfirm() {
    if (_currentPin.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez entrer un PIN à 6 chiffres';
      });
      return;
    }

    setState(() {
      _firstPin = _currentPin;
      _isConfirmStep = true;
      _errorMessage = null;
    });

    // Focus on first confirm field
    _confirmFocusNodes[0].requestFocus();
  }

  Future<void> _confirmPin() async {
    if (_currentPin.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez confirmer votre PIN à 6 chiffres';
      });
      return;
    }

    if (_firstPin != _currentPin) {
      setState(() {
        _errorMessage = 'Les codes PIN ne correspondent pas';
      });
      _resetConfirmPin();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPinAfterRecovery(_currentPin);

      if (mounted) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN réinitialisé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Naviguer vers l'écran de connexion
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _resetToFirstStep();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetConfirmPin() {
    for (var controller in _confirmControllers) {
      controller.clear();
    }
    _confirmFocusNodes[0].requestFocus();
  }

  void _resetToFirstStep() {
    setState(() {
      _isConfirmStep = false;
      _firstPin = '';
    });

    for (var controller in _pinControllers) {
      controller.clear();
    }
    for (var controller in _confirmControllers) {
      controller.clear();
    }

    _pinFocusNodes[0].requestFocus();
  }

  void _goBack() {
    if (_isConfirmStep) {
      setState(() {
        _isConfirmStep = false;
        _errorMessage = null;
      });
      _resetConfirmPin();
      _pinFocusNodes[0].requestFocus();
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildPinInput({
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextFormField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
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
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _onPinDigitChanged(index, value),
              ),
            );
          }),
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
                        Expanded(
                          child: Text(
                            _isConfirmStep
                                ? 'Confirmer le nouveau PIN'
                                : 'Nouveau PIN',
                            style: const TextStyle(
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
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              _isConfirmStep
                                  ? Icons.check_circle_outline
                                  : Icons.lock_reset,
                              size: 40,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isConfirmStep
                                ? 'Confirmez votre nouveau PIN'
                                : 'Créez un nouveau PIN',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isConfirmStep
                                ? 'Saisissez à nouveau votre nouveau PIN'
                                : 'Votre ancien PIN sera remplacé par ce nouveau code',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_phoneNumber != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Compte: $_phoneNumber',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // PIN Input
                    _buildPinInput(
                      controllers:
                          _isConfirmStep
                              ? _confirmControllers
                              : _pinControllers,
                      focusNodes:
                          _isConfirmStep ? _confirmFocusNodes : _pinFocusNodes,
                      label:
                          _isConfirmStep
                              ? 'Confirmez votre nouveau PIN'
                              : 'Entrez votre nouveau PIN',
                    ),

                    const SizedBox(height: 32),

                    // Security info
                    if (!_isConfirmStep)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Récupération réussie',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...const [
                              '• Votre wallet et vos bitcoins sont en sécurité',
                              '• Seul l\'accès par PIN est réinitialisé',
                              '• Choisissez un code facile à retenir',
                              '• Évitez les séquences simples (123456)',
                            ].map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                            ),
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
                        onPressed:
                            _isLoading || _currentPin.length != 6
                                ? null
                                : (_isConfirmStep
                                    ? _confirmPin
                                    : _proceedToConfirm),
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
                                : Text(
                                  _isConfirmStep
                                      ? 'Réinitialiser le PIN'
                                      : 'Continuer',
                                ),
                      ),
                    ),

                    // Progress indicator
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  _isConfirmStep
                                      ? Colors.green.shade600
                                      : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
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
          ),
        ],
      ),
    );
  }
}
