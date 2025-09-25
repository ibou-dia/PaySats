import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import 'currency_service.dart';

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
    _transactions = Transaction.getSampleTransactions();
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
      await prefs.setDouble(Constants.keyWalletBalance, 1250000); // 0.0125 BTC = 1,250,000 sats
      
      _wallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_demo',
        name: 'Mon Wallet Bitcoin',
        type: WalletType.bitcoin,
        address: Constants.dummyWalletAddress,
        balance: 1250000, // Balance en sats
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
      
      // Add transaction to history
      _transactions.insert(0, newTransaction);
      
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
    print('🔵 [DEBUG] addDeposit appelé avec: amount=$amount, provider=$provider');
    
    if (_wallet == null) {
      print('🔴 [ERROR] Wallet non initialisé');
      _setError('Wallet non initialisé');
      return false;
    }
    
    if (amount <= 0) {
      print('🔴 [ERROR] Montant invalide: $amount');
      _setError('Montant invalide: $amount');
      return false;
    }
    
    print('🔵 [DEBUG] Wallet actuel: balance=${_wallet!.balance}, address=${_wallet!.address}');
    
    _setLoading(true);
    _clearError();
    
    try {
      print('🔵 [DEBUG] Début du traitement du dépôt...');
      
      // Simulate deposit processing
      await Future.delayed(const Duration(seconds: 2));
      
      print('🔵 [DEBUG] Initialisation du CurrencyService...');
      
      // For mobile money deposits, we need to convert the fiat amount to SATS
      // using the current Bitcoin exchange rate from CurrencyService to maintain consistency
      // Get current XOF to BTC rate from CurrencyService
      final currencyService = CurrencyService();
      
      print('🔵 [DEBUG] Récupération des taux de change...');
      
      // Vérifier si les taux sont déjà chargés
      if (currencyService.exchangeRates['XOF'] == 0.0 || currencyService.exchangeRates.isEmpty) {
        print('🔵 [DEBUG] Taux non chargés, récupération en cours...');
        await currencyService.fetchExchangeRates(); // Ensure we have the latest rates
        
        // Attendre un peu pour s'assurer que les taux sont mis à jour
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        print('🔵 [DEBUG] Taux déjà disponibles');
      }
      
      print('🔵 [DEBUG] Taux de change récupérés: ${currencyService.exchangeRates}');
      
      // Utiliser les taux actuels ou les taux de secours
      double xofPerBtc = currencyService.exchangeRates['XOF'] ?? 0.0;
      
      // Si les taux sont toujours à zéro, utiliser les taux de secours
      if (xofPerBtc <= 0.0) {
        print('🟡 [WARNING] Utilisation des taux de secours car taux API = $xofPerBtc');
        xofPerBtc = 32797850.0; // Taux de secours: 1 BTC = 32,797,850 XOF
      }
      
      print('🔵 [DEBUG] Taux XOF/BTC utilisé: $xofPerBtc');
      
      // Validate exchange rate
      if (xofPerBtc <= 0) {
        print('🔴 [ERROR] Taux de change trop faible: $xofPerBtc');
        _setError('Taux de change invalide: $xofPerBtc (trop faible)');
        return false;
      }
      
      if (xofPerBtc.isNaN) {
        print('🔴 [ERROR] Taux de change NaN');
        _setError('Taux de change invalide: NaN');
        return false;
      }
      
      if (xofPerBtc.isInfinite) {
        print('🔴 [ERROR] Taux de change Infinity');
        _setError('Taux de change invalide: Infinity');
        return false;
      }
      
      print('🔵 [DEBUG] Calcul de la conversion...');
      final btcAmount = amount / xofPerBtc; // Convert XOF to BTC
      print('🔵 [DEBUG] Montant BTC calculé: $btcAmount');
      
      final satsEquivalent = btcAmount * 100000000; // Convert BTC to SATS
      print('🔵 [DEBUG] Équivalent SATS calculé: $satsEquivalent');
      
      // Validate conversion results
      if (btcAmount.isNaN) {
        print('🔴 [ERROR] Conversion BTC NaN: amount=$amount, xofPerBtc=$xofPerBtc');
        _setError('Erreur de conversion BTC: NaN (amount: $amount, xofPerBtc: $xofPerBtc)');
        return false;
      }
      
      if (btcAmount.isInfinite) {
        print('🔴 [ERROR] Conversion BTC Infinity: amount=$amount, xofPerBtc=$xofPerBtc');
        _setError('Erreur de conversion BTC: Infinity (amount: $amount, xofPerBtc: $xofPerBtc)');
        return false;
      }
      
      if (satsEquivalent.isNaN) {
        print('🔴 [ERROR] Conversion SATS NaN: btcAmount=$btcAmount');
        _setError('Erreur de conversion SATS: NaN (btcAmount: $btcAmount)');
        return false;
      }
      
      if (satsEquivalent.isInfinite) {
        print('🔴 [ERROR] Conversion SATS Infinity: btcAmount=$btcAmount');
        _setError('Erreur de conversion SATS: Infinity (btcAmount: $btcAmount)');
        return false;
      }
      
      print('🔵 [DEBUG] Création de la transaction...');
      // Create new deposit transaction
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
      
      print('🔵 [DEBUG] Transaction créée: ${newTransaction.id}');
      
      // Update wallet balance with SATS equivalent
      print('🔵 [DEBUG] Calcul du nouveau solde: ${_wallet!.balance} + $satsEquivalent');
      final newBalance = _wallet!.balance + satsEquivalent;
      print('🔵 [DEBUG] Nouveau solde calculé: $newBalance');
      
      // Validate new balance
      if (newBalance.isNaN) {
        print('🔴 [ERROR] Nouveau solde NaN: balance=${_wallet!.balance}, satsEquivalent=$satsEquivalent');
        _setError('Erreur de calcul du solde: NaN (balance actuel: ${_wallet!.balance}, satsEquivalent: $satsEquivalent)');
        return false;
      }
      
      if (newBalance.isInfinite) {
        print('🔴 [ERROR] Nouveau solde Infinity: balance=${_wallet!.balance}, satsEquivalent=$satsEquivalent');
        _setError('Erreur de calcul du solde: Infinity (balance actuel: ${_wallet!.balance}, satsEquivalent: $satsEquivalent)');
        return false;
      }
      
      print('🔵 [DEBUG] Mise à jour du wallet...');
      _wallet = _wallet!.copyWith(balance: newBalance);
      
      print('🔵 [DEBUG] Sauvegarde dans SharedPreferences...');
      // Update shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(Constants.keyWalletBalance, newBalance);
      
      print('🔵 [DEBUG] Ajout de la transaction à l\'historique...');
      _transactions.insert(0, newTransaction);
      
      print('🟢 [SUCCESS] Dépôt traité avec succès!');
      print('🔵 [DEBUG] Nouveau solde final: ${_wallet!.balance}');
      print('🔵 [DEBUG] Nombre de transactions: ${_transactions.length}');
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('🔴 [ERROR] Exception dans addDeposit: ${e.toString()}');
      print('🔴 [ERROR] Stack trace: ${e.runtimeType}');
      _setError('Failed to process deposit: ${e.toString()}');
      return false;
    } finally {
      print('🔵 [DEBUG] Fin de addDeposit');
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
