enum SecurityLevel {
  basic,
  enhanced,
  maximum
}

enum RecoveryMethod {
  seedPhrase,
  phoneOTP,
  biometric
}

class WalletSecurity {
  final String id;
  final String userId;
  final String walletId;
  final bool hasSeedPhrase;
  final bool isSeedPhraseBackedUp;
  final DateTime? seedPhraseBackupDate;
  final bool hasPIN;
  final DateTime? pinCreatedAt;
  final DateTime? lastPinChangeAt;
  final int pinAttempts;
  final bool isPinLocked;
  final DateTime? pinLockUntil;
  final bool biometricEnabled;
  final String? recoveryPhoneNumber;
  final bool isPhoneVerified;
  final DateTime? lastPhoneVerificationAt;
  final SecurityLevel securityLevel;
  final List<RecoveryMethod> enabledRecoveryMethods;
  final DateTime createdAt;
  final DateTime? lastSecurityUpdateAt;
  final Map<String, dynamic>? securitySettings;

  const WalletSecurity({
    required this.id,
    required this.userId,
    required this.walletId,
    this.hasSeedPhrase = false,
    this.isSeedPhraseBackedUp = false,
    this.seedPhraseBackupDate,
    this.hasPIN = false,
    this.pinCreatedAt,
    this.lastPinChangeAt,
    this.pinAttempts = 0,
    this.isPinLocked = false,
    this.pinLockUntil,
    this.biometricEnabled = false,
    this.recoveryPhoneNumber,
    this.isPhoneVerified = false,
    this.lastPhoneVerificationAt,
    this.securityLevel = SecurityLevel.basic,
    this.enabledRecoveryMethods = const [],
    required this.createdAt,
    this.lastSecurityUpdateAt,
    this.securitySettings,
  });

