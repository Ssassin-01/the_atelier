import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/crumple_effect.dart';
import '../widgets/masking_tape.dart';
import '../l10n/app_localizations.dart';

class RecipeIndexCard extends StatefulWidget {
  final dynamic recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RecipeIndexCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<RecipeIndexCard> createState() => _RecipeIndexCardState();
}

class _RecipeIndexCardState extends State<RecipeIndexCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _crumpleController;

  @override
  void initState() {
    super.initState();
    _crumpleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _crumpleController.dispose();
    super.dispose();
  }

  void _triggerFeedback() {
    HapticFeedback.mediumImpact();
  }

  Future<void> _confirmDelete() async {
    _triggerFeedback();
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtisanalTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ), // Sharp artisanal style
        title: Text(
          l10n.deleteRecord.toUpperCase(),
          style: ArtisanalTheme.receipt(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: ArtisanalTheme.redInk,
          ),
        ),
        content: Text(
          l10n.currentLanguage == '한국어'
              ? '이 레시피 기록을 보관함에서 영구적으로 삭제하시겠습니까?'
              : "This will permanently remove this entry from your archive drawer.",
          style: ArtisanalTheme.hand(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel.toUpperCase(),
              style: ArtisanalTheme.receipt(
                color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.remove.toUpperCase(),
              style: ArtisanalTheme.receipt(
                color: ArtisanalTheme.redInk,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _crumpleController.forward();
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.recipe.createdAt as DateTime;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: _confirmDelete,
      child: CrumpleEffect(
        controller: _crumpleController,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              4,
            ), // More rectangular for index card feel
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: ArtisanalTheme.ink.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    child: ArtisanalImage(
                      imagePath: widget.recipe.mainImageUrl,
                      width: double.infinity,
                      height: 110, // Calibrated for shorter card
                      fit: BoxFit.contain,
                      backgroundColor: const Color(0xFFFDFCF7),
                    ),
                  ),
                  if (widget.recipe.isDraft)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Transform.rotate(
                        angle: -0.1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD32F2F).withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(context).crafting,
                            style: ArtisanalTheme.hand(
                              color: const Color(0xFFD32F2F).withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Positioned(
                    top: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: MaskingTape(width: 50, rotation: -0.05),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: ArtisanalTheme.hand(
                          fontSize: 16,
                          color: ArtisanalTheme.ink,
                        ).copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.recipe.description != null &&
                          (widget.recipe.description as String)
                              .isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.recipe.description,
                              style: ArtisanalTheme.hand(
                                fontSize: 12,
                                color: ArtisanalTheme.ink.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MetaItem(
                            icon: Icons.calendar_today_outlined,
                            label: dateStr,
                          ),
                          if (widget.recipe.sketchImageUrl != null)
                            const Icon(
                              Icons.edit_note_rounded,
                              size: 14,
                              color: ArtisanalTheme.primary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        Icon(
          icon,
          size: 13,
          color: ArtisanalTheme.secondary.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: ArtisanalTheme.hand(
            fontSize: 12,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
