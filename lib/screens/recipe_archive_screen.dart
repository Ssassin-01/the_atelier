import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/polaroid_card.dart';
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
      body: CustomScrollView(
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
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stamp-like sub-label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: ArtisanalTheme.primary
                                  .withValues(alpha: 0.4),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.rndArchive.toUpperCase(),
                          style: ArtisanalTheme.hand(
                            fontSize: 14,
                            color: ArtisanalTheme.primary
                                .withValues(alpha: 0.6),
                          ).copyWith(letterSpacing: 1.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.myRecipes,
                        style: ArtisanalTheme.lightTheme.textTheme.displayMedium,
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
    );
  }
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                size: 22),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? ArtisanalTheme.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? ArtisanalTheme.ink
                : ArtisanalTheme.ink.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: ArtisanalTheme.hand(
            fontSize: 17,
            color: isSelected
                ? Colors.white
                : ArtisanalTheme.ink.withValues(alpha: 0.65),
          ),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail with washi tape ──────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: ArtisanalImage(
                    imagePath: recipe.mainImageUrl,
                    width: 110,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Mini washi tape detail at the top edge of the image
                const Positioned(
                  top: -6,
                  left: 20,
                  child: WashiTape(
                      width: 56, height: 13, rotation: -0.04, opacity: 0.75),
                ),
              ],
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: ArtisanalTheme.hand(
                        fontSize: 22,
                        color: ArtisanalTheme.ink,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (recipe.description != null &&
                        (recipe.description as String).isNotEmpty)
                      Text(
                        recipe.description,
                        style: ArtisanalTheme.hand(
                          fontSize: 16,
                          color:
                              ArtisanalTheme.ink.withValues(alpha: 0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    // Meta row
                    // Meta row - Using Wrap instead of Row to handle overflow gracefully
                    Wrap(
                      spacing: 14, // horizontal space between items
                      runSpacing: 4, // vertical space if wrapped
                      children: [
                        _MetaItem(
                            icon: Icons.calendar_today_outlined,
                            label: dateStr),
                        _MetaItem(
                            icon: Icons.layers_outlined,
                            label:
                                '${recipe.components.length} components'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Arrow ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: ArtisanalTheme.outline.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.45)),
        const SizedBox(width: 4),
        Text(
          label,
          style: ArtisanalTheme.hand(
            fontSize: 14,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
