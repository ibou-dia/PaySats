import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SeedBackupScreen extends StatefulWidget {
  const SeedBackupScreen({super.key});

  @override
  State<SeedBackupScreen> createState() => _SeedBackupScreenState();
}

class _SeedBackupScreenState extends State<SeedBackupScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _copySeedPhrase() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final seedPhrase = authService.seedPhrase;
    
    if (seedPhrase != null) {
      await Clipboard.setData(ClipboardData(text: seedPhrase.words.join(' ')));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seed phrase copiée dans le presse-papiers'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _continueToHome() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Marquer la seed phrase comme sauvegardée
      await authService.markSeedPhraseAsBackedUp();
      
      // Authentifier directement l'utilisateur
      await authService.authenticateDirectly();

      if (mounted) {
        // Naviguer directement vers l'écran d'accueil
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSeedPhraseDisplay() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final seedPhrase = authService.seedPhrase;

    if (seedPhrase == null) {
      return const Center(
        child: Text('Aucune seed phrase générée'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning message
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important !',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sauvegardez cette phrase de récupération en lieu sûr. Elle est le seul moyen de récupérer votre wallet.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Seed phrase grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: seedPhrase.words.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.bitcoinOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bitcoinOrange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      seedPhrase.words[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Copy button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _copySeedPhrase,
            icon: const Icon(Icons.copy),
            label: const Text('Copier la phrase'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.bitcoinOrange,
              side: BorderSide(color: AppTheme.bitcoinOrange),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Security tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Conseils de sécurité',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Écrivez cette phrase sur papier et conservez-la en lieu sûr\n'
                '• Ne la partagez jamais avec personne\n'
                '• Ne la stockez pas sur un appareil connecté à internet\n'
                '• Vérifiez que vous l\'avez bien notée avant de continuer',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Error message
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ),

        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _continueToHome,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('J\'ai sauvegardé ma phrase - Continuer'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios),
                        color: AppTheme.textPrimary,
                      ),
                      Expanded(
                        child: Text(
                          'Sauvegarde de la phrase de récupération',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildSeedPhraseDisplay(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}