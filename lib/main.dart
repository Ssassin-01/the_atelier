import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/pantry_item.dart';
import 'models/transaction.dart';
import 'theme/artisanal_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/business_ledger_screen.dart';
import 'screens/studio_log_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/pantry_shopping_screen.dart';
import 'screens/recipe_archive_screen.dart'; // Import the recipe archive for basic mode
import 'providers/locale_provider.dart';
import 'providers/settings_provider.dart';
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
  Hive.registerAdapter(PantryItemAdapter());
  Hive.registerAdapter(BusinessTransactionAdapter());

  try {
    // Open boxes
    Box<Recipe>? recipeBox;
    try {
      recipeBox = await Hive.openBox<Recipe>('recipes');
    } catch (e) {
      debugPrint("Recipe box corrupted, resetting: $e");
      await Hive.deleteBoxFromDisk('recipes');
      recipeBox = await Hive.openBox<Recipe>('recipes');
    }

    await Hive.openBox<PantryItem>('pantry');
    await Hive.openBox<BusinessTransaction>('transactions');
    await Hive.openBox('settings');

    // Populate with mock data only if boxes are empty
    if (recipeBox.isEmpty) {
      for (var recipe in getMockRecipes()) {
        await recipeBox.put(recipe.id, recipe);
      }
    }
  } catch (e) {
    debugPrint("Critical Hive initialization failed: $e");
  }

  runApp(const ProviderScope(child: MyAtelierApp()));
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
      supportedLocales: const [Locale('en'), Locale('ko')],
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final mode = settings.appMode;

    // Define screens based on mode
    List<Widget> allScreens;
    if (mode == 'basic') {
      allScreens = [
        const DashboardScreen(),
        const RecipeArchiveScreen(), // Classic recipe grid
        const PantryShoppingScreen(),
        const SettingsScreen(),
      ];
    } else if (mode == 'business') {
      allScreens = [
        const DashboardScreen(),
        const BusinessLedgerScreen(),
        const PantryShoppingScreen(),
        const SettingsScreen(),
      ];
    } else {
      // Creative mode
      allScreens = [
        const DashboardScreen(),
        const StudioLogScreen(),
        const PantryShoppingScreen(),
        const SettingsScreen(),
      ];
    }

    // Safety check for index out of bounds when switching modes
    if (_selectedIndex >= allScreens.length) {
      _selectedIndex = allScreens.length - 1;
    }

    final l10n = AppLocalizations.of(context);
    final isKo = l10n.currentLanguage == '한국어';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: ArtisanalTheme.background.withValues(alpha: 0.95),
        elevation: 10,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  isKo ? '홈' : l10n.dashboard,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  1,
                  _getSecondTabIcon(mode, false),
                  _getSecondTabIcon(mode, true),
                  _getSecondTabLabel(mode, l10n, isKo),
                ),
              ),
              const SizedBox(width: 80), // FAB space
              Expanded(
                child: _buildNavItem(
                  2,
                  Icons.shopping_basket_outlined,
                  Icons.shopping_basket,
                  isKo ? '장보기' : 'Shopping',
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  3,
                  Icons.settings_outlined,
                  Icons.settings,
                  isKo ? '설정' : l10n.settings,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 72,
        width: 72,
        child: FloatingActionButton(
          onPressed: () {
            _triggerFeedback();
            ref.invalidate(recipeDraftProvider);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddRecipeScreen(onBack: () => Navigator.pop(context)),
              ),
            );
          },
          backgroundColor: ArtisanalTheme.primary,
          elevation: 6,
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 4),
          ),
          child: const Icon(Icons.draw, color: Colors.white, size: 32),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: allScreens),
    );
  }

  IconData _getSecondTabIcon(String mode, bool active) {
    if (mode == 'basic') {
      return active ? Icons.menu_book : Icons.menu_book_outlined;
    } else if (mode == 'business') {
      return active ? Icons.receipt_long : Icons.receipt_long_outlined;
    } else {
      return active ? Icons.auto_awesome : Icons.auto_awesome_outlined;
    }
  }

  String _getSecondTabLabel(String mode, AppLocalizations l10n, bool isKo) {
    if (mode == 'basic') {
      return isKo ? '레시피' : 'Recipes';
    } else if (mode == 'business') {
      return l10n.businessOperations;
    } else {
      return l10n.studioLog;
    }
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
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
                color: isSelected
                    ? ArtisanalTheme.primary
                    : ArtisanalTheme.secondary.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style:
                  ArtisanalTheme.hand(
                    fontSize: 13,
                    color: isSelected
                        ? ArtisanalTheme.primary
                        : ArtisanalTheme.secondary.withValues(alpha: 0.6),
                  ).copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerFeedback() {
    HapticFeedback.lightImpact();
  }
}
