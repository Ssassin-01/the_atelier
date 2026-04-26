import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/masking_tape.dart';
import '../models/recipe.dart';
import '../models/component.dart';
import '../services/recipe_service.dart';
import 'package:intl/intl.dart';
import '../widgets/crumple_effect.dart';
import '../providers/recipe_cost_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_clippers.dart';
import 'add_recipe_screen.dart';

class SummaryNoteScreen extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const SummaryNoteScreen({super.key, this.recipe});

  @override
  ConsumerState<SummaryNoteScreen> createState() => _SummaryNoteScreenState();
}

class _SummaryNoteScreenState extends ConsumerState<SummaryNoteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _crumpleController;

  @override
  void initState() {
    super.initState();
    _crumpleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _crumpleController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteRecord.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text(l10n.removeMediaConfirm, style: ArtisanalTheme.hand(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _crumpleController.forward();
      if (mounted && widget.recipe != null) {
        await ref.read(recipeListProvider.notifier).removeRecipe(widget.recipe!.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _onEdit() {
    if (widget.recipe == null) return;
    
    // Map existing recipe to draft
    final draft = RecipeDraft(
      name: widget.recipe!.name,
      mainImagePath: widget.recipe!.mainImageUrl,
      components: widget.recipe!.components.map((c) => RecipeComponentDraft(
        id: DateTime.now().toString(),
        title: c.title,
        imagePath: c.imageUrl,
        ingredients: c.ingredients.map((i) => IngredientEntry(
          id: DateTime.now().toString(),
          name: i.name,
          weight: double.tryParse(i.amount) ?? 0.0,
          isFlour: i.isFlour,
        )).toList(),
        steps: c.steps.map((s) => RecipeStepDraft(
          id: DateTime.now().toString(),
          content: s.description,
        )).toList(),
      )).toList(),
    );

    // Seed the provider
    ref.read(recipeDraftProvider.notifier).state = draft;

    // Navigate to AddRecipeScreen in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecipeScreen(
          editingRecipeId: widget.recipe!.id,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
        ),
        actions: [
          if (widget.recipe != null) ...[
            TextButton(
              onPressed: _onEdit,
              child: Text(AppLocalizations.of(context).rename.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              onPressed: _confirmDelete,
              icon: Icon(Icons.delete_outline, color: ArtisanalTheme.redInk.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: CrumpleEffect(
                  controller: _crumpleController,
                  child: _JournalPage(recipe: widget.recipe),
                ),
              ),
              if (widget.recipe != null) ...[
                const SizedBox(height: 32),
                _BusinessInsightsCard(recipe: widget.recipe!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalPage extends StatelessWidget {
  final Recipe? recipe;
  const _JournalPage({this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final title = recipe?.name ?? (l10n.currentLanguage == '한국어' ? '이름 없는 연구' : 'Untitled Study');
    final mainImage = recipe?.mainImageUrl ?? 'assets/images/pumpkin_dessert.png';
    final components = recipe?.components ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 500, maxWidth: 700),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left leather binding
            _buildLeatherBinding(),
            // Page content
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _RuledLinePainter()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 48, 40, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            l10n.summaryDate,
                            style: ArtisanalTheme.hand(
                              fontSize: 18,
                              color: Colors.black.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Center(
                          child: Transform.rotate(
                            angle: -0.015,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: ArtisanalTheme.hand(fontSize: 48, color: ArtisanalTheme.ink).copyWith(fontWeight: FontWeight.bold, height: 1.1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Hero Image
                        Center(
                          child: Transform.rotate(
                            angle: 0.017,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
                                ],
                                border: Border.all(color: Colors.white, width: 8),
                              ),
                              child: SizedBox(
                                width: 380,
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: ArtisanalImage(imagePath: mainImage, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        
                        // Render Dynamic Components
                        ...components.map((comp) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _RecipeSection(component: comp),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeatherBinding() {
    return Container(
      width: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFDAD6CF), Color(0xFFE8E4DC)],
        ),
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  final RecipeComponent component;

  const _RecipeSection({
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    const ink = ArtisanalTheme.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title + Optional Photo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    component.title,
                    style: ArtisanalTheme.hand(fontSize: 28, color: ink).copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            if (component.imageUrl != null && component.imageUrl!.isNotEmpty) ...[
              const SizedBox(width: 16),
              Transform.rotate(
                angle: 0.05,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(2, 2)),
                        ],
                      ),
                      child: SizedBox(
                        width: 110,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ArtisanalImage(imagePath: component.imageUrl!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: -10,
                      child: MaskingTape(width: 60),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        
        // Body: Ingredients & Steps (Full Width)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredients
            ...() {
              final totalFlour = component.ingredients
                  .where((i) => i.isFlour)
                  .fold(0.0, (sum, i) => sum + (double.tryParse(i.amount) ?? 0));

              return component.ingredients.map((ing) {
                final weight = double.tryParse(ing.amount) ?? 0;
                final percentage =
                    totalFlour > 0 ? (weight / totalFlour) * 100 : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('• ${ing.name}',
                          style: ArtisanalTheme.hand(fontSize: 19, color: ink)),
                      if (totalFlour > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: ArtisanalTheme.hand(
                            fontSize: 15,
                            color: ink.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text('${ing.amount}${ing.unit}',
                          style: ArtisanalTheme.hand(fontSize: 19, color: ink)),
                    ],
                  ),
                );
              }).toList();
            }(),

            const SizedBox(height: 16),
            // Steps
            ...component.steps.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key + 1}. ', style: ArtisanalTheme.hand(fontSize: 18, color: ink.withValues(alpha: 0.6))),
                  Expanded(
                    child: Text(
                      entry.value.description, 
                      style: ArtisanalTheme.hand(fontSize: 18, color: ink, height: 1.4)
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ],
    );
  }
}

class _RuledLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E0D8)
      ..strokeWidth = 1.0;

    const double lineSpacing = 30.0;
    for (double y = 140; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BusinessInsightsCard extends ConsumerWidget {
  final Recipe recipe;
  const _BusinessInsightsCard({required this.recipe});

  Future<void> _logProduction(BuildContext context, WidgetRef ref, double cost) async {
    final l10n = AppLocalizations.of(context);
    
    // 1. Deduct Stock
    await ref.read(pantryProvider.notifier).deductStockByRecipe(recipe);
    
    // 2. Add Transaction
    await ref.read(transactionProvider.notifier).addProductionRecord(recipe.name, cost);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productionLogged),
          backgroundColor: ArtisanalTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costData = ref.watch(recipeCostProvider(recipe));
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);

    return Column(
      children: [
        const MaskingTape(width: 120),
        Transform.translate(
          offset: const Offset(0, -5),
          child: ClipPath(
            clipper: SerratedClipper(toothWidth: 15, toothHeight: 8, top: false),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFFFDFCFB),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      l10n.businessInsights.toUpperCase(),
                      style: ArtisanalTheme.hand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: ArtisanalTheme.ink.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now()),
                      style: ArtisanalTheme.hand(fontSize: 10, color: ArtisanalTheme.secondary),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _DottedDivider(),
                  ),
                  
                  if (costData.hasMissingItems)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: ArtisanalTheme.redInk, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.ingredientsMissingWarning,
                              style: ArtisanalTheme.hand(
                                fontSize: 10,
                                color: ArtisanalTheme.redInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildReceiptRow(
                    l10n.batchProductionCost,
                    currencyFormat.format(costData.totalCost),
                  ),
                  const SizedBox(height: 12),
                  _buildReceiptRow(
                    l10n.suggestedSalePrice,
                    currencyFormat.format(costData.suggestedPrice),
                    valueColor: ArtisanalTheme.primary,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _DottedDivider(),
                  ),
                  _buildReceiptRow(
                    l10n.estimatedProfit,
                    "+ ${currencyFormat.format(costData.estimatedProfit)}",
                    isTotal: true,
                    valueColor: Colors.green.shade700,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    l10n.marginsDisclaimer,
                    textAlign: TextAlign.center,
                    style: ArtisanalTheme.hand(
                      fontSize: 9,
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Log Production Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _logProduction(context, ref, costData.totalCost),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ArtisanalTheme.ink.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(
                        l10n.logProduction,
                        style: ArtisanalTheme.hand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ArtisanalTheme.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ArtisanalTheme.hand(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: ArtisanalTheme.ink,
          ),
        ),
        Text(
          value,
          style: ArtisanalTheme.hand(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? ArtisanalTheme.ink,
          ),
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: ArtisanalTheme.ink.withValues(alpha: 0.2)),
              ),
            );
          }),
        );
      },
    );
  }
}
