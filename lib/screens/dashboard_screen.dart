import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);
    final now = DateTime.now();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),

            // ── 1. Atelier Header: "공방에 출근한 느낌" ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: _buildAtelierHeader(l10n, now),
            ),

            const SizedBox(height: 40),

            // ── 2. Daily Memo: 와시테이프로 붙인 포스트잇 ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: _buildDailyMemo(),
            ),

            const SizedBox(height: 56),

            // ── 3. Recently Baked: 핵심 폴라로이드 섹션 ───────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Text(
                l10n.recentlyBaked,
                style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                    ?.copyWith(fontSize: 26),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 440,
              child: recipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera_back_outlined,
                              size: 56,
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
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.only(left: 28.0, right: 8.0),
                      itemCount:
                          recipes.length > 6 ? 6 : recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        // Slightly varying rotations and tape colors for a
                        // natural, hand-pinned look
                        final rotations = [0.03, -0.04, 0.05, -0.02, 0.04, -0.03];
                        final tapeColors = [
                          ArtisanalTheme.primary.withValues(alpha: 0.18),
                          ArtisanalTheme.secondary.withValues(alpha: 0.15),
                          const Color(0xFFA0522D).withValues(alpha: 0.20),
                          ArtisanalTheme.primary.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.08),
                          ArtisanalTheme.secondary.withValues(alpha: 0.18),
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(right: 28.0),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            ),
                            child: PolaroidCard(
                              rotation: rotations[index % rotations.length],
                              tapeColor: tapeColors[index % tapeColors.length],
                              title: recipe.name,
                              subtitle: recipe.description,
                              image: ArtisanalImage(
                                imagePath: recipe.mainImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildAtelierHeader(AppLocalizations l10n, DateTime now) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayOfWeek = weekdays[now.weekday - 1];
    final dateStr = '$dayOfWeek, ${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background "Journal No." label – slightly tilted, behind the title
        Positioned(
          top: -20,
          left: -4,
          child: Transform.rotate(
            angle: -0.06,
            child: Text(
              '${l10n.journalNo} 42',
              style: ArtisanalTheme.hand(
                fontSize: 22,
                color: ArtisanalTheme.primary.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              l10n.findPerfectRecipe,
              style: ArtisanalTheme.lightTheme.textTheme.displayLarge
                  ?.copyWith(height: 1.1),
            ),
            const SizedBox(height: 10),
            // Today's date – handwritten, understated
            Row(
              children: [
                const Icon(Icons.today_outlined,
                    size: 16, color: ArtisanalTheme.secondary),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: ArtisanalTheme.hand(
                    fontSize: 18,
                    color: ArtisanalTheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Daily Memo (washi-taped sticky note) ─────────────────────────────────
  Widget _buildDailyMemo() {
    // Fixed set of artisan notes that rotate – later this can be user-editable
    const notes = [
      '"Slow fermentation is the secret to a deep, soulful flavour."',
      '"Every loaf tells a story. Make yours worth reading."',
      '"Precision is the foundation. Soul is the secret ingredient."',
      '"The best recipes are written with patience and flour-dusted hands."',
    ];
    final note = notes[DateTime.now().day % notes.length];

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // Sticky-note paper
        Transform.rotate(
          angle: -0.012,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9DB), // warm cream-yellow
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(3, 4),
                ),
                // subtle right-edge curl shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(-2, 6),
                ),
              ],
            ),
            child: Text(
              note,
              style: ArtisanalTheme.hand(
                fontSize: 21,
                color: ArtisanalTheme.ink,
                height: 1.45,
              ),
            ),
          ),
        ),
        // Washi tape holding the note
        const Positioned(
          top: -14,
          child: WashiTape(width: 110, rotation: 0.018, opacity: 0.88),
        ),
      ],
    );
  }
}
