import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';

class SummaryNoteScreen extends StatelessWidget {
  const SummaryNoteScreen({super.key});

  // The ink color used throughout
  static const Color _ink = Color(0xFF4A3B32);
  static const Color _redInk = Color(0xFFA03030);
  static const Color _lineColor = Color(0xFFE5E0D8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _ink),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: _JournalPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left leather binding
            Container(
              width: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFDAD6CF), Color(0xFFE8E4DC)],
                ),
                border: Border(
                  right: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: Stack(
                children: [
                  // Ruled lines as background
                  Positioned.fill(
                    child: CustomPaint(painter: _RuledLinePainter()),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 48, 40, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date & version top-right
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.summaryDate,
                                style: ArtisanalTheme.hand(
                                  fontSize: 20,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                              ),
                              Text(
                                l10n.summaryVersion,
                                style: ArtisanalTheme.hand(
                                  fontSize: 18,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Title - big handwriting, center, rotated
                        Center(
                          child: Transform.rotate(
                            angle: -0.018,
                            child: Text(
                              'Pumpkin Porridge Dessert',
                              textAlign: TextAlign.center,
                              style: ArtisanalTheme.hand(
                                fontSize: 58,
                                color: _SummaryNoteScreen._ink,
                              ).copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Underline below title
                        Center(
                          child: Container(
                            height: 1.5,
                            width: 220,
                            color: _SummaryNoteScreen._ink.withValues(alpha: 0.25),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Hero image
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Transform.rotate(
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
                                    border: Border.all(color: Colors.white, width: 8),
                                  ),
                                  child: SizedBox(
                                    width: 420,
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1541014741259-df549fa9ba6f?q=80&w=800',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: const Color(0xFFEAE6DF),
                                          child: const Icon(Icons.image, size: 48, color: Color(0xFFB0A9A0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -28,
                                right: 0,
                                child: Transform.rotate(
                                  angle: -0.04,
                                  child: Text(
                                    '* ${AppLocalizations.of(context).finalPlatingIdea}',
                                    style: ArtisanalTheme.hand(
                                      fontSize: 20,
                                      color: _SummaryNoteScreen._ink.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 64),

                        // Recipe components
                        _RecipeSection(
                          l10n: l10n,
                          number: '1.',
                          name: l10n.pumpkinCreamTitle,
                          ingredients: [
                            (l10n.ingredientRoastedPumpkin, '250g'),
                            (l10n.ingredientHeavyCream, '150g'),
                            (l10n.ingredientBrownSugar, '35g'),
                            (l10n.ingredientCinnamon, '1 pinch'),
                          ],
                          method: l10n.methodPumpkinCream,
                          redNote: l10n.noteOvermix,
                          methodContinue: '\n${l10n.methodChill}',
                        ),

                        const SizedBox(height: 48),

                        _RecipeSection(
                          l10n: l10n,
                          number: '2.',
                          name: l10n.mochiTitle,
                          ingredients: [
                            (l10n.ingredientGlutinousFlour, '100g'),
                            (l10n.ingredientWarmWater, '~80ml'),
                            (l10n.ingredientSugar, '10g'),
                          ],
                          method: l10n.methodMochi,
                        ),

                        const SizedBox(height: 48),

                        _RecipeSection(
                          l10n: l10n,
                          number: '3.',
                          name: l10n.seedTuileTitle,
                          ingredients: [
                            (l10n.ingredientButterMelted, '40g'),
                            (l10n.ingredientIcingSugar, '40g'),
                            (l10n.ingredientEggWhite, '40g'),
                            (l10n.ingredientFlour, '30g'),
                            (l10n.ingredientPumpkinSeeds, '50g'),
                          ],
                          method: l10n.methodSeedTuile,
                          redNote: l10n.noteShapeHot,
                        ),

                        const SizedBox(height: 48),

                        _RecipeSection(
                          l10n: l10n,
                          number: '4.',
                          name: l10n.riceCrumbleTitle,
                          ingredients: [
                            (l10n.ingredientRiceFlour, '50g'),
                            (l10n.ingredientAlmondFlour, '50g'),
                            (l10n.ingredientColdButter, '50g'),
                            (l10n.ingredientDemeraraSugar, '40g'),
                            (l10n.ingredientSalt, '1 pinch'),
                          ],
                          method: l10n.methodRiceCrumble,
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
}

// Ignore lint: this is an alias to keep the code concise inside the nested class
// ignore: camel_case_types
class _SummaryNoteScreen {
  static const Color _ink = Color(0xFF4A3B32);
}

class _RecipeSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String number;
  final String name;
  final List<(String, String)> ingredients;
  final String method;
  final String? redNote;
  final String? methodContinue;

  const _RecipeSection({
    required this.l10n,
    required this.number,
    required this.name,
    required this.ingredients,
    required this.method,
    this.redNote,
    this.methodContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          '$number $name',
          style: ArtisanalTheme.hand(
            fontSize: 38,
            color: SummaryNoteScreen._ink,
          ).copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Ingredients list (Top)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (item, qty) in ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: ArtisanalTheme.hand(fontSize: 21, color: SummaryNoteScreen._ink),
                      ),
                    ),
                    Text(
                      qty,
                      style: ArtisanalTheme.hand(fontSize: 21, color: SummaryNoteScreen._ink),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Method text (Bottom)
        RichText(
          text: TextSpan(
            style: ArtisanalTheme.hand(fontSize: 21, color: SummaryNoteScreen._ink).copyWith(height: 1.55),
            children: [
              TextSpan(text: method),
              if (redNote != null)
                TextSpan(
                  text: ' $redNote',
                  style: ArtisanalTheme.hand(fontSize: 21, color: SummaryNoteScreen._redInk).copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.55,
                  ),
                ),
              if (methodContinue != null)
                TextSpan(text: methodContinue),
            ],
          ),
        ),
      ],
    );
  }
}

class _RuledLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SummaryNoteScreen._lineColor
      ..strokeWidth = 1.0;

    double y = 33.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += 33.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
