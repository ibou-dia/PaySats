import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/main_layout.dart';
import '../widgets/bitcoin_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: -1,
      currentRoute: '/about',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'À Propos',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // App logo and name
            const BitcoinLogo(size: 80),
            const SizedBox(height: 24),
            Text(
              'PaySats',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // App description
            const Text(
              'PaySats est une application mobile de paiement et de gestion financière qui facilite les transactions et la gestion de vos finances.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildLinkRow(
                      context,
                      icon: Icons.code,
                      title: 'Dépôt GitHub',
                      url: 'https://github.com/ibou-dia/paysats',
                    ),
                    const Divider(height: 24),
                    _buildLinkRow(
                      context,
                      icon: Icons.public,
                      title: 'Documentation PaySats',
                      url: 'https://docs.paysats.com/',
                    ),
                    const Divider(height: 24),
                    _buildLinkRow(
                      context,
                      icon: Icons.shield,
                      title: 'Politique de Confidentialité',
                      url: 'https://paysats.com/privacy',
                    ),
                    const Divider(height: 24),
                    _buildLinkRow(
                      context,
                      icon: Icons.gavel,
                      title: 'Conditions d\'Utilisation',
                      url: 'https://paysats.com/terms',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Info sections
            _buildInfoSection(
              context,
              title: 'Qu\'est-ce que PaySats ?',
              content:
                  'PaySats est une application mobile innovante qui simplifie les paiements et la gestion financière. Elle offre une interface intuitive pour effectuer des transactions rapides et sécurisées.',
            ),

            const SizedBox(height: 24),

            _buildInfoSection(
              context,
              title: 'Comment ça fonctionne',
              content:
                  'PaySats utilise des technologies modernes pour garantir la sécurité et la rapidité de vos transactions. L\'application vous permet de gérer facilement vos finances avec des fonctionnalités avancées de suivi et de contrôle.',
            ),

            const SizedBox(height: 40),

            // Credits
            Text(
              '© 2025 Équipe PaySats',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bitcoinOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.bitcoinOrange, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    url,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
