import 'package:flutter/material.dart';
import 'package:my_atelier/theme/app_theme.dart';
import 'package:my_atelier/screens/home_screen.dart';
import 'package:my_atelier/screens/business_dashboard_screen.dart';
import 'package:my_atelier/screens/recipe_archive_screen.dart';
import 'package:my_atelier/screens/settings_screen.dart';
import 'package:my_atelier/widgets/sketch_pad.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  runApp(const MyAtelierApp());
}

class MyAtelierApp extends StatelessWidget {
  const MyAtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '나의 아틀리에',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BusinessDashboardScreen(),
    const RecipeArchiveScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea( // Ensuring space for system navigation bar/gestures
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Symbols.home, '홈', fill: true),
                _buildNavItem(1, Symbols.payments, '운영', fill: true),
                _buildNavItem(2, Symbols.menu_book, '레시피', fill: true),
                _buildNavItem(3, Symbols.settings, '설정', fill: true),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => SketchPad.show(context),
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool fill = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
