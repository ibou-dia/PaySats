enum LightningPaymentType {
  send,
  receive,
  invoice
}

enum LightningPaymentStatus {
  pending,
  processing,
  completed,
  failed,
  expired,
  cancelled
}

enum LightningInvoiceType {
  standard,
  keysend,
  amp, // Atomic Multi-Path
  hodl // Hold invoice
}

class LightningPayment {
  final String id;
  final String userId;
  final String? walletId;
  final LightningPaymentType type;
  final LightningPaymentStatus status;
  final double amountSats;
  final double? amountMsat; // millisatoshis for precision
  final double? feesSats;
  final String? paymentHash;
  final String? paymentPreimage;
  final String? invoice; // BOLT11 invoice
  final String? description;
  final String? memo;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final String? destinationPubkey;
  final String? routeHints;
  final int? cltvExpiry;
  final bool isKeysend;
  final Map<String, String>? tlvRecords;
  
  // Invoice specific fields
  final LightningInvoiceType? invoiceType;
  final bool? isPrivate;
  final int? minFinalCltvExpiry;
  final List<String>? routingHints;
  
  // Payment routing info
  final List<Map<String, dynamic>>? paymentRoute;
  final int? totalHops;
  final double? totalFeeMsat;
  final int? totalTimeLock;
  
  // Error handling
  final String? errorMessage;
  final String? errorCode;
  final int? failureReason;
  
  final Map<String, dynamic>? metadata;

  const LightningPayment({
    required this.id,
    required this.userId,
    this.walletId,
    required this.type,
    this.status = LightningPaymentStatus.pending,
    required this.amountSats,
    this.amountMsat,
    this.feesSats,
    this.paymentHash,
    this.paymentPreimage,
    this.invoice,
    this.description,
    this.memo,
    required this.createdAt,
    this.completedAt,
    this.expiresAt,
    this.destinationPubkey,
    this.routeHints,
    this.cltvExpiry,
    this.isKeysend = false,
    this.tlvRecords,
    this.invoiceType,
    this.isPrivate,
    this.minFinalCltvExpiry,
    this.routingHints,
    this.paymentRoute,
    this.totalHops,
    this.totalFeeMsat,
    this.totalTimeLock,
    this.errorMessage,
    this.errorCode,
    this.failureReason,
    this.metadata,
  });

