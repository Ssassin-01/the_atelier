import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pantry_item.dart';
import '../models/transaction.dart';
import '../providers/pantry_provider.dart';
import '../providers/transaction_provider.dart';

class DataSeedService {
  static Future<void> seedAllData(WidgetRef ref) async {
    final pantry = ref.read(pantryProvider.notifier);
    final transactions = ref.read(transactionProvider.notifier);

    // 1. Seed Pantry Items (Organized by professional categories)
    final items = [
      // Flour
      PantryItem(
        id: 'p_rice_flour_dry',
        name: 'Dry Glutinous Rice Flour (건식 찹쌀가루)',
        category: 'Flour',
        currentStock: 800,
        purchasePrice: 4500,
        targetQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_rice_flour_cake',
        name: 'Rice Flour (Cake/박력 쌀가루)',
        category: 'Flour',
        currentStock: 100, // Intentional Low Stock
        purchasePrice: 4000,
        targetQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_soybean_powder',
        name: 'Soybean Powder (볶은 콩가루)',
        category: 'Flour',
        currentStock: 500,
        purchasePrice: 6000,
        targetQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_almond_flour',
        name: 'Almond Flour (아몬드 가루)',
        category: 'Flour',
        currentStock: 40, // Intentional Low Stock
        purchasePrice: 9000,
        targetQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      // Dairy/Eggs
      PantryItem(
        id: 'p_eggs',
        name: 'Fresh Eggs (계란)',
        category: 'Dairy/Eggs',
        currentStock: 2, // Intentional Low Stock
        purchasePrice: 5000,
        targetQuantity: 30,
        unit: 'pcs',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_milk',
        name: 'Milk (우유)',
        category: 'Dairy/Eggs',
        currentStock: 200, // Intentional Low Stock
        purchasePrice: 2800,
        targetQuantity: 1000,
        unit: 'ml',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_heavy_cream',
        name: 'Heavy Cream (생크림)',
        category: 'Dairy/Eggs',
        currentStock: 500,
        purchasePrice: 6500,
        targetQuantity: 500,
        unit: 'ml',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_butter',
        name: 'Butter (버터)',
        category: 'Dairy/Eggs',
        currentStock: 50, // Intentional Low Stock
        purchasePrice: 12000,
        targetQuantity: 450,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      // Sweetener
      PantryItem(
        id: 'p_sugar',
        name: 'Sugar (백설탕)',
        category: 'Sweetener',
        currentStock: 1000,
        purchasePrice: 2000,
        targetQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_icing_sugar',
        name: 'Icing Sugar (슈가파우더)',
        category: 'Sweetener',
        currentStock: 120, // Intentional Low Stock
        purchasePrice: 2500,
        targetQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      // Add-in
      PantryItem(
        id: 'p_kabocha',
        name: 'Frozen Kabocha (냉동 단호박)',
        category: 'Add-in',
        currentStock: 1800,
        purchasePrice: 12000,
        targetQuantity: 2000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_pumpkin_seeds',
        name: 'Pumpkin Seeds (호박씨)',
        category: 'Add-in',
        currentStock: 10, // Intentional Low Stock
        purchasePrice: 5500,
        targetQuantity: 200,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
    ];

    for (final item in items) {
      await pantry.addItem(item);
    }

    // 2. Seed Analytics Data (Last 30 Days for rich visualization)
    final random = Random();
    final now = DateTime.now();

    final saleCategories = ['Store Sales', 'One-day Class', 'Online Order', 'Custom Cake'];
    final expenseCategories = ['Ingredients', 'Packaging', 'Utility', 'Atelier Rent'];

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Daily Sale (Varied amounts)
      final saleAmount = 80000 + random.nextInt(150000).toDouble();
      final saleCat = saleCategories[random.nextInt(saleCategories.length)];
      await transactions.addTransaction(BusinessTransaction(
        id: 'seed_sale_$i',
        amount: saleAmount,
        date: date,
        type: 'sale',
        category: saleCat,
        description: 'Revenue from $saleCat',
      ));

      // Daily Expense (Every few days)
      if (i % 3 == 0) {
        final expenseAmount = 40000 + random.nextInt(60000).toDouble();
        final expCat = expenseCategories[random.nextInt(expenseCategories.length)];
        await transactions.addTransaction(BusinessTransaction(
          id: 'seed_exp_$i',
          amount: expenseAmount,
          date: date,
          type: 'expense',
          category: expCat,
          description: 'Payment for $expCat',
        ));
      }

      // Rent payment once a month
      if (date.day == 1) {
        await transactions.addTransaction(BusinessTransaction(
          id: 'seed_rent_$i',
          amount: 800000,
          date: date,
          type: 'expense',
          category: 'Atelier Rent',
          description: 'Monthly Maintenance & Rent',
        ));
      }
    }
  }
}
