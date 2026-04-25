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
        currentStock: 1000,
        purchasePrice: 4500,
        purchaseQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_rice_flour_cake',
        name: 'Rice Flour (Cake/박력 쌀가루)',
        category: 'Flour',
        currentStock: 1000,
        purchasePrice: 4000,
        purchaseQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_soybean_powder',
        name: 'Soybean Powder (볶은 콩가루)',
        category: 'Flour',
        currentStock: 500,
        purchasePrice: 6000,
        purchaseQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_almond_flour',
        name: 'Almond Flour (아몬드 가루)',
        category: 'Flour',
        currentStock: 500,
        purchasePrice: 9000,
        purchaseQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      // Dairy/Eggs
      PantryItem(
        id: 'p_eggs',
        name: 'Fresh Eggs (계란)',
        category: 'Dairy/Eggs',
        currentStock: 10,
        purchasePrice: 5000,
        purchaseQuantity: 10,
        unit: 'pcs',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_milk',
        name: 'Milk (우유)',
        category: 'Dairy/Eggs',
        currentStock: 1000,
        purchasePrice: 2800,
        purchaseQuantity: 1000,
        unit: 'ml',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_heavy_cream',
        name: 'Heavy Cream (생크림)',
        category: 'Dairy/Eggs',
        currentStock: 500,
        purchasePrice: 6500,
        purchaseQuantity: 500,
        unit: 'ml',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_butter',
        name: 'Butter (버터)',
        category: 'Dairy/Eggs',
        currentStock: 450,
        purchasePrice: 12000,
        purchaseQuantity: 450,
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
        purchaseQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_icing_sugar',
        name: 'Icing Sugar (슈가파우더)',
        category: 'Sweetener',
        currentStock: 500,
        purchasePrice: 2500,
        purchaseQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_dextrose',
        name: 'Dextrose (덱스트로스)',
        category: 'Sweetener',
        currentStock: 500,
        purchasePrice: 3800,
        purchaseQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_glucose_syrup',
        name: 'Glucose Syrup (물엿)',
        category: 'Sweetener',
        currentStock: 1000,
        purchasePrice: 4200,
        purchaseQuantity: 1000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      // Add-in
      PantryItem(
        id: 'p_kabocha',
        name: 'Frozen Kabocha (냉동 단호박)',
        category: 'Add-in',
        currentStock: 2000,
        purchasePrice: 12000,
        purchaseQuantity: 2000,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_pumpkin_seeds',
        name: 'Pumpkin Seeds (호박씨)',
        category: 'Add-in',
        currentStock: 2000,
        purchasePrice: 5500,
        purchaseQuantity: 200,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_roasted_rice',
        name: 'Roasted Brown Rice (볶은 현미)',
        category: 'Add-in',
        currentStock: 200,
        purchasePrice: 4500,
        purchaseQuantity: 200,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_cinnamon',
        name: 'Cinnamon Powder (시나몬 가루)',
        category: 'Add-in',
        currentStock: 50,
        purchasePrice: 3500,
        purchaseQuantity: 50,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
      // Others
      PantryItem(
        id: 'p_gelatin',
        name: 'Sheet Gelatin (판 젤라틴)',
        category: 'Others',
        currentStock: 20,
        purchasePrice: 4000,
        purchaseQuantity: 20,
        unit: 'pcs',
        lastUpdated: DateTime.now(),
      ),
      PantryItem(
        id: 'p_salt',
        name: 'Salt (꽃소금)',
        category: 'Others',
        currentStock: 500,
        purchasePrice: 1500,
        purchaseQuantity: 500,
        unit: 'g',
        lastUpdated: DateTime.now(),
      ),
    ];

    for (final item in items) {
      await pantry.addItem(item);
    }

    // 2. Seed Analytics Data (Last 7 Days)
    final random = Random();
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Daily Sale
      final saleAmount = 60000 + random.nextInt(80000).toDouble();
      await transactions.addTransaction(BusinessTransaction(
        id: 'seed_sale_$i',
        amount: saleAmount,
        date: date,
        type: 'sale',
        category: 'Sales',
        description: 'Daily revenue (Day $i)',
      ));

      // Daily Expense
      final expenseAmount = 15000 + random.nextInt(30000).toDouble();
      await transactions.addTransaction(BusinessTransaction(
        id: 'seed_exp_$i',
        amount: expenseAmount,
        date: date,
        type: 'expense',
        category: 'Ingredients',
        description: 'Restock ingredients (Day $i)',
      ));
    }
  }
}
