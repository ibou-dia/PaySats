import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService extends ChangeNotifier {
  static const String _priceApiUrl = 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,eur,gbp,jpy,cad,aud,chf,xof';
  static const String _prefKeyCurrency = 'selected_currency';
  
  // Singleton pattern
  static CurrencyService? _instance;
  static CurrencyService get instance {
    _instance ??= CurrencyService._internal();
    return _instance!;
  }
  
  Map<String, double> _exchangeRates = {
    'USD': 0.0,
    'EUR': 0.0,
    'GBP': 0.0,
    'JPY': 0.0,
    'CAD': 0.0,
    'AUD': 0.0,
    'CHF': 0.0,
    'XOF': 0.0, // FCFA (Franc CFA)
  };
  
  String _selectedCurrency = 'USD';
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;
  
  CurrencyService._internal() {
    _loadSelectedCurrency();
    fetchExchangeRates();
  }
  
  // Factory constructor pour maintenir la compatibilité
  factory CurrencyService() {
    return instance;
  }
  
  // Getters
  Map<String, double> get exchangeRates => _exchangeRates;
  String get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  
  // Get the current exchange rate for the selected currency
  double get currentRate => _exchangeRates[_selectedCurrency] ?? 0.0;
  
  // Get available currencies with XOF first, then USD, EUR, and others
  List<String> get availableCurrencies {
    final currencies = _exchangeRates.keys.toList();
    // Remove priority currencies to set custom order
    currencies.remove('XOF');
    currencies.remove('USD');
    currencies.remove('EUR');
    // Sort remaining currencies alphabetically
    currencies.sort();
    // Return in desired order: XOF (FCFA), USD, EUR, then others
    return ['XOF', 'USD', 'EUR', ...currencies];
  }
  
  // Load the selected currency from SharedPreferences
  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString(_prefKeyCurrency) ?? 'USD';
    notifyListeners();
  }
  
  // Change the selected currency
  Future<void> setSelectedCurrency(String currency) async {
    if (!_exchangeRates.containsKey(currency)) return;
    
    _selectedCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyCurrency, currency);
    notifyListeners();
  }
  
  // Convert from Satoshis to fiat
  double satsToFiat(double satsAmount) {
    final rate = _exchangeRates[_selectedCurrency] ?? 0.0;
    
    // Check for invalid inputs
    if (satsAmount.isNaN || satsAmount.isInfinite || rate <= 0) {
      return 0.0;
    }
    
    // Convert sats to BTC first (1 BTC = 100,000,000 sats), then to fiat
    final btcAmount = satsAmount / 100000000;
    final result = btcAmount * rate;
    
    // Check for invalid result
    if (result.isNaN || result.isInfinite) {
      return 0.0;
    }
    
    return result;
  }
  
  // Convert from fiat to Satoshis
  double fiatToSats(double fiatAmount) {
    final rate = _exchangeRates[_selectedCurrency] ?? 0.0;
    
    // Check for invalid inputs
    if (fiatAmount.isNaN || fiatAmount.isInfinite || rate <= 0) {
      return 0.0;
    }
    
    // Convert fiat to BTC first, then to sats
    final btcAmount = fiatAmount / rate;
    final result = btcAmount * 100000000;
    
    // Check for invalid result
    if (result.isNaN || result.isInfinite) {
      return 0.0;
    }
    
    return result;
  }

  // Convert from Bitcoin to fiat (kept for backward compatibility)
  double btcToFiat(double btcAmount) {
    final rate = _exchangeRates[_selectedCurrency] ?? 0.0;
    return btcAmount * rate;
  }
  
  // Convert from fiat to Bitcoin (kept for backward compatibility)
  double fiatToBtc(double fiatAmount) {
    final rate = _exchangeRates[_selectedCurrency] ?? 0.0;
    if (rate <= 0) return 0.0;
    return fiatAmount / rate;
  }
  
  // Format the currency amount for display
  String formatFiatAmount(double amount) {
    if (_selectedCurrency == 'JPY') {
      // No decimal places for Japanese Yen
      return '${amount.round()} $_selectedCurrency';
    } else if (_selectedCurrency == 'XOF') {
      // No decimal places for CFA Franc (large numbers) with thousand separators
      final roundedAmount = amount.round();
      final formattedAmount = _formatWithThousandsSeparator(roundedAmount);
      return '$formattedAmount FCFA';
    } else {
      // 2 decimal places for other currencies
      return '${amount.toStringAsFixed(2)} $_selectedCurrency';
    }
  }
  
  // Helper method to format numbers with thousands separator (spaces)
  String _formatWithThousandsSeparator(int number) {
    final numberStr = number.toString();
    final reversed = numberStr.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      final chunk = reversed.sublist(i, end).reversed.join('');
      chunks.add(chunk);
    }
    
    return chunks.reversed.join(' ');
  }
  
  // Fetch exchange rates from API
  Future<void> fetchExchangeRates() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await http.get(Uri.parse(_priceApiUrl));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('bitcoin')) {
          final bitcoin = data['bitcoin'];
          
          // Update exchange rates
          _exchangeRates = {
            'USD': bitcoin['usd']?.toDouble() ?? 0.0,
            'EUR': bitcoin['eur']?.toDouble() ?? 0.0,
            'GBP': bitcoin['gbp']?.toDouble() ?? 0.0,
            'JPY': bitcoin['jpy']?.toDouble() ?? 0.0,
            'CAD': bitcoin['cad']?.toDouble() ?? 0.0,
            'AUD': bitcoin['aud']?.toDouble() ?? 0.0,
            'CHF': bitcoin['chf']?.toDouble() ?? 0.0,
            'XOF': 0.0, // Will be calculated from USD rate
          };
          
          // Calculate XOF rate from USD (1 USD ≈ 655.957 XOF)
          final usdRate = _exchangeRates['USD'] ?? 0.0;
          if (usdRate > 0) {
            final xofRate = usdRate * 655.957; // USD to XOF conversion
            _exchangeRates['XOF'] = xofRate;
          }
          
          _lastUpdated = DateTime.now();
        } else {
          _setError('Bitcoin data not found in response');
        }
      } else {
        _setError('Failed to fetch exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Error fetching exchange rates: ${e.toString()}');
      
      // Use fallback rates if API call fails
      if (_exchangeRates['USD'] == 0.0) {
        _exchangeRates = {
          'USD': 50000.0, // 1 BTC = 50,000 USD
          'EUR': 45000.0, // 1 BTC = 45,000 EUR
          'GBP': 40000.0,
          'JPY': 7500000.0,
          'CAD': 67500.0,
          'AUD': 75000.0,
          'CHF': 45000.0,
          'XOF': 32797850.0, // 1 BTC = 32,797,850 XOF (50,000 * 655.957)
        };
      }
    } finally {
      _setLoading(false);
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
