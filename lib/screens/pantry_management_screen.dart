import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../theme/artisanal_theme.dart';
import '../providers/pantry_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/pantry_item.dart';
import '../models/transaction.dart';
import '../l10n/app_localizations.dart';
import '../providers/pantry_categories_provider.dart';
import '../widgets/pantry/inventory_tag.dart';
import '../widgets/pantry/pantry_dashboard.dart';
import '../widgets/staggered_drop_animation.dart';
import '../services/pantry_report_service.dart';

class PantryManagementScreen extends ConsumerStatefulWidget {
  const PantryManagementScreen({super.key});

  @override
  ConsumerState<PantryManagementScreen> createState() => _PantryManagementScreenState();
}

class _PantryManagementScreenState extends ConsumerState<PantryManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _sortByUrgency = false;
  bool _isSearchFocused = false;
  String _activeFilter = 'all'; // 'all', 'lowStock', 'missingInfo'
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showCompressedDashboard = false;

  @override
  void initState() {
    super.initState();
    final categories = ref.read(pantryCategoriesProvider);
    _tabController = TabController(length: categories.length, vsync: this);
    
    _scrollController.addListener(() {
      final showCompressed = _scrollController.offset > 180;
      if (showCompressed != _showCompressedDashboard) {
        setState(() => _showCompressedDashboard = showCompressed);
      }
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              160,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Professional Off-white paper color
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: ArtisanalTheme.ink, size: 20),
            ),
            centerTitle: true,
            title: Text(
              l10n.pantryLedger.toUpperCase(),
              style: ArtisanalTheme.hand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ArtisanalTheme.ink,
                letterSpacing: 2.0,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_sortByUrgency ? Icons.priority_high : Icons.sort_by_alpha, color: ArtisanalTheme.ink, size: 20),
                onPressed: () => setState(() => _sortByUrgency = !_sortByUrgency),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: ArtisanalTheme.ink, size: 20),
                onPressed: () => _manageCategories(context, ref, l10n),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          Expanded(
            child: DefaultTabController(
              length: categories.length,
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        PantryDashboard(
                          totalVaultValue: totalVaultValue,
                          urgentCount: urgentCount,
                          missingInfoCount: missingInfoCount,
                          totalEntries: pantryItems.length,
                          activeFilter: _activeFilter,
                          onTotalTap: () => setState(() => _activeFilter = 'all'),
                          onLowStockTap: () => setState(() => _activeFilter = 'lowStock'),
                          onMissingInfoTap: () => setState(() => _activeFilter = 'missingInfo'),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.1), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                   Icon(Icons.search, color: ArtisanalTheme.ink.withValues(alpha: 0.2), size: 20),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: TextField(
                                       controller: _searchController,
                                       focusNode: _searchFocusNode,
                                       style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.ink),
                                       onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                                       decoration: InputDecoration(
                                         hintText: l10n.searchIngredients.toUpperCase(),
                                         hintStyle: ArtisanalTheme.hand(
                                           fontSize: 13, 
                                           color: ArtisanalTheme.secondary.withValues(alpha: 0.3),
                                           letterSpacing: 1.5,
                                         ),
                                         border: InputBorder.none,
                                         isDense: true,
                                       ),
                                     ),
                                   ),
                                   if (_searchQuery.isNotEmpty)
                                     IconButton(
                                       icon: const Icon(Icons.close, size: 18),
                                       color: ArtisanalTheme.ink.withValues(alpha: 0.3),
                                       onPressed: () {
                                         HapticFeedback.lightImpact();
                                         _searchController.clear();
                                         setState(() => _searchQuery = '');
                                       },
                                     ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        if (_isSearchFocused && _searchQuery.isNotEmpty) 
                          _buildSearchSuggestions(pantryItems),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      PreferredSize(
                        preferredSize: Size.fromHeight(_showCompressedDashboard ? 108 : 48),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: const Color(0xFFFAF9F6).withValues(alpha: 0.8),
                              child: Column(
                                children: [
                                  if (_showCompressedDashboard)
                                    PantryDashboard(
                                      totalVaultValue: totalVaultValue,
                                      urgentCount: urgentCount,
                                      missingInfoCount: missingInfoCount,
                                      totalEntries: pantryItems.length,
                                      activeFilter: _activeFilter,
                                      onTotalTap: () => setState(() => _activeFilter = 'all'),
                                      onLowStockTap: () => setState(() => _activeFilter = 'lowStock'),
                                      onMissingInfoTap: () => setState(() => _activeFilter = 'missingInfo'),
                                      isCompressed: true,
                                    ),
                                  TabBar(
                                    controller: _tabController,
                                    labelColor: ArtisanalTheme.ink,
                                    unselectedLabelColor: ArtisanalTheme.ink.withValues(alpha: 0.3),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicator: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: ArtisanalTheme.ink, width: 2),
                                      ),
                                    ),
                                    labelStyle: ArtisanalTheme.hand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                    unselectedLabelStyle: ArtisanalTheme.hand(
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    dividerColor: ArtisanalTheme.ink.withValues(alpha: 0.05),
                                    tabs: categories.map((c) => Tab(
                                      text: _getCategoryDisplayName(c, l10n).toUpperCase(),
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

                    if (_activeFilter == 'lowStock') {
                      filteredItems = filteredItems.where((i) {
                        final stockPercent = i.currentStock / (i.targetQuantity > 0 ? i.targetQuantity : 1);
                        return stockPercent < 0.2;
                      }).toList();
                    } else if (_activeFilter == 'missingInfo') {
                      filteredItems = filteredItems.where((i) => 
                        i.purchasePrice == 0 || i.targetQuantity == 0
                      ).toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      filteredItems = filteredItems.where((i) => i.name.toLowerCase().contains(_searchQuery)).toList();
                    }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          _showAddEditSheet(l10n);
        },
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
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return StaggeredDropAnimation(
          index: index,
          child: Transform.rotate(
            angle: (item.id.hashCode % 10 - 5) / 400,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _showAddEditSheet(l10n, item);
              },
              child: InventoryTag(
                item: item,
                onRestock: () {
                  HapticFeedback.lightImpact();
                  _showRestockSheet(item, l10n);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions(List<PantryItem> pantryItems) {
    final suggestions = pantryItems
        .where((i) => i.name.toLowerCase().contains(_searchQuery))
        .take(5)
        .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: suggestions.map((item) => InkWell(
          onTap: () {
            setState(() {
              _searchQuery = item.name;
              _searchController.text = item.name;
              _searchFocusNode.unfocus();
            });
          },
          child: ListTile(
            dense: true,
            title: Text(item.name, style: ArtisanalTheme.hand(fontSize: 14)),
            trailing: Text(item.category.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 9, color: ArtisanalTheme.secondary.withValues(alpha: 0.5))),
          ),
        )).toList(),
      ),
    );
  }

  String _getCategoryDisplayName(String categoryKey, AppLocalizations l10n) {
    if (categoryKey == 'All') return l10n.all;
    if (categoryKey == 'Flour') return l10n.categoryFlour;
    if (categoryKey == 'Dairy/Eggs') return l10n.categoryDairy;
    if (categoryKey == 'Sweetener') return l10n.categorySweetener;
    if (categoryKey == 'Leavening') return l10n.categoryLeavening;
    if (categoryKey == 'Add-in') return l10n.categoryAddIn;
    if (categoryKey == 'Others') return l10n.categoryOthers;
    return categoryKey;
  }

  void _showRestockSheet(PantryItem item, AppLocalizations l10n) {
    final qtyController = TextEditingController();
    final costController = TextEditingController();

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
            image: DecorationImage(
              image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
              repeat: ImageRepeat.repeat,
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.03), BlendMode.dstATop),
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.restockIngredient(item.name).toUpperCase(), style: ArtisanalTheme.hand(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildLedgerField(label: l10n.quantityToAdd, controller: qtyController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildLedgerField(label: l10n.totalCostForBatch, controller: costController, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    final addQty = double.tryParse(qtyController.text) ?? 0;
                    final cost = double.tryParse(costController.text) ?? 0;
                    if (addQty <= 0) return;
                    
                    final now = DateTime.now();
                    ref.read(pantryProvider.notifier).updateItem(item.copyWith(
                      currentStock: item.currentStock + addQty,
                      lastUpdated: now,
                    ));
                    
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
                  },
                  style: TextButton.styleFrom(backgroundColor: ArtisanalTheme.ink, foregroundColor: Colors.white),
                  child: Text(l10n.restockButton.toUpperCase(), style: ArtisanalTheme.hand(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
    
    final activeCategories = ref.read(pantryCategoriesProvider).where((c) => c != 'All').toList();
    final categoryNotifier = ValueNotifier<String>(item?.category ?? activeCategories.first);

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
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text((item == null ? l10n.addIngredient : l10n.updateIngredient).toUpperCase(), style: ArtisanalTheme.hand(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildLedgerField(label: l10n.ingredientName, controller: nameController),
              const SizedBox(height: 16),
              _buildLedgerField(label: l10n.currentStockLabel, controller: currentQtyController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildLedgerField(label: l10n.inventoryGoal, controller: targetQtyController, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    final newItem = PantryItem(
                      id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      category: categoryNotifier.value,
                      currentStock: double.tryParse(currentQtyController.text) ?? 0,
                      targetQuantity: double.tryParse(targetQtyController.text) ?? 0,
                      unit: item?.unit ?? 'g',
                      purchasePrice: double.tryParse(priceController.text) ?? 0,
                      lastUpdated: DateTime.now(),
                      imageUrl: '',
                    );
                    if (item == null) {
                      ref.read(pantryProvider.notifier).addItem(newItem);
                    } else {
                      ref.read(pantryProvider.notifier).updateItem(newItem);
                    }
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(backgroundColor: ArtisanalTheme.ink, foregroundColor: Colors.white),
                  child: Text(l10n.saveChanges.toUpperCase(), style: ArtisanalTheme.hand(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _manageCategories(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.manageCategories.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text("Category management coming soon", style: ArtisanalTheme.note()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerField({required String label, required TextEditingController controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 10, color: ArtisanalTheme.secondary.withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: ArtisanalTheme.hand(fontSize: 16),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ArtisanalTheme.ink.withValues(alpha: 0.1))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ArtisanalTheme.ink)),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.child);
  final PreferredSizeWidget child;
  @override
  double get minExtent => child.preferredSize.height;
  @override
  double get maxExtent => child.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => true;
}
