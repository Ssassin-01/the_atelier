import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_atelier/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'recipe_detail_screen.dart';

class RecipeArchiveScreen extends StatelessWidget {
  const RecipeArchiveScreen({super.key});

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
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildFilterBar(),
                  const SizedBox(height: 32),
                  _buildRecipeList(context),
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
      backgroundColor: AppColors.background.withOpacity(0.8),
      elevation: 0,
      centerTitle: false,
      title: Text(
        'My Atelier',
        style: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: AppColors.primary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAtSDm_Mq79HVNHM_FmFkCw0ws0N9pyeLUA5gsFKctOL9dfhUL5p9Cr1lgKFple6JpiTMw-PBE5qOf0OjWmKiY6iQpNG0zLfYJDzRMvQz7-Gc01AQQmX7bM96haFlRpKtgzrHqylEs9PMaaxmH1I4YejEBWQseiWcLGXIlRu7Q8p3N5WZsE3DGs7lEEvlLbCtXwj8P_96HpCczFDN4LB7ZwJGQpBVfvgvz2R-yDtPF1WSAJZFfeCNVbl5epRRAJSmP5txrkGVFaY70'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'R&D 아카이브',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '마이 레시피',
              style: GoogleFonts.notoSerif(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              _buildViewBtn(Symbols.view_agenda, active: true),
              _buildViewBtn(Symbols.grid_view),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewBtn(IconData icon, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceContainerLowest : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
      ),
      child: Icon(icon, color: active ? AppColors.primary : AppColors.onSurfaceVariant, size: 20),
    );
  }

  Widget _buildFilterBar() {
    final tags = ['#비건', '#대량생산', '#저온발효', '#천연발효종', '#페이스트리'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: tags.map((tag) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: tag == '#비건' ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
              boxShadow: tag == '#비건' ? [
                BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
              ] : null,
            ),
            child: Text(
              tag,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tag == '#비건' ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context) {
    return Column(
      children: [
        _buildRecipeCard(
          context,
          '통밀 & 허니 사워도우',
          '80% 가수율, 12시간 저온 1차 발효',
          'Yield: 2 Loaves',
          '18 Hours',
          '68°F',
          Symbols.cloud,
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA4N3-ENyoXaCt-D-vZEB8npml3VjPqhZw5Pzo29Z_U-pCUUk4mqgD7qNS0Q3C24IYVVP5mB-R8sWyV0xKcbOd9lMPXbDAaBQpv-3OlV0JxFYJo69i45bsvy_a2FnEobgkiEN17tXccsU9W511RZMeJm4tRlIl5zGDynB9Z4dsssm7dKWMGEQ1PvZkIXaZ0mCE58wsFm6-qsJQPm_HxAXRVVgdh-HkhaZ2JLwlCTXIGkcJIuEp_WulfBq4lzZtV_CFWbJ0XtyCpe4c'
        ),
        const SizedBox(height: 20),
        _buildRecipeCard(
          context,
          '클래식 프랑스 바게트',
          '풀리시 기반, 스팀 분사 베이킹',
          'Yield: 4 Sticks',
          '5 Hours',
          '74°F',
          Symbols.light_mode,
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCzupx90INJjN48zVywnoIxPLc0hH6rr9g4uw4MNHVAJ-_SV8P2CYhqX4zxnHz_Z30KTTNnxEQlCiOsNopaEpCAa9RNQfLb45AK3zP9d6-tQiHy9csk_yjdoEQF0p_NLw6XzV7RTHQQCKyrxRriCZWZneLbg2vaUk_bGVgYDzmig3DlSgQEE6tvlTrD6bT3c0MX9UrQXi2j3afDDR7KcpEo-LNIXyB8pEBaMLEIbmDQzIRT81YE78JLd9q4tP_Ai9NNqmGzVG3fjR0'
        ),
        const SizedBox(height: 20),
        _buildRecipeCard(
          context,
          '로즈마리 올리브 오일 케이크',
          '시칠리아 냉압착 오일, 말돈 소금',
          'Yield: 10" Pan',
          '1.5 Hours',
          '65°F',
          Symbols.rainy,
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCAmACka-9TmWempQbOMDt-_aipB__ZWVrvxt_wo3VBxQKjk0dB6AOxwbcK3yP25-RJN8nFP3sJBBKQXVZMQmlL5A35LOiOigo9l-cpQJwGn7Sk1VKvixHhicxjUhsXS7tQJXO0TgOajFl6OnbGW1_Wi-OpaGqiTeRmPguFSqjXvmiQsHziA6ecNnClW0SRxazY0ejSu3Ebm3_lRml-HipMqAjLWLjKt5JJe4aCr-lDrI70yhbFm0NmhKbkK0cP8KOd8pBtsbxi1oU'
        ),
        const SizedBox(height: 20),
        _buildRecipeCard(
          context,
          '다크 초콜릿 칩 쿠키',
          '72% 카카오, 프랑스 고메 버터',
          'Yield: 24 Cookies',
          '2 Hours',
          '70°F',
          Symbols.partly_cloudy_day,
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCAlpRUbkPHGIyGaoyDSxXQEtcgmIKe0uPE4oe67oGemI-Rx3jIDH05Oamu90O1SV3q1dRbPHqhl7t6YcZdGoJcS6OcIEa580XuhCE2s5CdZINApayO2ekw8Oc-f8HKXogu28TgO4cYjQY9EuV3VXyFR5xx5pueIbztpEgC5mgEPnF6amhzzFWxYzHvWHh4398dBGPcDtRFuedRu9S1NQiwXI4XyJlO8UovA_sHSx7OEv6qDytlmJzS7JeI87EDfJIOBW0yyM9m46Y'
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, String title, String desc, String yield, String time, String temp, IconData tempIcon, String imgUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecipeDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: title,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.notoSerif(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(tempIcon, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              temp,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildIconLabel(Symbols.layers, yield),
                      const SizedBox(width: 16),
                      _buildIconLabel(Symbols.schedule, time),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
