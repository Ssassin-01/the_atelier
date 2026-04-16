import 'package:flutter/material.dart';
import 'package:my_atelier/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '나의 아틀리에',
          style: GoogleFonts.notoSerif(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.primary), onPressed: () {}),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white.withOpacity(0.8),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2))),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC_ZR3bgRBpsbGUjIK7muHaLC9A8UmFke768zdLrCt0TfayvLI7B3C9nZgrTlRaiepOdAKhoXzlT0sZwxjB7UpNQ0lWgP18w20M5yaLk1Eo8RgaPXU3he_pHO33suL2U76-qkn5OA-PJNvb3NT3TFyFT6-F5BXD-ZvFlLW4FK41QDMt9MGd6a4J3MlKnfHUFvB6NS7xu6iToqHE15hhsoQzmFt1Rp2jAGBjgJYPmgRl1J24rdyIspWe-6_vQnxepwgqUPgH4wWmV9M',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '클래식 헤이즐넛 휘낭시에',
                            style: GoogleFonts.notoSerif(
                              fontSize: 28, // Reduced slightly to avoid wrap issues
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                _buildInfoTag(Icons.restaurant, '12개분'),
                                const SizedBox(width: 8),
                                _buildInfoTag(Icons.schedule, '45분'),
                                const SizedBox(width: 8),
                                _buildWeatherTag('22℃ / 60%'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.outline,
                  labelStyle: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  indicatorColor: AppColors.tertiaryFixedDim,
                  indicatorWeight: 4,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
                  tabs: const [
                    Tab(text: '레시피 재료'),
                    Tab(text: '베이킹 공정'),
                    Tab(text: '테스팅 노트'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildIngredientsTab(),
            _buildStepsTab(),
            _buildRDNoteTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny, size: 16, color: AppColors.onTertiaryFixed),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onTertiaryFixed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScaleCard(),
          const SizedBox(height: 24),
          _buildIngredientListHeader(),
          _buildIngredientItem('누아제트 버터', '150g', '100%'),
          _buildIngredientItem('헤이즐넛 파우더', '112g', '75%'),
          _buildIngredientItem('난백 (Egg Whites)', '180g', '120%'),
          _buildIngredientItem('분당 (Icing Sugar)', '165g', '110%'),
          _buildIngredientItem('박력분', '60g', '40%'),
          _buildIngredientItem('말돈 소금', '3g', '2%', isLast: true),
          const SizedBox(height: 48),
          _buildBeginButton(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScaleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '재료 배합 비율 설정',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '배합량 변경하기',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                _buildRoundButton(Icons.remove),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '1.5x',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
                _buildRoundButton(Icons.add),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _buildIngredientListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 6, child: _buildHeaderText('품목')),
          Expanded(flex: 3, child: _buildHeaderText('중량(g)', align: TextAlign.right)),
          Expanded(flex: 3, child: _buildHeaderText('비중(%)', align: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: AppColors.outline,
      ),
    );
  }

  Widget _buildIngredientItem(String name, String weight, String percent, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: AppColors.surfaceContainerHigh.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              name,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              weight,
              textAlign: TextAlign.right,
              style: GoogleFonts.notoSerif(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              percent,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.outline,
                fontFamily: 'Courier',
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeginButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 10,
        shadowColor: AppColors.primary.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline),
          const SizedBox(width: 12),
          Text(
            '베이킹 프로세스 시작',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
          _buildStepItem(1, '버터를 갈색이 날 때까지 가열하여 헤이즐넛 향이 나도록 태운 버터(beurre noisette)를 만듭니다.'),
          _buildStepItem(2, '데크 오븐을 목표 온도로 예열합니다.', extra: _buildTemperatureTag('190°C')),
          _buildStepItem(3, '15분 동안 굽습니다.', extra: _buildTimerButton('15분 타이머 시작'), isLast: true),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStepItem(int number, String content, {Widget? extra, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppColors.surfaceContainerHighest,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 16),
                    extra,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureTag(String temp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.thermostat, size: 14, color: AppColors.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            temp,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_arrow),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRDNoteTab() {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainerHighest),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '배치 #04 - 버터를 더 진하게 태워보는 실험 중. \n이 수분율에서 크럼 구조가 완벽함. \n설탕을 10g 줄이고 말돈 소금을 한 꼬집 추가함.',
                    style: GoogleFonts.homemadeApple(
                      fontSize: 20,
                      color: const Color(0xFF3D2B1F),
                      height: 2.0,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSketchPlaceholder(),
                      _buildPolaroidPhoto(),
                    ],
                  ),
                  const SizedBox(height: 64),
                  Text(
                    '헤이즐넛은 갓 갈아서 사용할 때 향이 훨씬 진함. \n다음번에는 150°C에서 더 오래 구워볼 것.',
                    style: GoogleFonts.homemadeApple(
                      fontSize: 20,
                      color: const Color(0xFF3D2B1F),
                      height: 2.0,
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(child: _buildDrawingToolbar()),
          ),
        ],
      ),
    );
  }

  Widget _buildSketchPlaceholder() {
    return Transform.rotate(
      angle: 0.02,
      child: Container(
        width: 160,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '단면 스케치',
            style: GoogleFonts.homemadeApple(
              fontSize: 14,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolaroidPhoto() {
    return Transform.rotate(
      angle: 0.05,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.surfaceContainerHigh),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              color: AppColors.surfaceContainerLow,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDirSMpV-Y88g0tADVlMNYujbY8ZdZldRsTX95fWohZXdIkcqWk1gG1KMKOO2OOZMIyBpqcGkSYDHXY6sVaGBCV8hWr5WO0kdp9ZHIpmJuBF7KsT-YS3MaWxKYspFclSGk-gavICs6b4d36ope59VEyEVNV3pW_mTHNHcaSWXgf3OKXgPcT7kxC9X9hooKpirSyBjSzKvCpvymZvF_by7QhHzLDKO2hYEj9p9ol0Vh7Grps_K4O3T8Uh9xFtnHS4Hrs3u0YHDO_X6M',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '크러스트 텍스처 완성도',
              style: GoogleFonts.homemadeApple(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF321300),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolBtn(Symbols.undo),
          _buildToolBtn(Symbols.edit, active: true),
          _buildToolBtn(Symbols.ink_eraser),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: Colors.white24),
          const SizedBox(width: 12),
          _buildColorDot(const Color(0xFF3D2B1F), active: true),
          _buildColorDot(AppColors.error),
          _buildColorDot(AppColors.tertiaryFixedDim),
          _buildColorDot(Colors.white),
        ],
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.tertiaryFixed : Colors.white60),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(color: AppColors.tertiaryFixed, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: active ? Border.all(color: Colors.white, width: 2) : null,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea( // Added SafeArea to prevent system bar overlap
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Symbols.home, '아틀리에'),
              _buildBottomNavItem(Symbols.menu_book, '레시피', active: true),
              _buildBottomNavItem(Symbols.science, 'R&D'),
              _buildBottomNavItem(Symbols.auto_stories, '저널'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, {bool active = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? AppColors.primary : AppColors.primary.withOpacity(0.4)),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: active ? AppColors.primary : AppColors.primary.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
