import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import services
import 'services/wallet_service.dart';
import 'services/currency_service.dart';
import 'services/auth_service.dart';
import 'services/otp_service.dart';

// Import screens
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/send_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/account_screen.dart';
import 'screens/track_screen.dart';
import 'screens/currency_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/seed_backup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/recovery_screen.dart';

// Import theme
import 'theme/app_theme.dart';

// Import utils
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(create: (_) => CurrencyService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => OtpService()),
      ],
      child: MaterialApp(
        title: Constants.appName,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          // Initial screen
          '/splash': (context) => const SplashScreen(),

          // Main routes
          Constants.routeAuth: (context) => const AuthScreen(),
          Constants.routeHome: (context) => const HomeScreen(),
          Constants.routeSend: (context) => const SendScreen(),
          Constants.routeReceive: (context) => const ReceiveScreen(),
          Constants.routeTransactions: (context) => const TransactionsScreen(),
          Constants.routeOnboarding: (context) => const OnboardingScreen(),

          // Authentication routes
          '/registration': (context) => const RegistrationScreen(),
          '/otp-verification': (context) => const OtpVerificationScreen(),
          '/seed-backup': (context) => const SeedBackupScreen(),
          '/login': (context) => const LoginScreen(),
          '/recovery': (context) => const RecoveryScreen(),
          '/welcome': (context) => const AuthScreen(),

          // Drawer routes
          '/account': (context) => const AccountScreen(),
          '/track': (context) => const TrackScreen(),
          '/currency': (context) => const CurrencyScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/about': (context) => const AboutScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
