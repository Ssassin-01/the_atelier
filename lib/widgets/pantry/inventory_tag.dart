import 'package:flutter/material.dart';
import 'dart:io';
import '../../theme/artisanal_theme.dart';
import '../../models/pantry_item.dart';
import '../../l10n/app_localizations.dart';

class InventoryTag extends StatelessWidget {
  final PantryItem item;
  const InventoryTag({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stockPercent = (item.currentStock / (item.purchaseQuantity > 0 ? item.purchaseQuantity : 1)).clamp(0.0, 1.0);
    final isLow = stockPercent < 0.2;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFB),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
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
                border: Border.all(color: Colors.white, width: 6),
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
                  if (item.imageUrl != null && File(item.imageUrl!).existsSync())
                    Image.file(
                      File(item.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),
                  
                  if (item.currentStock == 0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.3),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: ArtisanalTheme.redInk, width: 3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.outOfStock.toUpperCase(),
                                style: ArtisanalTheme.hand(
                                  color: ArtisanalTheme.redInk,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: -10,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E0D8).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: ArtisanalTheme.hand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${item.currentStock.toInt()} / ${item.purchaseQuantity.toInt()} g",
                    style: ArtisanalTheme.hand(
                      fontSize: 10,
                      color: ArtisanalTheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: stockPercent,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.purchasePrice == 0 || item.purchaseQuantity == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 8, color: ArtisanalTheme.redInk),
                            const SizedBox(width: 4),
                            Text(
                              l10n.updateInfo.toUpperCase(),
                              style: ArtisanalTheme.hand(
                                color: ArtisanalTheme.redInk,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isLow)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        l10n.lowStock.toUpperCase(),
                        style: ArtisanalTheme.hand(
                          color: ArtisanalTheme.redInk,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFECEAE4),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_outlined,
          color: Colors.white.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}
