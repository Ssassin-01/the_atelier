import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../services/recipe_service.dart';
import '../providers/dashboard_provider.dart';
import 'recipe_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _swayController;
  late PageController _quoteController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    // Set initial page to a large enough value for infinite scrolling both ways
    _quoteController = PageController(
      initialPage: 800 + (DateTime.now().day % 8),
    );
  }

  @override
  void dispose() {
    _swayController.dispose();
    _quoteController.dispose();
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
                              l10n.verified.toUpperCase(),
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
    final weekdays = [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun];
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
              l10n.deskHeader,
              style: ArtisanalTheme.lightTheme.textTheme.displayLarge
                  ?.copyWith(height: 1.1, fontSize: 32),
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
    final l10n = AppLocalizations.of(context);
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    final quotes = [
      (l10n.quote1, l10n.quote1Author),
      (l10n.quote2, l10n.quote2Author),
      (l10n.quote3, l10n.quote3Author),
      (l10n.quote4, l10n.quote4Author),
      (l10n.quote5, l10n.quote5Author),
      (l10n.quote6, l10n.quote6Author),
      (l10n.quote7, l10n.quote7Author),
      (l10n.quote8, l10n.quote8Author),
    ];

    final isQuote = dashboardState.isQuoteMode;
    
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: -0.012,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header & Mode Toggle ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      isQuote ? Icons.format_quote : Icons.edit_note,
                      size: 20,
                      color: ArtisanalTheme.primary.withValues(alpha: 0.3),
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        dashboardNotifier.toggleMode();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ArtisanalTheme.primary.withValues(alpha: 0.05),
                        ),
                        child: Icon(
                          isQuote ? Icons.person_outline : Icons.auto_stories_outlined,
                          size: 16,
                          color: ArtisanalTheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),

                if (isQuote)
                  // ── Quotes PageView ──────────────────────────────────────────
                  SizedBox(
                    height: 100, // Fixed height for quotes area
                    child: PageView.builder(
                      controller: _quoteController,
                      // itemCount is null for infinite scrolling
                      itemBuilder: (context, index) {
                        final q = quotes[index % quotes.length];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                q.$1,
                                style: ArtisanalTheme.hand(
                                  fontSize: 20,
                                  color: ArtisanalTheme.ink,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "- ${q.$2}",
                                style: ArtisanalTheme.hand(
                                  fontSize: 15,
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  // ── Resolution Display ──────────────────────────────────────
                  GestureDetector(
                    onTap: () => _showEditResolutionDialog(dashboardState.resolution),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dashboardState.resolution.isEmpty 
                              ? "나의 소중한 다짐을\n이곳에 기록해보세요." 
                              : dashboardState.resolution,
                          style: ArtisanalTheme.hand(
                            fontSize: 21,
                            color: ArtisanalTheme.ink,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () => _showEditResolutionDialog(dashboardState.resolution),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, size: 12, color: ArtisanalTheme.primary.withValues(alpha: 0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  "다짐 수정하기",
                                  style: ArtisanalTheme.hand(
                                    fontSize: 14,
                                    color: ArtisanalTheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (isQuote) ...[
                  const SizedBox(height: 8),
                  // ── Page Indicator Dots ─────────────────────────────────────
                  Center(
                    child: ListenableBuilder(
                      listenable: _quoteController,
                      builder: (context, _) {
                        final page = _quoteController.hasClients 
                            ? (_quoteController.page ?? 0).round() % quotes.length 
                            : DateTime.now().day % 8;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(quotes.length, (index) => 
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: page == index 
                                    ? ArtisanalTheme.primary.withValues(alpha: 0.5)
                                    : ArtisanalTheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
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

  void _showEditResolutionDialog(String currentResolution) {
    final controller = TextEditingController(text: currentResolution);
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // ── Paper Background ───────────────────────────────────────────────
            Transform.rotate(
              angle: 0.01,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9DB), // Post-it yellow
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(5, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "나의 다짐 기록",
                        style: ArtisanalTheme.hand(
                          fontSize: 28,
                          color: ArtisanalTheme.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                    // ── Clean Handwritten Input Field ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: controller,
                        maxLines: 4,
                        autofocus: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        cursorColor: ArtisanalTheme.primary,
                        style: ArtisanalTheme.hand(
                          fontSize: 22,
                          color: ArtisanalTheme.ink,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: "이곳에 오늘의 다짐을\n자유롭게 적어보세요...",
                          hintStyle: ArtisanalTheme.hand(
                            fontSize: 20,
                            color: ArtisanalTheme.primary.withValues(alpha: 0.25),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                      const SizedBox(height: 32),
                      
                      // ── Action Buttons ─────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "나중에",
                              style: ArtisanalTheme.hand(
                                fontSize: 18,
                                color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                ref.read(dashboardProvider.notifier).updateResolution(controller.text);
                                Navigator.pop(context);
                                HapticFeedback.mediumImpact();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ArtisanalTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              "기록하기",
                              style: ArtisanalTheme.hand(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // ── Decorative Washi Tape ──────────────────────────────────────────
            const Positioned(
              top: -15,
              child: WashiTape(
                width: 120,
                rotation: -0.02,
                opacity: 0.9,
              ),
            ),
          ],
        ),
      ),
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
