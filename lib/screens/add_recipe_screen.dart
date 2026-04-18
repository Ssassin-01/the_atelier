import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/sketch_area.dart';

class AddRecipeScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const AddRecipeScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'The Atelier Notebook',
          style: ArtisanalTheme.lightTheme.textTheme.headlineMedium,
        ),
        actions: [
          const Icon(Icons.cloudy_snowing, color: ArtisanalTheme.primary),
          const SizedBox(width: 16),
          _buildProfileCircle(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Recipe Name...',
                hintStyle: GoogleFonts.notoSerif(
                  fontSize: 40,
                  fontStyle: FontStyle.italic,
                  color: ArtisanalTheme.ink.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.notoSerif(
                fontSize: 40,
                fontStyle: FontStyle.italic,
                color: ArtisanalTheme.ink,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTag('Pastry'),
                const SizedBox(width: 8),
                _buildTag('Fall Menu'),
                const SizedBox(width: 8),
                _buildAddTag(),
              ],
            ),
            const SizedBox(height: 48),
            // Components
            Text(
              'Component 1: Pumpkin Cremeux',
              style: ArtisanalTheme.hand(fontSize: 28, color: ArtisanalTheme.ink),
            ),
            const SizedBox(height: 24),
            _buildIngredientRow('Heavy Cream (35%)', '250', 'g'),
            _buildIngredientRow('Pumpkin Purée (Roasted)', '150', 'g'),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Ingredient', style: ArtisanalTheme.lightTheme.textTheme.labelLarge),
              style: TextButton.styleFrom(foregroundColor: ArtisanalTheme.outline),
            ),
            const SizedBox(height: 48),
            // Sketch Area Title
            Row(
              children: [
                Text(
                  'Free-form Sketch Area',
                  style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 10,
                    color: ArtisanalTheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            // Sketch Canvas
            const SizedBox(
              height: 500,
              child: SketchArea(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCircle() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ArtisanalTheme.outline.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: ArtisanalTheme.outline.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDc9JqjapFkoKGOYCCWiurAC7_IPrzJJKad0FjjL8BF1wNzisG4Yv5O1U1ADRTyiXf0IWWhGqD7WRNHwJlhRqU0YkX5CfGtE0qLOVv6qC_n0oi498Fyyh-aJVcPP9vhBStFgT0YzRevPRknuyMOC1RD0UxVss5bApJQBeebeiVgnpSzstXLhy2wjLLb2z6QHQqNgayUvDMnvLQzFVJ7MnvQ4_Ok-LE6BH0B-X-SJYgmK7vVrvzvTaFnkm-LIdvxg5oYc6S4a8fhABo',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E7),
        border: Border.all(color: const Color(0xFFE2DCC8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell, size: 14, color: ArtisanalTheme.ink),
          const SizedBox(width: 4),
          Text(label, style: ArtisanalTheme.lightTheme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildAddTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: ArtisanalTheme.outline, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 14, color: ArtisanalTheme.outline),
          const SizedBox(width: 4),
          Text('Add Tag', style: ArtisanalTheme.lightTheme.textTheme.labelLarge),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(String name, String amount, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ArtisanalTheme.ink.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name, style: ArtisanalTheme.lightTheme.textTheme.bodyLarge)),
          SizedBox(
            width: 60,
            child: Text(amount, textAlign: TextAlign.right, style: ArtisanalTheme.lightTheme.textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(unit, textAlign: TextAlign.center, style: ArtisanalTheme.lightTheme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
