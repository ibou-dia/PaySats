class Constants {
  // App
  static const String appName = 'PaySats';
  static const String appSlogan = 'Mobile Money + Bitcoin + Épargne';
  static const String appVersion = '1.0.0';
  
  // Routes - Principales
  static const String routeAuth = '/auth';
  static const String routeHome = '/home';
  static const String routeSend = '/send';
  static const String routeReceive = '/receive';
  static const String routeTransactions = '/transactions';
  static const String routeOnboarding = '/onboarding';
  static const String routeSplash = '/splash';
  
  // Routes - Mobile Money
  static const String routeMobileMoneyLink = '/mobile-money-link';
  static const String routeMobileMoneyDeposit = '/mobile-money-deposit';
  static const String routeMobileMoneyWithdraw = '/mobile-money-withdraw';
  
  // Routes - Épargne (Vaults)
  static const String routeVaults = '/vaults';
  static const String routeCreateVault = '/create-vault';
  static const String routeVaultDetails = '/vault-details';
  

  
  // Routes - Drawer
  static const String routeAccount = '/account';
  static const String routeTrack = '/track';
  static const String routeCurrency = '/currency';
  static const String routeSettings = '/settings';
  static const String routeAbout = '/about';
  
  // Storage Keys - Wallet
  static const String keyWalletAddress = 'wallet_address';
  static const String keyWalletBalance = 'wallet_balance';
  static const String keyLightningBalance = 'lightning_balance';
  
  // Storage Keys - Mobile Money
  static const String keyWaveAccount = 'wave_account';
  static const String keyOrangeMoneyAccount = 'orange_money_account';
  static const String keyFreeMoneyAccount = 'free_money_account';
  
  // Storage Keys - User
  static const String keyUserProfile = 'user_profile';
  static const String keyOptionalKYC = 'optional_kyc'; // KYC optionnel pour limites élevées
  static const String keyUserPIN = 'user_pin';
  static const String keyBiometricEnabled = 'biometric_enabled';
  
  // Storage Keys - Preferences
  static const String keySelectedLanguage = 'selected_language';
  static const String keySelectedCurrency = 'selected_currency';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Mobile Money Providers
  static const String providerWave = 'WAVE';
  static const String providerOrangeMoney = 'ORANGE_MONEY';
  static const String providerFreeMoney = 'FREE_MONEY';
  
  // Currencies
  static const String currencyFCFA = 'XOF';
  static const String currencyBTC = 'BTC';
  static const String currencySATS = 'SATS';
  
  // Languages
  static const String languageFrench = 'fr';
  static const String languageWolof = 'wo';
  
  // Vault Types
  static const String vaultTypeGeneral = 'GENERAL';
  static const String vaultTypeTabaski = 'TABASKI';
  static const String vaultTypeEducation = 'EDUCATION';
  static const String vaultTypeProject = 'PROJECT';
  static const String vaultTypeMarriage = 'MARRIAGE';
  

  
  // Transaction Types
  static const String transactionTypeSend = 'SEND';
  static const String transactionTypeReceive = 'RECEIVE';
  static const String transactionTypeDeposit = 'DEPOSIT';
  static const String transactionTypeWithdraw = 'WITHDRAW';
  static const String transactionTypeVaultDeposit = 'VAULT_DEPOSIT';
  static const String transactionTypeVaultWithdraw = 'VAULT_WITHDRAW';
  
  // Limits (en FCFA)
  static const double dailyTransactionLimit = 500000; // 500,000 FCFA
  static const double monthlyTransactionLimit = 2000000; // 2,000,000 FCFA
  static const double minTransactionAmount = 100; // 100 FCFA
  
  // Vault Durations (en jours)
  static const int vaultDuration1Month = 30;
  static const int vaultDuration3Months = 90;
  static const int vaultDuration6Months = 180;
  static const int vaultDuration12Months = 365;
  
  // Sample Data
  static const String dummyWalletAddress = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
  static const String dummyLightningAddress = 'user@paysats.com';
  static const String dummyTransactionHash = '0x1234567890abcdef1234567890abcdef';
  
  // API Endpoints (à configurer selon l'environnement)
  static const String baseApiUrl = 'https://api.paysats.com/v1';
  static const String lightningNodeUrl = 'https://lightning.paysats.com';
  
  // Contact & Support
  static const String supportEmail = 'support@paysats.com';
  static const String supportPhone = '+221 77 123 45 67';
  static const String telegramGroup = 'https://t.me/paysats';
  static const String twitterHandle = '@PaySatsApp';
}
