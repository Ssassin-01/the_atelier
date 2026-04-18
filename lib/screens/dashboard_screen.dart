import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);
    final now = DateTime.now();

    // ── LayoutBuilder gives us the EXACT viewport size ─────────────────────
    // The background is painted at this fixed size, completely independent
    // of the scroll view's content height.
    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final viewportHeight = constraints.maxHeight;

          return Stack(
            children: [
              // ── Layer 1: TRULY FIXED BACKGROUND ──────────────────────────
              // SizedBox pins this to the *viewport* size (not scroll content).
              // This widget will NEVER move regardless of scroll position.
              SizedBox(
                width: viewportWidth,
                height: viewportHeight,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: Size(viewportWidth, viewportHeight),
                    painter: _WorkbenchPainter(
                      viewportWidth: viewportWidth,
                      viewportHeight: viewportHeight,
                    ),
                  ),
                ),
              ),

              // ── Layer 2: SCROLLABLE CONTENT ──────────────────────────────
              CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 64)),

                  // 1. Atelier Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: _buildAtelierHeader(l10n, now),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // 2. Daily Memo (Swaying)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: AnimatedBuilder(
                        animation: _swayController,
                        builder: (context, child) {
                          final sway = math.sin(
                                  _swayController.value * math.pi * 2 + 0.5) *
                              0.008;
                          return Transform.rotate(angle: sway, child: child);
                        },
                        child: _buildDailyMemo(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 56)),

                  // 3. Recently Baked Label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Row(
                        children: [
                          Text(
                            l10n.recentlyBaked,
                            style: ArtisanalTheme.lightTheme.textTheme
                                .displayMedium
                                ?.copyWith(fontSize: 26),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: ArtisanalTheme.primary
                                      .withValues(alpha: 0.4)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "VERIFIED",
                              style: ArtisanalTheme.hand(
                                  fontSize: 10,
                                  color: ArtisanalTheme.primary
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // 4. Polaroid Cards
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 440,
                      child: recipes.isEmpty
                          ? _buildEmptyState(l10n)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              padding: const EdgeInsets.only(
                                  left: 28.0, right: 8.0),
                              itemCount:
                                  recipes.length > 6 ? 6 : recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                final baseRotation = [
                                  0.03,
                                  -0.04,
                                  0.05,
                                  -0.02,
                                  0.04,
                                  -0.03
                                ][index % 6];

                                return Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: AnimatedBuilder(
                                    animation: _swayController,
                                    builder: (context, child) {
                                      final sway = math.sin(
                                              _swayController.value *
                                                  math.pi *
                                                  2 +
                                              index) *
                                          0.012;
                                      return Transform.rotate(
                                          angle: sway, child: child);
                                    },
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RecipeDetailScreen(recipe: recipe),
                                        ),
                                      ),
                                      child: PolaroidCard(
                                        rotation: baseRotation,
                                        tapeColor: index % 2 == 0
                                            ? ArtisanalTheme.primary
                                                .withValues(alpha: 0.15)
                                            : Colors.black
                                                .withValues(alpha: 0.05),
                                        title: recipe.name,
                                        subtitle: recipe.description,
                                        image: ArtisanalImage(
                                          imagePath: recipe.mainImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_back_outlined,
              size: 56,
              color: ArtisanalTheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(l10n.emptyState,
              style: ArtisanalTheme.hand(
                  fontSize: 20,
                  color: ArtisanalTheme.secondary.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildAtelierHeader(AppLocalizations l10n, DateTime now) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dateStr =
        '${weekdays[now.weekday - 1]}, ${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -20,
          left: -4,
          child: Transform.rotate(
            angle: -0.06,
            child: Text(
              '${l10n.journalNo} 42',
              style: ArtisanalTheme.hand(
                  fontSize: 22,
                  color: ArtisanalTheme.primary.withValues(alpha: 0.5)),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              "From the Flour-dusted Desk",
              style: ArtisanalTheme.lightTheme.textTheme.displayLarge
                  ?.copyWith(height: 1.1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.today_outlined,
                    size: 16, color: ArtisanalTheme.secondary),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: ArtisanalTheme.hand(
                        fontSize: 18, color: ArtisanalTheme.secondary)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyMemo() {
    const notes = [
      '"Slow fermentation is the secret to a deep, soulful flavour."',
      '"Every loaf tells a story. Make yours worth reading."',
      '"The best flour is the one that still feels like life."',
      '"Warmth, patience, and time: the true artisan tools."',
    ];
    final note = notes[DateTime.now().day % notes.length];

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: -0.012,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9DB),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(4, 4)),
              ],
            ),
            child: Text(
              note,
              style: ArtisanalTheme.hand(
                  fontSize: 21, color: ArtisanalTheme.ink, height: 1.45),
            ),
          ),
        ),
        const Positioned(
          top: -14,
          child: WashiTape(width: 110, rotation: 0.018, opacity: 0.9),
        ),
      ],
    );
  }
}

// ── Workbench Background Painter ─────────────────────────────────────────────
class _WorkbenchPainter extends CustomPainter {
  final double viewportWidth;
  final double viewportHeight;

  const _WorkbenchPainter({
    required this.viewportWidth,
    required this.viewportHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background textures removed for now as requested.
  }

  @override
  bool shouldRepaint(_WorkbenchPainter old) =>
      old.viewportWidth != viewportWidth || old.viewportHeight != viewportHeight;
}
