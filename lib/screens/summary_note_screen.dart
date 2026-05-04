import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/masking_tape.dart';
import '../models/recipe.dart';
import '../models/component.dart';
import '../services/recipe_service.dart';
import '../widgets/crumple_effect.dart';
import '../providers/settings_provider.dart';
import 'add_recipe_screen.dart';

class SummaryNoteScreen extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const SummaryNoteScreen({super.key, this.recipe});

  @override
  ConsumerState<SummaryNoteScreen> createState() => _SummaryNoteScreenState();
}

class _SummaryNoteScreenState extends ConsumerState<SummaryNoteScreen>
    with SingleTickerProviderStateMixin {
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
        backgroundColor: ArtisanalTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteRecord.toUpperCase(),
          style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.removeMediaConfirm,
          style: ArtisanalTheme.hand(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel.toUpperCase(),
              style: ArtisanalTheme.hand(
                color: ArtisanalTheme.secondary,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete.toUpperCase(),
              style: ArtisanalTheme.hand(
                color: ArtisanalTheme.redInk,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _crumpleController.forward();
      if (mounted && widget.recipe != null) {
        await ref
            .read(recipeListProvider.notifier)
            .removeRecipe(widget.recipe!.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _onEdit() {
    if (widget.recipe == null) return;

    // Map existing recipe to draft
    // Map existing recipe to draft using the centralized factory
    final draft = RecipeDraft.fromModel(widget.recipe!, ref.read(settingsProvider));

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
    // Watch for changes in the recipe list to ensure we have the latest data after editing
    final recipes = ref.watch(recipeListProvider);
    final currentRecipe = widget.recipe != null
        ? recipes.firstWhere(
            (r) => r.id == widget.recipe!.id,
            orElse: () => widget.recipe!,
          )
        : null;

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
        ),
        actions: [
          if (currentRecipe != null) ...[
            TextButton(
              onPressed: _onEdit,
              child: Text(
                AppLocalizations.of(context).rename.toUpperCase(),
                style: ArtisanalTheme.hand(
                  color: ArtisanalTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _confirmDelete,
              icon: Icon(
                Icons.delete_outline,
                color: ArtisanalTheme.redInk.withValues(alpha: 0.7),
              ),
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
                  child: _JournalPage(recipe: currentRecipe),
                ),
              ),
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

    final title =
        recipe?.name ??
        (l10n.currentLanguage == '한국어' ? '이름 없는 연구' : 'Untitled Study');
    final mainImage = recipe?.mainImageUrl;
    final components = recipe?.components ?? [];

    return Container(
      decoration: BoxDecoration(
        color: ArtisanalTheme.background,
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
                              style:
                                  ArtisanalTheme.hand(
                                    fontSize: 48,
                                    color: ArtisanalTheme.ink,
                                  ).copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                            ),
                          ),
                        ),
                        // Hero Image
                        Center(
                          child: Transform.rotate(
                            angle: 0.017,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 8,
                                ),
                              ),
                              child: SizedBox(
                                width: 380,
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: ArtisanalImage(
                                    imagePath: mainImage,
                                    recipeName: title,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Artisanal Notes (Moved below image)
                        if (recipe?.description != null &&
                            recipe!.description!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              recipe!.description!,
                              textAlign: TextAlign.justify,
                              style: ArtisanalTheme.hand(
                                fontSize: 18,
                                height: 1.8,
                                color: ArtisanalTheme.ink.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                        const SizedBox(height: 32),

                        // Render Dynamic Components
                        ...components.map(
                          (comp) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _RecipeSection(component: comp),
                          ),
                        ),
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

class _RecipeSection extends ConsumerWidget {
  final RecipeComponent component;

  const _RecipeSection({required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
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
                    style: ArtisanalTheme.hand(fontSize: 28, color: ink)
                        .copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
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
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 110,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ArtisanalImage(
                          imagePath: component.imageUrl,
                          recipeName: component.title,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(top: -10, child: MaskingTape(width: 60)),
                ],
              ),
            ),
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
                  .fold(
                    0.0,
                    (sum, i) => sum + (double.tryParse(i.amount) ?? 0),
                  );

              return component.ingredients.map((ing) {
                final weight = double.tryParse(ing.amount) ?? 0;
                final percentage = totalFlour > 0
                    ? (weight / totalFlour) * 100
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '• ${ing.name}',
                        style: ArtisanalTheme.hand(fontSize: 19, color: ink),
                      ),
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
                      Text(
                        settings.formatWeight(
                          double.tryParse(ing.amount) ?? 0,
                          ing.unit,
                        ),
                        style: ArtisanalTheme.hand(fontSize: 19, color: ink),
                      ),
                    ],
                  ),
                );
              }).toList();
            }(),

            const SizedBox(height: 16),
            // Steps
            ...component.steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: ArtisanalTheme.hand(
                        fontSize: 18,
                        color: ink.withValues(alpha: 0.6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.description,
                        style: ArtisanalTheme.hand(
                          fontSize: 18,
                          color: ink,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
