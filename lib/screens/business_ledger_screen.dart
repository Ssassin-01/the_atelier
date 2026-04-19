import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/polaroid_card.dart';
import '../providers/transaction_provider.dart';
import '../providers/pantry_provider.dart';
import '../models/transaction.dart';
import '../models/pantry_item.dart';
import 'pantry_management_screen.dart';

class BusinessLedgerScreen extends ConsumerWidget {
  const BusinessLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactions = ref.watch(transactionProvider);
    final pantryItems = ref.watch(pantryProvider);
    final txNotifier = ref.read(transactionProvider.notifier);

    final totalExpenses = txNotifier.getTotal('expense');
    final totalSales = txNotifier.getTotal('sale');

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: ArtisanalTheme.primary),
        title: Text(l10n.appTitle,
            style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                ?.copyWith(fontSize: 24, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1583394838336-acd977730f8a?q=80&w=100'),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.businessOperations,
              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: ArtisanalTheme.primary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildQuickAction(
                    context, ref, l10n.manageDatabase, Icons.storage, const Color(0xFF8C6F1D), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PantryManagementScreen()),
                      );
                    }),
                const SizedBox(width: 12),
                _buildQuickAction(
                    context, ref, "Add Sale", Icons.add_shopping_cart, ArtisanalTheme.primary, () {
                      _showTransactionDialog(context, ref);
                    }),
                const SizedBox(width: 12),
                _buildQuickAction(
                    context, ref, l10n.exportPdf, Icons.picture_as_pdf, const Color(0xFF8C6F1D), () {}),
              ],
            ),
            const SizedBox(height: 40),
            _buildSerratedLedgerCard(
                context, totalExpenses, totalSales, transactions, pantryItems),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, WidgetRef ref) {
    final txNotifier = ref.read(transactionProvider.notifier);
    
    String description = '';
    double amount = 0;
    String type = 'sale'; // Default to sale
    String category = 'Sales';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ArtisanalTheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Add Transaction", style: ArtisanalTheme.lightTheme.textTheme.displaySmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Sale"),
                      selected: type == 'sale',
                      onSelected: (val) => setState(() {
                        type = 'sale';
                        category = 'Product Sale';
                      }),
                      selectedColor: Colors.green.shade100,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Expense"),
                      selected: type == 'expense',
                      onSelected: (val) => setState(() {
                        type = 'expense';
                        category = 'Ingredients';
                      }),
                      selectedColor: Colors.red.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Amount",
                  suffixText: "₩",
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (description.isNotEmpty && amount > 0) {
                  txNotifier.addTransaction(BusinessTransaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    type: type,
                    amount: amount,
                    category: category,
                    description: description,
                  ));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ArtisanalTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, WidgetRef ref, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: ArtisanalTheme.background, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSerratedLedgerCard(
      BuildContext context,
      double totalExpenses,
      double totalSales,
      List<dynamic> transactions,
      List<dynamic> pantryItems) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);
    final monthName = DateFormat('MMMM').format(DateTime.now());

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 40,
                    offset: const Offset(0, 12))
              ],
            ),
            child: ClipPath(
              clipper: SerratedClipper(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
                child: Column(
                  children: [
                    // Receipt Header
                    Text(
                      l10n.ingredientLedger,
                      style: ArtisanalTheme.lightTheme.textTheme.labelLarge
                          ?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(totalExpenses),
                      style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(fontSize: 40, color: ArtisanalTheme.primary),
                    ),
                    Text(
                      '${l10n.totalMonthlySpend} ($monthName)',
                      style: ArtisanalTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.black38),
                    ),
                    const SizedBox(height: 32),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    // Pantry Status Section
                    _buildLedgerSectionTitle(context, "PANTRY STATUS", Icons.inventory_2_outlined),
                    const SizedBox(height: 16),
                    if (pantryItems.isEmpty)
                      Text("No items in pantry", style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black26))
                    else
                      ...pantryItems.take(3).map((item) => _buildVaultItem(
                          item.name, 
                          '${(item.currentStock / 1000).toStringAsFixed(1)}kg')),

                    const SizedBox(height: 32),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    // Disbursements
                    _buildLedgerSectionTitle(
                        context, l10n.recentDisbursements, null),
                    const SizedBox(height: 16),
                    if (transactions.isEmpty)
                      Text("No recent transactions", style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black26))
                    else
                      ...transactions.take(3).map((tx) => _buildDisbursementItem(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          tx.description,
                          currencyFormat.format(tx.amount),
                          tx.type == 'sale')),

                    const SizedBox(height: 48),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    // Barcode Section
                    _buildBarcode(),
                    const SizedBox(height: 8),
                    Text('00293 84729 11029',
                        style: ArtisanalTheme.hand(fontSize: 12, color: Colors.black38)
                            .copyWith(letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
        // The Tape
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: WashiTape(width: 80, rotation: -0.05)),
        ),
        // Red Marker Note
        Positioned(
          top: 50,
          right: 20,
          child: Transform.rotate(
            angle: -0.1,
            child: Text(
              l10n.review,
              style: ArtisanalTheme.hand(
                      fontSize: 20, color: const Color(0xFFBA1A1A))
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dottedDivider() {
    return Row(
      children: List.generate(
          30,
          (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 1,
                  color: index % 2 == 0 ? Colors.black12 : Colors.transparent,
                ),
              )),
    );
  }

  Widget _buildBarcode() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            40,
            (index) => Container(
                  width: (index % 3 == 0) ? 3 : 1,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 30,
                  color: index % 5 == 0 ? Colors.transparent : Colors.black87,
                )),
      ),
    );
  }

  Widget _buildLedgerSectionTitle(
      BuildContext context, String title, IconData? icon) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: ArtisanalTheme.secondary),
          const SizedBox(width: 8)
        ],
        Text(title,
            style: ArtisanalTheme.lightTheme.textTheme.displaySmall
                ?.copyWith(fontSize: 18, fontStyle: FontStyle.italic)),
        const Spacer(),
      ],
    );
  }

  Widget _buildVaultItem(String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: ArtisanalTheme.lightTheme.textTheme.bodyLarge
                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value,
              style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: ArtisanalTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildDisbursementItem(
      String date, String description, String amount, bool isSale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: ArtisanalTheme.lightTheme.textTheme.labelSmall
                        ?.copyWith(color: Colors.black26)),
                Text(description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtisanalTheme.lightTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isSale ? "+$amount" : "-$amount",
            style: ArtisanalTheme.hand(
                fontSize: 18,
                color: isSale ? Colors.green.shade800 : ArtisanalTheme.ink),
          ),
        ],
      ),
    );
  }
}
