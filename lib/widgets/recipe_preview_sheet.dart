import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../screens/add_recipe_screen.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/masking_tape.dart';

class RecipePreviewSheet extends StatelessWidget {
  final RecipeDraft draft;

  const RecipePreviewSheet({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F3F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: _JournalPagePreview(draft: draft),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: ArtisanalTheme.ink,
              elevation: 4,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalPagePreview extends StatelessWidget {
  final RecipeDraft draft;
  const _JournalPagePreview({required this.draft});

  @override
  Widget build(BuildContext context) {
    final title = draft.name.isEmpty ? "Untitled Recipe" : draft.name;

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
            // Left binder detail (Matches SummaryNoteScreen)
            Container(
              width: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFDAD6CF), Color(0xFFE8E4DC)],
                ),
              ),
            ),
            // Page content
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _RuledLinePainter()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Label (Mimics handwritten date)
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "DRAFT PREVIEW",
                            style: ArtisanalTheme.hand(
                              fontSize: 18,
                              color: Colors.black.withValues(alpha: 0.3),
                            ).copyWith(letterSpacing: 2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Center(
                          child: Transform.rotate(
                            angle: -0.015,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: ArtisanalTheme.hand(
                                fontSize: 48,
                                color: ArtisanalTheme.ink,
                              ).copyWith(fontWeight: FontWeight.bold, height: 1.1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Main Hero Photo with Polaroid styling
                        if (draft.mainImagePath != null)
                          Center(
                            child: Transform.rotate(
                              angle: 0.017,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6)),
                                  ],
                                  border: Border.all(color: Colors.white, width: 8),
                                ),
                                child: SizedBox(
                                  width: 380,
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: ArtisanalImage(
                                      imagePath: draft.mainImagePath!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 80),

                        // Draft Components
                        ...draft.components.map((comp) => _ComponentPreview(component: comp)),
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

class _ComponentPreview extends StatelessWidget {
  final RecipeComponentDraft component;
  const _ComponentPreview({required this.component});

  @override
  Widget build(BuildContext context) {
    const ink = ArtisanalTheme.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title + Optional Photo (Matches _RecipeSection in SummaryNoteScreen)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    component.title.isEmpty ? "COMPONENT" : component.title,
                    style: ArtisanalTheme.hand(fontSize: 28, color: ink).copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            if (component.imagePath != null && component.imagePath != 'placeholder') ...[
              const SizedBox(width: 16),
              Transform.rotate(
                angle: 0.05,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(2, 2)),
                        ],
                      ),
                      child: SizedBox(
                        width: 110,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ArtisanalImage(
                            imagePath: component.imagePath!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: -10,
                      child: MaskingTape(width: 60),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Ingredients & Steps
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredients
            ...component.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('• ${ing.name}',
                          style: ArtisanalTheme.hand(fontSize: 19, color: ink)),
                      const Spacer(),
                      Text("${ing.weight.toStringAsFixed(0)}g",
                          style: ArtisanalTheme.hand(fontSize: 19, color: ink)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            // Steps
            ...component.steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key + 1}. ',
                          style: ArtisanalTheme.hand(
                              fontSize: 18, color: ink.withValues(alpha: 0.6))),
                      Expanded(
                        child: Text(
                          entry.value.content,
                          style: ArtisanalTheme.hand(fontSize: 18, color: ink),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}

class _RuledLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E0D8)
      ..strokeWidth = 1.0;

    const double lineSpacing = 30.0;
    // Start lines after the initial header area
    for (double y = 140; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
