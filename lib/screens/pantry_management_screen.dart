import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import 'dart:io';

class PantryManagementScreen extends ConsumerStatefulWidget {
  const PantryManagementScreen({super.key});

  @override
  ConsumerState<PantryManagementScreen> createState() => _PantryManagementScreenState();
}

class _PantryManagementScreenState extends ConsumerState<PantryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final categories = ['All', 'Flour', 'Dairy', 'Others'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pantryItems = ref.watch(pantryProvider);

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
          "Pantry Ledger",
          style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontStyle: FontStyle.italic,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ArtisanalTheme.primary,
          unselectedLabelColor: ArtisanalTheme.secondary.withValues(alpha: 0.5),
          indicatorColor: ArtisanalTheme.primary,
          indicatorWeight: 3,
          labelStyle: ArtisanalTheme.hand(fontWeight: FontWeight.bold),
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPantryItemSheet(context, ref),
        backgroundColor: ArtisanalTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final filteredItems = category == 'All' 
              ? pantryItems 
              : pantryItems.where((item) {
                  final pItem = item as PantryItem;
                  if (category == 'Flour') return pItem.name.toLowerCase().contains('flour');
                  if (category == 'Dairy') return pItem.name.toLowerCase().contains('milk') || pItem.name.toLowerCase().contains('butter') || pItem.name.toLowerCase().contains('cream');
                  if (category == 'Others') return !pItem.name.toLowerCase().contains('flour') && !pItem.name.toLowerCase().contains('milk') && !pItem.name.toLowerCase().contains('butter') && !pItem.name.toLowerCase().contains('cream');
                  return true;
                }).toList();
          
          return _buildPantryGrid(filteredItems.cast<PantryItem>());
        }).toList(),
      ),
    );
  }

  Widget _buildPantryGrid(List<PantryItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No inventory items yet.\nTap + to add your first batch.",
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
        return InventoryTag(item: items[index]);
      },
    );
  }

  void _showAddPantryItemSheet(BuildContext context, WidgetRef ref) {
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
                "New Stock Entry",
                style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                "Record your latest purchase arrivals",
                style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              _buildArtisanalInput(
                label: "Ingredient Name",
                hint: "e.g. Organic Rye Flour",
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildArtisanalInput(
                      label: "Quantity",
                      hint: "2500",
                      suffix: "g",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => quantity = double.tryParse(val) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildArtisanalInput(
                      label: "Purchase Price",
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
                "Category",
                style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.secondary),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setSheetState) => Wrap(
                  spacing: 8,
                  children: categories.where((c) => c != 'All').map((c) {
                    final isSelected = category == c;
                    return ChoiceChip(
                      label: Text(c, style: ArtisanalTheme.hand(
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
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && price > 0 && quantity > 0) {
                      ref.read(pantryProvider.notifier).addItem(PantryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        purchasePrice: price,
                        purchaseQuantity: quantity,
                        currentStock: quantity, // Initial stock is total purchase
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
                  child: Text("Register into Pantry", style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 100), // Space for keyboard
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtisanalInput({
    required String label,
    required String hint,
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
        TextField(
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
}

class InventoryTag extends StatelessWidget {
  final PantryItem item;
  const InventoryTag({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
                  if (isLow)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "LOW STOCK",
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