  // Create a copy of the wallet security with updated properties
  WalletSecurity copyWith({
    String? id,
    String? userId,
    String? walletId,
    bool? hasSeedPhrase,
    bool? isSeedPhraseBackedUp,
    DateTime? seedPhraseBackupDate,
    bool? hasPIN,
    DateTime? pinCreatedAt,
    DateTime? lastPinChangeAt,
    int? pinAttempts,
    bool? isPinLocked,
    DateTime? pinLockUntil,
    bool? biometricEnabled,
    String? recoveryPhoneNumber,
    bool? isPhoneVerified,
    DateTime? lastPhoneVerificationAt,
    SecurityLevel? securityLevel,
    List<RecoveryMethod>? enabledRecoveryMethods,
    DateTime? createdAt,
    DateTime? lastSecurityUpdateAt,
    Map<String, dynamic>? securitySettings,
  }) {
    return WalletSecurity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      hasSeedPhrase: hasSeedPhrase ?? this.hasSeedPhrase,
      isSeedPhraseBackedUp: isSeedPhraseBackedUp ?? this.isSeedPhraseBackedUp,
      seedPhraseBackupDate: seedPhraseBackupDate ?? this.seedPhraseBackupDate,
      hasPIN: hasPIN ?? this.hasPIN,
      pinCreatedAt: pinCreatedAt ?? this.pinCreatedAt,
      lastPinChangeAt: lastPinChangeAt ?? this.lastPinChangeAt,
      pinAttempts: pinAttempts ?? this.pinAttempts,
      isPinLocked: isPinLocked ?? this.isPinLocked,
      pinLockUntil: pinLockUntil ?? this.pinLockUntil,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      recoveryPhoneNumber: recoveryPhoneNumber ?? this.recoveryPhoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      lastPhoneVerificationAt: lastPhoneVerificationAt ?? this.lastPhoneVerificationAt,
      securityLevel: securityLevel ?? this.securityLevel,
      enabledRecoveryMethods: enabledRecoveryMethods ?? this.enabledRecoveryMethods,
      createdAt: createdAt ?? this.createdAt,
      lastSecurityUpdateAt: lastSecurityUpdateAt ?? this.lastSecurityUpdateAt,
      securitySettings: securitySettings ?? this.securitySettings,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'walletId': walletId,
      'hasSeedPhrase': hasSeedPhrase,
      'isSeedPhraseBackedUp': isSeedPhraseBackedUp,
      'seedPhraseBackupDate': seedPhraseBackupDate?.toIso8601String(),
      'hasPIN': hasPIN,
      'pinCreatedAt': pinCreatedAt?.toIso8601String(),
      'lastPinChangeAt': lastPinChangeAt?.toIso8601String(),
      'pinAttempts': pinAttempts,
      'isPinLocked': isPinLocked,
      'pinLockUntil': pinLockUntil?.toIso8601String(),
      'biometricEnabled': biometricEnabled,
      'recoveryPhoneNumber': recoveryPhoneNumber,
      'isPhoneVerified': isPhoneVerified,
      'lastPhoneVerificationAt': lastPhoneVerificationAt?.toIso8601String(),
      'securityLevel': securityLevel.name,
      'enabledRecoveryMethods': enabledRecoveryMethods.map((e) => e.name).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastSecurityUpdateAt': lastSecurityUpdateAt?.toIso8601String(),
      'securitySettings': securitySettings,
    };
  }

  // Create from JSON
  factory WalletSecurity.fromJson(Map<String, dynamic> json) {
    return WalletSecurity(
      id: json['id'],
      userId: json['userId'],
      walletId: json['walletId'],
      hasSeedPhrase: json['hasSeedPhrase'] ?? false,
      isSeedPhraseBackedUp: json['isSeedPhraseBackedUp'] ?? false,
      seedPhraseBackupDate: json['seedPhraseBackupDate'] != null 
          ? DateTime.parse(json['seedPhraseBackupDate']) 
          : null,
      hasPIN: json['hasPIN'] ?? false,
      pinCreatedAt: json['pinCreatedAt'] != null 
          ? DateTime.parse(json['pinCreatedAt']) 
          : null,
      lastPinChangeAt: json['lastPinChangeAt'] != null 
          ? DateTime.parse(json['lastPinChangeAt']) 
          : null,
      pinAttempts: json['pinAttempts'] ?? 0,
      isPinLocked: json['isPinLocked'] ?? false,
      pinLockUntil: json['pinLockUntil'] != null 
          ? DateTime.parse(json['pinLockUntil']) 
          : null,
      biometricEnabled: json['biometricEnabled'] ?? false,
      recoveryPhoneNumber: json['recoveryPhoneNumber'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      lastPhoneVerificationAt: json['lastPhoneVerificationAt'] != null 
          ? DateTime.parse(json['lastPhoneVerificationAt']) 
          : null,
      securityLevel: SecurityLevel.values.firstWhere(
        (e) => e.name == json['securityLevel'],
        orElse: () => SecurityLevel.basic,
      ),
      enabledRecoveryMethods: (json['enabledRecoveryMethods'] as List<dynamic>?)
          ?.map((e) => RecoveryMethod.values.firstWhere((method) => method.name == e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      lastSecurityUpdateAt: json['lastSecurityUpdateAt'] != null 
          ? DateTime.parse(json['lastSecurityUpdateAt']) 
          : null,
      securitySettings: json['securitySettings'],
    );
  }

  // Get security score (0-100)
  int get securityScore {
    int score = 0;
    
    if (hasSeedPhrase) score += 30;
    if (isSeedPhraseBackedUp) score += 20;
    if (hasPIN) score += 20;
    if (biometricEnabled) score += 15;
    if (isPhoneVerified) score += 10;
    if (enabledRecoveryMethods.length >= 2) score += 5;
    
    return score.clamp(0, 100);
  }

  // Get security level display name
  String get securityLevelDisplayName {
    switch (securityLevel) {
      case SecurityLevel.basic:
        return 'Basique';
      case SecurityLevel.enhanced:
        return 'Renforcée';
      case SecurityLevel.maximum:
        return 'Maximale';
    }
  }

  // Check if wallet is properly secured
  bool get isProperlySecured {
    return hasSeedPhrase && isSeedPhraseBackedUp && hasPIN;
  }

  // Check if PIN is currently usable
  bool get canUsePIN {
    if (!hasPIN) return false;
    if (isPinLocked && pinLockUntil != null) {
      return DateTime.now().isAfter(pinLockUntil!);
    }
    return !isPinLocked;
  }

  // Get remaining PIN lock time in minutes
  int? get pinLockRemainingMinutes {
    if (!isPinLocked || pinLockUntil == null) return null;
    final remaining = pinLockUntil!.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : null;
  }

  // Check if recovery is available
  bool get hasRecoveryOptions {
    return enabledRecoveryMethods.isNotEmpty;
  }

  // Get recommended security improvements
  List<String> get securityRecommendations {
    List<String> recommendations = [];
    
    if (!hasSeedPhrase) {
      recommendations.add('Générer une phrase de récupération');
    } else if (!isSeedPhraseBackedUp) {
      recommendations.add('Sauvegarder votre phrase de récupération');
    }
    
    if (!hasPIN) {
      recommendations.add('Configurer un code PIN');
    }
    
    if (!biometricEnabled) {
      recommendations.add('Activer l\'authentification biométrique');
    }
    
    if (!isPhoneVerified) {
      recommendations.add('Vérifier votre numéro de téléphone');
    }
    
    if (enabledRecoveryMethods.length < 2) {
      recommendations.add('Configurer plusieurs méthodes de récupération');
    }
    
    return recommendations;
  }
}