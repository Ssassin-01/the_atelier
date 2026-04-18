import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/polaroid_card.dart';

class BusinessLedgerScreen extends StatelessWidget {
  const BusinessLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: ArtisanalTheme.primary),
        title: Text(l10n.appTitle, style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 24, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1583394838336-acd977730f8a?q=80&w=100'),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.businessOperations,
              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 20, fontStyle: FontStyle.italic, color: ArtisanalTheme.primary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildQuickAction(l10n.manageDatabase, Icons.storage, const Color(0xFF8C6F1D)),
                const SizedBox(width: 12),
                _buildQuickAction(l10n.cloudSync, Icons.cloud_sync, ArtisanalTheme.primary),
                const SizedBox(width: 12),
                _buildQuickAction(l10n.exportPdf, Icons.picture_as_pdf, const Color(0xFF8C6F1D)),
              ],
            ),
            const SizedBox(height: 40),
            _buildSerratedLedgerCard(context),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ArtisanalTheme.background, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSerratedLedgerCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 40, offset: const Offset(0, 12))],
            ),
            child: ClipPath(
              clipper: SerratedClipper(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
                child: Column(
                  children: [
                    // Receipt Header
                    Text(
                      l10n.ingredientLedger,
                      style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '€4,250.00',
                      style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 48, color: ArtisanalTheme.primary),
                    ),
                    Text(
                      '${l10n.totalMonthlySpend} (Oct)',
                      style: ArtisanalTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: Colors.black38),
                    ),
                    const SizedBox(height: 32),
                    _dottedDivider(),
                    const SizedBox(height: 24),
                    
                    // Vault Section
                    _buildLedgerSectionTitle(context, l10n.recipeVault, Icons.stars),
                    const SizedBox(height: 16),
                    _buildVaultItem('Sourdough Levain Base', '82%'),
                    _buildVaultItem('Laminated Croissant Dough', '76%'),
                    _buildVaultItem('Almond Frangipane', '64%'),
                    
                    const SizedBox(height: 32),
                    _dottedDivider(),
                    const SizedBox(height: 24),
                    
                    // Disbursements
                    _buildLedgerSectionTitle(context, l10n.recentDisbursements, null),
                    const SizedBox(height: 16),
                    _buildDisbursementItem('24 Oct 2023', 'Artisan Flour Mill', '€840.50'),
                    _buildDisbursementItem('22 Oct 2023', 'Normandy Butter Co.', '€1,120.00'),
                    _buildDisbursementItem('20 Oct 2023', 'Local Vanilla Extract', '€185.00'),
                    
                    const SizedBox(height: 48),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    // Barcode Section
                    _buildBarcode(),
                    const SizedBox(height: 8),
                    Text('00293 84729 11029', style: ArtisanalTheme.hand(fontSize: 12, color: Colors.black38).copyWith(letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
        // The Tape
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: WashiTape(width: 80, rotation: -0.05)),
        ),
        // Red Marker Note
        Positioned(
          top: 50,
          right: 20,
          child: Transform.rotate(
            angle: -0.1,
            child: Text(
              l10n.review,
              style: ArtisanalTheme.hand(fontSize: 20, color: const Color(0xFFBA1A1A)).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dottedDivider() {
    return Row(
      children: List.generate(30, (index) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 1,
          color: index % 2 == 0 ? Colors.black12 : Colors.transparent,
        ),
      )),
    );
  }

  Widget _buildBarcode() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(40, (index) => Container(
          width: (index % 3 == 0) ? 3 : 1,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          height: 30,
          color: index % 5 == 0 ? Colors.transparent : Colors.black87,
        )),
      ),
    );
  }

  Widget _buildLedgerSectionTitle(BuildContext context, String title, IconData? icon) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 14, color: ArtisanalTheme.secondary), const SizedBox(width: 8)],
        Text(title, style: ArtisanalTheme.lightTheme.textTheme.displaySmall?.copyWith(fontSize: 18, fontStyle: FontStyle.italic)),
        const Spacer(),
        if (title == l10n.recipeVault)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: ArtisanalTheme.background, borderRadius: BorderRadius.circular(12)),
            child: Text(l10n.highMargin, style: ArtisanalTheme.lightTheme.textTheme.labelSmall?.copyWith(fontSize: 10)),
          ),
      ],
    );
  }

  Widget _buildVaultItem(String name, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(percentage, style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: ArtisanalTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildDisbursementItem(String date, String vendor, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: ArtisanalTheme.lightTheme.textTheme.labelSmall?.copyWith(color: Colors.black26)),
              Text(vendor, style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Text(amount, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink)),
        ],
      ),
    );
  }
}
