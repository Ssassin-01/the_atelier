import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/custom_clippers.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ArtisanalTheme.background,
            floating: true,
            leading: const Icon(Icons.menu, color: ArtisanalTheme.ink),
            title: Text(
              l10n.atelierProfile,
              style: ArtisanalTheme.hand(fontSize: 28, color: ArtisanalTheme.ink)
                  .copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: ArtisanalTheme.ink, size: 26),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileHeader(l10n),
                const SizedBox(height: 32),
                _buildSettingsGroup(l10n.dataAndBusiness, [
                  _settingsItem(Icons.receipt_long, l10n.ingredientPriceDb),
                  _settingsItem(Icons.backup, l10n.cloudBackupSync),
                  _settingsItem(Icons.menu_book, l10n.exportAllRecipes),
                ]),
                const SizedBox(height: 28),
                _buildSettingsGroup(l10n.preferences, [
                  _settingsItem(Icons.notifications_active, l10n.notifications),
                  _settingsItem(Icons.lightbulb_outline, l10n.displayAndTheme),
                  _settingsItem(
                    Icons.language,
                    l10n.language,
                    trailer: l10n.currentLanguage,
                    onTap: () {
                      final activeLocale = Localizations.localeOf(context);
                      final newLocale = activeLocale.languageCode == 'en' ? const Locale('ko') : const Locale('en');
                      ref.read(localeProvider.notifier).state = newLocale;
                    },
                  ),
                ]),
                const SizedBox(height: 28),
                _buildSettingsGroup(l10n.information, [
                  _settingsItem(Icons.contact_support, l10n.helpAndSupport),
                  _settingsItem(Icons.local_police, l10n.termsAndPrivacy),
                  _settingsItemStatic(Icons.info_outline, l10n.appVersion, value: 'v1.0.0'),
                ]),
                const SizedBox(height: 48),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Transform.rotate(
                      angle: -0.035,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB33939), width: 2.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '[ ${l10n.logout.toUpperCase()} ]',
                          style: ArtisanalTheme.hand(
                            fontSize: 26,
                            color: const Color(0xFFB33939),
                          ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: ScallopedClipper(),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Transform.rotate(
                    angle: 0.017,
                    child: Container(
                      width: 120,
                      height: 130,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                        border: Border.all(
                          color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1583394838336-acd977730f8a?q=80&w=400',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        width: 90,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEE8D5).withValues(alpha: 0.75),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.atelierStudio,
                style: ArtisanalTheme.hand(fontSize: 34, color: ArtisanalTheme.ink)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'chef@atelier.com',
                style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink),
              ),
              const SizedBox(height: 16),
              Transform.rotate(
                angle: -0.035,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC69C6D), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.proPlan,
                    style: ArtisanalTheme.hand(
                      fontSize: 16,
                      color: const Color(0xFFC69C6D),
                    ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ArtisanalTheme.ink, width: 2),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 24, color: ArtisanalTheme.ink),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Container(height: 2, color: ArtisanalTheme.ink.withValues(alpha: 0.2), width: 120),
            ],
          ),
        ),
        ClipPath(
          clipper: ScallopedClipper(),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(IconData icon, String label, {String? trailer, VoidCallback? onTap}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: ArtisanalTheme.ink, size: 24),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      label,
                      style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.ink)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (trailer != null) ...[
                    Text(
                      trailer,
                      style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.secondary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '-->',
                    style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DashedDivider(),
        ),
      ],
    );
  }

  Widget _settingsItemStatic(IconData icon, String label, {String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: ArtisanalTheme.ink, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.ink),
            ),
          ),
          if (value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: ArtisanalTheme.ink.withValues(alpha: 0.05),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: ArtisanalTheme.ink,
                  letterSpacing: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArtisanalTheme.ink.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
