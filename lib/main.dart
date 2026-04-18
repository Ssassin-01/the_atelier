import 'package:flutter/material.dart';
import 'theme/artisanal_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/recipe_archive_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/business_ledger_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyAtelierApp());
}

class MyAtelierApp extends StatelessWidget {
  const MyAtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Atelier',
      debugShowCheckedModeBanner: false,
      theme: ArtisanalTheme.lightTheme,
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardScreen(),
      const RecipeArchiveScreen(),
      AddRecipeScreen(onBack: () => _onItemTapped(0)),
      const BusinessLedgerScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true, // Allows the FAB to look better with the background
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: ArtisanalTheme.background.withValues(alpha: 0.9),
        elevation: 10,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.storefront_outlined, Icons.storefront, 'Atelier'),
              _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Vault'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(3, Icons.payments_outlined, Icons.payments, 'Ledger'),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 72,
        width: 72,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: _selectedIndex == 2 ? ArtisanalTheme.ink : ArtisanalTheme.primary,
          elevation: 4,
          shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 4)),
          child: const Icon(Icons.draw, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.secondary.withValues(alpha: 0.5),
          ),
          Text(
            label,
            style: ArtisanalTheme.hand(
              fontSize: 12,
              color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.secondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
