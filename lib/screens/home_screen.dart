import 'package:flutter/material.dart';
import 'package:my_atelier/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_atelier/screens/recipe_detail_screen.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeroSection(),
                  const SizedBox(height: 40),
                  _buildSearchBar(),
                  const SizedBox(height: 48),
                  _buildSectionHeader('최근 연구 기록', '전체보기'),
                  const SizedBox(height: 24),
                  _buildRecentCarousel(context),
                  const SizedBox(height: 48),
                  _buildSectionHeader('레시피 컬렉션', null),
                  const SizedBox(height: 24),
                  _buildCollectionsGrid(),
                  const SizedBox(height: 120), // Bottom padding for FAB and Nav
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
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBpDkT-uF1wOdJDr6OKlzcDtiHc2i1odN7juPdlXRHYk_R4qr7N0V-dvEQnZDP0HkE0QpFGHYb7hEaCOYO1GGB8au056deydRNNJYR0KIEc0ehH7gvGqvK7bqkMs9qE0DrZzQYpJvePmPo7D8aIODVCtq4ZlOMu6Ryj0XSyWdWzmtwGOwIxpfQxE05RHn1aOL3uWOG24YbwnyN_UCubgsoNYa-oK8mDXMCYMF1X6QgQuy8TlSgC2p-9VEPJtXHojkCDJ2qNYzuyyCM'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '더 아틀리에',
              style: GoogleFonts.notoSerif(
                fontStyle: FontStyle.italic,
                fontSize: 24,
                color: const Color(0xFF432818),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF432818)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '영감을 깨우는\n완벽한 레시피',
          style: GoogleFonts.notoSerif(
            fontSize: 44,
            height: 1.1,
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Text(
          '오늘은 어떤 빵을 구워볼까요?',
          style: GoogleFonts.manrope(
            fontSize: 18,
            color: const Color(0xFF4A3B32).withOpacity(0.8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '반죽, 필링, 테크닉 검색...',
                hintStyle: GoogleFonts.manrope(
                  color: AppColors.outlineVariant,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: GoogleFonts.manrope(fontSize: 14),
              maxLines: 1,
            ),
          ),
          const Icon(Icons.scale, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSerif(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  actionText.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentCarousel(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildRecipeCard(
            context,
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAG5M59sR2QxHWViT_9RVsqgbzw_7BfgNtrYGuON6_zweFBgT1AzYPVFht6qIdk4PC54stQ3xBGhXYfFCrUlFXvnpybhPEGoWdPD00_MCysuKubKLiTmAUEd4NaOL3KUfXKIDUQJ_EUvtVHuCSI40AAOlf-_Kuiqp_lA2iw8W3UtU8nVAHwW_-wR_OEK3rxoiI7bn3THOYYFV8x3E-lu4Jwiar3Py58sXYeCob9wQs-9_RMnVq_g316uyd60Mw17dzXyBfOZTuj2o8',
            '허니 버터 크로아상',
            '2시간 전 업데이트',
            isSignature: true,
          ),
          const SizedBox(width: 24),
          _buildRecipeCard(
            context,
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDllbnw96jDsqz1WAohJ2Wxkup4u5imOZIkhoNNlggGow_gHpdpVpoXrzdwiOXnoDLyC7EOPfaMxHa1QrZgR_2unUrUvIlFcqPL6ePL0vyQZ-bFJ6RcVf-1qWCkL24BF2x_qQejDLUlg1A9Q-3SuOSlhIMGyURdR826Lyb5o942-FWQfktbHsotLLd3EikMVCT_rXuVLRdul6BP0RAxCcUKWS6ppM4TtI4nRLVU3RRpImOeyeLNyBjDigLIQn4jU666fZeBrIMV-6M',
            '라벤더 마들렌',
            '5시간 전 업데이트',
            isSignature: true,
          ),
          const SizedBox(width: 24),
          _buildRecipeCard(
            context,
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDyx-s-5_bMiOPXczyE5MBVC8AeMUPDCSmSBsl2K9e40nluqNHFKYm2_c7fdArOEZ4is6cr5vXFQSNUWLAyhobGVDxolrj3nDxjaDJr2cUCa17itH1Jb_pAuVQShztKqA8Nf6I4E0JI8dS2AOBLhT9UDtITOKFRHqHKPTySAxPzGp9kaZZ_OLLiAqxW6xfaCLfG0ZeYnCutd8sy-Hsv7URYYJ1fWYJuL5DyNmOWvJItYmAS23DQdftWtxpTNl53ZYUp5wNFXgLGCvs',
            '헤리티지 사워도우',
            '어제 업데이트',
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, String imageUrl, String title, String time, {bool isSignature = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecipeDetailScreen()),
        );
      },
      child: Container(
        width: 280,
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isSignature)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          '#SIGNATURE',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildCollectionItem(Symbols.bakery_dining, '빵', isHighlighted: true),
        _buildCollectionItem(Symbols.cake, '케이크'),
        _buildCollectionItem(Symbols.cookie, '쿠키'),
        _buildCollectionItem(Symbols.pie_chart, '타르트'),
      ],
    );
  }

  Widget _buildCollectionItem(IconData icon, String label, {bool isHighlighted = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.secondaryContainer.withOpacity(0.4) : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isHighlighted ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
