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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9DB), // Warm parchment yellow
        borderRadius: BorderRadius.circular(2), // Sharper edges for paper look
        border: Border.all(color: const Color(0xFFE8D7A5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined,
                  color: ArtisanalTheme.redInk, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.lowStockAlert.toUpperCase(),
                style: ArtisanalTheme.hand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: ArtisanalTheme.redInk,
                ),
              ),
              const Spacer(),
              const Icon(Icons.push_pin, size: 16, color: ArtisanalTheme.redInk),
            ],
          ),
          const SizedBox(height: 16),
          ...lowStockItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ArtisanalTheme.redInk,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: ArtisanalTheme.hand(
                      fontSize: 16,
                      color: ArtisanalTheme.ink.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Text(
                  item.unit == 'pcs' 
                      ? "${item.currentStock.toInt()}pcs"
                      : "${(item.currentStock / 1000).toStringAsFixed(1)}kg",
                  style: ArtisanalTheme.hand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ArtisanalTheme.redInk,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

