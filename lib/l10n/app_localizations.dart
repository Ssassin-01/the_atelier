import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'The Atelier'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @pantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantry;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @atelierProfile.
  ///
  /// In en, this message translates to:
  /// **'Atelier Profile'**
  String get atelierProfile;

  /// No description provided for @atelierStudio.
  ///
  /// In en, this message translates to:
  /// **'Atelier Studio'**
  String get atelierStudio;

  /// No description provided for @proPlan.
  ///
  /// In en, this message translates to:
  /// **'PRO PLAN'**
  String get proPlan;

  /// No description provided for @dataAndBusiness.
  ///
  /// In en, this message translates to:
  /// **'Data & Business'**
  String get dataAndBusiness;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get currentLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @findPerfectRecipe.
  ///
  /// In en, this message translates to:
  /// **'Find your\nperfect recipe'**
  String get findPerfectRecipe;

  /// No description provided for @whatAreWeBaking.
  ///
  /// In en, this message translates to:
  /// **'What are we baking today?'**
  String get whatAreWeBaking;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search doughs, techniques...'**
  String get searchHint;

  /// No description provided for @recentRnD.
  ///
  /// In en, this message translates to:
  /// **'Recent R&D'**
  String get recentRnD;

  /// No description provided for @viewLab.
  ///
  /// In en, this message translates to:
  /// **'View Lab'**
  String get viewLab;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @breads.
  ///
  /// In en, this message translates to:
  /// **'Breads'**
  String get breads;

  /// No description provided for @cakes.
  ///
  /// In en, this message translates to:
  /// **'Cakes'**
  String get cakes;

  /// No description provided for @cookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get cookies;

  /// No description provided for @tarts.
  ///
  /// In en, this message translates to:
  /// **'Tarts'**
  String get tarts;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Vol.'**
  String get volume;

  /// No description provided for @rndArchive.
  ///
  /// In en, this message translates to:
  /// **'R&D Archive'**
  String get rndArchive;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @atelierNotebook.
  ///
  /// In en, this message translates to:
  /// **'The Atelier Notebook'**
  String get atelierNotebook;

  /// No description provided for @recipeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Recipe Name...'**
  String get recipeNameHint;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// No description provided for @freeformSketch.
  ///
  /// In en, this message translates to:
  /// **'Free-form Sketch Area'**
  String get freeformSketch;

  /// No description provided for @businessOperations.
  ///
  /// In en, this message translates to:
  /// **'Business & Operations'**
  String get businessOperations;

  /// No description provided for @manageDatabase.
  ///
  /// In en, this message translates to:
  /// **'Manage\nDatabase'**
  String get manageDatabase;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud\nSync'**
  String get cloudSync;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export\nPDF'**
  String get exportPdf;

  /// No description provided for @ingredientLedger.
  ///
  /// In en, this message translates to:
  /// **'INGREDIENT LEDGER'**
  String get ingredientLedger;

  /// No description provided for @totalMonthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Spend'**
  String get totalMonthlySpend;

  /// No description provided for @recipeVault.
  ///
  /// In en, this message translates to:
  /// **'Recipe Vault'**
  String get recipeVault;

  /// No description provided for @recentDisbursements.
  ///
  /// In en, this message translates to:
  /// **'Recent Disbursements'**
  String get recentDisbursements;

  /// No description provided for @highMargin.
  ///
  /// In en, this message translates to:
  /// **'High Margin'**
  String get highMargin;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review!'**
  String get review;

  /// No description provided for @ingredientPriceDb.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Price DB'**
  String get ingredientPriceDb;

  /// No description provided for @cloudBackupSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup & Sync'**
  String get cloudBackupSync;

  /// No description provided for @exportAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'Export All Recipes'**
  String get exportAllRecipes;

  /// No description provided for @displayAndTheme.
  ///
  /// In en, this message translates to:
  /// **'Display & Theme'**
  String get displayAndTheme;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsAndPrivacy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @autumnMenu24.
  ///
  /// In en, this message translates to:
  /// **'Autumn Menu \'24'**
  String get autumnMenu24;

  /// No description provided for @openJournalSummary.
  ///
  /// In en, this message translates to:
  /// **'Open Journal Summary'**
  String get openJournalSummary;

  /// No description provided for @jumpToProcedure.
  ///
  /// In en, this message translates to:
  /// **'Jump to Procedure'**
  String get jumpToProcedure;

  /// No description provided for @finalPlatingIdea.
  ///
  /// In en, this message translates to:
  /// **'final plating idea'**
  String get finalPlatingIdea;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pumpkinPuree.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin Puree'**
  String get pumpkinPuree;

  /// No description provided for @miniRiceBalls.
  ///
  /// In en, this message translates to:
  /// **'Mini Rice Balls'**
  String get miniRiceBalls;

  /// No description provided for @seedTuile.
  ///
  /// In en, this message translates to:
  /// **'Seed Tuile'**
  String get seedTuile;

  /// No description provided for @speltHoneySourdough.
  ///
  /// In en, this message translates to:
  /// **'Spelt & Honey Sourdough'**
  String get speltHoneySourdough;

  /// No description provided for @speltHoneyDesc.
  ///
  /// In en, this message translates to:
  /// **'80% Hydration, 12hr cold bulk ferment'**
  String get speltHoneyDesc;

  /// No description provided for @classicFrenchBaguette.
  ///
  /// In en, this message translates to:
  /// **'Classic French Baguette'**
  String get classicFrenchBaguette;

  /// No description provided for @classicFrenchBaguetteDesc.
  ///
  /// In en, this message translates to:
  /// **'Poolish based, steam injected bake'**
  String get classicFrenchBaguetteDesc;

  /// No description provided for @rosemaryOliveOilCake.
  ///
  /// In en, this message translates to:
  /// **'Rosemary Olive Oil Cake'**
  String get rosemaryOliveOilCake;

  /// No description provided for @rosemaryOliveOilCakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Sicilian cold-pressed oil, flaky sea salt'**
  String get rosemaryOliveOilCakeDesc;

  /// No description provided for @brownButterCookies.
  ///
  /// In en, this message translates to:
  /// **'Brown Butter Cookies'**
  String get brownButterCookies;

  /// No description provided for @brownButterCookiesDesc.
  ///
  /// In en, this message translates to:
  /// **'70% Dark chocolate, toasted hazelnuts'**
  String get brownButterCookiesDesc;

  /// No description provided for @yieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Yield'**
  String get yieldLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get temperatureLabel;

  /// No description provided for @lavenderMadeleine.
  ///
  /// In en, this message translates to:
  /// **'Lavender Madeleine'**
  String get lavenderMadeleine;

  /// No description provided for @lavenderMadeleineDesc.
  ///
  /// In en, this message translates to:
  /// **'Feb 12 • Floral Infusion'**
  String get lavenderMadeleineDesc;

  /// No description provided for @heritageSourdough.
  ///
  /// In en, this message translates to:
  /// **'Heritage Sourdough'**
  String get heritageSourdough;

  /// No description provided for @heritageSourdoughDesc.
  ///
  /// In en, this message translates to:
  /// **'Feb 10 • 80% Hydration'**
  String get heritageSourdoughDesc;

  /// No description provided for @journalNo.
  ///
  /// In en, this message translates to:
  /// **'Journal No.'**
  String get journalNo;

  /// No description provided for @summaryDate.
  ///
  /// In en, this message translates to:
  /// **'Nov 12, 2023'**
  String get summaryDate;

  /// No description provided for @summaryVersion.
  ///
  /// In en, this message translates to:
  /// **'V 2.1'**
  String get summaryVersion;

  /// No description provided for @pumpkinCreamTitle.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin Cream'**
  String get pumpkinCreamTitle;

  /// No description provided for @ingredientRoastedPumpkin.
  ///
  /// In en, this message translates to:
  /// **'Roasted Pumpkin'**
  String get ingredientRoastedPumpkin;

  /// No description provided for @ingredientHeavyCream.
  ///
  /// In en, this message translates to:
  /// **'Heavy Cream'**
  String get ingredientHeavyCream;

  /// No description provided for @ingredientBrownSugar.
  ///
  /// In en, this message translates to:
  /// **'Brown Sugar'**
  String get ingredientBrownSugar;

  /// No description provided for @ingredientCinnamon.
  ///
  /// In en, this message translates to:
  /// **'Cinnamon'**
  String get ingredientCinnamon;

  /// No description provided for @methodPumpkinCream.
  ///
  /// In en, this message translates to:
  /// **'Roast pumpkin at 180C until completely soft. Puree while hot.\nIn a cold bowl, whip heavy cream with sugar and cinnamon until soft peaks form.\nGently fold puree into the cream.'**
  String get methodPumpkinCream;

  /// No description provided for @noteOvermix.
  ///
  /// In en, this message translates to:
  /// **'*Do not overmix, keep it airy!'**
  String get noteOvermix;

  /// No description provided for @methodChill.
  ///
  /// In en, this message translates to:
  /// **'Chill for 2 hours before piping.'**
  String get methodChill;

  /// No description provided for @mochiTitle.
  ///
  /// In en, this message translates to:
  /// **'Mini Rice Ball (Mochi)'**
  String get mochiTitle;

  /// No description provided for @ingredientGlutinousFlour.
  ///
  /// In en, this message translates to:
  /// **'Glutinous Rice Flour'**
  String get ingredientGlutinousFlour;

  /// No description provided for @ingredientWarmWater.
  ///
  /// In en, this message translates to:
  /// **'Warm Water'**
  String get ingredientWarmWater;

  /// No description provided for @ingredientSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get ingredientSugar;

  /// No description provided for @methodMochi.
  ///
  /// In en, this message translates to:
  /// **'Mix flour and sugar. Slowly add warm water until dough comes together.\nKnead until smooth. Roll into tiny spheres (approx 5g each).\nBoil until they float, then plunge immediately into ice water.'**
  String get methodMochi;

  /// No description provided for @seedTuileTitle.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin Seed Tuile'**
  String get seedTuileTitle;

  /// No description provided for @ingredientButterMelted.
  ///
  /// In en, this message translates to:
  /// **'Butter (melted)'**
  String get ingredientButterMelted;

  /// No description provided for @ingredientIcingSugar.
  ///
  /// In en, this message translates to:
  /// **'Icing Sugar'**
  String get ingredientIcingSugar;

  /// No description provided for @ingredientEggWhite.
  ///
  /// In en, this message translates to:
  /// **'Egg White'**
  String get ingredientEggWhite;

  /// No description provided for @ingredientFlour.
  ///
  /// In en, this message translates to:
  /// **'Flour'**
  String get ingredientFlour;

  /// No description provided for @ingredientPumpkinSeeds.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin Seeds'**
  String get ingredientPumpkinSeeds;

  /// No description provided for @methodSeedTuile.
  ///
  /// In en, this message translates to:
  /// **'Whisk egg whites and icing sugar. Stir in flour, then melted butter.\nFold in lightly toasted pumpkin seeds. Let rest for 30 mins.\nSpread thinly on silpat. Bake at 160C for 8-10 mins until golden.'**
  String get methodSeedTuile;

  /// No description provided for @noteShapeHot.
  ///
  /// In en, this message translates to:
  /// **'*Must shape immediately while hot!'**
  String get noteShapeHot;

  /// No description provided for @riceCrumbleTitle.
  ///
  /// In en, this message translates to:
  /// **'Rice Crumble'**
  String get riceCrumbleTitle;

  /// No description provided for @ingredientRiceFlour.
  ///
  /// In en, this message translates to:
  /// **'Rice Flour'**
  String get ingredientRiceFlour;

  /// No description provided for @ingredientAlmondFlour.
  ///
  /// In en, this message translates to:
  /// **'Almond Flour'**
  String get ingredientAlmondFlour;

  /// No description provided for @ingredientColdButter.
  ///
  /// In en, this message translates to:
  /// **'Cold Butter'**
  String get ingredientColdButter;

  /// No description provided for @ingredientDemeraraSugar.
  ///
  /// In en, this message translates to:
  /// **'Demerara Sugar'**
  String get ingredientDemeraraSugar;

  /// No description provided for @ingredientSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get ingredientSalt;

  /// No description provided for @methodRiceCrumble.
  ///
  /// In en, this message translates to:
  /// **'Combine all dry ingredients. Cut in cold butter until coarse crumbs form.\nSpread on a baking sheet. Bake at 170C for 15 mins, tossing halfway.\nCool completely for crunch.'**
  String get methodRiceCrumble;

  /// No description provided for @pumpkinPureeBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin Puree Base'**
  String get pumpkinPureeBaseTitle;

  /// No description provided for @ingredientKabochaSquash.
  ///
  /// In en, this message translates to:
  /// **'Kabocha Squash'**
  String get ingredientKabochaSquash;

  /// No description provided for @ingredientWholeMilk.
  ///
  /// In en, this message translates to:
  /// **'Whole Milk'**
  String get ingredientWholeMilk;

  /// No description provided for @miniRiceBallsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mini Rice Balls'**
  String get miniRiceBallsTitle;

  /// No description provided for @tagVegan.
  ///
  /// In en, this message translates to:
  /// **'#Vegan'**
  String get tagVegan;

  /// No description provided for @tagLargeBatch.
  ///
  /// In en, this message translates to:
  /// **'#LargeBatch'**
  String get tagLargeBatch;

  /// No description provided for @tagSlowFerment.
  ///
  /// In en, this message translates to:
  /// **'#SlowFerment'**
  String get tagSlowFerment;

  /// No description provided for @tagSourdough.
  ///
  /// In en, this message translates to:
  /// **'#Sourdough'**
  String get tagSourdough;

  /// No description provided for @recipeSourdoughDesc.
  ///
  /// In en, this message translates to:
  /// **'A classic artisan bread with 80% hydration and cold fermentation.'**
  String get recipeSourdoughDesc;

  /// No description provided for @recipeBaguetteDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional French baguette using a poolish starter.'**
  String get recipeBaguetteDesc;

  /// No description provided for @recipeCakeDesc.
  ///
  /// In en, this message translates to:
  /// **'Moist and aromatic cake with fresh rosemary and premium olive oil.'**
  String get recipeCakeDesc;

  /// No description provided for @recipeCookieDesc.
  ///
  /// In en, this message translates to:
  /// **'Rich brown butter cookies with dark chocolate chunks.'**
  String get recipeCookieDesc;

  /// No description provided for @artisanalKitchenDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore the nuances of sourdough, pastry, and more.'**
  String get artisanalKitchenDesc;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search for a recipe...'**
  String get searchRecipes;

  /// No description provided for @recentlyBaked.
  ///
  /// In en, this message translates to:
  /// **'Recently Baked'**
  String get recentlyBaked;

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'No recipes found. Start baking!'**
  String get emptyState;

  /// No description provided for @collectionSourdough.
  ///
  /// In en, this message translates to:
  /// **'Sourdough'**
  String get collectionSourdough;

  /// No description provided for @collectionDesserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get collectionDesserts;

  /// No description provided for @collectionPastry.
  ///
  /// In en, this message translates to:
  /// **'Pastry'**
  String get collectionPastry;

  /// No description provided for @collectionCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get collectionCookies;

  /// No description provided for @tabIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get tabIngredients;

  /// No description provided for @tabMethods.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get tabMethods;

  /// No description provided for @businessInsights.
  ///
  /// In en, this message translates to:
  /// **'Business Insights'**
  String get businessInsights;

  /// No description provided for @batchProductionCost.
  ///
  /// In en, this message translates to:
  /// **'Batch Production Cost'**
  String get batchProductionCost;

  /// No description provided for @suggestedSalePrice.
  ///
  /// In en, this message translates to:
  /// **'Suggested Sale Price (3x)'**
  String get suggestedSalePrice;

  /// No description provided for @estimatedProfit.
  ///
  /// In en, this message translates to:
  /// **'Estimated Profit'**
  String get estimatedProfit;

  /// No description provided for @marginsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Margins are calculated based on your pantry unit prices. Taxes and utilities not included.'**
  String get marginsDisclaimer;

  /// No description provided for @logProduction.
  ///
  /// In en, this message translates to:
  /// **'Log Production & Deduct Stock'**
  String get logProduction;

  /// No description provided for @ingredientsMissingWarning.
  ///
  /// In en, this message translates to:
  /// **'Some ingredients are missing from your pantry. Cost data might be incomplete.'**
  String get ingredientsMissingWarning;

  /// No description provided for @productionLogged.
  ///
  /// In en, this message translates to:
  /// **'Production logged! Transaction added and stock updated.'**
  String get productionLogged;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Restock Needed'**
  String get lowStockAlert;

  /// No description provided for @restockNow.
  ///
  /// In en, this message translates to:
  /// **'Get more at the market'**
  String get restockNow;

  /// No description provided for @salesSlip.
  ///
  /// In en, this message translates to:
  /// **'Sales Slip'**
  String get salesSlip;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'+ Add line item'**
  String get addItem;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get salesHistory;

  /// No description provided for @noSalesRecords.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded yet.'**
  String get noSalesRecords;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Discard this record?'**
  String get deleteRecord;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saleRegistered.
  ///
  /// In en, this message translates to:
  /// **'Sale registered with a flourish.'**
  String get saleRegistered;

  /// No description provided for @newIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'New Ingredient Found!'**
  String get newIngredientTitle;

  /// No description provided for @newIngredientDesc.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t in your pantry yet. Should we add it to the shelf?'**
  String get newIngredientDesc;

  /// No description provided for @addToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to Pantry'**
  String get addToPantry;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @totalVaultValue.
  ///
  /// In en, this message translates to:
  /// **'Total Vault Value'**
  String get totalVaultValue;

  /// No description provided for @inventoryStatus.
  ///
  /// In en, this message translates to:
  /// **'Inventory Status'**
  String get inventoryStatus;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @missingInfo.
  ///
  /// In en, this message translates to:
  /// **'Missing Info'**
  String get missingInfo;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get totalEntries;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK'**
  String get outOfStock;

  /// No description provided for @updateInfo.
  ///
  /// In en, this message translates to:
  /// **'UPDATE INFO'**
  String get updateInfo;

  /// No description provided for @pantryLedger.
  ///
  /// In en, this message translates to:
  /// **'Pantry Ledger'**
  String get pantryLedger;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @updateIngredient.
  ///
  /// In en, this message translates to:
  /// **'Update Ingredient'**
  String get updateIngredient;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get ingredientName;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity'**
  String get totalQuantity;

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStockLabel;

  /// No description provided for @purchasePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePriceLabel;

  /// No description provided for @categoryFlour.
  ///
  /// In en, this message translates to:
  /// **'Flour'**
  String get categoryFlour;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy/Eggs'**
  String get categoryDairy;

  /// No description provided for @categorySweetener.
  ///
  /// In en, this message translates to:
  /// **'Sweetener'**
  String get categorySweetener;

  /// No description provided for @categoryLeavening.
  ///
  /// In en, this message translates to:
  /// **'Leavening'**
  String get categoryLeavening;

  /// No description provided for @categoryAddIn.
  ///
  /// In en, this message translates to:
  /// **'Add-in'**
  String get categoryAddIn;

  /// No description provided for @categoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get categoryOthers;

  /// No description provided for @quote1.
  ///
  /// In en, this message translates to:
  /// **'\"The scent of wood and fresh sourdough—a master’s morning.\"'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In en, this message translates to:
  /// **'\"Every crumb tells the story of the grain’s journey.\"'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In en, this message translates to:
  /// **'\"Precision is key, but intuition is most important.\"'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In en, this message translates to:
  /// **'\"The best flour is the one that still feels like life.\"'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In en, this message translates to:
  /// **'\"Warmth, patience, and time: the true artisan tools.\"'**
  String get quote5;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @mainDough.
  ///
  /// In en, this message translates to:
  /// **'Main Dough'**
  String get mainDough;

  /// No description provided for @newComponent.
  ///
  /// In en, this message translates to:
  /// **'New Component'**
  String get newComponent;

  /// No description provided for @breadFlour.
  ///
  /// In en, this message translates to:
  /// **'Bread Flour'**
  String get breadFlour;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @removeMedia.
  ///
  /// In en, this message translates to:
  /// **'REMOVE MEDIA?'**
  String get removeMedia;

  /// No description provided for @removeMediaConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this image from the recipe?'**
  String get removeMediaConfirm;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'KEEP IT'**
  String get keepIt;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @newIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'NEW INGREDIENTS FOUND'**
  String get newIngredientsFound;

  /// No description provided for @addIngredientsToPantry.
  ///
  /// In en, this message translates to:
  /// **'Would you like to add these to your pantry journal?'**
  String get addIngredientsToPantry;

  /// No description provided for @registerIntoPantry.
  ///
  /// In en, this message translates to:
  /// **'Register into Pantry'**
  String get registerIntoPantry;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get renameCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get newName;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @addSale.
  ///
  /// In en, this message translates to:
  /// **'Add Sale'**
  String get addSale;

  /// No description provided for @recentPurchases.
  ///
  /// In en, this message translates to:
  /// **'Recent Purchases'**
  String get recentPurchases;

  /// No description provided for @noPurchaseRecords.
  ///
  /// In en, this message translates to:
  /// **'No purchase records'**
  String get noPurchaseRecords;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History >'**
  String get history;

  /// No description provided for @percentLeft.
  ///
  /// In en, this message translates to:
  /// **'{percent}% left'**
  String percentLeft(Object percent);

  /// No description provided for @addProductHint.
  ///
  /// In en, this message translates to:
  /// **'Add product...'**
  String get addProductHint;

  /// No description provided for @productSale.
  ///
  /// In en, this message translates to:
  /// **'Product Sale'**
  String get productSale;

  /// No description provided for @ingredientPurchase.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Purchase'**
  String get ingredientPurchase;

  /// No description provided for @boughtDescription.
  ///
  /// In en, this message translates to:
  /// **'Bought: {name} ({quantity}g)'**
  String boughtDescription(Object name, Object quantity);

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name...'**
  String get nameHint;

  /// No description provided for @ingredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Organic Rye Flour'**
  String get ingredientNameHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
