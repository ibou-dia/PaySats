import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'currency_service.dart';
import 'auth_service.dart';

// Note: We removed flutter_secure_storage dependency due to Android SDK platform issues
// and we're now using only shared_preferences for storage

class WalletService extends ChangeNotifier {
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  WalletService() {
    _loadWallet();
    _loadTransactions();
  }

  // Getters
  Wallet? get wallet => _wallet;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _wallet != null && _wallet!.connected;

  // Load wallet data from storage
  Future<void> _loadWallet() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString(Constants.keyWalletAddress);
      final balance = prefs.getDouble(Constants.keyWalletBalance) ?? 0.0;

      if (address != null) {
        _wallet = Wallet(
          id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'user_demo',
          name: 'Mon Wallet Bitcoin',
          type: WalletType.bitcoin,
          address: address,
          balance: balance,
          currency: 'SATS',
          connected: true,
          createdAt: DateTime.now(),
        );
      }
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load wallet: ${e.toString()}');
    }
  }

  // Load transaction history (currently using sample data)
  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtenir l'ID de l'utilisateur actuel depuis AuthService
      final authService = AuthService();
      final currentWallet = authService.wallet;
      
      if (currentWallet != null) {
        // Charger les transactions spécifiques à ce wallet
        final transactionsKey = 'transactions_${currentWallet.userId}';
        final transactionsJson = prefs.getString(transactionsKey);
        
        if (transactionsJson != null) {
          final transactionsList = (jsonDecode(transactionsJson) as List)
              .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
              .toList();
          _transactions = transactionsList;
        } else {
          // Si aucune transaction sauvegardée pour ce wallet, liste vide
          _transactions = [];
        }
      } else {
        // Si pas de wallet connecté, utiliser les données d'exemple
        _transactions = Transaction.getSampleTransactions();
      }
    } catch (e) {
      // En cas d'erreur, utiliser les données d'exemple
      _transactions = Transaction.getSampleTransactions();
    }
    notifyListeners();
  }

  // Connect wallet
  Future<bool> connectWallet() async {
    _setLoading(true);
    _clearError();
    
    try {
      // In a real app, this would connect to an actual wallet
      // For demo purposes, we're just creating a wallet with sample data
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.keyWalletAddress, Constants.dummyWalletAddress);
      await prefs.setDouble(Constants.keyWalletBalance, 1000); // 1000 sats
      
      _wallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_demo',
        name: 'Mon Wallet Bitcoin',
        type: WalletType.bitcoin,
        address: Constants.dummyWalletAddress,
        balance: 1000, // Balance en sats
        currency: 'SATS',
        connected: true,
        createdAt: DateTime.now(),
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to connect wallet: ${e.toString()}');
      return false;
    }
  }

  // Create a new wallet
  Future<bool> createWallet() async {
    _setLoading(true);
    _clearError();
    
    try {
      // In a real app, this would actually create a wallet
      // For demo purposes, we're just simulating wallet creation
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.keyWalletAddress, Constants.dummyWalletAddress);
      await prefs.setDouble(Constants.keyWalletBalance, 0);
      
      _wallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_demo',
        name: 'Mon Wallet Bitcoin',
        type: WalletType.bitcoin,
        address: Constants.dummyWalletAddress,
        balance: 0,
        currency: 'SATS',
        connected: true,
        createdAt: DateTime.now(),
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create wallet: ${e.toString()}');
      return false;
    }
  }

  // Send sBTC transaction
  Future<bool> sendTransaction(String toAddress, double amount) async {
    if (_wallet == null) return false;
    if (amount <= 0 || amount > _wallet!.balance) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      // In a real app, this would send an actual transaction
      // For demo purposes, we're just simulating a transaction
      await Future.delayed(const Duration(seconds: 2)); // Simulate blockchain confirmation
      
      // Create new transaction
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // In a real app, this would be the actual user ID
        type: TransactionType.bitcoinSent,
        status: TransactionStatus.completed,
        category: TransactionCategory.payment,
        amount: amount,
        currency: 'SATS',
        toAddress: toAddress,
        timestamp: DateTime.now(),
        completedAt: DateTime.now(),
        hash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
        confirmations: 6,
        description: 'Bitcoin envoyé',
      );
      
      // Update wallet balance
      final newBalance = _wallet!.balance - amount;
      _wallet = _wallet!.copyWith(balance: newBalance);
      
      // Update shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(Constants.keyWalletBalance, newBalance);
      
      // Add transaction to history and save to SharedPreferences
      _transactions.insert(0, newTransaction);
      await _saveTransactions();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to send transaction: ${e.toString()}');
      return false;
    }
  }

  // Disconnect wallet
  Future<void> disconnectWallet() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.keyWalletAddress);
      await prefs.remove(Constants.keyWalletBalance);
      
      _wallet = null;
      _transactions = [];
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect wallet: ${e.toString()}');
    }
  }

  // Add deposit transaction and update balance
  Future<bool> addDeposit(double amount, String provider) async {
    if (_wallet == null) {
      _setError('Wallet non initialisé');
      return false;
    }
    
    if (amount <= 0) {
      _setError('Montant invalide: $amount');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // Simulate deposit processing
      await Future.delayed(const Duration(seconds: 2));
      
      // For mobile money deposits, we need to convert the fiat amount to SATS
      // using the current Bitcoin exchange rate from CurrencyService to maintain consistency
      // Get current XOF to BTC rate from CurrencyService
      final currencyService = CurrencyService();
      
      // Vérifier si les taux sont déjà chargés
      if (currencyService.exchangeRates['XOF'] == 0.0 || currencyService.exchangeRates.isEmpty) {
        await currencyService.fetchExchangeRates(); // Ensure we have the latest rates
        
        // Attendre un peu pour s'assurer que les taux sont mis à jour
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // Utiliser les taux actuels ou les taux de secours
      double xofPerBtc = currencyService.exchangeRates['XOF'] ?? 0.0;
      
      // Si les taux sont toujours à zéro, utiliser un taux de secours
      if (xofPerBtc <= 0.0) {
        // Taux de secours basé sur un prix Bitcoin approximatif
        xofPerBtc = 32797850; // ~50,000 USD * 656 XOF/USD (taux approximatif)
      }
      
      // Validation du taux de change
      if (xofPerBtc <= 1000) { // Taux trop faible (probablement une erreur)
        _setError('Taux de change invalide: $xofPerBtc (trop faible)');
        return false;
      }
      
      if (xofPerBtc.isNaN) {
        _setError('Taux de change invalide: NaN');
        return false;
      }
      
      if (xofPerBtc.isInfinite) {
        _setError('Taux de change invalide: Infinity');
        return false;
      }
      
      // Convert XOF to BTC, then to SATS
      final btcAmount = amount / xofPerBtc; // XOF to BTC
      
      final satsEquivalent = (btcAmount * 100000000).round().toDouble(); // BTC to SATS
      
      // Validation des conversions
      if (btcAmount.isNaN) {
        _setError('Erreur de conversion BTC: NaN (amount: $amount, xofPerBtc: $xofPerBtc)');
        return false;
      }
      
      if (btcAmount.isInfinite) {
        _setError('Erreur de conversion BTC: Infinity (amount: $amount, xofPerBtc: $xofPerBtc)');
        return false;
      }
      
      if (satsEquivalent.isNaN) {
        _setError('Erreur de conversion SATS: NaN (btcAmount: $btcAmount)');
        return false;
      }
      
      if (satsEquivalent.isInfinite) {
        _setError('Erreur de conversion SATS: Infinity (btcAmount: $btcAmount)');
        return false;
      }
      
      // Create transaction record
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        type: TransactionType.mobileMoneyDeposit,
        status: TransactionStatus.completed,
        category: TransactionCategory.payment,
        amount: amount,
        currency: 'XOF',
        fromAccount: '$provider - 77 474 88 87',
        toAccount: 'Wave',
        timestamp: DateTime.now(),
        completedAt: DateTime.now(),
        description: 'Dépôt via $provider',
        mobileMoneyAccountId: '${provider.toLowerCase()}_account',
      );
      
      // Update wallet balance with SATS equivalent
      final newBalance = _wallet!.balance + satsEquivalent;
      
      // Validate new balance
      if (newBalance.isNaN) {
        _setError('Erreur de calcul du solde: NaN (balance actuel: ${_wallet!.balance}, satsEquivalent: $satsEquivalent)');
        return false;
      }
      
      if (newBalance.isInfinite) {
        _setError('Erreur de calcul du solde: Infinity (balance actuel: ${_wallet!.balance}, satsEquivalent: $satsEquivalent)');
        return false;
      }
      
      // Update wallet
      _wallet = _wallet!.copyWith(balance: newBalance);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(Constants.keyWalletBalance, newBalance);
      
      // Add transaction to history and save to SharedPreferences
      _transactions.insert(0, newTransaction);
      await _saveTransactions();
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors du dépôt: ${e.toString()}');
      return false;
    }
  }

  // Sauvegarder les transactions dans SharedPreferences
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService();
      final currentWallet = authService.wallet;
      
      if (currentWallet != null) {
        final transactionsKey = 'transactions_${currentWallet.userId}';
        final transactionsJson = _transactions.map((t) => t.toJson()).toList();
        await prefs.setString(transactionsKey, jsonEncode(transactionsJson));
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des transactions: $e');
    }
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
