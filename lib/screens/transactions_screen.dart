import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _filterType;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final allTransactions = walletService.transactions;
    
    // Apply filters
    var filteredTransactions = allTransactions;
    if (_filterType != null) {
      filteredTransactions = filteredTransactions
          .where((t) => t.type == _filterType)
          .toList();
    }
    
    // Apply search if not empty
    if (_searchQuery.isNotEmpty) {
      filteredTransactions = filteredTransactions
          .where((t) => 
              (t.toAddress?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (t.fromAddress?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (t.hash?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (t.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher par adresse ou hash',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Tous',
                        selected: _filterType == null,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Reçu',
                        selected: _filterType == TransactionType.bitcoinReceived,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = selected ? TransactionType.bitcoinReceived : null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Envoyé',
                        selected: _filterType == TransactionType.bitcoinSent,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = selected ? TransactionType.bitcoinSent : null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions list
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterType != null
                              ? 'Aucune transaction ne correspond à votre filtre'
                              : 'Aucune transaction pour le moment',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        if (_searchQuery.isNotEmpty || _filterType != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterType = null;
                              });
                            },
                            child: const Text('Effacer les filtres'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return TransactionItem(
                        transaction: transaction,
                        onTap: () {
                          _showTransactionDetails(context, transaction);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: AppTheme.cardBackground,
      selectedColor: AppTheme.bitcoinOrange.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.bitcoinOrange,
      labelStyle: TextStyle(
        color: selected ? AppTheme.bitcoinOrange : AppTheme.textSecondary,
      ),
    );
  }

  String _getTransactionAddress(Transaction transaction) {
    if (transaction.toAddress != null && transaction.toAddress!.isNotEmpty) {
      return transaction.toAddress!;
    }
    if (transaction.fromAddress != null && transaction.fromAddress!.isNotEmpty) {
      return transaction.fromAddress!;
    }
    if (transaction.toAccount != null && transaction.toAccount!.isNotEmpty) {
      return transaction.toAccount!;
    }
    if (transaction.fromAccount != null && transaction.fromAccount!.isNotEmpty) {
      return transaction.fromAccount!;
    }
    return transaction.description ?? 'Adresse inconnue';
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: transaction.isIncoming
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        transaction.isIncoming
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: transaction.isIncoming
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.displayType,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            transaction.timestamp.toString().substring(0, 16),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 32),
                
                // Transaction details
                _buildDetailRow(context, 'Montant', 
                  transaction.formattedAmount,
                  valueColor: transaction.isIncoming
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(context, 
                  transaction.isIncoming ? 'De' : 'Vers', 
                  _getTransactionAddress(transaction),
                ),
                const SizedBox(height: 16),
                if (transaction.hash != null)
                  _buildDetailRow(context, 'Hash de transaction', transaction.hash!),
                if (transaction.hash != null)
                  const SizedBox(height: 16),
                _buildDetailRow(context, 'Statut', 
                  transaction.displayStatus,
                  valueColor: transaction.isCompleted ? Colors.green : Colors.orange,
                ),
                
                const SizedBox(height: 32),
                
                // View on explorer button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Voir sur Stacks Explorer'),
                    onPressed: () {
                      // TODO: Open transaction in Stacks Explorer
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
