enum InvestmentType {
  bitcoin,
  stocks,
  bonds,
  crypto,
  commodities,
  realEstate
}

enum InvestmentStatus {
  active,
  paused,
  closed,
  pending
}

enum InvestmentStrategy {
  dollarCostAveraging,
  lumpSum,
  valueAveraging,
  custom
}

class Investment {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final InvestmentType type;
  final InvestmentStatus status;
  final String symbol; // BTC, ETH, AAPL, etc.
  final double totalInvested;
  final double currentValue;
  final double quantity;
  final double averageBuyPrice;
  final DateTime createdAt;
  final DateTime? lastTransactionAt;
  final String currency;
  final String? imageUrl;
  
  // Strategy settings
  final InvestmentStrategy strategy;
  final bool autoInvestEnabled;
  final double? autoInvestAmount;
  final String? autoInvestFrequency; // daily, weekly, monthly
  final DateTime? nextAutoInvestDate;
  
  // Performance tracking
  final double totalGainLoss;
  final double gainLossPercentage;
  final double dayChange;
  final double dayChangePercentage;
  final double weekChange;
  final double monthChange;
  final double yearChange;
  
  // Risk and alerts
  final String riskLevel; // low, medium, high
  final double? stopLossPrice;
  final double? takeProfitPrice;
  final bool alertsEnabled;
  
  final Map<String, dynamic>? metadata;

  const Investment({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.type,
    this.status = InvestmentStatus.active,
    required this.symbol,
    this.totalInvested = 0.0,
    this.currentValue = 0.0,
    this.quantity = 0.0,
    this.averageBuyPrice = 0.0,
    required this.createdAt,
    this.lastTransactionAt,
    this.currency = 'XOF',
    this.imageUrl,
    this.strategy = InvestmentStrategy.lumpSum,
    this.autoInvestEnabled = false,
    this.autoInvestAmount,
    this.autoInvestFrequency,
    this.nextAutoInvestDate,
    this.totalGainLoss = 0.0,
    this.gainLossPercentage = 0.0,
    this.dayChange = 0.0,
    this.dayChangePercentage = 0.0,
    this.weekChange = 0.0,
    this.monthChange = 0.0,
    this.yearChange = 0.0,
    this.riskLevel = 'medium',
    this.stopLossPrice,
    this.takeProfitPrice,
    this.alertsEnabled = false,
    this.metadata,
  });

