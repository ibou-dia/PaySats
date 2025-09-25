import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import '../models/user.dart';
import '../models/auth_state.dart';
import '../models/seed_phrase.dart';
import '../models/wallet.dart';

class AuthService extends ChangeNotifier {
  static const String _authStateKey = 'auth_state';
  static const String _userKey = 'user_data';
  static const String _seedPhraseKey = 'seed_phrase';
  static const String _pinHashKey = 'pin_hash';
  static const String _walletKey = 'wallet_data';

  AuthState _authState = AuthState.initial;
  User? _currentUser;
  SeedPhrase? _seedPhrase;
  Wallet? _wallet;

  AuthState get authState => _authState;
  User? get currentUser => _currentUser;
  SeedPhrase? get seedPhrase => _seedPhrase;
  Wallet? get wallet => _wallet;

  bool get isAuthenticated => _authState.isAuthenticated;
  bool get isRegistering => _authState.isRegistering;

  /// Initialise le service d'authentification
  Future<void> initialize() async {
    await _loadAuthState();
    await _loadUserData();
    await _checkSessionValidity();
  }

  /// Démarre le processus d'inscription
  Future<String> startRegistration(String phoneNumber) async {
    try {
      // Générer un token temporaire pour l'inscription
      final token = _generateRegistrationToken();
      
      _authState = _authState.copyWith(
        status: AuthStatus.registering,
        tempRegistrationToken: token,
        pendingPhoneNumber: phoneNumber,
      );
      
      await _saveAuthState();
      notifyListeners();
      
      return token;
    } catch (e) {
      throw Exception('Erreur lors du démarrage de l\'inscription: $e');
    }
  }

  /// Génère un nouveau wallet Bitcoin avec seed phrase
  Future<SeedPhrase> generateWallet({bool use24Words = false}) async {
    try {
      // Générer la seed phrase
      final seedPhrase = use24Words 
          ? SeedPhrase.generate24Words()
          : SeedPhrase.generate12Words();

      // Générer le wallet à partir de la seed phrase
      final wallet = await _generateWalletFromSeed(seedPhrase);

      _seedPhrase = seedPhrase;
      _wallet = wallet;

      // Mettre à jour l'état d'authentification
      _authState = _authState.copyWith(
        hasSeedPhrase: true,
        status: AuthStatus.pendingSeedBackup,
      );

      await _saveSeedPhrase(seedPhrase);
      await _saveWallet(wallet);
      await _saveAuthState();
      
      notifyListeners();
      return seedPhrase;
    } catch (e) {
      throw Exception('Erreur lors de la génération du wallet: $e');
    }
  }

  /// Marque la seed phrase comme sauvegardée sans vérification
  Future<void> markSeedPhraseAsBackedUp() async {
    if (_seedPhrase == null) {
      throw Exception('Aucune seed phrase générée');
    }

    _seedPhrase = _seedPhrase!.copyWith(
      isVerified: true,
      isBackedUp: true,
    );

    _authState = _authState.copyWith(
      isSeedPhraseBackedUp: true,
      status: AuthStatus.pendingPinSetup,
    );

    await _saveSeedPhrase(_seedPhrase!);
    await _saveAuthState();
    notifyListeners();
  }

  /// Vérifie la sauvegarde de la seed phrase
  Future<bool> verifySeedPhraseBackup(List<String> userWords) async {
    if (_seedPhrase == null) {
      throw Exception('Aucune seed phrase générée');
    }

    final isValid = _seedPhrase!.words.length == userWords.length &&
        _seedPhrase!.words.every((word) => userWords.contains(word));

    if (isValid) {
      _seedPhrase = _seedPhrase!.copyWith(
        isVerified: true,
        isBackedUp: true,
      );

      _authState = _authState.copyWith(
        isSeedPhraseBackedUp: true,
        status: AuthStatus.pendingOtpVerification,
      );

      await _saveSeedPhrase(_seedPhrase!);
      await _saveAuthState();
      notifyListeners();
    }

    return isValid;
  }

  /// Configure le PIN de sécurité
  Future<void> setupPin(String pin) async {
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw Exception('Le PIN doit contenir exactement 6 chiffres');
    }

    try {
      final pinHash = _hashPin(pin);
      await _savePinHash(pinHash);

      _authState = _authState.copyWith(
        hasPinSetup: true,
        status: AuthStatus.authenticated,
        sessionExpiresAt: DateTime.now().add(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );

      await _saveAuthState();
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de la configuration du PIN: $e');
    }
  }

