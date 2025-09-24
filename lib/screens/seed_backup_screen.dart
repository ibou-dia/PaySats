import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../models/seed_phrase.dart';

class SeedBackupScreen extends StatefulWidget {
  const SeedBackupScreen({super.key});

  @override
  State<SeedBackupScreen> createState() => _SeedBackupScreenState();
}

class _SeedBackupScreenState extends State<SeedBackupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Verification state
  List<String> _shuffledWords = [];
  List<String> _selectedWords = [];
  List<int> _correctPositions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupVerificationWords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupVerificationWords() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final seedPhrase = authService.seedPhrase;
    
    if (seedPhrase != null) {
      // Sélectionner 4 positions aléatoirement pour la vérification
      final random = Random();
      final wordCount = seedPhrase.words.length;
      _correctPositions = [];
      
      while (_correctPositions.length < 4) {
        final position = random.nextInt(wordCount);
        if (!_correctPositions.contains(position)) {
          _correctPositions.add(position);
        }
      }
      _correctPositions.sort();

      // Créer une liste mélangée avec les mots corrects et quelques distracteurs
      final correctWords = _correctPositions.map((pos) => seedPhrase.words[pos]).toList();
      final allWords = List<String>.from(seedPhrase.words);
      allWords.shuffle(random);
      
      // Ajouter quelques mots distracteurs
      final distractors = allWords.where((word) => !correctWords.contains(word)).take(4).toList();
      
      _shuffledWords = [...correctWords, ...distractors];
      _shuffledWords.shuffle(random);
      
      _selectedWords = List.filled(4, '');
    }
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

  Future<void> _verifyBackup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Vérifier que tous les mots sont sélectionnés
      if (_selectedWords.any((word) => word.isEmpty)) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner tous les mots manquants';
        });
        return;
      }

      // Créer la liste complète avec les mots sélectionnés
      final seedPhrase = authService.seedPhrase!;
      final verificationWords = List<String>.from(seedPhrase.words);
      
      for (int i = 0; i < _correctPositions.length; i++) {
        verificationWords[_correctPositions[i]] = _selectedWords[i];
      }

      // Vérifier la seed phrase
      final isValid = await authService.verifySeedPhraseBackup(verificationWords);

      if (isValid) {
        if (mounted) {
          // Naviguer vers la configuration du PIN
          Navigator.pushReplacementNamed(context, '/pin-setup');
        }
      } else {
        setState(() {
          _errorMessage = 'Vérification échouée. Veuillez vérifier les mots sélectionnés.';
        });
        _resetVerification();
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

  void _resetVerification() {
    setState(() {
      _selectedWords = List.filled(4, '');
    });
  }

  void _selectWord(String word, int position) {
    setState(() {
      _selectedWords[position] = word;
      _errorMessage = null;
    });
  }

  void _removeWord(int position) {
    setState(() {
      _selectedWords[position] = '';
    });
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
              ...const [
                '• Écrivez cette phrase sur papier',
                '• Conservez-la dans un endroit sûr',
                '• Ne la partagez jamais avec personne',
                '• Ne la stockez pas numériquement',
              ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  tip,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationView() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final seedPhrase = authService.seedPhrase;

    if (seedPhrase == null) {
      return const Center(
        child: Text('Aucune seed phrase à vérifier'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.quiz_outlined, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sélectionnez les mots manquants dans l\'ordre correct pour vérifier votre sauvegarde.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Seed phrase with missing words
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
            final isBlank = _correctPositions.contains(index);
            final blankIndex = isBlank ? _correctPositions.indexOf(index) : -1;
            final selectedWord = isBlank ? _selectedWords[blankIndex] : '';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isBlank 
                    ? (selectedWord.isEmpty ? Colors.grey.shade100 : Colors.green.shade50)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isBlank 
                      ? (selectedWord.isEmpty ? Colors.grey.shade400 : Colors.green.shade300)
                      : Colors.grey.shade300,
                ),
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
                    child: isBlank
                        ? GestureDetector(
                            onTap: selectedWord.isNotEmpty 
                                ? () => _removeWord(blankIndex)
                                : null,
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: selectedWord.isEmpty 
                                    ? Colors.white
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: selectedWord.isEmpty 
                                      ? Colors.grey.shade400
                                      : Colors.green.shade400,
                                  style: selectedWord.isEmpty 
                                      ? BorderStyle.solid
                                      : BorderStyle.solid,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  selectedWord.isEmpty ? '?' : selectedWord,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: selectedWord.isEmpty 
                                        ? Colors.grey.shade500
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(
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

        // Word selection buttons
        const Text(
          'Sélectionnez les mots manquants :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _shuffledWords.map((word) {
            final isUsed = _selectedWords.contains(word);
            return GestureDetector(
              onTap: isUsed ? null : () {
                // Find first empty position
                final emptyIndex = _selectedWords.indexWhere((w) => w.isEmpty);
                if (emptyIndex != -1) {
                  _selectWord(word, emptyIndex);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.grey.shade200 : AppTheme.bitcoinOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUsed ? Colors.grey.shade400 : AppTheme.bitcoinOrange,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: isUsed ? Colors.grey.shade500 : AppTheme.bitcoinOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

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

        // Verify button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading || _selectedWords.any((word) => word.isEmpty) 
                ? null 
                : _verifyBackup,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Vérifier la sauvegarde'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: const AssetImage('assets/images/pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
                colorFilter: ColorFilter.mode(
                  AppTheme.bitcoinOrange.withValues(alpha: 0.2),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Sauvegarde Seed Phrase',
                          style: TextStyle(
                            fontSize: 24,
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

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.bitcoinOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: const [
                      Tab(text: 'Sauvegarde'),
                      Tab(text: 'Vérification'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildSeedPhraseDisplay(),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildVerificationView(),
                      ),
                    ],
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