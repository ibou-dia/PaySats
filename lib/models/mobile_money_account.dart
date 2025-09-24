enum MobileMoneyProvider {
  wave,
  orangeMoney,
  freeMoney,
  mtnMoney,
  moovMoney
}

enum MobileMoneyAccountStatus {
  active,
  inactive,
  suspended,
  pending
}

class MobileMoneyAccount {
  final String id;
  final String userId;
  final MobileMoneyProvider provider;
  final String phoneNumber;
  final String? accountName;
  final String? accountNumber;
  final MobileMoneyAccountStatus status;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool isVerified;
  final bool isDefault;
  final Map<String, dynamic>? providerData;

  const MobileMoneyAccount({
    required this.id,
    required this.userId,
    required this.provider,
    required this.phoneNumber,
    this.accountName,
    this.accountNumber,
    this.status = MobileMoneyAccountStatus.pending,
    this.balance = 0.0,
    this.currency = 'XOF',
    required this.createdAt,
    this.lastUsedAt,
    this.isVerified = false,
    this.isDefault = false,
    this.providerData,
  });

  // Create a copy of the account with updated properties
  MobileMoneyAccount copyWith({
    String? id,
    String? userId,
    MobileMoneyProvider? provider,
    String? phoneNumber,
    String? accountName,
    String? accountNumber,
    MobileMoneyAccountStatus? status,
    double? balance,
    String? currency,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool? isVerified,
    bool? isDefault,
    Map<String, dynamic>? providerData,
  }) {
    return MobileMoneyAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isVerified: isVerified ?? this.isVerified,
      isDefault: isDefault ?? this.isDefault,
      providerData: providerData ?? this.providerData,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'provider': provider.name,
      'phoneNumber': phoneNumber,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'status': status.name,
      'balance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'isVerified': isVerified,
      'isDefault': isDefault,
      'providerData': providerData,
    };
  }

  // Create from JSON
  factory MobileMoneyAccount.fromJson(Map<String, dynamic> json) {
    return MobileMoneyAccount(
      id: json['id'],
      userId: json['userId'],
      provider: MobileMoneyProvider.values.firstWhere(
        (e) => e.name == json['provider'],
      ),
      phoneNumber: json['phoneNumber'],
      accountName: json['accountName'],
      accountNumber: json['accountNumber'],
      status: MobileMoneyAccountStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MobileMoneyAccountStatus.pending,
      ),
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt']) 
          : null,
      isVerified: json['isVerified'] ?? false,
      isDefault: json['isDefault'] ?? false,
      providerData: json['providerData'],
    );
  }

  // Get provider display name
  String get providerDisplayName {
    switch (provider) {
      case MobileMoneyProvider.wave:
        return 'Wave';
      case MobileMoneyProvider.orangeMoney:
        return 'Orange Money';
      case MobileMoneyProvider.freeMoney:
        return 'Free Money';
      case MobileMoneyProvider.mtnMoney:
        return 'MTN Money';
      case MobileMoneyProvider.moovMoney:
        return 'Moov Money';
    }
  }

  // Get provider color
  String get providerColor {
    switch (provider) {
      case MobileMoneyProvider.wave:
        return '#00D4FF';
      case MobileMoneyProvider.orangeMoney:
        return '#FF6600';
      case MobileMoneyProvider.freeMoney:
        return '#E60012';
      case MobileMoneyProvider.mtnMoney:
        return '#FFCC00';
      case MobileMoneyProvider.moovMoney:
        return '#00A651';
    }
  }

  // Get formatted balance
  String get formattedBalance {
    return '$balance $currency';
  }

  // Get display name for account
  String get displayName {
    return accountName ?? '$providerDisplayName - $phoneNumber';
  }

  // Check if account can be used for transactions
  bool get canTransact {
    return status == MobileMoneyAccountStatus.active && isVerified;
  }
}