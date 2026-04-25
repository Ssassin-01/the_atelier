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
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("DELETE ENTRY?", style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text("This will permanently remove this recipe from your collection.", style: ArtisanalTheme.hand(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("CANCEL", style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("REMOVE", style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk, fontWeight: FontWeight.bold, fontSize: 16)),
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: ArtisanalImage(
                      imagePath: widget.recipe.mainImageUrl,
                      width: 110,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    top: -6,
                    left: 20,
                    child: MaskingTape(
                        width: 56, rotation: -0.04),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: ArtisanalTheme.hand(
                          fontSize: 22,
                          color: ArtisanalTheme.ink,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (widget.recipe.description != null &&
                          (widget.recipe.description as String).isNotEmpty)
                        Text(
                          widget.recipe.description,
                          style: ArtisanalTheme.hand(
                            fontSize: 16,
                            color:
                                ArtisanalTheme.ink.withValues(alpha: 0.55),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 4,
                        children: [
                          _MetaItem(
                              icon: Icons.calendar_today_outlined,
                              label: dateStr),
                          _MetaItem(
                              icon: Icons.layers_outlined,
                              label:
                                  '${widget.recipe.components.length} components'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: ArtisanalTheme.outline.withValues(alpha: 0.6)),
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
