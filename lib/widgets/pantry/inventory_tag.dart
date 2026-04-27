import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
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

  Widget _buildIngredientImage(String name, String category) {
    String assetPath = 'assets/images/categories/others.png';
    final lowerName = name.toLowerCase();

    // Map specific ingredients to the updated realistic category assets
    if (lowerName.contains('flour') || lowerName.contains('밀가루') || lowerName.contains('강력') || lowerName.contains('박력')) {
      assetPath = 'assets/images/categories/flour.png';
    } else if (lowerName.contains('salt') || lowerName.contains('소금')) {
      assetPath = 'assets/images/categories/others.png'; // Now maps to realistic salt photo
    } else if (lowerName.contains('butter') || lowerName.contains('버터')) {
      assetPath = 'assets/images/categories/dairy_eggs.png'; // Now maps to realistic butter photo
    } else if (lowerName.contains('sugar') || lowerName.contains('설탕')) {
      assetPath = 'assets/images/categories/sweetener.png'; // Now maps to realistic sugar photo
    } else {
      // Fallback to category defaults which are now all realistic photos
      switch (category) {
        case 'Flour': assetPath = 'assets/images/categories/flour.png'; break;
        case 'Dairy/Eggs': assetPath = 'assets/images/categories/dairy_eggs.png'; break;
        case 'Sweetener': assetPath = 'assets/images/categories/sweetener.png'; break;
        case 'Leavening': assetPath = 'assets/images/categories/leavening.png'; break;
        case 'Add-in': assetPath = 'assets/images/categories/addin.png'; break;
        default: assetPath = 'assets/images/categories/others.png'; break;
      }
    }

    return Image.asset(assetPath, fit: BoxFit.cover);
  }

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
              color: const Color(0xFFFDFCFB),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Part - Looking like a Polaroid or pasted photo
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3F0),
                            image: DecorationImage(
                              image: const NetworkImage('https://www.transparenttextures.com/patterns/natural-paper.png'),
                              opacity: 0.05,
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Center(
                                  child: (item.imageUrl != null && 
                                          !item.imageUrl!.startsWith('assets/') && 
                                          File(item.imageUrl!).existsSync())
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.file(File(item.imageUrl!), fit: BoxFit.cover),
                                        )
                                      : Opacity(
                                          opacity: 0.8,
                                          child: _buildIngredientImage(item.name, item.category),
                                        ),
                                ),
                              ),
                              if (isLow)
                                Positioned(
                                  left: 8,
                                  top: 8,
                                  child: Transform.rotate(
                                    angle: -0.15,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ArtisanalTheme.redInk.withValues(alpha: 0.8),
                                      ),
                                      child: Text(
                                        l10n.urgent.toUpperCase(),
                                        style: ArtisanalTheme.hand(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Info Part
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.toUpperCase(),
                                style: ArtisanalTheme.hand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: ArtisanalTheme.ink,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                l10n.lastRestocked(DateFormat('MM.dd').format(item.lastUpdated)),
                                style: ArtisanalTheme.hand(
                                  fontSize: 9,
                                  color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${item.currentStock.toInt()}${item.unit == 'g' ? l10n.unitG : l10n.unitPcs}",
                                    style: ArtisanalTheme.hand(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    "/ ${item.targetQuantity.toInt()}",
                                    style: ArtisanalTheme.hand(
                                      fontSize: 11,
                                      color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
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
                    ],
                  ),
                  
                  // Action Button
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: onRestock,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.add_shopping_cart, 
                          color: ArtisanalTheme.ink.withValues(alpha: 0.3), size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Adding Masking Tape at the top to make it look "pasted"
        Positioned(
          top: -6,
          left: 0,
          right: 0,
          child: Center(
            child: MaskingTape(
              width: 50,
              rotation: (item.id.hashCode % 10 - 5) / 50, // Subtle random rotation
              color: const Color(0xFFE2DCC8).withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }
}

