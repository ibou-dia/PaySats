import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bitcoin_logo.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern (subtle Bitcoin pattern)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: const AssetImage('assets/images/pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
                colorFilter: ColorFilter.mode(
                  AppTheme.bitcoinOrange.withOpacity(0.2),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and title
                    const BitcoinLogo(size: 80),
                    const SizedBox(height: 32),
                    const Text(
                      'Bienvenue sur PaySats',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gérez vos paiements, épargne et investissements avec Bitcoin et Mobile Money',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.08),
                    
                    // Create wallet button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: walletService.isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/registration');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.bitcoinOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Créer wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Connect wallet button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: walletService.isLoading
                            ? null
                            : () async {
                                final success = await walletService.connectWallet();
                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.bitcoinOrange,
                          side: const BorderSide(color: AppTheme.bitcoinOrange),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: walletService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.bitcoinOrange,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    // Error message if any
                    if (walletService.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          walletService.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
