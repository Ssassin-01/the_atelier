import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../theme/artisanal_theme.dart';
import '../providers/pantry_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/pantry_item.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';
import '../providers/pantry_categories_provider.dart';
import '../widgets/pantry/inventory_tag.dart';
import '../widgets/pantry/pantry_dashboard.dart';

class PantryManagementScreen extends ConsumerStatefulWidget {
  const PantryManagementScreen({super.key});

  @override
  ConsumerState<PantryManagementScreen> createState() => _PantryManagementScreenState();
}

class _PantryManagementScreenState extends ConsumerState<PantryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _sortByUrgency = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final categories = ref.read(pantryCategoriesProvider);
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = ref.watch(pantryProvider);
    final categories = ref.watch(pantryCategoriesProvider);
    final l10n = AppLocalizations.of(context);

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
      if (item.targetQuantity > 0) {
        totalVaultValue += item.purchasePrice * (item.currentStock / item.targetQuantity);
      }
      final stockPercent = item.currentStock / (item.targetQuantity > 0 ? item.targetQuantity : 1);
      if (stockPercent < 0.2) {
        urgentCount++;
      }
      if (item.purchasePrice == 0 || item.targetQuantity == 0) {
        missingInfoCount++;
      }
    }

    // Locale-aware category names
    String getCategoryDisplayName(String categoryKey) {
      if (categoryKey == 'All') return l10n.all;
      if (categoryKey == 'Flour') return l10n.categoryFlour;
      if (categoryKey == 'Dairy/Eggs') return l10n.categoryDairy;
      if (categoryKey == 'Sweetener') return l10n.categorySweetener;
      if (categoryKey == 'Leavening') return l10n.categoryLeavening;
      if (categoryKey == 'Add-in') return l10n.categoryAddIn;
      if (categoryKey == 'Others') return l10n.categoryOthers;
      return categoryKey;
    }

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.05),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            // Top Bar
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: ArtisanalTheme.primary, size: 20),
              ),
              title: Text(
                l10n.pantryLedger.toUpperCase(),
                style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  fontSize: 18,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(_sortByUrgency ? Icons.priority_high : Icons.sort_by_alpha, color: ArtisanalTheme.primary, size: 20),
                  onPressed: () => setState(() => _sortByUrgency = !_sortByUrgency),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: ArtisanalTheme.primary, size: 20),
                  onPressed: () => _manageCategories(context, ref, categories, l10n),
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            Expanded(
              child: DefaultTabController(
                length: categories.length,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          PantryDashboard(
                            totalVaultValue: totalVaultValue,
                            urgentCount: urgentCount,
                            missingInfoCount: missingInfoCount,
                            totalEntries: pantryItems.length,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F6F1),
                                border: Border.all(color: const Color(0xFFD4C4A1), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Brass Handle Detail (Simulated with icons/shapes)
                                  Positioned(
                                    left: 0, right: 0, bottom: 5,
                                    child: Center(
                                      child: Container(
                                        width: 30,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB8860B).withValues(alpha: 0.3),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                         const Icon(Icons.inventory_2_outlined, color: Color(0xFFB8860B), size: 18),
                                         const SizedBox(width: 12),
                                         Expanded(
                                           child: TextField(
                                             controller: _searchController,
                                             style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.ink),
                                             onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                                             decoration: InputDecoration(
                                               hintText: l10n.searchIngredients.toUpperCase(),
                                               hintStyle: ArtisanalTheme.hand(
                                                 fontSize: 14, 
                                                 color: ArtisanalTheme.secondary.withValues(alpha: 0.3),
                                                 letterSpacing: 1.2,
                                               ),
                                               border: InputBorder.none,
                                               isDense: true,
                                             ),
                                           ),
                                         ),
                                         Container(
                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                           decoration: BoxDecoration(
                                             border: Border.all(color: const Color(0xFFD4C4A1)),
                                           ),
                                           child: Text(
                                             "CAT. N°",
                                             style: ArtisanalTheme.hand(fontSize: 9, color: const Color(0xFFD4C4A1)),
                                           ),
                                         ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: ArtisanalTheme.primary.withValues(alpha: 0.5),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: ArtisanalTheme.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          labelStyle: ArtisanalTheme.hand(fontWeight: FontWeight.bold, fontSize: 13),
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: ArtisanalTheme.primary.withValues(alpha: 0.2),
                          tabs: categories.map((c) => Tab(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(getCategoryDisplayName(c).toUpperCase()),
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: categories.map((category) {
                      var filteredItems = category == 'All'
                          ? pantryItems
                          : pantryItems.where((i) => i.category == category).toList();

                      // Apply Search Filter
                      if (_searchQuery.isNotEmpty) {
                        filteredItems = filteredItems.where((i) => i.name.toLowerCase().contains(_searchQuery)).toList();
                      }

                      // Apply Sort
                      if (_sortByUrgency) {
                        filteredItems.sort((a, b) {
                            final aStock = a.currentStock / (a.targetQuantity > 0 ? a.targetQuantity : 1);
                            final bStock = b.currentStock / (b.targetQuantity > 0 ? b.targetQuantity : 1);
                            return aStock.compareTo(bStock);
                        });
                      } else {
                        filteredItems.sort((a, b) => a.name.compareTo(b.name));
                      }

                      return _buildPantryGrid(filteredItems, l10n);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(l10n),
        backgroundColor: ArtisanalTheme.ink,
        tooltip: l10n.addIngredient,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPantryGrid(List<PantryItem> items, AppLocalizations l10n) {
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Transform.rotate(
          angle: (item.id.hashCode % 10 - 5) / 400, // Very subtle random rotation (-0.0125 to 0.0125 rad)
          child: GestureDetector(
            onTap: () => _showAddEditSheet(l10n, item),
            child: InventoryTag(
              item: item,
              onRestock: () => _showRestockSheet(item, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientImage(String name, String category) {
    String assetPath = 'assets/images/categories/others.png';
    final lowerName = name.toLowerCase();

    // Map specific ingredients to the updated realistic category assets
    if (lowerName.contains('flour') || lowerName.contains('밀가루') || lowerName.contains('강력') || lowerName.contains('박력')) {
      assetPath = 'assets/images/categories/flour.png';
    } else if (lowerName.contains('salt') || lowerName.contains('소금')) {
      assetPath = 'assets/images/categories/others.png';
    } else if (lowerName.contains('butter') || lowerName.contains('버터')) {
      assetPath = 'assets/images/categories/dairy_eggs.png';
    } else if (lowerName.contains('sugar') || lowerName.contains('설탕')) {
      assetPath = 'assets/images/categories/sweetener.png';
    } else {
      switch (category) {
        case 'Flour': assetPath = 'assets/images/categories/flour.png'; break;
        case 'Dairy/Eggs': assetPath = 'assets/images/categories/dairy_eggs.png'; break;
        case 'Sweetener': assetPath = 'assets/images/categories/sweetener.png'; break;
        case 'Leavening': assetPath = 'assets/images/categories/leavening.png'; break;
        case 'Add-in': assetPath = 'assets/images/categories/addin.png'; break;
        default: assetPath = 'assets/images/categories/others.png'; break;
      }
    }

    return Image.asset(assetPath, fit: BoxFit.cover);
  }

  void _showRestockSheet(PantryItem item, AppLocalizations l10n) {
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    final targetQtyController = TextEditingController(text: item.targetQuantity.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCFB),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              image: DecorationImage(
                image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
                repeat: ImageRepeat.repeat,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.03),
                  BlendMode.dstATop,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 2),
                          Text(l10n.restockIngredient(item.name), style: ArtisanalTheme.note(fontSize: 14, color: ArtisanalTheme.secondary.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: 0.8,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildIngredientImage(item.name, item.category),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Smart Ledger Guidance
                Text(
                  "Note: ${l10n.restockGuidance(
                    (item.targetQuantity - item.currentStock).clamp(0, double.infinity).toInt().toString(),
                    item.unit == 'g' ? l10n.unitG : l10n.unitPcs,
                  )}",
                  style: ArtisanalTheme.hand(fontSize: 13, fontStyle: FontStyle.italic, color: ArtisanalTheme.primary.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 20),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLedgerField(
                          label: l10n.quantityToAdd,
                          controller: qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          suffixText: item.unit == 'g' ? l10n.unitG : l10n.unitPcs,
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        _buildLedgerField(
                          label: l10n.totalCostForBatch,
                          controller: costController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixText: "${l10n.currencySymbol} ",
                        ),
                        const SizedBox(height: 16),
                        _buildLedgerField(
                          label: l10n.inventoryGoal,
                          controller: targetQtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          suffixText: item.unit == 'g' ? l10n.unitG : l10n.unitPcs,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton(
                  onPressed: () {
                    final addQty = double.tryParse(qtyController.text) ?? 0;
                    final cost = double.tryParse(costController.text) ?? 0;
                    final newTarget = double.tryParse(targetQtyController.text) ?? item.targetQuantity;

                    if (addQty <= 0) return;

                    final now = DateTime.now();
                    ref.read(pantryProvider.notifier).updateItem(
                          item.copyWith(
                            currentStock: item.currentStock + addQty,
                            targetQuantity: newTarget,
                            lastUpdated: now,
                          ),
                        );

                    if (cost > 0) {
                      ref.read(transactionProvider.notifier).addTransaction(BusinessTransaction(
                            id: 'restock_${now.millisecondsSinceEpoch}',
                            date: now,
                            type: 'expense',
                            amount: cost,
                            category: l10n.ingredientPurchase,
                            description: l10n.boughtDescription(item.name, addQty.toInt()),
                          ));
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.dataCurated), backgroundColor: ArtisanalTheme.primary),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: ArtisanalTheme.ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.restockButton, style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _showAddEditSheet(AppLocalizations l10n, [PantryItem? item]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item?.purchasePrice.toString() ?? '');
    final targetQtyController = TextEditingController(text: item?.targetQuantity.toString() ?? '');
    final currentQtyController = TextEditingController(text: item?.currentStock.toString() ?? '');
    
    final categoryNotifier = ValueNotifier<String>(item?.category ?? 'Flour');
    final unitNotifier = ValueNotifier<String>(item?.unit ?? 'g');
    String? imageUrl = item?.imageUrl;

    final displayCategories = [
      ('Flour', l10n.categoryFlour),
      ('Dairy/Eggs', l10n.categoryDairy),
      ('Sweetener', l10n.categorySweetener),
      ('Leavening', l10n.categoryLeavening),
      ('Add-in', l10n.categoryAddIn),
      ('Others', l10n.categoryOthers),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDFCFB),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            image: DecorationImage(
              image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
              repeat: ImageRepeat.repeat,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.03),
                BlendMode.dstATop,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(item == null ? l10n.addIngredient.toUpperCase() : l10n.updateIngredient.toUpperCase(),
                  style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.categoryName.toUpperCase(), style: ArtisanalTheme.note(fontSize: 12, color: ArtisanalTheme.secondary.withValues(alpha: 0.6))),
                          const SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable: categoryNotifier,
                            builder: (context, currentCat, _) => SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: displayCategories.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final cat = displayCategories[index];
                                  final isSelected = cat.$1 == currentCat;
                                  return GestureDetector(
                                    onTap: () => categoryNotifier.value = cat.$1,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected ? ArtisanalTheme.primary : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: isSelected ? [
                                              BoxShadow(
                                                color: ArtisanalTheme.primary.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              )
                                            ] : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                _buildIngredientImage('', cat.$1),
                                                if (isSelected)
                                                  Container(
                                                    color: ArtisanalTheme.primary.withValues(alpha: 0.2),
                                                    child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          cat.$2.toUpperCase(),
                                          style: ArtisanalTheme.hand(
                                            fontSize: 10,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLedgerField(
                        label: l10n.ingredientName,
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      _buildUnifiedLedgerQuantityField(
                        label: l10n.inventoryGoal,
                        controller: targetQtyController,
                        unitNotifier: unitNotifier,
                      ),
                      const SizedBox(height: 16),
                      _buildLedgerField(
                        label: l10n.currentStockLabel,
                        controller: currentQtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      _buildLedgerField(
                        label: l10n.purchasePriceLabel,
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixText: "${l10n.currencySymbol} ",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton(
                  onPressed: () {
                     final newItem = PantryItem(
                      id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      category: categoryNotifier.value,
                      currentStock: double.tryParse(currentQtyController.text) ?? 0,
                      targetQuantity: double.tryParse(targetQtyController.text) ?? 0,
                      unit: unitNotifier.value,
                      purchasePrice: double.tryParse(priceController.text) ?? 0,
                      lastUpdated: DateTime.now(),
                      imageUrl: imageUrl,
                    );

                    if (item == null) {
                      ref.read(pantryProvider.notifier).addItem(newItem);
                    } else {
                      ref.read(pantryProvider.notifier).updateItem(newItem);
                    }
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: ArtisanalTheme.ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.saveChanges, style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _manageCategories(BuildContext context, WidgetRef ref, List<String> categories, AppLocalizations l10n) {
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
                      trailing: (c != 'Others' && c != 'Flour') ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: ArtisanalTheme.redInk),
                        onPressed: () {
                          ref.read(pantryCategoriesProvider.notifier).removeCategory(c);
                        },
                      ) : null,
                      onTap: () {
                        if (c == 'Others' || c == 'Flour' || c == 'Dairy/Eggs' || c == 'Sweetener' || c == 'Leavening' || c == 'Add-in') {
                           return; // Don't rename core categories for now to avoid broken mappings
                        }
                        _showRenameCategoryDialog(context, ref, c, l10n);
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              TextButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref, l10n),
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
            child: Text(l10n.close, style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty) {
                ref.read(pantryCategoriesProvider.notifier).addCategory(newName);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showRenameCategoryDialog(BuildContext context, WidgetRef ref, String oldName, AppLocalizations l10n) {
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty) {
                ref.read(pantryCategoriesProvider.notifier).renameCategory(oldName, newName);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
  }

  // --- Hand-drawn Ledger UI Helpers ---

  Widget _buildLedgerField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ArtisanalTheme.note(fontSize: 12, color: ArtisanalTheme.secondary.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ArtisanalTheme.primary.withValues(alpha: 0.2))),
          ),
          child: Row(
            children: [
              if (prefixText != null) 
                Text(prefixText, style: ArtisanalTheme.hand(fontSize: 18)),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  autofocus: autofocus,
                  style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.onSurface),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (suffixText != null)
                Text(suffixText, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.secondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ArtisanalTheme.note(fontSize: 12, color: ArtisanalTheme.secondary.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ArtisanalTheme.primary.withValues(alpha: 0.2))),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.onSurface),
            icon: const Icon(Icons.expand_more, size: 20),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedLedgerQuantityField({
    required String label,
    required TextEditingController controller,
    required ValueNotifier<String> unitNotifier,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ArtisanalTheme.note(fontSize: 12, color: ArtisanalTheme.secondary.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ArtisanalTheme.primary.withValues(alpha: 0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: ArtisanalTheme.hand(fontSize: 20),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: unitNotifier,
                builder: (context, val, _) => DropdownButton<String>(
                  value: val,
                  underline: const SizedBox(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.expand_more, size: 18),
                  items: ['g', 'pcs']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u, style: ArtisanalTheme.hand(fontSize: 18))))
                      .toList(),
                  onChanged: (newVal) => unitNotifier.value = newVal!,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ArtisanalTheme.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
