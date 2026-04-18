import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/torn_edge_clipper.dart';
import '../widgets/masking_tape.dart';
import '../widgets/verified_stamp.dart';
import 'recipe_detail_screen.dart';

class RecipeArchiveScreen extends ConsumerStatefulWidget {
  const RecipeArchiveScreen({super.key});

  @override
  ConsumerState<RecipeArchiveScreen> createState() =>
      _RecipeArchiveScreenState();
}

class _RecipeArchiveScreenState extends ConsumerState<RecipeArchiveScreen> {
  String _searchQuery = '';
  String? _selectedCategory; // null = All

  final List<(String, String)> _categories = const [
    ('All', 'All'),
    ('Sourdough', 'Sourdough'),
    ('Desserts', 'Desserts'),
    ('Pastry', 'Pastry'),
    ('Cookies', 'Cookies'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);

    // ── Real filtering ───────────────────────────────────────────────────────
    final filtered = recipes.where((r) {
      final matchesSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (r.description
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);

      // Simple category mapping by recipe name keywords
      // (In a real app this would use a `category` field on the model)
      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == 'All' ||
          r.name.toLowerCase().contains(_selectedCategory!.toLowerCase()) ||
          (r.description
                  ?.toLowerCase()
                  .contains(_selectedCategory!.toLowerCase()) ??
              false);

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Slightly warmer paper color
      body: Stack(
        children: [
          // ── Ruled Paper Background ──
          Positioned.fill(
            child: CustomPaint(
              painter: _JournalBackgroundPainter(),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
          // ── Header (SliverAppBar) ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: ArtisanalTheme.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hand-drawn volume/chapter indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform.rotate(
                            angle: -0.05,
                            child: Text(
                              'VOL. II',
                              style: ArtisanalTheme.hand(
                                fontSize: 18,
                                color: ArtisanalTheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Text(
                            'Spring 2024',
                            style: ArtisanalTheme.hand(
                              fontSize: 16,
                              color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Main Title: "Table of Contents" / "Research Records"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            l10n.journal,
                            style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                                ?.copyWith(fontSize: 40, height: 1.0),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ArtisanalTheme.ink.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Baker\'s Research Log & Technical Archives',
                        style: ArtisanalTheme.hand(
                          fontSize: 18,
                          color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Search Bar ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
              child: _SearchBar(
                hint: l10n.searchRecipes,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // ── Category Filter Chips ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 0, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = (_selectedCategory == null &&
                            cat.$1 == 'All') ||
                        cat.$1 == _selectedCategory;
                    return _CategoryChip(
                      label: cat.$2,
                      isSelected: isSelected,
                      onTap: () => setState(() {
                        _selectedCategory =
                            cat.$1 == 'All' ? null : cat.$1;
                      }),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Entry count divider ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} ${filtered.length == 1 ? 'entry' : 'entries'}',
                    style: ArtisanalTheme.hand(
                      fontSize: 16,
                      color:
                          ArtisanalTheme.secondary.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Recipe Card List ──────────────────────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 52,
                            color: ArtisanalTheme.outline
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.emptyState,
                          style: ArtisanalTheme.hand(
                            fontSize: 20,
                            color: ArtisanalTheme.secondary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(28, 20, 28, 120),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      return _RecipeIndexCard(
                        recipe: recipe,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Journal Background Painter ───────────────────────────────────────────────
class _JournalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E2D8)
      ..strokeWidth = 1.0;

    const double lineSpacing = 32.0;
    // We start drawing from the top, providing a notebook look.
    for (double y = 60; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Left margin line
    final marginPaint = Paint()
      ..color = const Color(0xFFF2A4A4).withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    
    canvas.drawLine(const Offset(45, 0), Offset(45, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Search Bar ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCEC), // Sticky note color
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ArtisanalTheme.hand(
            fontSize: 18,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.35),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.search_rounded,
                color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
                size: 20),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ── Category Chip ──────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2D7D7) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? ArtisanalTheme.redInk.withValues(alpha: 0.3)
                : ArtisanalTheme.ink.withValues(alpha: 0.1),
            width: 1.0,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(1, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: ArtisanalTheme.hand(
            fontSize: 16,
            color: isSelected
                ? ArtisanalTheme.redInk
                : ArtisanalTheme.ink.withValues(alpha: 0.5),
          ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}

// ── Recipe Index Card ──────────────────────────────────────────────────────
class _RecipeIndexCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;

  const _RecipeIndexCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = recipe.createdAt as DateTime;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // ── Main Card (Torn Edge) ──
          TornEdgeContainer(
            padding: EdgeInsets.zero,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Thumbnail ──
                SizedBox(
                  width: 120,
                  child: ArtisanalImage(
                    imagePath: recipe.mainImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // ── Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: ArtisanalTheme.hand(
                            fontSize: 24,
                            color: ArtisanalTheme.ink,
                          ).copyWith(fontWeight: FontWeight.bold, height: 1.1),
                        ),
                        const SizedBox(height: 6),
                        if (recipe.description != null &&
                            (recipe.description as String).isNotEmpty)
                          Text(
                            recipe.description,
                            style: ArtisanalTheme.hand(
                              fontSize: 16,
                              color: ArtisanalTheme.ink.withValues(alpha: 0.55),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Spacer(),
                        // Dynamic "Snippet" - First few ingredients
                        if (recipe.components.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '• ${recipe.components[0].ingredients.take(2).map((i) => i.name).join(", ")}...',
                              style: ArtisanalTheme.note(
                                fontSize: 13,
                                color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        // Meta Info
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 11,
                                color: ArtisanalTheme.secondary
                                    .withValues(alpha: 0.3)),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: ArtisanalTheme.hand(
                                fontSize: 13,
                                color: ArtisanalTheme.secondary
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // ── Arrow ──
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Center(
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: ArtisanalTheme.outline.withValues(alpha: 0.4)),
                  ),
                ),
              ],
            ),
          ),

          // ── Masking Tape Decoration ──
          const Positioned(
            top: -12,
            child: MaskingTape(width: 70),
          ),

          // ── Verified Stamp (Optional based on some logic, let's say index % 3 == 0)
          Positioned(
            bottom: 12,
            right: 45,
            child: Opacity(
              opacity: 0.8,
              child: CircularVerifiedStamp(size: 60),
            ),
          ),
        ],
      ),
    );
  }
}
