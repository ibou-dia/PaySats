import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue sur PaySats',
      description: 'Votre super wallet qui relie Bitcoin et Mobile Money pour l\'Afrique de l\'Ouest.',
      image: 'assets/images/onboarding_1.png',
      imageIcon: Icons.account_balance_wallet,
    ),
    OnboardingPage(
      title: 'Qu\'est-ce que PaySats?',
      description: 'PaySats combine Bitcoin, Mobile Money, épargne et investissement dans une seule application simple et sécurisée.',
      image: 'assets/images/onboarding_2.png',
      imageIcon: Icons.currency_bitcoin,
    ),
    OnboardingPage(
      title: 'Sécurité Avancée',
      description: 'Votre wallet Bitcoin est protégé par une phrase de récupération et un code PIN. Vos clés privées restent toujours sous votre contrôle.',
      image: 'assets/images/onboarding_3.png',
      imageIcon: Icons.security,
    ),
    OnboardingPage(
      title: 'Authentification Sécurisée',
      description: 'Créez votre compte avec votre numéro de téléphone, sauvegardez votre phrase de récupération et configurez votre PIN de sécurité.',
      image: 'assets/images/onboarding_auth.png',
      imageIcon: Icons.verified_user,
    ),
    OnboardingPage(
      title: 'Commencez Maintenant',
      description: 'Gérez vos paiements, épargne et investissements facilement. Envoyez, recevez et suivez vos transactions.',
      image: 'assets/images/onboarding_4.png',
      imageIcon: Icons.rocket_launch,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to auth screen after onboarding
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  void _skipOnboarding() {
    // Navigate to auth screen
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Passer',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Navigation controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? AppTheme.bitcoinOrange
                              : AppTheme.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Next/Finish button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Créer mon compte' : 'Suivant',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or icon
          page.image != null
              ? Image.asset(
                  page.image!,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image is not found
                    return Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.bitcoinOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        page.imageIcon ?? Icons.monetization_on,
                        size: 80,
                        color: AppTheme.bitcoinOrange,
                      ),
                    );
                  },
                )
              : Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.bitcoinOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    page.imageIcon ?? Icons.monetization_on,
                    size: 80,
                    color: AppTheme.bitcoinOrange,
                  ),
                ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String? image;
  final IconData? imageIcon;

  OnboardingPage({
    required this.title,
    required this.description,
    this.image,
    this.imageIcon,
  });
}
