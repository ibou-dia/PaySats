import 'dart:math';
import 'package:flutter/foundation.dart';

enum OtpType {
  registration,
  recovery,
  phoneVerification,
}

class OtpRequest {
  final String phoneNumber;
  final OtpType type;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final int attempts;

  const OtpRequest({
    required this.phoneNumber,
    required this.type,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired && attempts < 3;

  OtpRequest copyWith({
    String? phoneNumber,
    OtpType? type,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
    int? attempts,
  }) {
    return OtpRequest(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      type: type ?? this.type,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      attempts: attempts ?? this.attempts,
    );
  }
}

class OtpService extends ChangeNotifier {
  final Map<String, OtpRequest> _activeRequests = {};
  final Map<String, DateTime> _lastRequestTimes = {};

  /// Envoie un code OTP par SMS
  Future<bool> sendOtp(String phoneNumber, OtpType type) async {
    try {
      // Vérifier le délai entre les demandes (1 minute minimum)
      if (_canSendOtp(phoneNumber)) {
        final code = _generateOtpCode();
        final request = OtpRequest(
          phoneNumber: phoneNumber,
          type: type,
          code: code,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );

        _activeRequests[phoneNumber] = request;
        _lastRequestTimes[phoneNumber] = DateTime.now();

        // Simuler l'envoi SMS (dans une vraie app, utiliser un service SMS)
        await _simulateSmsDelivery(phoneNumber, code, type);

        notifyListeners();
        return true;
      } else {
        throw Exception('Veuillez attendre avant de demander un nouveau code');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi OTP: $e');
      return false;
    }
  }

  /// Vérifie un code OTP
  Future<bool> verifyOtp(String phoneNumber, String code) async {
    try {
      final request = _activeRequests[phoneNumber];
      
      if (request == null) {
        throw Exception('Aucun code OTP en attente pour ce numéro');
      }

      if (!request.isValid) {
        if (request.isExpired) {
          throw Exception('Le code OTP a expiré');
        } else if (request.isUsed) {
          throw Exception('Ce code OTP a déjà été utilisé');
        } else if (request.attempts >= 3) {
          throw Exception('Trop de tentatives. Demandez un nouveau code');
        }
      }

      if (request.code == code) {
        // Code correct
        _activeRequests[phoneNumber] = request.copyWith(isUsed: true);
        notifyListeners();
        return true;
      } else {
        // Code incorrect
        _activeRequests[phoneNumber] = request.copyWith(
          attempts: request.attempts + 1,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification OTP: $e');
      rethrow;
    }
  }

  /// Renvoie un code OTP
  Future<bool> resendOtp(String phoneNumber) async {
    final request = _activeRequests[phoneNumber];
    if (request == null) {
      throw Exception('Aucun code OTP en cours pour ce numéro');
    }

    return await sendOtp(phoneNumber, request.type);
  }

  /// Annule une demande OTP
  void cancelOtp(String phoneNumber) {
    _activeRequests.remove(phoneNumber);
    notifyListeners();
  }

  /// Vérifie si un OTP est en attente pour un numéro
  bool hasActiveOtp(String phoneNumber) {
    final request = _activeRequests[phoneNumber];
    return request != null && request.isValid;
  }

  /// Obtient le temps restant avant expiration (en secondes)
  int getTimeRemaining(String phoneNumber) {
    final request = _activeRequests[phoneNumber];
    if (request == null) return 0;

    final remaining = request.expiresAt.difference(DateTime.now());
    return remaining.inSeconds.clamp(0, double.infinity).toInt();
  }

  /// Obtient le temps restant avant pouvoir renvoyer (en secondes)
  int getResendTimeRemaining(String phoneNumber) {
    final lastRequest = _lastRequestTimes[phoneNumber];
    if (lastRequest == null) return 0;

    final nextAllowed = lastRequest.add(const Duration(minutes: 1));
    final remaining = nextAllowed.difference(DateTime.now());
    return remaining.inSeconds.clamp(0, double.infinity).toInt();
  }

  /// Nettoie les demandes expirées
  void cleanupExpiredRequests() {
    final now = DateTime.now();
    _activeRequests.removeWhere((key, request) => 
        request.isExpired || request.isUsed);
    
    // Nettoyer les anciens temps de demande (plus de 24h)
    _lastRequestTimes.removeWhere((key, time) => 
        now.difference(time).inHours > 24);
    
    notifyListeners();
  }

  // Méthodes privées

  bool _canSendOtp(String phoneNumber) {
    final lastRequest = _lastRequestTimes[phoneNumber];
    if (lastRequest == null) return true;

    final timeSinceLastRequest = DateTime.now().difference(lastRequest);
    return timeSinceLastRequest.inMinutes >= 1;
  }

  String _generateOtpCode() {
    final random = Random.secure();
    final code = random.nextInt(9000) + 1000; // 4 chiffres
    return code.toString();
  }

  Future<void> _simulateSmsDelivery(String phoneNumber, String code, OtpType type) async {
    // Simuler un délai d'envoi SMS
    await Future.delayed(const Duration(seconds: 2));

    String message;
    switch (type) {
      case OtpType.registration:
        message = 'Votre code de vérification PaySats: $code. Valide 5 minutes.';
        break;
      case OtpType.recovery:
        message = 'Code de récupération PaySats: $code. Valide 5 minutes.';
        break;
      case OtpType.phoneVerification:
        message = 'Code de vérification téléphone PaySats: $code. Valide 5 minutes.';
        break;
    }

    // En mode debug, afficher le code dans la console
    if (kDebugMode) {
      debugPrint('📱 SMS envoyé à $phoneNumber: $message');
    }

    // Dans une vraie application, ici on appellerait l'API SMS
    // Exemples: Twilio, AWS SNS, Firebase Auth, etc.
  }

  /// Méthode pour les tests - obtient le code OTP actuel
  @visibleForTesting
  String? getCurrentOtpCode(String phoneNumber) {
    return _activeRequests[phoneNumber]?.code;
  }

  /// Méthode pour les tests - force l'expiration d'un OTP
  @visibleForTesting
  void forceExpireOtp(String phoneNumber) {
    final request = _activeRequests[phoneNumber];
    if (request != null) {
      _activeRequests[phoneNumber] = request.copyWith(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      notifyListeners();
    }
  }
}