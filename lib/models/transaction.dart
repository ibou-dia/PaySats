enum TransactionType {
  // Bitcoin transactions
  bitcoinSent,
  bitcoinReceived,

  // Lightning Network transactions
  lightningSent,
  lightningReceived,

  // Mobile Money transactions
  mobileMoneyDeposit,
  mobileMoneyWithdraw,
  mobileMoneyTransfer,

  // Vault operations
  vaultDeposit,
  vaultWithdraw,
  vaultInterest,

  // Internal transfers
  internalTransfer,

  // Fees and charges
  networkFee,
  serviceFee,

  // Other
  refund,
  bonus,
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  expired,
}

enum TransactionCategory { payment, transfer, savings, fee, reward }

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionCategory category;
  final double amount;
  final String currency;
  final double? fees;
  final String? fromAddress;
  final String? toAddress;
  final String? fromAccount; // For mobile money, vault, etc.
  final String? toAccount;
  final DateTime timestamp;
  final DateTime? completedAt;
  final String? hash;
  final String? txid;
  final bool confirmed;
  final int? confirmations;
  final String? description;
  final String? memo;
  final String? reference;
  final Map<String, dynamic>? metadata;

  // Related entity IDs
  final String? walletId;
  final String? vaultId;
  final String? mobileMoneyAccountId;
  final String? lightningPaymentId;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    this.status = TransactionStatus.completed,
    required this.category,
    required this.amount,
    this.currency = 'SATS',
    this.fees,
    this.fromAddress,
    this.toAddress,
    this.fromAccount,
    this.toAccount,
    required this.timestamp,
    this.completedAt,
    this.hash,
    this.txid,
    this.confirmed = true,
    this.confirmations,
    this.description,
    this.memo,
    this.reference,
    this.metadata,
    this.walletId,
    this.vaultId,
    this.mobileMoneyAccountId,
    this.lightningPaymentId,
  });

  // Méthodes utilitaires
  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    TransactionCategory? category,
    double? amount,
    String? currency,
    double? fees,
    String? fromAddress,
    String? toAddress,
    String? fromAccount,
    String? toAccount,
    DateTime? timestamp,
    DateTime? completedAt,
    String? hash,
    String? txid,
    bool? confirmed,
    int? confirmations,
    String? description,
    String? memo,
    String? reference,
    Map<String, dynamic>? metadata,
    String? walletId,
    String? vaultId,
    String? mobileMoneyAccountId,
    String? lightningPaymentId,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fees: fees ?? this.fees,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      timestamp: timestamp ?? this.timestamp,
      completedAt: completedAt ?? this.completedAt,
      hash: hash ?? this.hash,
      txid: txid ?? this.txid,
      confirmed: confirmed ?? this.confirmed,
      confirmations: confirmations ?? this.confirmations,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      reference: reference ?? this.reference,
      metadata: metadata ?? this.metadata,
      walletId: walletId ?? this.walletId,
      vaultId: vaultId ?? this.vaultId,
      mobileMoneyAccountId: mobileMoneyAccountId ?? this.mobileMoneyAccountId,
      lightningPaymentId: lightningPaymentId ?? this.lightningPaymentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'category': category.name,
      'amount': amount,
      'currency': currency,
      'fees': fees,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'timestamp': timestamp.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'hash': hash,
      'txid': txid,
      'confirmed': confirmed,
      'confirmations': confirmations,
      'description': description,
      'memo': memo,
      'reference': reference,
      'metadata': metadata,
      'walletId': walletId,
      'vaultId': vaultId,
      'mobileMoneyAccountId': mobileMoneyAccountId,
      'lightningPaymentId': lightningPaymentId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.bitcoinReceived,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.payment,
      ),
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'SATS',
      fees: json['fees']?.toDouble(),
      fromAddress: json['fromAddress'],
      toAddress: json['toAddress'],
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount'],
      timestamp: DateTime.parse(json['timestamp']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      hash: json['hash'],
      txid: json['txid'],
      confirmed: json['confirmed'] ?? true,
      confirmations: json['confirmations'],
      description: json['description'],
      memo: json['memo'],
      reference: json['reference'],
      metadata: json['metadata'],
      walletId: json['walletId'],
      vaultId: json['vaultId'],
      mobileMoneyAccountId: json['mobileMoneyAccountId'],
      lightningPaymentId: json['lightningPaymentId'],
    );
  }

  // Getters utilitaires
  String get displayType {
    switch (type) {
      case TransactionType.bitcoinSent:
        return 'Bitcoin envoyé';
      case TransactionType.bitcoinReceived:
        return 'Bitcoin reçu';
      case TransactionType.lightningSent:
        return 'Lightning envoyé';
      case TransactionType.lightningReceived:
        return 'Lightning reçu';
      case TransactionType.mobileMoneyDeposit:
        return 'Dépôt Mobile Money';
      case TransactionType.mobileMoneyWithdraw:
        return 'Retrait Mobile Money';
      case TransactionType.mobileMoneyTransfer:
        return 'Transfert Mobile Money';
      case TransactionType.vaultDeposit:
        return 'Dépôt coffre';
      case TransactionType.vaultWithdraw:
        return 'Retrait coffre';
      case TransactionType.vaultInterest:
        return 'Intérêts coffre';
      case TransactionType.internalTransfer:
        return 'Transfert interne';
      case TransactionType.networkFee:
        return 'Frais réseau';
      case TransactionType.serviceFee:
        return 'Frais service';
      case TransactionType.refund:
        return 'Remboursement';
      case TransactionType.bonus:
        return 'Bonus';
    }
  }

  String get displayStatus {
    switch (status) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.processing:
        return 'En cours';
      case TransactionStatus.completed:
        return 'Terminé';
      case TransactionStatus.failed:
        return 'Échoué';
      case TransactionStatus.cancelled:
        return 'Annulé';
      case TransactionStatus.expired:
        return 'Expiré';
    }
  }

  String get formattedAmount {
    final sign = isOutgoing ? '-' : '+';
    // Format amount with appropriate decimal places, removing trailing zeros
    String formattedValue;

    // Check for invalid values
    if (amount.isNaN || amount.isInfinite) {
      return '${sign}0.00 $currency';
    }

    if (currency == 'BTC' || currency == 'SATS') {
      // For Bitcoin/SATS, use formatBitcoin to remove trailing zeros
      formattedValue = amount
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'([.]*0+)$'), '');
    } else {
      // For fiat currencies, use 2 decimal places
      formattedValue = amount.toStringAsFixed(2);
    }
    return '$sign$formattedValue $currency';
  }

  String get formattedFees {
    if (fees == null) return '';

    // Check for invalid values
    if (fees!.isNaN || fees!.isInfinite) {
      return '0.00 $currency';
    }

    // Format fees with appropriate decimal places, removing trailing zeros
    String formattedValue;
    if (currency == 'BTC' || currency == 'SATS') {
      // For Bitcoin/SATS, remove trailing zeros
      formattedValue = fees!
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'([.]*0+)$'), '');
    } else {
      // For fiat currencies, use 2 decimal places
      formattedValue = fees!.toStringAsFixed(2);
    }
    return '$formattedValue $currency';
  }

  bool get isOutgoing {
    return [
      TransactionType.bitcoinSent,
      TransactionType.lightningSent,
      TransactionType.mobileMoneyWithdraw,
      TransactionType.vaultDeposit,
      TransactionType.networkFee,
      TransactionType.serviceFee,
    ].contains(type);
  }

  bool get isIncoming {
    return [
      TransactionType.bitcoinReceived,
      TransactionType.lightningReceived,
      TransactionType.mobileMoneyDeposit,
      TransactionType.vaultWithdraw,
      TransactionType.vaultInterest,
      TransactionType.refund,
      TransactionType.bonus,
    ].contains(type);
  }

  bool get isPending => status == TransactionStatus.pending;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;

  // Génération d'exemples de transactions
  static List<Transaction> getSampleTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        userId: 'user123',
        type: TransactionType.bitcoinReceived,
        category: TransactionCategory.payment,
        amount: 1000.0, // 1000 sats
        currency: 'SATS',
        toAddress: 'SP2JXKMSH007NPYAQHKJPQMAQYAD90NQGTVJVQ02B',
        timestamp: now,
        hash: '0x56767890ldsjfhg45689653afxcf',
        description: 'Paiement reçu',
      ),
    ];
  }
}
