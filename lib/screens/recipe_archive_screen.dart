import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_index_card.dart';
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

    final filtered = recipes.where((r) {
      final matchesSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (r.description
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);

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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                child: _SearchBar(
                  hint: l10n.searchRecipes,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        return RecipeIndexCard(
                          recipe: recipe,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          ),
                          onDelete: () => ref.read(recipeListProvider.notifier).removeRecipe(recipe.id),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

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
