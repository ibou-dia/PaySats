import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../services/currency_service.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/address_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/app_drawer.dart';
import '../utils/constants.dart';
import 'wave_payment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final wallet = walletService.wallet;

    // Si pas de wallet et pas en cours de chargement, créer un wallet
    if (wallet == null && !walletService.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        walletService.createWallet();
      });
    }

    if (wallet == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.bitcoinOrange),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(currentRoute: Constants.routeHome),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'PaySats',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.bitcoinOrange,
                      AppTheme.bitcoinOrange.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre Solde',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${Formatters.formatSats(wallet.balance)} SATS',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<CurrencyService>(
                      builder: (context, currencyService, _) {
                        // Convertir le solde SATS en devise fiat
                        final fiatBalance = currencyService.satsToFiat(
                          wallet.balance,
                        );
                        return Text(
                          currencyService.formatFiatAmount(fiatBalance),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    AddressCard(
                      address: wallet.address,
                      showFullAddress: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.arrow_upward_rounded,
                  label: 'Envoyer',
                  onTap: () => Navigator.pushNamed(context, '/send'),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Recevoir',
                  onTap: () => Navigator.pushNamed(context, '/receive'),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Dépot',
                  onTap: () => _showDepositOptions(context),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  context,
                  icon: Icons.history,
                  label: 'Récents',
                  onTap: () => Navigator.pushNamed(context, '/transactions'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Transactions
            Text(
              'Transactions Récentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            if (walletService.transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune transaction pour le moment',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    walletService.transactions.length > 3
                        ? 3
                        : walletService.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = walletService.transactions[index];
                  return TransactionItem(
                    transaction: transaction,
                    onTap: () {
                      // TODO: Show transaction details
                    },
                  );
                },
              ),

            // View all transactions button
            if (walletService.transactions.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/transactions'),
                    child: Text(
                      'Voir toutes les transactions',
                      style: TextStyle(
                        color: AppTheme.bitcoinOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.bitcoinOrange, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepositOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Choisir une méthode de dépôt',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Orange Money Option
              _buildDepositOption(
                context,
                title: 'Orange Money',
                subtitle: 'Déposer via Orange Money',
                imagePath: 'assets/images/orange-money-nobg.png',
                containerColor: const Color.fromARGB(255, 255, 226, 183),
                onTap: () {
                  Navigator.pop(context);
                  _handleDepositMethod('Orange Money');
                },
              ),

              const SizedBox(height: 16),

              // Wave Option
              _buildDepositOption(
                context,
                title: 'Wave',
                subtitle: 'Déposer via Wave',
                imagePath: 'assets/images/wave-nobg.png',
                containerColor: Colors.blue.shade100,
                onTap: () {
                  Navigator.pop(context);
                  _handleDepositMethod('Wave');
                },
              ),

              const SizedBox(height: 16),

              // Mixx Option
              _buildDepositOption(
                context,
                title: 'Mixx by Yas',
                subtitle: 'Déposer via Mixx',
                imagePath: 'assets/images/mixx-by-yas.png',
                containerColor: const Color(0xFF1A237E), // Bleu nuit
                onTap: () {
                  Navigator.pop(context);
                  _handleDepositMethod('Mixx');
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepositOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required Color containerColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDepositMethod(String method) {
    if (method == 'Wave') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WavePaymentScreen(),
        ),
      ).then((result) {
        // Rafraîchir les données si le dépôt a réussi
        if (result == true) {
          setState(() {
            // Déclencher un rebuild pour mettre à jour l'affichage
          });
        }
      });
    } else {
      // TODO: Implémenter la logique de dépôt pour les autres méthodes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dépôt via $method sélectionné'),
          backgroundColor: AppTheme.bitcoinOrange,
        ),
      );
    }
  }
}
