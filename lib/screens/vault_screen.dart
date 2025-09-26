import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/main_layout.dart';
import '../models/vault.dart';
import '../services/wallet_service.dart';
import '../utils/formatters.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<Vault> vaults = [];

  @override
  void initState() {
    super.initState();
    _loadVaults();
  }

  void _loadVaults() {
    // Simulation de chargement des coffres
    // Dans une vraie app, ceci viendrait d'une base de données
    setState(() {
      vaults = [
        // Exemple de coffre pour démonstration
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: -1,
      currentRoute: '/vaults',
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coffre d\'Épargne',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              // En-tête avec bouton de création
              _buildHeader(context),
              const SizedBox(height: 24),

              // Liste des coffres
              Expanded(
                child:
                    vaults.isEmpty
                        ? _buildEmptyState(context)
                        : _buildVaultsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.bitcoinOrange.withOpacity(0.1),
            AppTheme.bitcoinOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bitcoinOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Coffres',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vaults.length} coffre(s) actif(s)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateVaultDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouveau'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bitcoinOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.bitcoinOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.savings_rounded,
              size: 60,
              color: AppTheme.bitcoinOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun coffre créé',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier coffre d\'épargne\npour sécuriser vos sats',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateVaultDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Créer un coffre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bitcoinOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultsList() {
    return ListView.builder(
      itemCount: vaults.length,
      itemBuilder: (context, index) {
        final vault = vaults[index];
        return _buildVaultCard(vault);
      },
    );
  }

  Widget _buildVaultCard(Vault vault) {
    final isLocked =
        vault.isLocked &&
        vault.unlockDate != null &&
        DateTime.now().isBefore(vault.unlockDate!);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppTheme.bitcoinOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vault.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (vault.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        vault.description!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      isLocked
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLocked ? Icons.lock : Icons.lock_open,
                      size: 14,
                      color: isLocked ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isLocked ? 'Verrouillé' : 'Disponible',
                      style: TextStyle(
                        color: isLocked ? Colors.red : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Montant
          Text(
            '${Formatters.formatSats(vault.currentAmount)} sats',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          if (isLocked && vault.unlockDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Déverrouillage le ${_formatDate(vault.unlockDate!)}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Boutons d'action
          const SizedBox(height: 16),
          Row(
            children: [
              // Bouton Ajouter (toujours disponible)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMoneyDialog(context, vault),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bitcoinOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton Retirer (seulement si non verrouillé)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isLocked
                          ? null
                          : () => _showWithdrawMoneyDialog(context, vault),
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Retirer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLocked ? Colors.grey.shade300 : Colors.red,
                    foregroundColor:
                        isLocked ? Colors.grey.shade600 : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showCreateVaultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateVaultDialog(),
    ).then((result) {
      if (result != null && result is Vault) {
        setState(() {
          vaults.add(result);
        });
      }
    });
  }

  void _showAddMoneyDialog(BuildContext context, Vault vault) {
    showDialog(
      context: context,
      builder: (context) => AddMoneyDialog(vault: vault),
    ).then((amount) {
      if (amount != null && amount is double && amount > 0) {
        setState(() {
          // Créer un nouveau vault avec le montant mis à jour
          final index = vaults.indexOf(vault);
          if (index != -1) {
            vaults[index] = Vault(
              id: vault.id,
              userId: vault.userId,
              name: vault.name,
              description: vault.description,
              type: vault.type,
              status: vault.status,
              currentAmount: vault.currentAmount + amount,
              targetAmount: vault.targetAmount,
              createdAt: vault.createdAt,
              targetDate: vault.targetDate,
              lastDepositAt: DateTime.now(),
              currency: vault.currency,
              imageUrl: vault.imageUrl,
              color: vault.color,
              autoSaveEnabled: vault.autoSaveEnabled,
              autoSaveAmount: vault.autoSaveAmount,
              autoSaveFrequency: vault.autoSaveFrequency,
              nextAutoSaveDate: vault.nextAutoSaveDate,
              interestRate: vault.interestRate,
              totalInterestEarned: vault.totalInterestEarned,
              isLocked: vault.isLocked,
              unlockDate: vault.unlockDate,
              metadata: vault.metadata,
            );
          }
        });
      }
    });
  }

  void _showWithdrawMoneyDialog(BuildContext context, Vault vault) {
    showDialog(
      context: context,
      builder: (context) => WithdrawMoneyDialog(vault: vault),
    ).then((amount) {
      if (amount != null && amount is double && amount > 0) {
        setState(() {
          // Créer un nouveau vault avec le montant mis à jour
          final index = vaults.indexOf(vault);
          if (index != -1) {
            final newAmount = (vault.currentAmount - amount).clamp(
              0.0,
              vault.currentAmount,
            );
            vaults[index] = Vault(
              id: vault.id,
              userId: vault.userId,
              name: vault.name,
              description: vault.description,
              type: vault.type,
              status: vault.status,
              currentAmount: newAmount,
              targetAmount: vault.targetAmount,
              createdAt: vault.createdAt,
              targetDate: vault.targetDate,
              lastDepositAt: vault.lastDepositAt,
              currency: vault.currency,
              imageUrl: vault.imageUrl,
              color: vault.color,
              autoSaveEnabled: vault.autoSaveEnabled,
              autoSaveAmount: vault.autoSaveAmount,
              autoSaveFrequency: vault.autoSaveFrequency,
              nextAutoSaveDate: vault.nextAutoSaveDate,
              interestRate: vault.interestRate,
              totalInterestEarned: vault.totalInterestEarned,
              isLocked: vault.isLocked,
              unlockDate: vault.unlockDate,
              metadata: vault.metadata,
            );
          }
        });
      }
    });
  }
}

class CreateVaultDialog extends StatefulWidget {
  const CreateVaultDialog({super.key});

  @override
  State<CreateVaultDialog> createState() => _CreateVaultDialogState();
}

class _CreateVaultDialogState extends State<CreateVaultDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  int _lockDurationDays = 30;
  bool _isLocked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer un coffre',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Nom du coffre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du coffre',
                  hintText: 'Ex: Vacances 2025',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.savings),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description (optionnelle)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optionnelle)',
                  hintText: 'Décrivez l\'objectif de ce coffre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Montant initial
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Montant initial (sats)',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_bitcoin),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Option de verrouillage
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isLocked,
                          onChanged: (value) {
                            setState(() {
                              _isLocked = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Verrouiller ce coffre',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (_isLocked) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Durée de verrouillage: $_lockDurationDays jours',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _lockDurationDays.toDouble(),
                        min: 1,
                        max: 365,
                        divisions: 364,
                        activeColor: AppTheme.bitcoinOrange,
                        onChanged: (value) {
                          setState(() {
                            _lockDurationDays = value.round();
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1 jour',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '1 an',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createVault,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.bitcoinOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Créer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createVault() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final now = DateTime.now();

      final vault = Vault(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // À remplacer par l'ID utilisateur réel
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        type: VaultType.savings,
        status: VaultStatus.active,
        currentAmount: amount,
        createdAt: now,
        currency: 'SATS',
        autoSaveEnabled: false,
        interestRate: 0.0,
        totalInterestEarned: 0.0,
        isLocked: _isLocked,
        unlockDate:
            _isLocked ? now.add(Duration(days: _lockDurationDays)) : null,
      );

      Navigator.of(context).pop(vault);
    }
  }
}

// Dialogue pour ajouter de l'argent
class AddMoneyDialog extends StatefulWidget {
  final Vault vault;

  const AddMoneyDialog({super.key, required this.vault});

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: AppTheme.bitcoinOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ajouter de l\'argent',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Coffre: ${widget.vault.name}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Champ montant
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant (sats)',
                  hintText: 'Entrez le montant à ajouter',
                  prefixIcon: const Icon(Icons.currency_bitcoin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addMoney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.bitcoinOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ajouter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addMoney() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      Navigator.of(context).pop(amount);
    }
  }
}

// Dialogue pour retirer de l'argent
class WithdrawMoneyDialog extends StatefulWidget {
  final Vault vault;

  const WithdrawMoneyDialog({super.key, required this.vault});

  @override
  State<WithdrawMoneyDialog> createState() => _WithdrawMoneyDialogState();
}

class _WithdrawMoneyDialogState extends State<WithdrawMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.remove_circle,
                    color: AppTheme.bitcoinOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Retirer de l\'argent',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Coffre: ${widget.vault.name}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              Text(
                'Solde disponible: ${Formatters.formatSats(widget.vault.currentAmount)} sats',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Champ montant
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant (sats)',
                  hintText: 'Entrez le montant à retirer',
                  prefixIcon: const Icon(Icons.monetization_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                  if (amount > widget.vault.currentAmount) {
                    return 'Montant supérieur au solde disponible';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _withdrawMoney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.bitcoinOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retirer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _withdrawMoney() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      Navigator.of(context).pop(amount);
    }
  }
}
