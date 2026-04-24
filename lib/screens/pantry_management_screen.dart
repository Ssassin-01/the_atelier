import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../providers/pantry_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/pantry_item.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';
import '../providers/pantry_categories_provider.dart';
import 'dart:io';

class PantryManagementScreen extends ConsumerStatefulWidget {
  const PantryManagementScreen({super.key});

  @override
  ConsumerState<PantryManagementScreen> createState() => _PantryManagementScreenState();
}

class _PantryManagementScreenState extends ConsumerState<PantryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // We'll initialize with a dummy or use DefaultTabController.
    // Given the complexity of the current build, I'll use ref.read to get initial count.
    final initialCount = ref.read(pantryCategoriesProvider).length;
    _tabController = TabController(length: initialCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = ref.watch(pantryProvider);
    final categories = ref.watch(pantryCategoriesProvider);
    final l10n = AppLocalizations.of(context);

    // Sync tab controller length if categories changed
    if (_tabController.length != categories.length) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: categories.length, 
        vsync: this,
        initialIndex: oldIndex.clamp(0, categories.length - 1),
      );
    }

    // Dashboard Calculations
    double totalVaultValue = 0;
    int urgentCount = 0;
    int missingInfoCount = 0;

    for (var item in pantryItems) {
      if (item.purchaseQuantity > 0) {
        totalVaultValue += item.purchasePrice * (item.currentStock / item.purchaseQuantity);
      }
      final stockPercent = item.currentStock / (item.purchaseQuantity > 0 ? item.purchaseQuantity : 1);
      if (stockPercent < 0.2) {
        urgentCount++;
      }
      if (item.purchasePrice == 0 || item.purchaseQuantity == 0) {
        missingInfoCount++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
        ),
        title: Text(
          l10n.pantryLedger,
          style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: ArtisanalTheme.ink),
            onPressed: () => _manageCategories(context, ref, categories),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Ledger Dashboard
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCFB),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE5E0D8), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.totalVaultValue.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 10, color: ArtisanalTheme.secondary, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text("₩ ${totalVaultValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}", 
                            style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E0D8)),
                        ),
                        child: Column(
                          children: [
                            Text(l10n.inventoryStatus.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 8, color: ArtisanalTheme.secondary)),
                            Text(urgentCount > 0 ? l10n.urgent.toUpperCase() : l10n.stable.toUpperCase(), 
                              style: ArtisanalTheme.hand(fontSize: 12, fontWeight: FontWeight.bold, 
                              color: urgentCount > 0 ? ArtisanalTheme.redInk : Colors.green.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(height: 1, color: Color(0xFFE5E0D8)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDashboardStat(l10n.lowStock.toUpperCase(), urgentCount.toString(), ArtisanalTheme.redInk),
                      _buildDashboardStat(l10n.missingInfo.toUpperCase(), missingInfoCount.toString(), Colors.orange.shade700),
                      _buildDashboardStat(l10n.totalEntries.toUpperCase(), pantryItems.length.toString(), ArtisanalTheme.ink),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Custom TabBar area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TabBar(
              controller: _tabController,
              labelColor: ArtisanalTheme.primary,
              unselectedLabelColor: ArtisanalTheme.secondary.withValues(alpha: 0.5),
              indicatorColor: ArtisanalTheme.primary,
              indicatorWeight: 3,
              labelStyle: ArtisanalTheme.hand(fontWeight: FontWeight.bold),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              tabs: categories.map((c) {
                String name = c;
                if (c == 'All') {
                  name = l10n.all;
                } else if (c == 'Flour') {
                  name = l10n.categoryFlour;
                } else if (c == 'Dairy/Eggs') {
                  name = l10n.categoryDairy;
                } else if (c == 'Sweetener') {
                  name = l10n.categorySweetener;
                } else if (c == 'Leavening') {
                  name = l10n.categoryLeavening;
                } else if (c == 'Add-in') {
                  name = l10n.categoryAddIn;
                } else if (c == 'Others') {
                  name = l10n.categoryOthers;
                }
                return Tab(text: name.toUpperCase());
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final filteredItems = category == 'All'
                    ? pantryItems
                    : pantryItems.where((i) => i.category == category).toList();

                return _buildPantryGrid(filteredItems);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPantryItemSheet(context, ref),
        backgroundColor: ArtisanalTheme.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPantryGrid(List<PantryItem> items) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.emptyState,
          textAlign: TextAlign.center,
          style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _showEditPantryItemSheet(context, ref, item),
          child: InventoryTag(item: item),
        );
      },
    );
  }

  void _showAddPantryItemSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    String name = '';
    double price = 0;
    double quantity = 0;
    String category = 'Flour';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFFDFCFB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.addItem,
                style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                l10n.newIngredientDesc,
                style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              _buildArtisanalInput(
                label: l10n.ingredientName,
                hint: l10n.ingredientNameHint,
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildArtisanalInput(
                      label: l10n.totalQuantity,
                      hint: "2500",
                      suffix: "g",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => quantity = double.tryParse(val) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildArtisanalInput(
                      label: l10n.purchasePriceLabel,
                      hint: "12000",
                      suffix: "₩",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => price = double.tryParse(val) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.categoryName, 
                style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.secondary),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setSheetState) {
                  final allCategories = ref.watch(pantryCategoriesProvider);
                  return Wrap(
                    spacing: 8,
                    children: allCategories.where((c) => c != 'All').map((c) {
                      final isSelected = category == c;
                      String translatedName = c;
                      if (c == 'Flour') {
                        translatedName = l10n.categoryFlour;
                      } else if (c == 'Dairy/Eggs') {
                        translatedName = l10n.categoryDairy;
                      } else if (c == 'Sweetener') {
                        translatedName = l10n.categorySweetener;
                      } else if (c == 'Leavening') {
                        translatedName = l10n.categoryLeavening;
                      } else if (c == 'Add-in') {
                        translatedName = l10n.categoryAddIn;
                      } else if (c == 'Others') {
                        translatedName = l10n.categoryOthers;
                      }
                      
                      return ChoiceChip(
                        label: Text(translatedName, style: ArtisanalTheme.hand(
                          fontSize: 12,
                          color: isSelected ? Colors.white : ArtisanalTheme.ink,
                        )),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() => category = c);
                        },
                        selectedColor: ArtisanalTheme.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? ArtisanalTheme.primary : const Color(0xFFE5E0D8),
                          ),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && price > 0 && quantity > 0) {
                      final now = DateTime.now();
                      ref.read(pantryProvider.notifier).addItem(PantryItem(
                        id: now.millisecondsSinceEpoch.toString(),
                        name: name,
                        purchasePrice: price,
                        purchaseQuantity: quantity,
                        currentStock: quantity, // Initial stock is total purchase
                        lastUpdated: now,
                        category: category,
                      ));
                      
                      // Also record as a business transaction (expense)
                      ref.read(transactionProvider.notifier).addTransaction(BusinessTransaction(
                        id: 'tx_${now.millisecondsSinceEpoch}',
                        date: now,
                        type: 'expense',
                        amount: price,
                        category: l10n.ingredientPurchase,
                        description: l10n.boughtDescription(name, quantity.toInt()),
                      ));
                      
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArtisanalTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(l10n.addToPantry, style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 100), // Space for keyboard
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPantryItemSheet(BuildContext context, WidgetRef ref, PantryItem item) {
    final l10n = AppLocalizations.of(context);
    String name = item.name;
    double price = item.purchasePrice;
    double quantity = item.purchaseQuantity;
    String category = item.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFFDFCFB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 32),
              Text(l10n.updateIngredient, style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 28, fontStyle: FontStyle.italic)),
              const SizedBox(height: 40),
              _buildArtisanalInput(label: l10n.ingredientName, hint: l10n.nameHint, initialValue: name, onChanged: (val) => name = val),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildArtisanalInput(label: l10n.totalQuantity, hint: "1000", suffix: "g", initialValue: quantity.toString(), keyboardType: TextInputType.number, onChanged: (val) => quantity = double.tryParse(val) ?? 0)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildArtisanalInput(label: l10n.currentStockLabel, hint: "1000", suffix: "g", initialValue: item.currentStock.toString(), keyboardType: TextInputType.number, onChanged: (val) => item = item.copyWith(currentStock: double.tryParse(val) ?? 0))),
                ],
              ),
              const SizedBox(height: 24),
              _buildArtisanalInput(label: l10n.purchasePriceLabel, hint: "0", suffix: "₩", initialValue: price.toString(), keyboardType: TextInputType.number, onChanged: (val) => price = double.tryParse(val) ?? 0),
              
              const SizedBox(height: 32),
              Text(
                  l10n.categoryName.toUpperCase(), 
                  style: ArtisanalTheme.hand(fontSize: 10, color: ArtisanalTheme.secondary, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setSheetState) {
                  final allCategories = ref.watch(pantryCategoriesProvider);
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allCategories.where((c) => c != 'All').map((c) {
                      final isSelected = category == c;
                      String translatedName = c;
                      if (c == 'Flour') {
                        translatedName = l10n.categoryFlour;
                      } else if (c == 'Dairy/Eggs') {
                        translatedName = l10n.categoryDairy;
                      } else if (c == 'Sweetener') {
                        translatedName = l10n.categorySweetener;
                      } else if (c == 'Leavening') {
                        translatedName = l10n.categoryLeavening;
                      } else if (c == 'Add-in') {
                        translatedName = l10n.categoryAddIn;
                      } else if (c == 'Others') {
                        translatedName = l10n.categoryOthers;
                      }
                      
                      return ChoiceChip(
                        label: Text(translatedName, style: ArtisanalTheme.hand(
                          fontSize: 12,
                          color: isSelected ? Colors.white : ArtisanalTheme.ink,
                        )),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() => category = c);
                        },
                        selectedColor: ArtisanalTheme.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? ArtisanalTheme.primary : const Color(0xFFE5E0D8),
                          ),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && quantity > 0) {
                      ref.read(pantryProvider.notifier).updateItem(item.copyWith(
                        name: name,
                        purchasePrice: price,
                        purchaseQuantity: quantity,
                        category: category,
                        lastUpdated: DateTime.now(),
                      ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArtisanalTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(l10n.saveChanges, style: ArtisanalTheme.hand(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDashboardStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: ArtisanalTheme.hand(fontSize: 8, color: ArtisanalTheme.secondary)),
        const SizedBox(height: 2),
        Text(value, style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildArtisanalInput({
    required String label,
    required String hint,
    String? initialValue,
    String? suffix,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.secondary),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ArtisanalTheme.hand(color: Colors.grey.shade400, fontSize: 16),
            suffixText: suffix,
            suffixStyle: ArtisanalTheme.hand(color: ArtisanalTheme.secondary),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE5E0D8), width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: ArtisanalTheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Category Management Logic
  void _manageCategories(BuildContext context, WidgetRef ref, List<String> categories) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.manageCategories.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    if (c == 'All') return const SizedBox.shrink();
                    
                    return ListTile(
                      title: Text(() {
                        if (c == 'Flour') return l10n.categoryFlour;
                        if (c == 'Dairy/Eggs') return l10n.categoryDairy;
                        if (c == 'Sweetener') return l10n.categorySweetener;
                        if (c == 'Leavening') return l10n.categoryLeavening;
                        if (c == 'Add-in') return l10n.categoryAddIn;
                        if (c == 'Others') return l10n.categoryOthers;
                        return c;
                      }(), style: ArtisanalTheme.hand(fontSize: 16)),
                      trailing: (c != 'Others') ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: ArtisanalTheme.redInk),
                        onPressed: () {
                          ref.read(pantryCategoriesProvider.notifier).removeCategory(c);
                        },
                      ) : null,
                      onTap: () {
                        if (c == 'Others') return;
                        _showRenameCategoryDialog(context, ref, c);
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              TextButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.addCategory.toUpperCase(), style: ArtisanalTheme.hand(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: ArtisanalTheme.primary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    String newName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newCategory.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.categoryName),
          onChanged: (val) => newName = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel.toUpperCase())),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty) {
                ref.read(pantryCategoriesProvider.notifier).addCategory(newName);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _showRenameCategoryDialog(BuildContext context, WidgetRef ref, String oldName) {
    final l10n = AppLocalizations.of(context);
    String newName = oldName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameCategory.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.newName),
          controller: TextEditingController(text: oldName),
          onChanged: (val) => newName = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel.toUpperCase())),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty) {
                ref.read(pantryCategoriesProvider.notifier).renameCategory(oldName, newName);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.rename.toUpperCase()),
          ),
        ],
      ),
    );
  }
}