  /// Finalise l'inscription après vérification OTP
  Future<void> completeRegistration(String userId) async {
    if (_authState.pendingPhoneNumber == null) {
      throw Exception('Aucune inscription en cours');
    }

    try {
      // Créer l'utilisateur
      final user = User(
        id: userId,
        phoneNumber: _authState.pendingPhoneNumber!,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isPhoneVerified: true,
      );

      _currentUser = user;
      
      _authState = _authState.copyWith(
        userId: userId,
        phoneNumber: _authState.pendingPhoneNumber,
        status: AuthStatus.pendingPinSetup,
        tempRegistrationToken: null,
        pendingPhoneNumber: null,
      );

      await _saveUserData(user);
      await _saveAuthState();
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de la finalisation de l\'inscription: $e');
    }
  }

  /// Connexion avec PIN
  Future<bool> loginWithPin(String pin) async {
    if (_authState.isLocked) {
      throw Exception('Compte verrouillé. Réessayez dans ${_authState.minutesUntilUnlock} minutes.');
    }

    try {
      final storedPinHash = await _loadPinHash();
      if (storedPinHash == null) {
        throw Exception('Aucun PIN configuré');
      }

      final pinHash = _hashPin(pin);
      
      if (pinHash == storedPinHash) {
        // PIN correct
        _authState = _authState.copyWith(
          status: AuthStatus.authenticated,
          failedPinAttempts: 0,
          lockedUntil: null,
          lastLoginAt: DateTime.now(),
          sessionExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );

        await _saveAuthState();
        notifyListeners();
        return true;
      } else {
        // PIN incorrect
        _authState = _authState.incrementFailedAttempts();
        await _saveAuthState();
        notifyListeners();
        return false;
      }
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _authState = AuthState.initial;
    _currentUser = null;
    
    await _saveAuthState();
    notifyListeners();
  }

  /// Démarrer la récupération de compte
  Future<void> startAccountRecovery(String phoneNumber) async {
    _authState = _authState.copyWith(
      status: AuthStatus.pendingOtpVerification,
      pendingPhoneNumber: phoneNumber,
    );

    await _saveAuthState();
    notifyListeners();
  }

  /// Réinitialiser le PIN après récupération OTP
  Future<void> resetPinAfterRecovery(String newPin) async {
    if (newPin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(newPin)) {
      throw Exception('Le PIN doit contenir exactement 6 chiffres');
    }

    try {
      final pinHash = _hashPin(newPin);
      await _savePinHash(pinHash);

      _authState = _authState.copyWith(
        status: AuthStatus.authenticated,
        failedPinAttempts: 0,
        lockedUntil: null,
        sessionExpiresAt: DateTime.now().add(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );

      await _saveAuthState();
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation du PIN: $e');
    }
  }

  /// Supprime toutes les données d'authentification (pour les tests)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authStateKey);
    await prefs.remove(_userKey);
    await prefs.remove(_seedPhraseKey);
    await prefs.remove(_pinHashKey);
    await prefs.remove(_walletKey);

    _authState = AuthState.initial;
    _currentUser = null;
    _seedPhrase = null;
    _wallet = null;

    notifyListeners();
  }

  // Méthodes privées

  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authStateJson = prefs.getString(_authStateKey);
      
      if (authStateJson != null) {
        final authStateMap = jsonDecode(authStateJson);
        _authState = AuthState.fromJson(authStateMap);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'état d\'authentification: $e');
    }
  }

  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authStateJson = jsonEncode(_authState.toJson());
      await prefs.setString(_authStateKey, authStateJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'état d\'authentification: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = User.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des données utilisateur: $e');
    }
  }

  Future<void> _saveSeedPhrase(SeedPhrase seedPhrase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seedPhraseJson = jsonEncode(seedPhrase.toJson());
      await prefs.setString(_seedPhraseKey, seedPhraseJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la seed phrase: $e');
    }
  }

  Future<void> _saveWallet(Wallet wallet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final walletJson = jsonEncode(wallet.toJson());
      await prefs.setString(_walletKey, walletJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du wallet: $e');
    }
  }

  Future<String?> _loadPinHash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinHashKey);
    } catch (e) {
      debugPrint('Erreur lors du chargement du hash PIN: $e');
      return null;
    }
  }

  Future<void> _savePinHash(String pinHash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinHashKey, pinHash);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du hash PIN: $e');
    }
  }

  Future<void> _checkSessionValidity() async {
    if (_authState.isAuthenticated && !_authState.isSessionValid) {
      _authState = _authState.expireSession();
      await _saveAuthState();
      notifyListeners();
    }
  }

  String _generateRegistrationToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + 'paysats_salt_2024');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Wallet> _generateWalletFromSeed(SeedPhrase seedPhrase) async {
    // Simulation de génération de wallet Bitcoin
    // Dans une vraie implémentation, on utiliserait une bibliothèque crypto
    final random = Random(seedPhrase.phrase.hashCode);
    
    // Générer une adresse Bitcoin simulée
    final addressBytes = List<int>.generate(20, (i) => random.nextInt(256));
    final address = '1${base64Encode(addressBytes).substring(0, 26)}';
    
    // Générer une clé publique simulée
    final publicKeyBytes = List<int>.generate(33, (i) => random.nextInt(256));
    final publicKey = base64Encode(publicKeyBytes);

    return Wallet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _authState.userId ?? 'temp_user',
      name: 'Mon Wallet Bitcoin',
      type: WalletType.bitcoin,
      address: address,
      publicKey: publicKey,
      balance: 0.0,
      currency: 'SATS',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Authentifier directement l'utilisateur sans PIN
  Future<void> authenticateDirectly() async {
    try {
      _authState = _authState.copyWith(
        status: AuthStatus.authenticated,
        sessionExpiresAt: DateTime.now().add(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      );

      await _saveAuthState();
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de l\'authentification: $e');
    }
  }
}