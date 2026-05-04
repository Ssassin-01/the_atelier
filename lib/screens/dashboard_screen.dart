import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/custom_clippers.dart';
import '../services/recipe_service.dart';
import '../providers/dashboard_provider.dart';
import '../providers/settings_provider.dart';
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
  late TextEditingController _resolutionController;
  late FocusNode _resolutionFocusNode;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _quoteController = PageController(
      initialPage: 800 + (DateTime.now().day % 8),
    );

    _resolutionController = TextEditingController();
    _resolutionFocusNode = FocusNode();
    
    // Auto-save on blur
    _resolutionFocusNode.addListener(() {
      if (!_resolutionFocusNode.hasFocus) {
        ref.read(dashboardProvider.notifier).updateResolution(_resolutionController.text);
      }
    });
  }

  @override
  void dispose() {
    _swayController.dispose();
    _quoteController.dispose();
    _resolutionController.dispose();
    _resolutionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);
    final now = DateTime.now();

    // Keep controller in sync with provider state (only when not editing)
    if (!_resolutionFocusNode.hasFocus) {
      final res = ref.read(dashboardProvider).resolution;
      if (_resolutionController.text != res) {
        _resolutionController.text = res;
      }
    }

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // ── LAYER 1: FIXED MASTER BACKGROUND (Wallpaper) ────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/images/wallpaper.png',
                  repeat: ImageRepeat.repeat,
                  opacity: const AlwaysStoppedAnimation(0.12),
                  fit: BoxFit.none,
                ),
              ),

              // ── LAYER 2: MASTER STAINS (Flour Dust) ─────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _WorkbenchStainsPainter(),
                ),
              ),

              // ── LAYER 3: SCROLLABLE WORKBENCH CONTENT ───────────────────────
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 64)),

                  // 1. Atelier Header (2D Stamp)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: _buildAtelierHeader(l10n, now),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // 2. Multi-layered Stacked Memo (In-place Edit)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: AnimatedBuilder(
                        animation: _swayController,
                        builder: (context, child) {
                          final sway = math.sin(_swayController.value * math.pi * 2 + 0.5) * 0.006;
                          return Transform.rotate(angle: sway, child: child);
                        },
                        child: _buildStackedMemoPad(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 56)),

                  // 3. Recently Baked Label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        l10n.recentlyBaked,
                        style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 26),
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
                              padding: const EdgeInsets.only(left: 28.0, right: 8.0),
                              itemCount: recipes.length > 6 ? 6 : recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                final baseRotation = [0.03, -0.04, 0.05, -0.02, 0.04, -0.03][index % 6];

                                return Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: AnimatedBuilder(
                                    animation: _swayController,
                                    builder: (context, child) {
                                      final sway = math.sin(_swayController.value * math.pi * 2 + index) * 0.01;
                                      return Transform.rotate(
                                        angle: sway,
                                        child: child,
                                      );
                                    },
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RecipeDetailScreen(recipe: recipe),
                                        ),
                                      ),
                                      child: PolaroidCard(
                                        rotation: baseRotation,
                                        tapeColor: index % 2 == 0
                                            ? ArtisanalTheme.primary.withValues(alpha: 0.15)
                                            : Colors.black.withValues(alpha: 0.05),
                                        title: recipe.name,
                                        subtitle: recipe.description,
                                        image: (recipe.mainImageUrl?.isEmpty ?? true) 
                                            ? null 
                                            : ArtisanalImage(
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

                  const SliverToBoxAdapter(child: SizedBox(height: 56)),

                  // 5. Atelier Signature
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_edu_outlined,
                            size: 32,
                            color: ArtisanalTheme.primary.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "My Atelier Journal",
                            style: ArtisanalTheme.hand(
                              fontSize: 18,
                              color: ArtisanalTheme.primary.withValues(alpha: 0.2),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "SINCE 2026",
                            style: ArtisanalTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              letterSpacing: 3.0,
                              color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
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
          Icon(
            Icons.photo_camera_back_outlined,
            size: 56,
            color: ArtisanalTheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyState,
            style: ArtisanalTheme.hand(
              fontSize: 20,
              color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtelierHeader(AppLocalizations l10n, DateTime now) {
    final weekdays = [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun];
    final dateStr = '${weekdays[now.weekday - 1]}, ${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10,
          left: -4,
          child: Transform.rotate(
            angle: -0.05,
            child: _build2DStampLabel(now.year.toString()),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              ref.watch(settingsProvider).atelierName,
              style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                height: 1.1,
                fontSize: 34,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.today_outlined, size: 16, color: ArtisanalTheme.secondary),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.secondary),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _build2DStampLabel(String year) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.journalNo.toUpperCase(),
            style: ArtisanalTheme.hand(
              fontSize: 12,
              letterSpacing: 1.0,
              color: ArtisanalTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            year,
            style: ArtisanalTheme.hand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ArtisanalTheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedMemoPad() {
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
        // ── 1. BOTTOM-MOST SHEET (Layer 1 - Straight & Neat) ──────────────
        Positioned(
          top: 9,
          left: 6,
          right: -4,
          bottom: -9,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD4C9A8),
              borderRadius: BorderRadius.circular(2), // Subtle corner roundness
            ),
          ),
        ),

        // ── 2. SECOND SHEET (Layer 2 - Straight & Neat) ───────────────────
        Positioned(
          top: 6,
          left: 4,
          right: -3,
          bottom: -6,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE5D9B6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // ── 3. THIRD SHEET (Layer 3 - Straight & Neat) ────────────────────
        Positioned(
          top: 3,
          left: 2,
          right: -1,
          bottom: -3,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2EAC7),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        // ── 4. TOP SHEET FACE (Active - Hand-torn Accent) ─────────────────
        ClipPath(
          clipper: TornPaperClipper(seed: 444, intensity: 5),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9DB), 
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      isQuote ? Icons.format_quote : Icons.edit_note,
                      size: 18,
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
                const SizedBox(height: 10),
                if (isQuote)
                  SizedBox(
                    height: 105,
                    child: PageView.builder(
                      controller: _quoteController,
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
                                  height: 1.35,
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
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(8, (i) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (index % 8 == i) 
                                    ? ArtisanalTheme.primary.withValues(alpha: 0.4)
                                    : ArtisanalTheme.primary.withValues(alpha: 0.1),
                                ),
                              )),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _resolutionController,
                        focusNode: _resolutionFocusNode,
                        maxLines: null,
                        minLines: 2,
                        cursorColor: ArtisanalTheme.primary.withValues(alpha: 0.3),
                        style: ArtisanalTheme.hand(
                          fontSize: 21,
                          color: ArtisanalTheme.ink,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: "오늘의 다짐을 이곳에...",
                          hintStyle: ArtisanalTheme.hand(
                            fontSize: 19,
                            color: ArtisanalTheme.primary.withValues(alpha: 0.15),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            if (_resolutionFocusNode.hasFocus) {
                              _resolutionFocusNode.unfocus();
                            } else {
                              _resolutionFocusNode.requestFocus();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 12, color: ArtisanalTheme.primary.withValues(alpha: 0.3)),
                              const SizedBox(width: 4),
                              Text(
                                _resolutionFocusNode.hasFocus ? "저장하기" : "다짐 수정하기",
                                style: ArtisanalTheme.hand(
                                  fontSize: 13,
                                  color: ArtisanalTheme.primary.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // ── 5. PUSH PINS ───────────────────────────────────────────────
        const Positioned(
          top: -10,
          left: 10,
          child: _PushPin(color: Color(0xFF43A047)),
        ),
        const Positioned(
          top: -10,
          right: 10,
          child: _PushPin(color: Color(0xFFE53935)),
        ),
      ],
    );
  }
}

class _PushPin extends StatelessWidget {
  final Color color;
  const _PushPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _PushPinPainter(color: color),
      ),
    );
  }
}

class _PushPinPainter extends CustomPainter {
  final Color color;
  _PushPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    canvas.drawCircle(
      center.translate(3, 4),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.7), color],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center.translate(-2, -2), radius: radius));

    canvas.drawCircle(center, radius, paint);

    canvas.drawCircle(
      center.translate(-3, -3),
      radius * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _WorkbenchStainsPainter extends CustomPainter {
  const _WorkbenchStainsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final flourPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 30.0 + random.nextDouble() * 100.0;
      canvas.drawCircle(Offset(x, y), radius, flourPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
