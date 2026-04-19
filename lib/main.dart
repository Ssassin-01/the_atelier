import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/artisanal_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/recipe_archive_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/business_ledger_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/locale_provider.dart';
import 'models/recipe.dart';
import 'models/component.dart';
import 'models/ingredient.dart';
import 'models/step.dart';
import 'services/mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(RecipeComponentAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(RecipeStepAdapter());
  
  // Open boxes
  final recipeBox = await Hive.openBox<Recipe>('recipes');
  
  // Clear and Populate with latest mock data for development visibility
  await recipeBox.clear();
  for (var recipe in getMockRecipes()) {
    await recipeBox.put(recipe.id, recipe);
  }
  
  runApp(
    const ProviderScope(
      child: MyAtelierApp(),
    ),
  );
}

class MyAtelierApp extends ConsumerWidget {
  const MyAtelierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: ArtisanalTheme.lightTheme,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
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

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: ArtisanalTheme.background.withValues(alpha: 0.95),
        elevation: 10,
        padding: EdgeInsets.zero, // Remove internal padding to maximize hit area
        child: SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill full height
            children: [
              Expanded(child: _buildNavItem(0, Icons.storefront_outlined, Icons.storefront, l10n.dashboard)),
              Expanded(child: _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, l10n.journal)),
              const SizedBox(width: 80), // Larger space for the draw FAB
              Expanded(child: _buildNavItem(3, Icons.payments_outlined, Icons.payments, l10n.pantry)),
              Expanded(child: _buildNavItem(4, Icons.person_outline, Icons.person, l10n.profile)),
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
          elevation: 6,
          shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 4)),
          child: const Icon(Icons.draw, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        splashColor: ArtisanalTheme.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.secondary.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: ArtisanalTheme.hand(
                fontSize: 13,
                color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.secondary.withValues(alpha: 0.6),
              ).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
