import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/recipe.dart';
import '../providers/transaction_provider.dart';
import '../providers/recipe_cost_provider.dart';
import '../services/recipe_service.dart';
import 'custom_clippers.dart';

class SalesSlipSheet extends ConsumerStatefulWidget {
  final BusinessTransaction? initialTransaction;
  const SalesSlipSheet({super.key, this.initialTransaction});

  @override
  ConsumerState<SalesSlipSheet> createState() => _SalesSlipSheetState();
}

class _ItemEntry {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController amountController = TextEditingController();
  
  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    amountController.dispose();
  }
}

class _SalesSlipSheetState extends ConsumerState<SalesSlipSheet> {
  final List<_ItemEntry> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final tx = widget.initialTransaction!;
      final entry = _ItemEntry();
      
      // Parse "Name (xQty)"
      final regex = RegExp(r"^(.*) \(x(\d+)\)$");
      final match = regex.firstMatch(tx.description);
      
      if (match != null) {
        entry.descriptionController.text = match.group(1)!;
        entry.quantityController.text = match.group(2)!;
      } else {
        entry.descriptionController.text = tx.description;
        entry.quantityController.text = "1";
      }
      
      final qty = double.tryParse(entry.quantityController.text) ?? 1;
      entry.amountController.text = (tx.amount / qty).toStringAsFixed(0);
      _items.add(entry);
    } else {
      _items.add(_ItemEntry());
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_ItemEntry());
    });
    // Scroll to bottom after frame is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (final item in _items) {
      final qty = double.tryParse(item.quantityController.text) ?? 0;
      final price = double.tryParse(item.amountController.text) ?? 0;
      total += qty * price;
    }
    return total;
  }

  Future<void> _handleSave() async {
    if (_isPaid) return;

    final txNotifier = ref.read(transactionProvider.notifier);
    final l10n = AppLocalizations.of(context);
    
    // Validate if any item has content
    final validItems = _items.where((it) => 
      it.descriptionController.text.isNotEmpty && 
      (double.tryParse(it.amountController.text) ?? 0) > 0
    ).toList();

    if (validItems.isEmpty) return;

    setState(() => _isPaid = true);

    // Briefly show the PAID stamp before closing
    await Future.delayed(const Duration(milliseconds: 600));

    for (final item in validItems) {
      final qty = double.tryParse(item.quantityController.text) ?? 1;
      final price = double.tryParse(item.amountController.text) ?? 0;
      
      final tx = BusinessTransaction(
        id: widget.initialTransaction?.id ?? (DateTime.now().millisecondsSinceEpoch.toString() + item.hashCode.toString()),
        date: widget.initialTransaction?.date ?? DateTime.now(),
        type: 'sale',
        amount: qty * price,
        category: l10n.productSale,
        description: "${item.descriptionController.text} (x${qty.toInt()})",
      );

      txNotifier.addTransaction(tx);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.saleRegistered),
          backgroundColor: ArtisanalTheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);
    final total = _calculateTotal();

    return Container(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Transform.translate(
            offset: const Offset(0, 10),
            child: ClipPath(
              clipper: SerratedClipper(toothWidth: 12, toothHeight: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCF6E0), // Vintage creamy yellow paper
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.salesSlip.toUpperCase(),
                            style: ArtisanalTheme.hand(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                              letterSpacing: 2,
                            ),
                          ),
                          _buildDateStamp(),
                        ],
                      ),
                      const Divider(color: Colors.black12, height: 32),
                      
                      // Table Header
                      Row(
                        children: [
                          Expanded(flex: 4, child: Text(l10n.description.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black38))),
                          Expanded(flex: 1, child: Text(l10n.quantity.toUpperCase(), textAlign: TextAlign.center, style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black38))),
                          Expanded(flex: 2, child: Text(l10n.price.toUpperCase(), textAlign: TextAlign.right, style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black38))),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 8),
  
                      // Entries
                      ...List.generate(_items.length, (index) => _buildEntryRow(index)),
  
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _addItem,
                        child: Text(
                          l10n.addItem,
                          style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primaryContainer, fontStyle: FontStyle.italic),
                        ),
                      ),
  
                      const Divider(color: Colors.black12, height: 40),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.totalAmount, style: ArtisanalTheme.hand(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(total), style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold, color: ArtisanalTheme.primary)),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Center(
                        child: _buildPaidStampButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStamp() {
    final dateStr = DateFormat('yy.MM.dd').format(DateTime.now());
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.5), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          dateStr,
          style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.redInk.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEntryRow(int index) {
    final l10n = AppLocalizations.of(context);
    final entry = _items[index];
    final recipes = ref.watch(recipeListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Selection
          Expanded(
            flex: 4,
            child: Autocomplete<Recipe>(
              displayStringForOption: (option) => option.name,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Recipe>.empty();
                return recipes.where((recipe) => 
                  recipe.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (recipe) {
                entry.descriptionController.text = recipe.name;
                final costData = ref.read(recipeCostProvider(recipe));
                entry.amountController.text = costData.suggestedPrice.toStringAsFixed(0);
                setState(() {});
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                if (entry.descriptionController.text.isNotEmpty && controller.text.isEmpty) {
                  controller.text = entry.descriptionController.text;
                }
                
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: l10n.addProductHint,
                      hintStyle: const TextStyle(color: Colors.black12),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.only(bottom: 2),
                    ),
                    style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
                    onChanged: (val) {
                      entry.descriptionController.text = val;
                    },
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option.name, style: ArtisanalTheme.hand(fontSize: 16)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: 12),

          // Quantity Controls
          Row(
            children: [
              _buildQtyButton(Icons.remove, () {
                final current = int.tryParse(entry.quantityController.text) ?? 1;
                if (current > 1) {
                  entry.quantityController.text = (current - 1).toString();
                  setState(() {});
                }
              }),
              SizedBox(
                width: 30,
                child: TextField(
                  controller: entry.quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink, fontWeight: FontWeight.bold),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              _buildQtyButton(Icons.add, () {
                final current = int.tryParse(entry.quantityController.text) ?? 0;
                entry.quantityController.text = (current + 1).toString();
                setState(() {});
              }),
            ],
          ),

          const SizedBox(width: 12),

          // Price
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                ),
              ),
              child: TextField(
                controller: entry.amountController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "0",
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 2),
                ),
                style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Delete Row
          IconButton(
            icon: Icon(Icons.remove_circle_outline, size: 22, color: ArtisanalTheme.redInk.withValues(alpha: 0.3)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 14, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildPaidStampButton() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _handleSave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: _isPaid ? Colors.transparent : ArtisanalTheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: _isPaid ? ArtisanalTheme.redInk : ArtisanalTheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: _isPaid ? 0 : 1,
              child: Text(
                l10n.paid.toUpperCase(),
                style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold, color: ArtisanalTheme.primary),
              ),
            ),
            if (_isPaid)
              Transform.rotate(
                angle: -0.15,
                child: Text(
                  l10n.paid.toUpperCase(),
                  style: ArtisanalTheme.hand(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: ArtisanalTheme.redInk.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
