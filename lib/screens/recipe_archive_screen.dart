import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import 'package:my_atelier/models/recipe.dart';
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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      // Small delay to ensure keyboard starts appearing or layout stabilizes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            160.0, // Height of the SliverAppBar
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);

    // Stable sorting by date (newest first)
    final sortedRecipes = List<Recipe>.from(recipes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final filtered = sortedRecipes.where((r) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (r.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
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
            image: const NetworkImage(
              'https://www.transparenttextures.com/patterns/paper-fibers.png',
            ),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.05),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 125,
              floating: false,
              snap: false,
              pinned: false,
              backgroundColor: ArtisanalTheme.background,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leadingWidth: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ArtisanalTheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                border: Border.all(
                                  color: ArtisanalTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                l10n.rndArchive.toUpperCase(),
                                style: ArtisanalTheme.receipt(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: ArtisanalTheme.primary,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "VOL. ${DateTime.now().year}",
                              style: ArtisanalTheme.receipt(
                                  fontSize: 10,
                                  color: ArtisanalTheme.secondary.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.myRecipes,
                          style: ArtisanalTheme
                              .lightTheme
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 32,
                                color: ArtisanalTheme.ink,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pinned Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverSearchDelegate(
                topPadding: MediaQuery.of(context).padding.top,
                child: Container(
                  color: ArtisanalTheme.background,
                  padding: const EdgeInsets.fromLTRB(28, 6, 28, 12),
                  child: _SearchBar(
                    hint: l10n.searchRecipes,
                    focusNode: _searchFocusNode,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${filtered.length} ${filtered.length == 1 ? l10n.entry : l10n.entries}',
                        style: ArtisanalTheme.receipt(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ArtisanalTheme.secondary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ArtisanalTheme.ink.withValues(alpha: 0.1),
                              ArtisanalTheme.ink.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
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
                          Icon(
                            Icons.search_off,
                            size: 52,
                            color: ArtisanalTheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.emptyState,
                            style: ArtisanalTheme.hand(
                              fontSize: 20,
                              color: ArtisanalTheme.secondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            childAspectRatio:
                                0.70, // Updated ratio for more height space to prevent overflow
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final recipe = filtered[index];
                        return RecipeIndexCard(
                          key: ValueKey(recipe.id),
                          recipe: recipe,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          ),
                          onDelete: () => ref
                              .read(recipeListProvider.notifier)
                              .removeRecipe(recipe.id),
                        );
                      }, childCount: filtered.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double topPadding;

  _SliverSearchDelegate({required this.child, required this.topPadding});

  @override
  double get minExtent => 66 + topPadding;
  @override
  double get maxExtent => 66 + topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: ArtisanalTheme.background,
      padding: EdgeInsets.only(top: topPadding),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverSearchDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding || oldDelegate.child != child;
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  const _SearchBar({
    required this.hint,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ArtisanalTheme.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ArtisanalTheme.ink.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        focusNode: focusNode,
        cursorColor: ArtisanalTheme.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ArtisanalTheme.hand(
            fontSize: 16,
            color: ArtisanalTheme.ink.withValues(alpha: 0.25),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: ArtisanalTheme.primary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
      ),
    );
  }
}
