import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../providers/pantry_provider.dart';
import '../providers/settings_provider.dart';
import '../models/pantry_item.dart';
import '../l10n/app_localizations.dart';
import '../providers/pantry_categories_provider.dart';
import '../widgets/pantry/inventory_tag.dart';
import '../widgets/pantry/pantry_dashboard.dart';
import '../widgets/pantry/category_manager_sheet.dart';
import '../widgets/staggered_drop_animation.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/masking_tape.dart';

class PantryManagementScreen extends ConsumerStatefulWidget {
  const PantryManagementScreen({super.key});

  @override
  ConsumerState<PantryManagementScreen> createState() =>
      _PantryManagementScreenState();
}

class _PantryManagementScreenState extends ConsumerState<PantryManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _sortByUrgency = false;
  bool _isSearchFocused = false;
  String _activeFilter = 'all'; 
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showCompressedDashboard = false;

  @override
  void initState() {
    super.initState();
    final categories = ref.read(pantryCategoriesProvider).keys.toList();
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
    final categoriesMap = ref.watch(pantryCategoriesProvider);
    final categories = categoriesMap.keys.toList();
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
      totalVaultValue += item.purchasePrice * item.currentStock;
      final stockPercent = item.targetQuantity > 0
          ? item.currentStock / item.targetQuantity
          : 0.0;
      if (stockPercent < 0.2) {
        urgentCount++;
      }
      if (item.purchasePrice == 0 || item.targetQuantity == 0) {
        missingInfoCount++;
      }
    }

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: ArtisanalTheme.ink,
                size: 20,
              ),
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
                icon: Icon(
                  _sortByUrgency ? Icons.priority_high : Icons.sort_by_alpha,
                  color: ArtisanalTheme.ink,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _sortByUrgency = !_sortByUrgency),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: ArtisanalTheme.ink,
                  size: 20,
                ),
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
                          onTotalTap: () =>
                              setState(() => _activeFilter = 'all'),
                          onLowStockTap: () =>
                              setState(() => _activeFilter = 'lowStock'),
                          onMissingInfoTap: () =>
                              setState(() => _activeFilter = 'missingInfo'),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: ArtisanalTheme.ink.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: ArtisanalTheme.ink.withValues(
                                      alpha: 0.2,
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      style: ArtisanalTheme.hand(
                                        fontSize: 16,
                                        color: ArtisanalTheme.ink,
                                      ),
                                      onChanged: (val) => setState(
                                        () => _searchQuery = val.toLowerCase(),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: l10n.searchIngredients
                                            .toUpperCase(),
                                        hintStyle: ArtisanalTheme.hand(
                                          fontSize: 13,
                                          color: ArtisanalTheme.secondary
                                              .withValues(alpha: 0.3),
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
                                      color: ArtisanalTheme.ink.withValues(
                                        alpha: 0.3,
                                      ),
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
                        preferredSize: Size.fromHeight(
                          _showCompressedDashboard ? 108 : 48,
                        ),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: const Color(
                                0xFFFAF9F6,
                              ).withValues(alpha: 0.8),
                              child: Column(
                                children: [
                                  if (_showCompressedDashboard)
                                    PantryDashboard(
                                      totalVaultValue: totalVaultValue,
                                      urgentCount: urgentCount,
                                      missingInfoCount: missingInfoCount,
                                      totalEntries: pantryItems.length,
                                      activeFilter: _activeFilter,
                                      onTotalTap: () =>
                                          setState(() => _activeFilter = 'all'),
                                      onLowStockTap: () => setState(
                                        () => _activeFilter = 'lowStock',
                                      ),
                                      onMissingInfoTap: () => setState(
                                        () => _activeFilter = 'missingInfo',
                                      ),
                                      isCompressed: true,
                                    ),
                                  TabBar(
                                    controller: _tabController,
                                    labelColor: ArtisanalTheme.ink,
                                    unselectedLabelColor: ArtisanalTheme.ink
                                        .withValues(alpha: 0.3),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicator: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: ArtisanalTheme.ink,
                                          width: 2,
                                        ),
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
                                    dividerColor: ArtisanalTheme.ink.withValues(
                                      alpha: 0.05,
                                    ),
                                    tabs: categories
                                        .map((c) => Tab(text: c.toUpperCase()))
                                        .toList(),
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
                        : pantryItems
                              .where((i) => i.category == category)
                              .toList();

                    if (_activeFilter == 'lowStock') {
                      filteredItems = filteredItems.where((i) {
                        final stockPercent =
                            i.currentStock /
                            (i.targetQuantity > 0 ? i.targetQuantity : 1);
                        return stockPercent < 0.2;
                      }).toList();
                    } else if (_activeFilter == 'missingInfo') {
                      filteredItems = filteredItems
                          .where(
                            (i) =>
                                i.purchasePrice == 0 || i.targetQuantity == 0,
                          )
                          .toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      filteredItems = filteredItems
                          .where(
                            (i) => i.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();
                    }

                    if (_sortByUrgency) {
                      filteredItems.sort((a, b) {
                        final aStock =
                            a.currentStock /
                            (a.targetQuantity > 0 ? a.targetQuantity : 1);
                        final bStock =
                            b.currentStock /
                            (b.targetQuantity > 0 ? b.targetQuantity : 1);
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
          _showEditDetailsSheet(l10n);
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
                _showQuickUpdateSheet(l10n, item);
              },
              child: InventoryTag(item: item),
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
        children: suggestions
            .map(
              (item) => InkWell(
                onTap: () {
                  setState(() {
                    _searchQuery = item.name;
                    _searchController.text = item.name;
                    _searchFocusNode.unfocus();
                  });
                },
                child: ListTile(
                  dense: true,
                  title: Text(
                    item.name,
                    style: ArtisanalTheme.hand(fontSize: 14),
                  ),
                  trailing: Text(
                    item.category.toUpperCase(),
                    style: ArtisanalTheme.hand(
                      fontSize: 9,
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSheetHeader(PantryItem item, AppLocalizations l10n, dynamic settings, Widget? trailing) {
    final categoryMap = ref.read(pantryCategoriesProvider);
    final color = Color(categoryMap[item.category] ?? 0xFF804E2E);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          Row(
            children: [
              // Postage Stamp / Label look for the icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.inventory_2_outlined, color: color, size: 24),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      style: ArtisanalTheme.receipt(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ArtisanalTheme.ink,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "#${item.category}",
                            style: ArtisanalTheme.hand(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Handwritten "Date Stamp"
                        Transform.rotate(
                          angle: -0.05,
                          child: Text(
                            "Updated ${DateFormat('MMM dd').format(item.lastUpdated)}",
                            style: ArtisanalTheme.hand(
                              fontSize: 12,
                              color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ignore: use_null_aware_elements
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          // Subtle dotted divider
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DottedLinePainter(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  void _showPantryItemSheet(AppLocalizations l10n, [PantryItem? item]) {
    final settings = ref.read(settingsProvider);
    final categoriesMap = ref.read(pantryCategoriesProvider);
    final activeCategories = categoriesMap.keys.where((c) => c != 'All').toList();
    
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item != null ? item.purchasePrice.toStringAsFixed(0) : '');
    final quickAddController = TextEditingController();
    final quickCostController = TextEditingController();
    
    String selectedUnit = item?.unit ?? (settings.measurementSystem == 'metric' ? 'g' : 'oz');
    
    final initialStock = item != null ? settings.fromGrams(item.currentStock, selectedUnit) : 0.0;
    final initialTarget = item != null ? settings.fromGrams(item.targetQuantity, selectedUnit) : 0.0;

    final currentStockController = TextEditingController(
      text: item != null ? (selectedUnit == 'g' || selectedUnit == 'oz' || selectedUnit == 'pcs') 
          ? initialStock.toStringAsFixed(0) 
          : initialStock.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '') : '',
    );
    final targetQtyController = TextEditingController(
      text: item != null ? (selectedUnit == 'g' || selectedUnit == 'oz' || selectedUnit == 'pcs') 
          ? initialTarget.toStringAsFixed(0) 
          : initialTarget.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '') : '',
    );

    final categoryNotifier = ValueNotifier<String>(
      item?.category ?? (activeCategories.contains('Others') ? 'Others' : activeCategories.isNotEmpty ? activeCategories.first : '')
    );
    bool isEditMode = item == null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: ArtisanalTheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    left: 0,
                    right: 0,
                    child: Center(child: MaskingTape(width: 100, rotation: 0.02)),
                  ),
                  
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 16, bottom: 8),
                        decoration: BoxDecoration(
                          color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Mode Toggle was here, moved to header

                      Flexible(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item != null)
                                _buildSheetHeader(
                                  item, 
                                  l10n, 
                                  settings,
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildModeToggleButton(
                                          icon: Icons.inventory_2_outlined,
                                          isSelected: !isEditMode,
                                          onTap: () => setSheetState(() => isEditMode = false),
                                        ),
                                        _buildModeToggleButton(
                                          icon: Icons.edit_note_outlined,
                                          isSelected: isEditMode,
                                          onTap: () => setSheetState(() => isEditMode = true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              if (item != null && !isEditMode)
                                _buildQuickAdjustView(
                                  item: item,
                                  settings: settings,
                                  l10n: l10n,
                                  qtyController: quickAddController,
                                  costController: quickCostController,
                                  selectedUnit: selectedUnit,
                                  onUnitSelected: (u) => setSheetState(() => selectedUnit = u),
                                  onSave: () {
                                    final addVal = double.tryParse(quickAddController.text.replaceAll(',', '').trim()) ?? 0;
                                    final costVal = double.tryParse(quickCostController.text.replaceAll(',', '').trim()) ?? 0;
                                    
                                    final addedGrams = settings.convertToGrams(addVal, selectedUnit);
                                    final newStock = item.currentStock + addedGrams;
                                    final newPrice = item.purchasePrice + costVal;

                                    ref.read(pantryProvider.notifier).updateItem(
                                      item.copyWith(
                                        currentStock: newStock,
                                        purchasePrice: newPrice,
                                        lastUpdated: DateTime.now(),
                                      ),
                                    );
                                    HapticFeedback.mediumImpact();
                                    Navigator.pop(context);
                                  },
                                )
                              else
                                _buildMetadataEditView(
                                  item: item ?? PantryItem(id: '', name: '', purchasePrice: 0, targetQuantity: 0, lastUpdated: DateTime.now()),
                                  settings: settings,
                                  l10n: l10n,
                                  nameController: nameController,
                                  priceController: priceController,
                                  targetQtyController: targetQtyController,
                                  currentStockController: currentStockController,
                                  categoryNotifier: categoryNotifier,
                                  activeCategories: activeCategories,
                                  categoriesMap: categoriesMap,
                                  selectedUnit: selectedUnit,
                                  onCategorySelected: (cat) => categoryNotifier.value = cat,
                                  onUnitSelected: (newUnit) {
                                    if (newUnit == selectedUnit) return;
                                    final oldUnit = selectedUnit;
                                    setSheetState(() {
                                      selectedUnit = newUnit;
                                      for (var ctrl in [currentStockController, targetQtyController]) {
                                        final val = double.tryParse(ctrl.text.replaceAll(',', '').trim()) ?? 0;
                                        if (val > 0) {
                                          final grams = settings.convertToGrams(val, oldUnit);
                                          final converted = settings.fromGrams(grams, newUnit);
                                          ctrl.text = (newUnit == 'g' || newUnit == 'oz' || newUnit == 'pcs')
                                              ? converted.toStringAsFixed(0)
                                              : converted.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
                                        }
                                      }
                                    });
                                  },
                                  onSave: () {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) return;

                                    final stockVal = double.tryParse(currentStockController.text.replaceAll(',', '').trim()) ?? 0;
                                    final targetVal = double.tryParse(targetQtyController.text.replaceAll(',', '').trim()) ?? 0;
                                    final priceVal = double.tryParse(priceController.text.replaceAll(',', '').trim()) ?? 0;

                                    final newItem = PantryItem(
                                      id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                      name: name,
                                      category: categoryNotifier.value,
                                      currentStock: settings.convertToGrams(stockVal, selectedUnit),
                                      targetQuantity: settings.convertToGrams(targetVal, selectedUnit),
                                      unit: selectedUnit,
                                      purchasePrice: priceVal,
                                      lastUpdated: DateTime.now(),
                                      imageUrl: item?.imageUrl ?? '',
                                    );

                                    if (item == null) {
                                      ref.read(pantryProvider.notifier).addItem(newItem);
                                    } else {
                                      ref.read(pantryProvider.notifier).updateItem(newItem);
                                    }
                                    HapticFeedback.mediumImpact();
                                    Navigator.pop(context);
                                  },
                                  onDelete: item != null ? () {
                                    ref.read(pantryProvider.notifier).deleteItem(item.id);
                                    Navigator.pop(context);
                                  } : null,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQuickUpdateSheet(AppLocalizations l10n, PantryItem item) {
    _showPantryItemSheet(l10n, item);
  }

  void _showEditDetailsSheet(AppLocalizations l10n, [PantryItem? item]) {
    _showPantryItemSheet(l10n, item);
  }

  Widget _buildQuickAdjustView({
    required PantryItem item,
    required dynamic settings,
    required AppLocalizations l10n,
    required TextEditingController qtyController,
    required TextEditingController costController,
    required String selectedUnit,
    required Function(String) onUnitSelected,
    required VoidCallback onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stock Display as a "Wax Seal"
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: qtyController,
            builder: (context, value, _) {
              final incrementStr = value.text.trim();
              final incrementValueRaw = double.tryParse(incrementStr.replaceAll(',', '')) ?? 0.0;
              final incrementInGrams = settings.convertToGrams(incrementValueRaw, selectedUnit);
              final projectedStock = item.currentStock + incrementInGrams;
              
              return Stack(
                // Scalloped Ledger Card Look
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Paper Card
                  ClipPath(
                    clipper: ScallopedClipper(radius: 8),
                    child: Container(
                      width: 200,
                      height: 120,
                      decoration: BoxDecoration(
                        color: ArtisanalTheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                (selectedUnit == 'g' || selectedUnit == 'oz' || selectedUnit == 'pcs')
                                    ? settings.fromGrams(projectedStock, selectedUnit).toStringAsFixed(0)
                                    : settings.fromGrams(projectedStock, selectedUnit).toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), ''),
                                style: ArtisanalTheme.hand(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w600,
                                  color: incrementInGrams > 0 ? ArtisanalTheme.primary : ArtisanalTheme.ink,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                selectedUnit,
                                style: ArtisanalTheme.receipt(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.currentStockLabel.toUpperCase(),
                            style: ArtisanalTheme.receipt(
                              fontSize: 9,
                              color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Handwritten Red Ink Annotation for increment
                  if (incrementStr.isNotEmpty && incrementInGrams != 0)
                    Positioned(
                      top: -15,
                      right: -10,
                      child: Transform.rotate(
                        angle: 0.15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "+ $incrementStr",
                              style: ArtisanalTheme.hand(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ArtisanalTheme.redInk,
                              ),
                            ),
                            // A small hand-drawn underline
                            Container(
                              width: 40,
                              height: 1.5,
                              decoration: BoxDecoration(
                                color: ArtisanalTheme.redInk.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Input Section (Transparent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.unitLabel.toUpperCase(),
                          style: ArtisanalTheme.receipt(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                        _buildUnitToggle(
                          selectedUnit,
                          [
                            ...(settings.measurementSystem == 'metric'
                                ? ['g', 'kg']
                                : ['oz', 'lb']),
                            'pcs',
                          ],
                          onUnitSelected,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildArtisanalField(
                            label: l10n.quantityToAdd,
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            suffix: selectedUnit,
                            icon: Icons.add_circle_outline,
                            hintText: '0',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildArtisanalField(
                            label: l10n.totalCostForBatch,
                            controller: costController,
                            keyboardType: TextInputType.number,
                            suffix: settings.currencySymbol,
                            icon: Icons.payments_outlined,
                            hintText: '0',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          
          // Quick Update Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.cancel.toUpperCase(),
                      style: ArtisanalTheme.receipt(
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onSave,
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ArtisanalTheme.ink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.saveChanges.toUpperCase(),
                      style: ArtisanalTheme.receipt(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        fontSize: 16,
                      ),
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

  Widget _buildMetadataEditView({
    required PantryItem item,
    required dynamic settings,
    required AppLocalizations l10n,
    required TextEditingController nameController,
    required TextEditingController priceController,
    required TextEditingController targetQtyController,
    required TextEditingController currentStockController,
    required ValueNotifier<String> categoryNotifier,
    required List<String> activeCategories,
    required Map<String, int> categoriesMap,
    required String selectedUnit,
    required Function(String) onCategorySelected,
    required Function(String) onUnitSelected,
    required VoidCallback onSave,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Name & Category Section
          _buildArtisanalField(
            label: l10n.ingredientName,
            controller: nameController,
            icon: Icons.label_outline,
            hintText: l10n.ingredientNameHint,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            l10n.categoryName.toUpperCase(),
            style: ArtisanalTheme.receipt(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: activeCategories.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = activeCategories[index];
                final color = Color(categoriesMap[cat] ?? 0xFFFDFCFB);
                return ValueListenableBuilder<String>(
                  valueListenable: categoryNotifier,
                  builder: (context, selectedCat, _) {
                    final isSelected = selectedCat == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onCategorySelected(cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? ArtisanalTheme.ink.withValues(alpha: 0.2) : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                        child: Text(
                          "#$cat",
                          style: ArtisanalTheme.hand(
                            fontSize: 13,
                            color: isSelected ? ArtisanalTheme.ink : ArtisanalTheme.ink.withValues(alpha: 0.4),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 32),
          
          // Lined Paper Section for Metadata (Transparent)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.unitLabel.toUpperCase(),
                      style: ArtisanalTheme.receipt(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                    _buildUnitToggle(selectedUnit, ['g', 'kg', 'pcs'], onUnitSelected),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildArtisanalField(
                        label: l10n.currentStockLabel,
                        controller: currentStockController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        suffix: selectedUnit,
                        isPencil: true,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildArtisanalField(
                        label: l10n.inventoryGoal.toUpperCase(),
                        controller: targetQtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        suffix: selectedUnit,
                        isPencil: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildArtisanalField(
                  label: l10n.purchasePriceLabel,
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  icon: Icons.payments_outlined,
                  suffix: '₩',
                  hintText: '0',
                  isPencil: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          // Horizontal Actions
          Row(
            children: [
              if (item.id.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(item, l10n),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ArtisanalTheme.redInk.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: ArtisanalTheme.redInk, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: onSave,
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ArtisanalTheme.ink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.saveChanges.toUpperCase(),
                      style: ArtisanalTheme.receipt(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _manageCategories(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryManagerSheet(),
    );
  }

  Widget _buildArtisanalField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    String? suffix,
    String? suffixText,
    String? hintText,
    bool isPencil = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: isPencil
                  ? ArtisanalTheme.hand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                    )
                  : ArtisanalTheme.receipt(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                      letterSpacing: 1.0,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: isPencil
              ? ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.primary)
              : ArtisanalTheme.receipt(fontSize: 16, color: ArtisanalTheme.ink, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            hintText: hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintStyle: ArtisanalTheme.hand(
              fontSize: 18,
              color: ArtisanalTheme.ink.withValues(alpha: 0.2),
            ),
            suffixText: suffix ?? suffixText,
            suffixStyle: ArtisanalTheme.hand(
              fontSize: 14,
              color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: ArtisanalTheme.ink.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(PantryItem item, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dangerousAction),
        content: Text(l10n.deleteConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.keepData),
          ),
          TextButton(
            onPressed: () {
              ref.read(pantryProvider.notifier).deleteItem(item.id);
              Navigator.pop(context); // Dialog
              Navigator.pop(this.context); // Sheet
            },
            child: Text(
              l10n.deleteButton,
              style: const TextStyle(color: ArtisanalTheme.redInk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle(String activeUnit, List<String> units, Function(String) onSelected) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: ArtisanalTheme.ink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: units.map((u) {
          final isSelected = activeUnit == u;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(u);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                u.toUpperCase(),
                style: ArtisanalTheme.hand(
                  fontSize: 11,
                  color: isSelected
                      ? ArtisanalTheme.ink
                      : ArtisanalTheme.ink.withValues(alpha: 0.4),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? ArtisanalTheme.ink : ArtisanalTheme.ink.withValues(alpha: 0.3),
        ),
      ),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => true;
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var dashWidth = 5;
    var dashSpace = 3;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
