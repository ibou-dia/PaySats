enum WalletType {
  bitcoin,
  lightning,
  mobileMoney,
}

class Wallet {
  final String id;
  final String userId;
  final String name;
  final WalletType type;
  final String address;
  final String? publicKey;
  final double balance;
  final String currency;
  final bool isActive;
  final bool connected;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.address,
    this.publicKey,
    required this.balance,
    required this.currency,
    this.isActive = true,
    this.connected = false,
    required this.createdAt,
    this.lastUsedAt,
  });

  // Create a copy of the wallet with updated properties
  Wallet copyWith({
    String? id,
    String? userId,
    String? name,
    WalletType? type,
    String? address,
    String? publicKey,
    double? balance,
    String? currency,
    bool? isActive,
    bool? connected,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      publicKey: publicKey ?? this.publicKey,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      connected: connected ?? this.connected,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.name,
      'address': address,
      'publicKey': publicKey,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'connected': connected,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: WalletType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WalletType.bitcoin,
      ),
      address: json['address'],
      publicKey: json['publicKey'],
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'],
      isActive: json['isActive'] ?? true,
      connected: json['connected'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt']) 
          : null,
    );
  }

  // Get display name for the wallet
  String get displayName {
    return '$name ($currency)';
  }

  // Get formatted balance
  String get formattedBalance {
    if (currency == 'BTC' || currency == 'SATS') {
      return '${balance.toStringAsFixed(8).replaceAll(RegExp(r'([.]*0+)$'), '')} $currency';
    }
    return '${balance.toStringAsFixed(2)} $currency';
  }

  // Check if wallet is Bitcoin
  bool get isBitcoin => type == WalletType.bitcoin;

  // Check if wallet is Lightning
  bool get isLightning => type == WalletType.lightning;

  // Check if wallet is Mobile Money
  bool get isMobileMoney => type == WalletType.mobileMoney;
}
