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

      return matchesSearch;
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
              expandedHeight: 180,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: ArtisanalTheme.background,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.2,
                titlePadding: const EdgeInsets.only(left: 28, bottom: 20),
                title: Text(
                  l10n.myRecipes,
                  style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                    color: ArtisanalTheme.ink,
                  ),
                ),
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            l10n.rndArchive.toUpperCase(),
                            style: ArtisanalTheme.receipt(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: ArtisanalTheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Elegant Search Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                child: _SearchBar(
                  hint: l10n.searchRecipes,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? l10n.entry : l10n.entries}',
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
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 120),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.65, // More vertical space to prevent overflow
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = filtered[index];
                          return RecipeIndexCard(
                            recipe: recipe,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipe: recipe),
                              ),
                            ),
                            onDelete: () => ref.read(recipeListProvider.notifier).removeRecipe(recipe.id),
                          );
                        },
                        childCount: filtered.length,
                      ),
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
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2), // Sharp card style
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: ArtisanalTheme.ink.withValues(alpha: 0.08),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint.toUpperCase(),
          hintStyle: ArtisanalTheme.receipt(
            fontSize: 10,
            color: ArtisanalTheme.ink.withValues(alpha: 0.3),
            letterSpacing: 1.2,
          ),
          prefixIcon: const Icon(Icons.search, color: ArtisanalTheme.primary, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: ArtisanalTheme.hand(fontSize: 18),
      ),
    );
  }
}

