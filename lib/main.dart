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
  Hive.registerAdapter(PantryItemAdapter());
  Hive.registerAdapter(BusinessTransactionAdapter());
  
  // Open boxes
  final recipeBox = await Hive.openBox<Recipe>('recipes');
  await Hive.openBox<PantryItem>('pantry');
  await Hive.openBox<BusinessTransaction>('transactions');
  await Hive.openBox('settings');
  
  // Populate with mock data only if the box is empty (first run)
  if (recipeBox.isEmpty) {
    for (var recipe in getMockRecipes()) {
      await recipeBox.put(recipe.id, recipe);
    }
  }
  
  final transactionBox = await Hive.openBox<BusinessTransaction>('transactions');
  if (transactionBox.isEmpty) {
    await transactionBox.putAll({
      'tx1': BusinessTransaction(
        id: 'tx1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'expense',
        amount: 840.50,
        category: 'Ingredients',
        description: 'Artisan Flour Mill - 200kg',
      ),
      'tx2': BusinessTransaction(
        id: 'tx2',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'expense',
        amount: 1120.00,
        category: 'Ingredients',
        description: 'Normandy Butter Co. - 50kg',
      ),
      'tx3': BusinessTransaction(
        id: 'tx3',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'sale',
        amount: 2500.00,
        category: 'Product Sale',
        description: 'Weekend Market Sales',
      ),
    });
  }

  final pantryBox = Hive.box<PantryItem>('pantry');
  if (pantryBox.isEmpty) {
    await pantryBox.putAll({
      'p1': PantryItem(
        id: 'p1',
        name: 'Organic Spelt Flour',
        purchasePrice: 45000,
        purchaseQuantity: 20000,
        unit: 'g',
        currentStock: 15000,
        lastUpdated: DateTime.now(),
        imageUrl: r'C:\Users\user b\.gemini\antigravity\brain\db180eb2-9cff-4fbc-b8f6-6387589caf05\pantry_flour_1776622828776.png',
      ),
      'p2': PantryItem(
        id: 'p2',
        name: 'Artisanal Bread Flour',
        purchasePrice: 38000,
        purchaseQuantity: 20000,
        unit: 'g',
        currentStock: 18000,
        lastUpdated: DateTime.now(),
        imageUrl: r'C:\Users\user b\.gemini\antigravity\brain\db180eb2-9cff-4fbc-b8f6-6387589caf05\pantry_flour_1776622828776.png', // Reuse flour image
      ),
      'p3': PantryItem(
        id: 'p3',
        name: 'Normandy Butter',
        purchasePrice: 112000,
        purchaseQuantity: 10000,
        unit: 'g',
        currentStock: 5000,
        lastUpdated: DateTime.now(),
        imageUrl: r'C:\Users\user b\.gemini\antigravity\brain\db180eb2-9cff-4fbc-b8f6-6387589caf05\pantry_butter_1776622843805.png',
      ),
      'p4': PantryItem(
        id: 'p4',
        name: 'Farm Fresh Eggs',
        purchasePrice: 8000,
        purchaseQuantity: 30,
        unit: 'pcs',
        currentStock: 12,
        lastUpdated: DateTime.now(),
        imageUrl: r'C:\Users\user b\.gemini\antigravity\brain\db180eb2-9cff-4fbc-b8f6-6387589caf05\pantry_eggs_1776622860038.png',
      ),
    });
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
              Expanded(child: _buildNavItem(2, Icons.payments_outlined, Icons.payments, l10n.pantry)),
              Expanded(child: _buildNavItem(3, Icons.person_outline, Icons.person, l10n.profile)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return SizedBox(
            height: 72,
            width: 72,
            child: FloatingActionButton(
              onPressed: () {
                _triggerFeedback();
                // Ensure fresh state for new recipe
                ref.invalidate(recipeDraftProvider);
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipeScreen(
                      onBack: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              backgroundColor: ArtisanalTheme.primary,
              elevation: 6,
              shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 4)),
              child: const Icon(Icons.draw, color: Colors.white, size: 32),
            ),
          );
        },
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

  void _triggerFeedback() {
    HapticFeedback.lightImpact();
  }
}
