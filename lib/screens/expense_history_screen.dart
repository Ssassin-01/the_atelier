import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_clippers.dart';

class ExpenseHistoryScreen extends ConsumerWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(transactionProvider);
    final expenses = allTransactions.where((tx) => tx.type == 'expense').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by date
    Map<String, List<BusinessTransaction>> grouped = {};
    for (var expense in expenses) {
      final dateStr = DateFormat('yyyy. MM. dd (EEE)').format(expense.date);
      grouped.putIfAbsent(dateStr, () => []).add(expense);
    }

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        title: Text("Ingredient Purchase History", style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: expenses.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final dayExpenses = grouped[dateKey]!;
                return _buildDateGroup(context, ref, dateKey, dayExpenses);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: ArtisanalTheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text("No purchase records yet.", style: ArtisanalTheme.hand(fontSize: 18, color: Colors.black26)),
        ],
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, WidgetRef ref, String dateKey, List<BusinessTransaction> dayExpenses) {
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);
    final dayTotal = dayExpenses.fold(0.0, (sum, tx) => sum + tx.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateKey,
                style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.secondary, fontWeight: FontWeight.bold),
              ),
              Text(
                "Total: ${currencyFormat.format(dayTotal)}",
                style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.redInk, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...dayExpenses.map((tx) => _buildExpenseCard(context, ref, tx)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildExpenseCard(BuildContext context, WidgetRef ref, BusinessTransaction tx) {
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);

    return GestureDetector(
      onTap: () => _showEditExpense(context, ref, tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipPath(
          clipper: SerratedClipper(toothWidth: 10, toothHeight: 4, top: false, bottom: true),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: ArtisanalTheme.redInk, width: 4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description,
                        style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(tx.date),
                        style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black26),
                      ),
                    ],
                  ),
                ),
                Text(
                  "-${currencyFormat.format(tx.amount)}",
                  style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.redInk),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: ArtisanalTheme.redInk.withValues(alpha: 0.3)),
                  onPressed: () => _confirmDelete(context, ref, tx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditExpense(BuildContext context, WidgetRef ref, BusinessTransaction tx) {
    final descriptionController = TextEditingController(text: tx.description);
    final amountController = TextEditingController(text: tx.amount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        title: Text("Edit Expense Record", style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: ArtisanalTheme.hand(color: ArtisanalTheme.secondary),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E0D8))),
              ),
              style: ArtisanalTheme.hand(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                suffixText: "₩",
                labelStyle: ArtisanalTheme.hand(color: ArtisanalTheme.secondary),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E0D8))),
              ),
              style: ArtisanalTheme.hand(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: ArtisanalTheme.hand(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              final newDescription = descriptionController.text;
              final newAmount = double.tryParse(amountController.text) ?? tx.amount;
              
              ref.read(transactionProvider.notifier).addTransaction(BusinessTransaction(
                id: tx.id,
                date: tx.date,
                type: tx.type,
                amount: newAmount,
                category: tx.category,
                description: newDescription,
                relatedItemId: tx.relatedItemId,
              ));
              Navigator.pop(context);
            },
            child: Text("Save", style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, BusinessTransaction tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete this record?", style: ArtisanalTheme.hand(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: ArtisanalTheme.hand(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionProvider.notifier).deleteTransaction(tx.id);
              Navigator.pop(context);
            },
            child: Text("Delete", style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk)),
          ),
        ],
      ),
    );
  }
}
