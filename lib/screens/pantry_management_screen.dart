import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
import '../widgets/sketch_area.dart';
import '../providers/category_icons_provider.dart';

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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final categories = ref.read(pantryCategoriesProvider);
    _tabController = TabController(length: categories.length, vsync: this);
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_searchFocusNode.hasFocus) {
        // Ensure search bar and suggestions are pushed up to be clear of keyboard
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              160, // Approximate height to push Dashboard mostly out of view
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
                  onPressed: () => _manageCategories(context, ref, l10n),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    PantryReportService.generateAndPrintReport(ref.watch(pantryProvider));
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: ArtisanalTheme.primary),
                  tooltip: "EXPORT LEDGER",
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
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              margin: EdgeInsets.only(top: _isSearchFocused ? 12 : 0),
                              transform: Matrix4.identity()..setTranslationRaw(0.0, _isSearchFocused ? 4.0 : 0.0, 0.0),
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F6F1),
                                border: Border.all(color: const Color(0xFFD4C4A1), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: _isSearchFocused ? 0.15 : 0.08),
                                    blurRadius: _isSearchFocused ? 12 : 4,
                                    offset: Offset(0, _isSearchFocused ? 6 : 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Brass Handle Detail (Simulated with icons/shapes)
                                  Positioned(
                                    left: 0, right: 0, bottom: 5,
                                    child: Center(
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: _isSearchFocused ? 1.0 : 0.5,
                                        child: Container(
                                          width: 40,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB8860B).withValues(alpha: 0.4),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                            boxShadow: [
                                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 1, offset: const Offset(0, 1))
                                            ]
                                          ),
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
                                             focusNode: _searchFocusNode,
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
                                         GestureDetector(
                                           onTap: () {
                                             HapticFeedback.lightImpact();
                                             _searchController.clear();
                                             setState(() => _searchQuery = '');
                                           },
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                             decoration: BoxDecoration(
                                               border: Border.all(color: const Color(0xFFD4C4A1)),
                                             ),
                                             child: Text(
                                               "CAT. N°",
                                               style: ArtisanalTheme.hand(fontSize: 9, color: const Color(0xFFD4C4A1)),
                                             ),
                                           ),
                                         ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Autocomplete Suggestions
                          if (_isSearchFocused && _searchQuery.isNotEmpty) 
                            _buildSearchSuggestions(pantryItems),
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
                              child: Text(_getCategoryDisplayName(c, l10n).toUpperCase()),
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

                      // Apply Dashboard Filter
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
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return StaggeredDropAnimation(
          index: index,
          child: Transform.rotate(
            angle: (item.id.hashCode % 10 - 5) / 400, // Very subtle random rotation
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

  Widget _buildIngredientImage(WidgetRef ref, String name, String category, [String? customImageUrl]) {
    // Priority 1: User's custom image
    if (customImageUrl != null && customImageUrl.isNotEmpty) {
      if (customImageUrl.startsWith('http')) {
        return Image.network(customImageUrl, fit: BoxFit.cover);
      } else {
        final file = File(customImageUrl);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        }
      }
    }

    String assetPath = 'assets/images/categories/others.png';
    final lowerName = name.toLowerCase();

    // Priority 2: Name-based mapping
    if (lowerName.contains('flour') || lowerName.contains('밀가루') || lowerName.contains('강력') || lowerName.contains('박력')) {
      assetPath = 'assets/images/categories/flour.png';
    } else if (lowerName.contains('salt') || lowerName.contains('소금')) {
      assetPath = 'assets/images/categories/others.png';
    } else if (lowerName.contains('butter') || lowerName.contains('버터')) {
      assetPath = 'assets/images/categories/dairy_eggs.png';
    } else if (lowerName.contains('sugar') || lowerName.contains('설탕')) {
      assetPath = 'assets/images/categories/sweetener.png';
    } else {
      // Priority 3: Category-level custom icons
      final categoryIcons = ref.watch(categoryIconsProvider);
      if (categoryIcons.containsKey(category)) {
        final catPath = categoryIcons[category]!;
        if (catPath.startsWith('http')) {
          return Image.network(catPath, fit: BoxFit.cover);
        } else if (catPath.startsWith('assets/')) {
          return Image.asset(catPath, fit: BoxFit.cover);
        } else {
          final file = File(catPath);
          if (file.existsSync()) {
            return Image.file(file, fit: BoxFit.cover);
          }
        }
      }

      // Priority 4: Category-based hardcoded defaults
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

  Widget _buildDefaultIconPicker(BuildContext context, String label, String assetPath) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, assetPath),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: ArtisanalTheme.note(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
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
                          child: _buildIngredientImage(ref, item.name, item.category, item.imageUrl),
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

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (photo == null) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'pantry_${DateTime.now().millisecondsSinceEpoch}${p.extension(photo.path)}';
      final String localPath = p.join(appDir.path, fileName);

      final File newImage = await File(photo.path).copy(localPath);
      return newImage.path;
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  Future<String?> _showSketchDialog(AppLocalizations l10n) async {
    if (!mounted) return null;
    final boundaryKey = GlobalKey();
    
    // Ensure we are using the context safely
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(16),
        title: Text(l10n.sketch.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 400,
          child: SketchArea(canvasKey: boundaryKey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = await _saveSketch(boundaryKey);
              Navigator.pop(context, path);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ArtisanalTheme.ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.saveChanges.toUpperCase(), style: ArtisanalTheme.hand(color: Colors.white)),
          ),
        ],
      ),
    );
    return result;
  }

  Future<String?> _saveSketch(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      
      final buffer = byteData.buffer.asUint8List();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final String localPath = p.join(appDir.path, fileName);
      
      final file = File(localPath);
      await file.writeAsBytes(buffer);
      return file.path;
    } catch (e) {
      debugPrint("Error saving sketch: $e");
      return null;
    }
  }

  void _showAddEditSheet(AppLocalizations l10n, [PantryItem? item]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item?.purchasePrice.toString() ?? '');
    final targetQtyController = TextEditingController(text: item?.targetQuantity.toString() ?? '');
    final currentQtyController = TextEditingController(text: item?.currentStock.toString() ?? '');
    
    final activeCategories = ref.read(pantryCategoriesProvider).where((c) => c != 'All').toList();
    final displayCategories = activeCategories.map((c) => (c, _getCategoryDisplayName(c, l10n))).toList();

    final categoryNotifier = ValueNotifier<String>(item?.category ?? (activeCategories.contains('Flour') ? 'Flour' : activeCategories.first));
    final unitNotifier = ValueNotifier<String>(item?.unit ?? 'g');
    final imagePathNotifier = ValueNotifier<String?>(item?.imageUrl);

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
              const SizedBox(height: 12),
              
              ValueListenableBuilder<String?>(
                valueListenable: imagePathNotifier,
                builder: (context, path, _) => Center(
                  child: GestureDetector(
                    onTap: () async {
                      final source = await showModalBottomSheet<dynamic>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDFCFB),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ListTile(
                                leading: const Icon(Icons.photo_library_outlined, color: ArtisanalTheme.ink),
                                title: Text(l10n.gallery, style: ArtisanalTheme.hand(fontSize: 18)),
                                onTap: () => Navigator.pop(context, ImageSource.gallery),
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt_outlined, color: ArtisanalTheme.ink),
                                title: Text(l10n.camera, style: ArtisanalTheme.hand(fontSize: 18)),
                                onTap: () => Navigator.pop(context, ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.palette_outlined, color: ArtisanalTheme.ink),
                                title: Text(l10n.sketch, style: ArtisanalTheme.hand(fontSize: 18)),
                                onTap: () => Navigator.pop(context, 'sketch'),
                              ),
                              if (path != null) 
                                ListTile(
                                  leading: const Icon(Icons.refresh, color: ArtisanalTheme.redInk),
                                  title: Text("RESTORE DEFAULT", style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.redInk)),
                                  onTap: () => Navigator.pop(context, 'reset'),
                                ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      );
                        if (source != null) {
                          String? newPath;
                          if (source == 'sketch') {
                            newPath = await _showSketchDialog(l10n);
                          } else if (source == 'reset') {
                            imagePathNotifier.value = null;
                            return;
                          } else if (source is ImageSource) {
                            newPath = await _pickImage(source);
                          }
                          
                          if (newPath != null) {
                            imagePathNotifier.value = newPath;
                          }
                        }
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 110,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: _buildIngredientImage(ref, nameController.text, categoryNotifier.value, path),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 20,
                                height: 1,
                                color: ArtisanalTheme.secondary.withValues(alpha: 0.1),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ArtisanalTheme.ink,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.add_a_photo, color: Colors.white, size: 16),
                          ),
                        ),
                        if (path != null)
                          Positioned(
                            left: -4,
                            top: -4,
                            child: GestureDetector(
                              onTap: () => imagePathNotifier.value = null,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: ArtisanalTheme.redInk,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
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
                                                _buildIngredientImage(ref, '', cat.$1),
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
                              imageUrl: imagePathNotifier.value,
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
                          child: Text(l10n.saveChanges.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final categories = ref.watch(pantryCategoriesProvider);
          final pantryItems = ref.watch(pantryProvider);
          
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCFB),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5)),
                ],
                image: DecorationImage(
                  image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
                  repeat: ImageRepeat.repeat,
                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.03), BlendMode.dstATop),
                ),
              ),
              padding: const EdgeInsets.all(28),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.manageCategories.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          Text("Ledger Index Organization", style: ArtisanalTheme.note(fontSize: 12, color: ArtisanalTheme.secondary.withValues(alpha: 0.6))),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => categories[index] == 'All' ? const SizedBox.shrink() : Divider(color: ArtisanalTheme.primary.withValues(alpha: 0.05)),
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        if (c == 'All') return const SizedBox.shrink();
                        
                        final itemCount = pantryItems.where((i) => i.category == c).length;
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: GestureDetector(
                            onTap: () async {
                              final source = await showModalBottomSheet<dynamic>(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFDFCFB),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.selectSource.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library_outlined, color: ArtisanalTheme.ink),
                                        title: Text(l10n.gallery, style: ArtisanalTheme.hand(fontSize: 18)),
                                        onTap: () => Navigator.pop(context, ImageSource.gallery),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt_outlined, color: ArtisanalTheme.ink),
                                        title: Text(l10n.camera, style: ArtisanalTheme.hand(fontSize: 18)),
                                        onTap: () => Navigator.pop(context, ImageSource.camera),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.edit_outlined, color: ArtisanalTheme.ink),
                                        title: Text(l10n.sketch, style: ArtisanalTheme.hand(fontSize: 18)),
                                        onTap: () => Navigator.pop(context, 'sketch'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.auto_awesome_outlined, color: ArtisanalTheme.primary),
                                        title: Text(l10n.restoreDefault.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary)),
                                        onTap: () async {
                                          final selectedAsset = await showModalBottomSheet<String>(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFDFCFB),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("CHOOSE ARTISANAL DEFAULT", style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 20),
                                                  GridView.count(
                                                    shrinkWrap: true,
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 12,
                                                    crossAxisSpacing: 12,
                                                    children: [
                                                      _buildDefaultIconPicker(context, 'Flour', 'assets/images/categories/flour.png'),
                                                      _buildDefaultIconPicker(context, 'Dairy', 'assets/images/categories/dairy_eggs.png'),
                                                      _buildDefaultIconPicker(context, 'Sugar', 'assets/images/categories/sweetener.png'),
                                                      _buildDefaultIconPicker(context, 'Yeast', 'assets/images/categories/leavening.png'),
                                                      _buildDefaultIconPicker(context, 'Ad-in', 'assets/images/categories/addin.png'),
                                                      _buildDefaultIconPicker(context, 'Other', 'assets/images/categories/others.png'),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24),
                                                ],
                                              ),
                                            ),
                                          );
                                          if (selectedAsset != null) {
                                            await ref.read(categoryIconsProvider.notifier).setIcon(c, selectedAsset);
                                            if (context.mounted) Navigator.pop(context); // Close source selector
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              );
                              
                              if (source != null) {
                                String? newPath;
                                if (source == 'sketch') {
                                  newPath = await _showSketchDialog(l10n);
                                } else if (source == 'reset') {
                                  await ref.read(categoryIconsProvider.notifier).setIcon(c, null);
                                  return;
                                } else if (source is ImageSource) {
                                  newPath = await _pickImage(source);
                                }
                                
                                if (newPath != null) {
                                  await ref.read(categoryIconsProvider.notifier).setIcon(c, newPath);
                                }
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: ArtisanalTheme.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.1)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    _buildIngredientImage(ref, "Category Icon", c),
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: ArtisanalTheme.ink, shape: BoxShape.circle),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            _getCategoryDisplayName(c, l10n),
                            style: ArtisanalTheme.hand(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "$itemCount Items Registered",
                            style: ArtisanalTheme.note(fontSize: 11, color: ArtisanalTheme.secondary.withValues(alpha: 0.5)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (c != 'Others') ...[
                                IconButton(
                                  icon: const Icon(Icons.edit_note, size: 20, color: ArtisanalTheme.primary),
                                  onPressed: () => _showRenameCategoryDialog(context, ref, c, l10n),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: ArtisanalTheme.redInk),
                                  onPressed: () async {
                                    HapticFeedback.heavyImpact();
                                    // 1. Move items to 'Others'
                                    await ref.read(pantryProvider.notifier).bulkUpdateCategory(c, 'Others');
                                    // 2. Remove category
                                    await ref.read(pantryCategoriesProvider.notifier).removeCategory(c);
                                  },
                                ),
                              ] else 
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(l10n.fixedLabel.toUpperCase(), style: ArtisanalTheme.note(fontSize: 8, color: ArtisanalTheme.secondary.withValues(alpha: 0.3))),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Add New Category Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6F1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4C4A1).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_box_outlined, color: ArtisanalTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.newCategory.toUpperCase(),
                            style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.primary.withValues(alpha: 0.7)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showAddCategoryDialog(context, ref, l10n),
                          style: TextButton.styleFrom(
                            backgroundColor: ArtisanalTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text("CREATE", style: ArtisanalTheme.hand(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.newCategory.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: ArtisanalTheme.hand(fontSize: 18),
          decoration: InputDecoration(
            hintText: l10n.categoryName,
            hintStyle: ArtisanalTheme.hand(color: ArtisanalTheme.secondary.withValues(alpha: 0.3)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4C4A1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ArtisanalTheme.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(l10n.cancel.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(pantryCategoriesProvider.notifier).addCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showRenameCategoryDialog(BuildContext context, WidgetRef ref, String oldName, AppLocalizations l10n) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.renameCategory.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: ArtisanalTheme.hand(fontSize: 18),
          decoration: InputDecoration(
            hintText: l10n.newName,
            hintStyle: ArtisanalTheme.hand(color: ArtisanalTheme.secondary.withValues(alpha: 0.3)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4C4A1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ArtisanalTheme.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(l10n.cancel.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 13)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                // 1. Move items to new name
                await ref.read(pantryProvider.notifier).bulkUpdateCategory(oldName, controller.text);
                // 2. Migrate icon
                await ref.read(categoryIconsProvider.notifier).migrateIcon(oldName, controller.text);
                // 3. Rename category
                await ref.read(pantryCategoriesProvider.notifier).renameCategory(oldName, controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.rename.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildSearchSuggestions(List<PantryItem> allItems) {
    final filtered = allItems.where((item) => 
      item.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).take(4).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCF9), 
        border: const Border(
          left: BorderSide(color: Color(0xFFD4C4A1), width: 1.5),
          right: BorderSide(color: Color(0xFFD4C4A1), width: 1.5),
          bottom: BorderSide(color: Color(0xFFD4C4A1), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: filtered.map((item) => Material(
          color: Colors.transparent,
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.history_edu_outlined, size: 16, color: Color(0xFFB8860B)),
            title: Text(item.name, style: ArtisanalTheme.hand(fontSize: 15)),
            trailing: Text(item.category.toUpperCase(), style: ArtisanalTheme.note(fontSize: 9, color: ArtisanalTheme.secondary.withValues(alpha: 0.5))),
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _searchQuery = item.name;
                _searchController.text = item.name;
                _searchFocusNode.unfocus();
              });
            },
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
