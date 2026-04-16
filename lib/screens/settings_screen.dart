import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_atelier/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildProfileSection(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('기본 설정'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSettingsItem(Symbols.language, '언어 설정', '한국어'),
                    _buildSettingsDivider(),
                    _buildSettingsItem(Symbols.dark_mode, '테마 모드', '라이트 모드'),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('비즈니스 및 작업'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSettingsItem(Symbols.payments, '통화 설정', 'KRW (₩)'),
                    _buildSettingsDivider(),
                    _buildSettingsItem(Symbols.straighten, '측정 단위', 'Metric (g, kg, L)'),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('데이터 및 보안'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSettingsItem(Symbols.cloud_sync, '클라우드 동기화', '활성화됨'),
                    _buildSettingsDivider(),
                    _buildSettingsItem(Symbols.download, '데이터 내보내기', 'PDF / CSV'),
                    _buildSettingsDivider(),
                    _buildSettingsItem(Symbols.delete_forever, '캐시 삭제', '42.5 MB', isDestructive: true),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader('정보'),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSettingsItem(Symbols.info, '앱 버전', 'v1.2.4'),
                    _buildSettingsDivider(),
                    _buildSettingsItem(Symbols.description, '이용 약관', ''),
                    _buildSettingsDivider(),
                    _buildSettingsItem(Symbols.policy, '개인정보 처리방침', ''),
                  ]),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        '로그아웃',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: false,
      title: Text(
        '설정',
        style: GoogleFonts.notoSerif(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAtSDm_Mq79HVNHM_FmFkCw0ws0N9pyeLUA5gsFKctOL9dfhUL5p9Cr1lgKFple6JpiTMw-PBE5qOf0OjWmKiY6iQpNG0zLfYJDzRMvQz7-Gc01AQQmX7bM96haFlRpKtgzrHqylEs9PMaaxmH1I4YejEBWQseiWcLGXIlRu7Q8p3N5WZsE3DGs7lEEvlLbCtXwj8P_96HpCczFDN4LB7ZwJGQpBVfvgvz2R-yDtPF1WSAJZFfeCNVbl5epRRAJSmP5txrkGVFaY70'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '김아틀리에',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'atelier.kim@myatelier.com',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.edit, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String trailingText, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? AppColors.error : AppColors.outline, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? AppColors.error : AppColors.onSurface,
              ),
            ),
          ),
          if (trailingText.isNotEmpty)
            Text(
              trailingText,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Symbols.chevron_right, color: AppColors.outlineVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsDivider() {
    return Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.05), indent: 58);
  }
}
