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
  final String type; // 'sale' or 'expense'
  const SalesSlipSheet({super.key, this.initialTransaction, this.type = 'sale'});

  @override
  ConsumerState<SalesSlipSheet> createState() => _SalesSlipSheetState();
}

class _ItemEntry {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController amountController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  
  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    amountController.dispose();
    focusNode.dispose();
  }
}

class _SalesSlipSheetState extends ConsumerState<SalesSlipSheet> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<_ItemEntry> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isPaid = false;
  bool _isSaving = false;

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
    final newEntry = _ItemEntry();
    _items.add(newEntry);
    _listKey.currentState?.insertItem(_items.length - 1, duration: const Duration(milliseconds: 400));
    
    setState(() {});
    
    // Focus on new entry after animation starts
    Future.delayed(const Duration(milliseconds: 100), () {
      newEntry.focusNode.requestFocus();
    });
    
    // Scroll to bottom after frame is rendered
    Future.delayed(const Duration(milliseconds: 450), () {
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
      final removedItem = _items[index];
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildEntryRow(index, animation, isRemoving: true, itemOverride: removedItem),
        duration: const Duration(milliseconds: 300),
      );
      
      _items.removeAt(index);
      setState(() {});
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

    setState(() {
      _isSaving = true;
      _isPaid = true;
    });

    // Briefly show the PAID stamp before closing
    await Future.delayed(const Duration(milliseconds: 800));

    for (final item in validItems) {
      final qty = double.tryParse(item.quantityController.text) ?? 1;
      final price = double.tryParse(item.amountController.text) ?? 0;
      
      final tx = BusinessTransaction(
        id: widget.initialTransaction?.id ?? (DateTime.now().millisecondsSinceEpoch.toString() + item.hashCode.toString()),
        date: widget.initialTransaction?.date ?? DateTime.now(),
        type: widget.type,
        amount: qty * price,
        category: widget.type == 'sale' ? l10n.productSale : l10n.totalExpensesLabel,
        description: "${item.descriptionController.text} (x${qty.toInt()})",
      );

      txNotifier.addTransaction(tx);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.type == 'sale' ? l10n.saleRegistered : '기록되었습니다'),
          backgroundColor: widget.type == 'sale' ? ArtisanalTheme.primary : ArtisanalTheme.redInk,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol, decimalDigits: 0);
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
                  color: Color(0xFFFDFCF7), // Cleaner, lighter off-white/ivory
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
                            (widget.type == 'sale' ? l10n.salesSlip : '지출 전표').toUpperCase(),
                            style: ArtisanalTheme.hand(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: (widget.type == 'sale' ? ArtisanalTheme.secondary : ArtisanalTheme.redInk).withValues(alpha: 0.6),
                              letterSpacing: 2,
                            ),
                          ),
                          _buildDateStamp(context),
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
  
                      // Entries with Animation
                      AnimatedList(
                        key: _listKey,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        initialItemCount: _items.length,
                        itemBuilder: (context, index, animation) {
                          return _buildEntryRow(index, animation);
                        },
                      ),
  
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
                          Text(currencyFormat.format(total), style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold, color: widget.type == 'sale' ? ArtisanalTheme.primary : ArtisanalTheme.redInk)),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Center(
                        child: _buildPaidStampButton(),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildDateStamp(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat.yMd(locale).format(DateTime.now());
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.3), width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: [
            Text(
              "DATE",
              style: ArtisanalTheme.note(fontSize: 8, color: ArtisanalTheme.redInk.withValues(alpha: 0.5)),
            ),
            Text(
              dateStr,
              style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.redInk.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryRow(int index, Animation<double> animation, {bool isRemoving = false, _ItemEntry? itemOverride}) {
    final l10n = AppLocalizations.of(context);
    final entry = itemOverride ?? _items[index];
    final recipes = ref.watch(recipeListProvider);

    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Selection
              Expanded(
                flex: 4,
                child: Autocomplete<Recipe>(
                  focusNode: entry.focusNode,
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
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: l10n.addProductHint,
                            hintStyle: TextStyle(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(bottom: 2),
                          ),
                          style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
                          onChanged: (val) {
                            entry.descriptionController.text = val;
                          },
                        ),
                        Container(height: 1, color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
                      ],
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 8,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 250, maxWidth: 220),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                dense: true,
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
                    width: 35,
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
                child: Column(
                  children: [
                    TextField(
                      controller: entry.amountController,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.priceHint,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 2),
                      ),
                      style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
                      onChanged: (_) => setState(() {}),
                    ),
                    Container(height: 1, color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
                  ],
                ),
              ),
    
              const SizedBox(width: 4),
    
              // Delete Row
              if (!isRemoving)
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, size: 22, color: ArtisanalTheme.redInk.withValues(alpha: 0.2)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _removeItem(index),
                )
              else
                const SizedBox(width: 40),
            ],
          ),
        ),
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
      child: AnimatedScale(
        scale: _isSaving ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
          decoration: BoxDecoration(
            color: _isPaid ? Colors.transparent : (widget.type == 'sale' ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.05),
            border: Border.all(
              color: _isPaid ? ArtisanalTheme.redInk : (widget.type == 'sale' ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                opacity: _isPaid ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  (widget.type == 'sale' ? l10n.paid : '지출 확인').toUpperCase(),
                  style: ArtisanalTheme.hand(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: widget.type == 'sale' ? ArtisanalTheme.primary : ArtisanalTheme.redInk,
                    letterSpacing: 2,
                  ),
                ),
              ),
              if (_isPaid)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 2.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.bounceOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: -0.15,
                        child: Text(
                          (widget.type == 'sale' ? l10n.paid : '지출 확인').toUpperCase(),
                          style: ArtisanalTheme.hand(
                            fontSize: 34, 
                            fontWeight: FontWeight.bold, 
                            color: ArtisanalTheme.redInk.withValues(alpha: 0.8),
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
