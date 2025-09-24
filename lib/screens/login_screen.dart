import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/auth_state.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  bool _isLoading = false;
  String? _errorMessage;
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockoutSeconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _animationController.forward();
    
    // Check if account is locked
    _checkLockStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkLockStatus() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final authState = authService.authState;
    
    if (authState.status == AuthStatus.locked) {
      setState(() {
        _isLocked = true;
        _failedAttempts = authState.failedPinAttempts;
      });
      _startLockoutTimer();
    }
  }

  void _startLockoutTimer() {
    // Lockout duration increases with failed attempts
    final baseLockout = 30; // 30 seconds base
    final multiplier = _failedAttempts > 3 ? (_failedAttempts - 2) : 1;
    _lockoutSeconds = baseLockout * multiplier;
    
    _updateLockoutTimer();
  }

  void _updateLockoutTimer() {
    if (_lockoutSeconds > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _lockoutSeconds--;
          });
          if (_lockoutSeconds > 0) {
            _updateLockoutTimer();
          } else {
            setState(() {
              _isLocked = false;
            });
          }
        }
      });
    }
  }

  String get _currentPin {
    return _pinControllers.map((controller) => controller.text).join();
  }

  void _onPinDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }

    // Auto-login when PIN is complete
    if (_currentPin.length == 6) {
      _login();
    }

    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _login() async {
    if (_isLocked) {
      setState(() {
        _errorMessage = 'Compte temporairement verrouillé';
      });
      return;
    }

    if (_currentPin.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre PIN à 6 chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.loginWithPin(_currentPin);

      if (success && mounted) {
        // Naviguer vers l'écran d'accueil
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        _handleLoginFailure();
      }
    } catch (e) {
      _handleLoginFailure(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLoginFailure([String? error]) {
    setState(() {
      _failedAttempts++;
      _errorMessage = error ?? 'PIN incorrect';
    });

    // Shake animation
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    // Clear PIN fields
    for (var controller in _pinControllers) {
      controller.clear();
    }
    _pinFocusNodes[0].requestFocus();

    // Lock account after too many attempts
    if (_failedAttempts >= 5) {
      setState(() {
        _isLocked = true;
      });
      _startLockoutTimer();
    }
  }

  void _goToRecovery() {
    Navigator.pushNamed(context, '/recovery');
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                  (route) => false,
                );
              }
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInput() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeAnimation.value * 10 * 
            (1 - _shakeAnimation.value) * 
            (_shakeAnimation.value < 0.5 ? 1 : -1);
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrez votre PIN',
                style: TextStyle(
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
                      controller: _pinControllers[index],
                      focusNode: _pinFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      obscureText: true,
                      enabled: !_isLocked && !_isLoading,
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
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onPinDigitChanged(index, value),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header with logout button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        const Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          tooltip: 'Déconnexion',
                        ),
                      ],
                    ),
                    
                    SizedBox(height: size.height * 0.08),
                    
                    // User info and welcome
                    Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.bitcoinOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: user?.profileImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    user!.profileImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppTheme.bitcoinOrange,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bonjour ${user?.displayName ?? 'Utilisateur'} !',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Entrez votre PIN pour accéder à votre wallet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: size.height * 0.08),
                    
                    // PIN Input
                    _buildPinInput(),
                    
                    const SizedBox(height: 32),
                    
                    // Lockout message
                    if (_isLocked)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.lock_clock, color: Colors.orange.shade600),
                            const SizedBox(height: 8),
                            Text(
                              'Compte temporairement verrouillé',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Réessayez dans ${_lockoutSeconds}s',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Error message
                    if (_errorMessage != null && !_isLocked)
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
                    
                    // Failed attempts warning
                    if (_failedAttempts > 0 && _failedAttempts < 5 && !_isLocked)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.yellow.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.yellow.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tentatives échouées: $_failedAttempts/5',
                                style: TextStyle(color: Colors.yellow.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Loading indicator
                    if (_isLoading)
                      const CircularProgressIndicator(
                        color: AppTheme.bitcoinOrange,
                      ),
                    
                    SizedBox(height: size.height * 0.06),
                    
                    // Recovery options
                    Column(
                      children: [
                        TextButton(
                          onPressed: _isLoading ? null : _goToRecovery,
                          child: const Text(
                            'PIN oublié ? Récupérer l\'accès',
                            style: TextStyle(
                              color: AppTheme.bitcoinOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vous recevrez un code par SMS',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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