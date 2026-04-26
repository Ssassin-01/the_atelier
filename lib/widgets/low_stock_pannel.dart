import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../models/pantry_item.dart';
import '../l10n/app_localizations.dart';

class LowStockPannel extends StatelessWidget {
  final List<PantryItem> items;

  const LowStockPannel({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lowStockItems = items.where((item) {
      final percent = item.targetQuantity > 0 
          ? (item.currentStock / item.targetQuantity) 
          : 0.0;
      return percent < 0.2;
    }).toList();

    if (lowStockItems.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArtisanalTheme.redInk.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: ArtisanalTheme.redInk, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.lowStockAlert,
                style: ArtisanalTheme.hand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ArtisanalTheme.redInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.restockNow,
            style: ArtisanalTheme.hand(
              fontSize: 14,
              color: ArtisanalTheme.redInk.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: lowStockItems.map((item) {
              final stockText = item.unit == 'pcs' 
                  ? "${item.currentStock.toInt()}pcs"
                  : "${(item.currentStock / 1000).toStringAsFixed(1)}kg";
                  
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: ArtisanalTheme.hand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.redInk,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stockText,
                      style: ArtisanalTheme.hand(
                        fontSize: 12,
                        color: ArtisanalTheme.redInk.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