class InventoryTag extends StatelessWidget {
  final PantryItem item;
  const InventoryTag({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stockPercent = (item.currentStock / item.purchaseQuantity).clamp(0.0, 1.0);
    final isLow = stockPercent < 0.2;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFB),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area (Polaroid style)
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3F0),
                border: Border.all(color: Colors.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageUrl != null)
                    Image.file(
                      File(item.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),
                  
                  if (item.currentStock == 0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.3),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: ArtisanalTheme.redInk, width: 3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.outOfStock.toUpperCase(),
                                style: ArtisanalTheme.hand(
                                  color: ArtisanalTheme.redInk,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Tape effect on image
                  Positioned(
                    top: -10,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E0D8).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info Area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: ArtisanalTheme.hand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${item.currentStock.toInt()} / ${item.purchaseQuantity.toInt()} g",
                    style: ArtisanalTheme.hand(
                      fontSize: 10,
                      color: ArtisanalTheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  // Wavy Stock Gauge
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: stockPercent,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.purchasePrice == 0 || item.purchaseQuantity == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 8, color: ArtisanalTheme.redInk),
                            const SizedBox(width: 4),
                            Text(
                              l10n.updateInfo.toUpperCase(),
                              style: ArtisanalTheme.hand(
                                color: ArtisanalTheme.redInk,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isLow)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        l10n.lowStock.toUpperCase(),
                        style: ArtisanalTheme.hand(
                          color: ArtisanalTheme.redInk,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFECEAE4),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_outlined,
          color: Colors.white.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}
