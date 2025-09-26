import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/main_layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedNetwork = 'Mainnet';
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;

  final List<String> _availableLanguages = [
    'Français',
    'English',
    'Español',
    'Deutsch',
    '中文',
    '日本語',
  ];

  final List<String> _availableNetworks = ['Mainnet', 'Testnet'];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: -1,
      currentRoute: '/settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader(context, 'Apparence'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode Sombre'),
                    subtitle: const Text(
                      'Basculer entre le thème clair et sombre',
                    ),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                      // TODO: Implement theme change
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mode sombre bientôt disponible'),
                        ),
                      );
                    },
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dark_mode),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.language),
                    ),
                    title: const Text('Langue'),
                    subtitle: Text(_selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showLanguageSelector(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Network Section
            _buildSectionHeader(context, 'Réseau'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.wifi),
                    ),
                    title: const Text('Réseau'),
                    subtitle: Text(_selectedNetwork),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showNetworkSelector(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sync),
                    ),
                    title: const Text('Synchronisation automatique'),
                    subtitle: const Text(
                      'Synchroniser le portefeuille au démarrage',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement auto-sync settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Paramètres de synchronisation automatique bientôt disponibles',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader(context, 'Sécurité'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Authentification Biométrique'),
                    subtitle: const Text(
                      'Utiliser l\'empreinte digitale ou Face ID',
                    ),
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      // TODO: Implement biometric authentication
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Authentification biométrique bientôt disponible',
                          ),
                        ),
                      );
                    },
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fingerprint),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock),
                    ),
                    title: const Text('Changer le PIN'),
                    subtitle: const Text(
                      'Mettre à jour votre PIN de portefeuille',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement PIN change
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Changement de PIN bientôt disponible'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(context, 'Notifications'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Activer les Notifications'),
                subtitle: const Text(
                  'Recevoir des alertes pour les transactions',
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // TODO: Implement notification settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications activées'
                            : 'Notifications désactivées',
                      ),
                    ),
                  );
                },
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Clear Data Section
            _buildSectionHeader(context, 'Données'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Effacer les Données Locales'),
                subtitle: const Text(
                  'Supprimer les données mises en cache de l\'appareil',
                ),
                onTap: () {
                  _showClearDataConfirmation(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sélectionner la Langue',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ...List.generate(_availableLanguages.length, (index) {
                final language = _availableLanguages[index];
                final isSelected = language == _selectedLanguage;

                return ListTile(
                  title: Text(language),
                  trailing:
                      isSelected
                          ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.bitcoinOrange,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);

                    // TODO: Implement language change
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Langue changée vers $language')),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNetworkSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sélectionner le Réseau',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ...List.generate(_availableNetworks.length, (index) {
                final network = _availableNetworks[index];
                final isSelected = network == _selectedNetwork;

                return ListTile(
                  title: Text(network),
                  subtitle: Text(
                    network == 'Mainnet'
                        ? 'Réseau principal avec de vrais fonds'
                        : 'Réseau de test avec des fonds de test',
                  ),
                  trailing:
                      isSelected
                          ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.bitcoinOrange,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedNetwork = network;
                    });
                    Navigator.pop(context);

                    // TODO: Implement network change
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Réseau changé vers $network')),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Changer de réseau nécessitera un redémarrage de l\'application et une re-authentification',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Effacer les Données Locales'),
            content: const Text(
              'Ceci supprimera toutes les données mises en cache de votre appareil. Votre portefeuille et vos fonds ne seront pas affectés, mais vous devrez peut-être vous re-authentifier. Êtes-vous sûr ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // TODO: Implement clear data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Données locales effacées')),
                  );
                },
                child: const Text(
                  'Effacer les Données',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
