import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/crumple_effect.dart';
import '../widgets/masking_tape.dart';

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

class _RecipeIndexCardState extends State<RecipeIndexCard> with SingleTickerProviderStateMixin {
  late AnimationController _crumpleController;

  @override
  void initState() {
    super.initState();
    _crumpleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtisanalTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Sharp artisanal style
        title: Text("DELETE RECORD?", style: ArtisanalTheme.receipt(fontSize: 16, fontWeight: FontWeight.w900, color: ArtisanalTheme.redInk)),
        content: Text("This will permanently remove this entry from your archive drawer.", style: ArtisanalTheme.hand(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("CANCEL", style: ArtisanalTheme.receipt(color: ArtisanalTheme.ink.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("REMOVE", style: ArtisanalTheme.receipt(color: ArtisanalTheme.redInk, fontWeight: FontWeight.w900, fontSize: 12)),
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
            borderRadius: BorderRadius.circular(4), // More rectangular for index card feel
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
            border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
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
                      height: 120, // Reduced from 140
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    top: -8,
                    left: 20,
                    child: MaskingTape(
                        width: 60, rotation: -0.05),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible( // Wrapped in Flexible to prevent overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.recipe.name,
                              style: ArtisanalTheme.hand(
                                fontSize: 17, // Reduced from 18
                                color: ArtisanalTheme.ink,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (widget.recipe.description != null &&
                                (widget.recipe.description as String).isNotEmpty)
                              Text(
                                widget.recipe.description,
                                style: ArtisanalTheme.hand(
                                  fontSize: 12,
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.45),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MetaItem(
                              icon: Icons.calendar_today_outlined,
                              label: dateStr),
                          if (widget.recipe.sketchImageUrl != null)
                            const Icon(Icons.edit_note_rounded, size: 14, color: ArtisanalTheme.primary),
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
        Icon(icon,
            size: 13,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.45)),
        const SizedBox(width: 4),
        Text(
          label,
          style: ArtisanalTheme.hand(
            fontSize: 14,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
