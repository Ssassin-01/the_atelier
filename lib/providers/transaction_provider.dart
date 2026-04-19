import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<BusinessTransaction>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<BusinessTransaction>> {
  TransactionNotifier() : super([]) {
    _loadTransactions();
  }

  Box<BusinessTransaction> get _box => Hive.box<BusinessTransaction>('transactions');

  void _loadTransactions() {
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(BusinessTransaction tx) async {
    await _box.put(tx.id, tx);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _loadTransactions();
  }

  double getTotal(String type) {
    return state
        .where((tx) => tx.type == type)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyBalance => getTotal('sale') - getTotal('expense');

  /// Records the cost of producing a batch of a recipe as an expense
  Future<void> addProductionRecord(String recipeName, double cost) async {
    final tx = BusinessTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: 'expense',
      amount: cost,
      category: 'Ingredients',
      description: 'Production: $recipeName',
    );
    await addTransaction(tx);
  }
}
