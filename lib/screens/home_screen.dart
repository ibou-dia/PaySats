import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart';
import '../services/currency_service.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/address_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/app_drawer.dart';
import '../utils/constants.dart';

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
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Recevoir',
                  onTap: () => Navigator.pushNamed(context, '/receive'),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  icon: Icons.history,
                  label: 'Historique',
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
}
