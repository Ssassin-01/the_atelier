import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/artisanal_theme.dart';
import '../../models/pantry_item.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom_clippers.dart';
import '../../widgets/masking_tape.dart';

class InventoryTag extends ConsumerWidget {
  final PantryItem item;
  final VoidCallback onRestock;
  
  const InventoryTag({
    super.key, 
    required this.item,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stockPercent = (item.currentStock / (item.targetQuantity > 0 ? item.targetQuantity : 1)).clamp(0.0, 1.0);
    final isLow = stockPercent < 0.2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: ClipPath(
            clipper: TornPaperClipper(intensity: 2.0, seed: item.id.hashCode),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              color: const Color(0xFFFDFCFB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name.toUpperCase(),
                          style: ArtisanalTheme.hand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ArtisanalTheme.ink,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isLow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: ArtisanalTheme.redInk.withValues(alpha: 0.8),
                          ),
                          child: Text(
                            l10n.urgent.toUpperCase(),
                            style: ArtisanalTheme.hand(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.category.toUpperCase(),
                    style: ArtisanalTheme.hand(
                      fontSize: 9,
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.lastRestocked(DateFormat('MM.dd').format(item.lastUpdated)),
                              style: ArtisanalTheme.hand(
                                fontSize: 8,
                                color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${item.currentStock.toInt()}${item.unit == 'g' ? l10n.unitG : l10n.unitPcs}",
                                    style: ArtisanalTheme.hand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    " / ${item.targetQuantity.toInt()}",
                                    style: ArtisanalTheme.hand(
                                      fontSize: 11,
                                      color: ArtisanalTheme.secondary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onRestock,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.add_shopping_cart, 
                            color: ArtisanalTheme.ink.withValues(alpha: 0.4), size: 16),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E0D8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: stockPercent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.primary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          left: 0,
          right: 0,
          child: Center(
            child: MaskingTape(
              width: 50,
              rotation: (item.id.hashCode % 10 - 5) / 50,
              color: const Color(0xFFE2DCC8).withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}
