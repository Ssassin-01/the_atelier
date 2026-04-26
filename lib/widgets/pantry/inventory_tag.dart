import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../theme/artisanal_theme.dart';
import '../../models/pantry_item.dart';
import '../../l10n/app_localizations.dart';

class InventoryTag extends ConsumerWidget {
  final PantryItem item;
  final VoidCallback onRestock;
  
  const InventoryTag({
    super.key, 
    required this.item,
    required this.onRestock,
  });

  String _getCategoryImageAsset(String category) {
    switch (category) {
      case 'Flour':
        return 'assets/images/categories/flour.png';
      case 'Dairy/Eggs':
        return 'assets/images/categories/dairy_eggs.png';
      case 'Sweetener':
        return 'assets/images/categories/sweetener.png';
      case 'Leavening':
        return 'assets/images/categories/leavening.png';
      case 'Add-in':
        return 'assets/images/categories/addin.png';
      default:
        return 'assets/images/categories/others.png';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stockPercent = (item.currentStock / (item.targetQuantity > 0 ? item.targetQuantity : 1)).clamp(0.0, 1.0);
    final isLow = stockPercent < 0.2;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
        border: isLow ? Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.3), width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3F0),
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: item.imageUrl != null && File(item.imageUrl!).existsSync()
                        ? Image.file(
                            File(item.imageUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(_getCategoryImageAsset(item.category), fit: BoxFit.cover),
                          )
                        : Image.asset(_getCategoryImageAsset(item.category), fit: BoxFit.cover),
                  ),
                  
                  if (item.currentStock == 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                           color: Colors.white.withValues(alpha: 0.3),
                           borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: ArtisanalTheme.redInk, width: 2),
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.outOfStock.toUpperCase(),
                                style: ArtisanalTheme.hand(
                                  color: ArtisanalTheme.redInk,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Restock Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRestock,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ArtisanalTheme.ink.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                             BoxShadow(
                               color: Colors.black.withValues(alpha: 0.2),
                               blurRadius: 4,
                               offset: const Offset(0, 2),
                             ),
                          ],
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: ArtisanalTheme.hand(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "${item.currentStock.toInt()} / ${item.targetQuantity.toInt()} ${item.unit == 'g' ? l10n.unitG : l10n.unitPcs}",
                    style: ArtisanalTheme.hand(
                      fontSize: 9,
                      color: ArtisanalTheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: stockPercent,
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.primary,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.purchasePrice == 0 || item.targetQuantity == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        l10n.updateInfo.toUpperCase(),
                        style: ArtisanalTheme.hand(
                          color: ArtisanalTheme.redInk,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isLow)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        l10n.lowStock.toUpperCase(),
                        style: ArtisanalTheme.hand(
                          color: ArtisanalTheme.redInk,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