  // Create a copy of the lightning payment with updated properties
  LightningPayment copyWith({
    String? id,
    String? userId,
    String? walletId,
    LightningPaymentType? type,
    LightningPaymentStatus? status,
    double? amountSats,
    double? amountMsat,
    double? feesSats,
    String? paymentHash,
    String? paymentPreimage,
    String? invoice,
    String? description,
    String? memo,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    String? destinationPubkey,
    String? routeHints,
    int? cltvExpiry,
    bool? isKeysend,
    Map<String, String>? tlvRecords,
    LightningInvoiceType? invoiceType,
    bool? isPrivate,
    int? minFinalCltvExpiry,
    List<String>? routingHints,
    List<Map<String, dynamic>>? paymentRoute,
    int? totalHops,
    double? totalFeeMsat,
    int? totalTimeLock,
    String? errorMessage,
    String? errorCode,
    int? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return LightningPayment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      status: status ?? this.status,
      amountSats: amountSats ?? this.amountSats,
      amountMsat: amountMsat ?? this.amountMsat,
      feesSats: feesSats ?? this.feesSats,
      paymentHash: paymentHash ?? this.paymentHash,
      paymentPreimage: paymentPreimage ?? this.paymentPreimage,
      invoice: invoice ?? this.invoice,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      destinationPubkey: destinationPubkey ?? this.destinationPubkey,
      routeHints: routeHints ?? this.routeHints,
      cltvExpiry: cltvExpiry ?? this.cltvExpiry,
      isKeysend: isKeysend ?? this.isKeysend,
      tlvRecords: tlvRecords ?? this.tlvRecords,
      invoiceType: invoiceType ?? this.invoiceType,
      isPrivate: isPrivate ?? this.isPrivate,
      minFinalCltvExpiry: minFinalCltvExpiry ?? this.minFinalCltvExpiry,
      routingHints: routingHints ?? this.routingHints,
      paymentRoute: paymentRoute ?? this.paymentRoute,
      totalHops: totalHops ?? this.totalHops,
      totalFeeMsat: totalFeeMsat ?? this.totalFeeMsat,
      totalTimeLock: totalTimeLock ?? this.totalTimeLock,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'walletId': walletId,
      'type': type.name,
      'status': status.name,
      'amountSats': amountSats,
      'amountMsat': amountMsat,
      'feesSats': feesSats,
      'paymentHash': paymentHash,
      'paymentPreimage': paymentPreimage,
      'invoice': invoice,
      'description': description,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'destinationPubkey': destinationPubkey,
      'routeHints': routeHints,
      'cltvExpiry': cltvExpiry,
      'isKeysend': isKeysend,
      'tlvRecords': tlvRecords,
      'invoiceType': invoiceType?.name,
      'isPrivate': isPrivate,
      'minFinalCltvExpiry': minFinalCltvExpiry,
      'routingHints': routingHints,
      'paymentRoute': paymentRoute,
      'totalHops': totalHops,
      'totalFeeMsat': totalFeeMsat,
      'totalTimeLock': totalTimeLock,
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory LightningPayment.fromJson(Map<String, dynamic> json) {
    return LightningPayment(
      id: json['id'],
      userId: json['userId'],
      walletId: json['walletId'],
      type: LightningPaymentType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      status: LightningPaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LightningPaymentStatus.pending,
      ),
      amountSats: (json['amountSats'] ?? 0.0).toDouble(),
      amountMsat: json['amountMsat']?.toDouble(),
      feesSats: json['feesSats']?.toDouble(),
      paymentHash: json['paymentHash'],
      paymentPreimage: json['paymentPreimage'],
      invoice: json['invoice'],
      description: json['description'],
      memo: json['memo'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      destinationPubkey: json['destinationPubkey'],
      routeHints: json['routeHints'],
      cltvExpiry: json['cltvExpiry'],
      isKeysend: json['isKeysend'] ?? false,
      tlvRecords: json['tlvRecords'] != null 
          ? Map<String, String>.from(json['tlvRecords']) 
          : null,
      invoiceType: json['invoiceType'] != null
          ? LightningInvoiceType.values.firstWhere(
              (e) => e.name == json['invoiceType'],
            )
          : null,
      isPrivate: json['isPrivate'],
      minFinalCltvExpiry: json['minFinalCltvExpiry'],
      routingHints: json['routingHints'] != null 
          ? List<String>.from(json['routingHints']) 
          : null,
      paymentRoute: json['paymentRoute'] != null 
          ? List<Map<String, dynamic>>.from(json['paymentRoute']) 
          : null,
      totalHops: json['totalHops'],
      totalFeeMsat: json['totalFeeMsat']?.toDouble(),
      totalTimeLock: json['totalTimeLock'],
      errorMessage: json['errorMessage'],
      errorCode: json['errorCode'],
      failureReason: json['failureReason'],
      metadata: json['metadata'],
    );
  }

  // Get amount in Bitcoin
  double get amountBTC {
    if (amountSats.isNaN || amountSats.isInfinite) return 0.0;
    final result = amountSats / 100000000; // 1 BTC = 100,000,000 sats
    if (result.isNaN || result.isInfinite) return 0.0;
    return result;
  }

  // Get fees in Bitcoin
  double get feesBTC {
    if (feesSats == null || feesSats!.isNaN || feesSats!.isInfinite) return 0.0;
    final result = feesSats! / 100000000;
    if (result.isNaN || result.isInfinite) return 0.0;
    return result;
  }

  // Get formatted amount
  String get formattedAmount {
    if (amountSats.isNaN || amountSats.isInfinite) {
      return '0 sats';
    }
    
    if (amountSats >= 1000000) {
      return '${(amountSats / 1000000).toStringAsFixed(2)}M sats';
    } else if (amountSats >= 1000) {
      return '${(amountSats / 1000).toStringAsFixed(1)}k sats';
    }
    return '${amountSats.toInt()} sats';
  }

  // Get formatted fees
  String get formattedFees {
    if (feesSats == null || feesSats!.isNaN || feesSats!.isInfinite) return '0 sats';
    return '${feesSats!.toInt()} sats';
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case LightningPaymentType.send:
        return 'Envoi';
      case LightningPaymentType.receive:
        return 'Réception';
      case LightningPaymentType.invoice:
        return 'Facture';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case LightningPaymentStatus.pending:
        return 'En attente';
      case LightningPaymentStatus.processing:
        return 'En cours';
      case LightningPaymentStatus.completed:
        return 'Terminé';
      case LightningPaymentStatus.failed:
        return 'Échoué';
      case LightningPaymentStatus.expired:
        return 'Expiré';
      case LightningPaymentStatus.cancelled:
        return 'Annulé';
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case LightningPaymentStatus.pending:
        return '#FF9800';
      case LightningPaymentStatus.processing:
        return '#2196F3';
      case LightningPaymentStatus.completed:
        return '#4CAF50';
      case LightningPaymentStatus.failed:
        return '#F44336';
      case LightningPaymentStatus.expired:
        return '#9E9E9E';
      case LightningPaymentStatus.cancelled:
        return '#607D8B';
    }
  }

  // Check if payment is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if payment is final (completed, failed, expired, cancelled)
  bool get isFinal {
    return [
      LightningPaymentStatus.completed,
      LightningPaymentStatus.failed,
      LightningPaymentStatus.expired,
      LightningPaymentStatus.cancelled,
    ].contains(status);
  }

  // Get processing time in seconds
  int? get processingTimeSeconds {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt).inSeconds;
  }

  // Get fee rate (fees per sat)
  double? get feeRate {
    if (feesSats == null || amountSats <= 0) return null;
    return (feesSats! / amountSats) * 100; // percentage
  }

  // Get display description
  String get displayDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (memo != null && memo!.isNotEmpty) {
      return memo!;
    }
    return 'Paiement Lightning';
  }
}