enum VaultType {
  savings,
  goal,
  emergency,
  investment
}

enum VaultStatus {
  active,
  paused,
  completed,
  cancelled
}

enum AutoSaveFrequency {
  daily,
  weekly,
  monthly,
  custom
}

class Vault {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final VaultType type;
  final VaultStatus status;
  final double currentAmount;
  final double? targetAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final DateTime? lastDepositAt;
  final String currency;
  final String? imageUrl;
  final String? color;
  
  // Auto-save settings
  final bool autoSaveEnabled;
  final double? autoSaveAmount;
  final AutoSaveFrequency? autoSaveFrequency;
  final DateTime? nextAutoSaveDate;
  
  // Interest and rewards
  final double interestRate;
  final double totalInterestEarned;
  final bool isLocked;
  final DateTime? unlockDate;
  
  final Map<String, dynamic>? metadata;

  const Vault({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.type = VaultType.savings,
    this.status = VaultStatus.active,
    this.currentAmount = 0.0,
    this.targetAmount,
    required this.createdAt,
    this.targetDate,
    this.lastDepositAt,
    this.currency = 'XOF',
    this.imageUrl,
    this.color,
    this.autoSaveEnabled = false,
    this.autoSaveAmount,
    this.autoSaveFrequency,
    this.nextAutoSaveDate,
    this.interestRate = 0.0,
    this.totalInterestEarned = 0.0,
    this.isLocked = false,
    this.unlockDate,
    this.metadata,
  });

  // Create a copy of the vault with updated properties
  Vault copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    VaultType? type,
    VaultStatus? status,
    double? currentAmount,
    double? targetAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? lastDepositAt,
    String? currency,
    String? imageUrl,
    String? color,
    bool? autoSaveEnabled,
    double? autoSaveAmount,
    AutoSaveFrequency? autoSaveFrequency,
    DateTime? nextAutoSaveDate,
    double? interestRate,
    double? totalInterestEarned,
    bool? isLocked,
    DateTime? unlockDate,
    Map<String, dynamic>? metadata,
  }) {
    return Vault(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      lastDepositAt: lastDepositAt ?? this.lastDepositAt,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      autoSaveAmount: autoSaveAmount ?? this.autoSaveAmount,
      autoSaveFrequency: autoSaveFrequency ?? this.autoSaveFrequency,
      nextAutoSaveDate: nextAutoSaveDate ?? this.nextAutoSaveDate,
      interestRate: interestRate ?? this.interestRate,
      totalInterestEarned: totalInterestEarned ?? this.totalInterestEarned,
      isLocked: isLocked ?? this.isLocked,
      unlockDate: unlockDate ?? this.unlockDate,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'lastDepositAt': lastDepositAt?.toIso8601String(),
      'currency': currency,
      'imageUrl': imageUrl,
      'color': color,
      'autoSaveEnabled': autoSaveEnabled,
      'autoSaveAmount': autoSaveAmount,
      'autoSaveFrequency': autoSaveFrequency?.name,
      'nextAutoSaveDate': nextAutoSaveDate?.toIso8601String(),
      'interestRate': interestRate,
      'totalInterestEarned': totalInterestEarned,
      'isLocked': isLocked,
      'unlockDate': unlockDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      type: VaultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VaultType.savings,
      ),
      status: VaultStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VaultStatus.active,
      ),
      currentAmount: (json['currentAmount'] ?? 0.0).toDouble(),
      targetAmount: json['targetAmount']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null 
          ? DateTime.parse(json['targetDate']) 
          : null,
      lastDepositAt: json['lastDepositAt'] != null 
          ? DateTime.parse(json['lastDepositAt']) 
          : null,
      currency: json['currency'] ?? 'XOF',
      imageUrl: json['imageUrl'],
      color: json['color'],
      autoSaveEnabled: json['autoSaveEnabled'] ?? false,
      autoSaveAmount: json['autoSaveAmount']?.toDouble(),
      autoSaveFrequency: json['autoSaveFrequency'] != null
          ? AutoSaveFrequency.values.firstWhere(
              (e) => e.name == json['autoSaveFrequency'],
            )
          : null,
      nextAutoSaveDate: json['nextAutoSaveDate'] != null 
          ? DateTime.parse(json['nextAutoSaveDate']) 
          : null,
      interestRate: (json['interestRate'] ?? 0.0).toDouble(),
      totalInterestEarned: (json['totalInterestEarned'] ?? 0.0).toDouble(),
      isLocked: json['isLocked'] ?? false,
      unlockDate: json['unlockDate'] != null 
          ? DateTime.parse(json['unlockDate']) 
          : null,
      metadata: json['metadata'],
    );
  }

  // Get progress percentage
  double get progressPercentage {
    if (targetAmount == null || targetAmount! <= 0) return 0.0;
    return (currentAmount / targetAmount!) * 100;
  }

  // Get remaining amount to reach target
  double get remainingAmount {
    if (targetAmount == null) return 0.0;
    return targetAmount! - currentAmount;
  }

  // Get formatted current amount
  String get formattedCurrentAmount {
    return '$currentAmount $currency';
  }

  // Get formatted target amount
  String get formattedTargetAmount {
    if (targetAmount == null) return '';
    return '$targetAmount $currency';
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case VaultType.savings:
        return 'Épargne';
      case VaultType.goal:
        return 'Objectif';
      case VaultType.emergency:
        return 'Urgence';
      case VaultType.investment:
        return 'Investissement';
    }
  }

  // Check if vault can accept deposits
  bool get canDeposit {
    return status == VaultStatus.active && !isLocked;
  }

  // Check if vault can be withdrawn from
  bool get canWithdraw {
    if (isLocked && unlockDate != null) {
      return DateTime.now().isAfter(unlockDate!);
    }
    return status == VaultStatus.active;
  }

  // Check if target is reached
  bool get isTargetReached {
    if (targetAmount == null) return false;
    return currentAmount >= targetAmount!;
  }

  // Get days remaining to target date
  int? get daysToTarget {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }
}