enum AuthStatus {
  /// Utilisateur non authentifié
  unauthenticated,
  
  /// Utilisateur en cours d'inscription
  registering,
  
  /// En attente de vérification OTP
  pendingOtpVerification,
  
  /// En attente de sauvegarde de la seed phrase
  pendingSeedBackup,
  
  /// En attente de configuration du PIN
  pendingPinSetup,
  
  /// Utilisateur authentifié
  authenticated,
  
  /// Session expirée
  sessionExpired,
  
  /// Compte verrouillé (trop de tentatives de PIN incorrectes)
  locked,
}

enum RecoveryMethod {
  /// Récupération par SMS/OTP
  sms,
  
  /// Récupération par seed phrase (non recommandée pour l'usage quotidien)
  seedPhrase,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? phoneNumber;
  final DateTime? lastLoginAt;
  final DateTime? sessionExpiresAt;
  final int failedPinAttempts;
  final DateTime? lockedUntil;
  final bool hasSeedPhrase;
  final bool isSeedPhraseBackedUp;
  final bool hasPinSetup;
  final String? tempRegistrationToken;
  final String? pendingPhoneNumber;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.userId,
    this.phoneNumber,
    this.lastLoginAt,
    this.sessionExpiresAt,
    this.failedPinAttempts = 0,
    this.lockedUntil,
    this.hasSeedPhrase = false,
    this.isSeedPhraseBackedUp = false,
    this.hasPinSetup = false,
    this.tempRegistrationToken,
    this.pendingPhoneNumber,
  });

  /// État initial (non authentifié)
  static const AuthState initial = AuthState();

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Vérifie si l'utilisateur est en cours d'inscription
  bool get isRegistering => status == AuthStatus.registering;

  /// Vérifie si la session est valide
  bool get isSessionValid {
    if (sessionExpiresAt == null) return false;
    return DateTime.now().isBefore(sessionExpiresAt!);
  }

  /// Vérifie si le compte est verrouillé
  bool get isLocked {
    if (status == AuthStatus.locked && lockedUntil != null) {
      return DateTime.now().isBefore(lockedUntil!);
    }
    return status == AuthStatus.locked;
  }

  /// Vérifie si l'inscription est complète
  bool get isRegistrationComplete {
    return hasSeedPhrase && isSeedPhraseBackedUp && hasPinSetup;
  }

  /// Temps restant avant déverrouillage (en minutes)
  int get minutesUntilUnlock {
    if (lockedUntil == null) return 0;
    final diff = lockedUntil!.difference(DateTime.now());
    return diff.inMinutes.clamp(0, double.infinity).toInt();
  }

  /// Crée une copie avec des propriétés modifiées
  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? phoneNumber,
    DateTime? lastLoginAt,
    DateTime? sessionExpiresAt,
    int? failedPinAttempts,
    DateTime? lockedUntil,
    bool? hasSeedPhrase,
    bool? isSeedPhraseBackedUp,
    bool? hasPinSetup,
    String? tempRegistrationToken,
    String? pendingPhoneNumber,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      sessionExpiresAt: sessionExpiresAt ?? this.sessionExpiresAt,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      hasSeedPhrase: hasSeedPhrase ?? this.hasSeedPhrase,
      isSeedPhraseBackedUp: isSeedPhraseBackedUp ?? this.isSeedPhraseBackedUp,
      hasPinSetup: hasPinSetup ?? this.hasPinSetup,
      tempRegistrationToken: tempRegistrationToken ?? this.tempRegistrationToken,
      pendingPhoneNumber: pendingPhoneNumber ?? this.pendingPhoneNumber,
    );
  }

  /// Réinitialise les tentatives de PIN échouées
  AuthState clearFailedAttempts() {
    return copyWith(
      failedPinAttempts: 0,
      lockedUntil: null,
      status: status == AuthStatus.locked ? AuthStatus.unauthenticated : status,
    );
  }

  /// Incrémente les tentatives de PIN échouées
  AuthState incrementFailedAttempts() {
    final newAttempts = failedPinAttempts + 1;
    
    // Verrouiller après 5 tentatives échouées
    if (newAttempts >= 5) {
      return copyWith(
        failedPinAttempts: newAttempts,
        status: AuthStatus.locked,
        lockedUntil: DateTime.now().add(const Duration(minutes: 30)),
      );
    }
    
    return copyWith(failedPinAttempts: newAttempts);
  }

  /// Marque la session comme expirée
  AuthState expireSession() {
    return copyWith(
      status: AuthStatus.sessionExpired,
      sessionExpiresAt: null,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'sessionExpiresAt': sessionExpiresAt?.toIso8601String(),
      'failedPinAttempts': failedPinAttempts,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'hasSeedPhrase': hasSeedPhrase,
      'isSeedPhraseBackedUp': isSeedPhraseBackedUp,
      'hasPinSetup': hasPinSetup,
      'tempRegistrationToken': tempRegistrationToken,
      'pendingPhoneNumber': pendingPhoneNumber,
    };
  }

  /// Crée une instance depuis un Map
  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      status: AuthStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AuthStatus.unauthenticated,
      ),
      userId: json['userId'],
      phoneNumber: json['phoneNumber'],
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      sessionExpiresAt: json['sessionExpiresAt'] != null 
          ? DateTime.parse(json['sessionExpiresAt']) 
          : null,
      failedPinAttempts: json['failedPinAttempts'] ?? 0,
      lockedUntil: json['lockedUntil'] != null 
          ? DateTime.parse(json['lockedUntil']) 
          : null,
      hasSeedPhrase: json['hasSeedPhrase'] ?? false,
      isSeedPhraseBackedUp: json['isSeedPhraseBackedUp'] ?? false,
      hasPinSetup: json['hasPinSetup'] ?? false,
      tempRegistrationToken: json['tempRegistrationToken'],
      pendingPhoneNumber: json['pendingPhoneNumber'],
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, userId: $userId, isAuthenticated: $isAuthenticated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.userId == userId &&
        other.phoneNumber == phoneNumber &&
        other.lastLoginAt == lastLoginAt &&
        other.sessionExpiresAt == sessionExpiresAt &&
        other.failedPinAttempts == failedPinAttempts &&
        other.lockedUntil == lockedUntil &&
        other.hasSeedPhrase == hasSeedPhrase &&
        other.isSeedPhraseBackedUp == isSeedPhraseBackedUp &&
        other.hasPinSetup == hasPinSetup &&
        other.tempRegistrationToken == tempRegistrationToken &&
        other.pendingPhoneNumber == pendingPhoneNumber;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        userId.hashCode ^
        phoneNumber.hashCode ^
        lastLoginAt.hashCode ^
        sessionExpiresAt.hashCode ^
        failedPinAttempts.hashCode ^
        lockedUntil.hashCode ^
        hasSeedPhrase.hashCode ^
        isSeedPhraseBackedUp.hashCode ^
        hasPinSetup.hashCode ^
        tempRegistrationToken.hashCode ^
        pendingPhoneNumber.hashCode;
  }
}