  // Create a copy of the investment with updated properties
  Investment copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    InvestmentType? type,
    InvestmentStatus? status,
    String? symbol,
    double? totalInvested,
    double? currentValue,
    double? quantity,
    double? averageBuyPrice,
    DateTime? createdAt,
    DateTime? lastTransactionAt,
    String? currency,
    String? imageUrl,
    InvestmentStrategy? strategy,
    bool? autoInvestEnabled,
    double? autoInvestAmount,
    String? autoInvestFrequency,
    DateTime? nextAutoInvestDate,
    double? totalGainLoss,
    double? gainLossPercentage,
    double? dayChange,
    double? dayChangePercentage,
    double? weekChange,
    double? monthChange,
    double? yearChange,
    String? riskLevel,
    double? stopLossPrice,
    double? takeProfitPrice,
    bool? alertsEnabled,
    Map<String, dynamic>? metadata,
  }) {
    return Investment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      symbol: symbol ?? this.symbol,
      totalInvested: totalInvested ?? this.totalInvested,
      currentValue: currentValue ?? this.currentValue,
      quantity: quantity ?? this.quantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      createdAt: createdAt ?? this.createdAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      strategy: strategy ?? this.strategy,
      autoInvestEnabled: autoInvestEnabled ?? this.autoInvestEnabled,
      autoInvestAmount: autoInvestAmount ?? this.autoInvestAmount,
      autoInvestFrequency: autoInvestFrequency ?? this.autoInvestFrequency,
      nextAutoInvestDate: nextAutoInvestDate ?? this.nextAutoInvestDate,
      totalGainLoss: totalGainLoss ?? this.totalGainLoss,
      gainLossPercentage: gainLossPercentage ?? this.gainLossPercentage,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercentage: dayChangePercentage ?? this.dayChangePercentage,
      weekChange: weekChange ?? this.weekChange,
      monthChange: monthChange ?? this.monthChange,
      yearChange: yearChange ?? this.yearChange,
      riskLevel: riskLevel ?? this.riskLevel,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      takeProfitPrice: takeProfitPrice ?? this.takeProfitPrice,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
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
      'symbol': symbol,
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'quantity': quantity,
      'averageBuyPrice': averageBuyPrice,
      'createdAt': createdAt.toIso8601String(),
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
      'currency': currency,
      'imageUrl': imageUrl,
      'strategy': strategy.name,
      'autoInvestEnabled': autoInvestEnabled,
      'autoInvestAmount': autoInvestAmount,
      'autoInvestFrequency': autoInvestFrequency,
      'nextAutoInvestDate': nextAutoInvestDate?.toIso8601String(),
      'totalGainLoss': totalGainLoss,
      'gainLossPercentage': gainLossPercentage,
      'dayChange': dayChange,
      'dayChangePercentage': dayChangePercentage,
      'weekChange': weekChange,
      'monthChange': monthChange,
      'yearChange': yearChange,
      'riskLevel': riskLevel,
      'stopLossPrice': stopLossPrice,
      'takeProfitPrice': takeProfitPrice,
      'alertsEnabled': alertsEnabled,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      type: InvestmentType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      status: InvestmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvestmentStatus.active,
      ),
      symbol: json['symbol'],
      totalInvested: (json['totalInvested'] ?? 0.0).toDouble(),
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      averageBuyPrice: (json['averageBuyPrice'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      lastTransactionAt: json['lastTransactionAt'] != null 
          ? DateTime.parse(json['lastTransactionAt']) 
          : null,
      currency: json['currency'] ?? 'XOF',
      imageUrl: json['imageUrl'],
      strategy: InvestmentStrategy.values.firstWhere(
        (e) => e.name == json['strategy'],
        orElse: () => InvestmentStrategy.lumpSum,
      ),
      autoInvestEnabled: json['autoInvestEnabled'] ?? false,
      autoInvestAmount: json['autoInvestAmount']?.toDouble(),
      autoInvestFrequency: json['autoInvestFrequency'],
      nextAutoInvestDate: json['nextAutoInvestDate'] != null 
          ? DateTime.parse(json['nextAutoInvestDate']) 
          : null,
      totalGainLoss: (json['totalGainLoss'] ?? 0.0).toDouble(),
      gainLossPercentage: (json['gainLossPercentage'] ?? 0.0).toDouble(),
      dayChange: (json['dayChange'] ?? 0.0).toDouble(),
      dayChangePercentage: (json['dayChangePercentage'] ?? 0.0).toDouble(),
      weekChange: (json['weekChange'] ?? 0.0).toDouble(),
      monthChange: (json['monthChange'] ?? 0.0).toDouble(),
      yearChange: (json['yearChange'] ?? 0.0).toDouble(),
      riskLevel: json['riskLevel'] ?? 'medium',
      stopLossPrice: json['stopLossPrice']?.toDouble(),
      takeProfitPrice: json['takeProfitPrice']?.toDouble(),
      alertsEnabled: json['alertsEnabled'] ?? false,
      metadata: json['metadata'],
    );
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case InvestmentType.bitcoin:
        return 'Bitcoin';
      case InvestmentType.stocks:
        return 'Actions';
      case InvestmentType.bonds:
        return 'Obligations';
      case InvestmentType.crypto:
        return 'Crypto';
      case InvestmentType.commodities:
        return 'Matières premières';
      case InvestmentType.realEstate:
        return 'Immobilier';
    }
  }

  // Get strategy display name
  String get strategyDisplayName {
    switch (strategy) {
      case InvestmentStrategy.dollarCostAveraging:
        return 'DCA (Dollar Cost Averaging)';
      case InvestmentStrategy.lumpSum:
        return 'Investissement unique';
      case InvestmentStrategy.valueAveraging:
        return 'Value Averaging';
      case InvestmentStrategy.custom:
        return 'Stratégie personnalisée';
    }
  }

  // Get formatted total invested
  String get formattedTotalInvested {
    return '$totalInvested $currency';
  }

  // Get formatted current value
  String get formattedCurrentValue {
    return '$currentValue $currency';
  }

  // Get formatted gain/loss
  String get formattedGainLoss {
    final sign = totalGainLoss >= 0 ? '+' : '';
    return '$sign$totalGainLoss $currency';
  }

  // Get formatted gain/loss percentage
  String get formattedGainLossPercentage {
    if (gainLossPercentage.isNaN || gainLossPercentage.isInfinite) {
      return '0.00%';
    }
    final sign = gainLossPercentage >= 0 ? '+' : '';
    return '$sign${gainLossPercentage.toStringAsFixed(2)}%';
  }

  // Check if investment is profitable
  bool get isProfitable {
    return totalGainLoss > 0;
  }

  // Get current price per unit
  double get currentPrice {
    if (quantity <= 0 || currentValue.isNaN || currentValue.isInfinite) return 0.0;
    final result = currentValue / quantity;
    if (result.isNaN || result.isInfinite) return 0.0;
    return result;
  }

  // Get risk level color
  String get riskLevelColor {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return '#4CAF50';
      case 'medium':
        return '#FF9800';
      case 'high':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  // Check if stop loss should trigger
  bool shouldTriggerStopLoss(double currentPrice) {
    return stopLossPrice != null && currentPrice <= stopLossPrice!;
  }

  // Check if take profit should trigger
  bool shouldTriggerTakeProfit(double currentPrice) {
    return takeProfitPrice != null && currentPrice >= takeProfitPrice!;
  }
}