import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/custom_clippers.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/pantry_categories_provider.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/transaction.dart';
import 'add_recipe_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _photoStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) return;
    
    final camera = await Permission.camera.status;
    final photo = await Permission.photos.status;
    if (mounted) {
      setState(() {
        _cameraStatus = camera;
        _photoStatus = photo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 64, 28, 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    l10n.settings,
                    style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      color: ArtisanalTheme.ink,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                // Mode selector hidden since Basic is the only mode in this version
                // _buildModeSelector(l10n, settings),
                // const SizedBox(height: 28),
                _buildSettingsGroup(l10n.preferences, [
                  _settingsItem(
                    Icons.language,
                    l10n.language,
                    trailer: _getLanguageTrailer(ref.watch(localeProvider.notifier).currentLanguageCode, l10n),
                    onTap: () => _showLanguagePicker(context),
                  ),
                  _settingsItem(
                    Icons.scale_outlined,
                    l10n.measurementUnit,
                    trailer: settings.measurementSystem == 'metric' ? l10n.metric : l10n.imperial,
                    onTap: () => _showUnitPicker(context),
                  ),
                  if (settings.appMode != 'basic') ...[
                    _settingsItem(
                      Icons.payments_outlined,
                      l10n.currencySymbolLabel,
                      trailer: settings.currencySymbol,
                      onTap: () => _showCurrencyPicker(context),
                    ),
                    _settingsItem(
                      Icons.sync,
                      l10n.refreshExchangeRates,
                      infoMessage: l10n.refreshRatesInfo,
                      onTap: () async {
                        await ref.read(settingsProvider.notifier).refreshRates();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.exchangeRatesUpdated)),
                          );
                        }
                      },
                    ),
                  ],
                  _settingsItem(
                    Icons.store_outlined,
                    l10n.atelierProfile,
                    trailer: settings.atelierName,
                    onTap: () => _showProfileEditor(context, settings, l10n),
                  ),
                ]),
                const SizedBox(height: 28),
                _buildSettingsGroup(l10n.privacyPermissions, [
                  _settingsItem(
                    Icons.security_outlined,
                    l10n.appPermissions,
                    onTap: () => _showPermissionsManager(context, l10n),
                  ),
                ]),
                const SizedBox(height: 28),
                _buildSettingsGroup(l10n.dataAndBusiness, [
                  _settingsItem(
                    Icons.delete_forever_outlined,
                    l10n.resetAllData,
                    isDestructive: true,
                    onTap: () => _showResetConfirmation(context, l10n),
                  ),
                ]),
                const SizedBox(height: 28),
                _buildSettingsGroup(l10n.information, [
                  _settingsItem(
                    Icons.policy_outlined,
                    l10n.termsAndPrivacy,
                    onTap: () => _showTermsAndPrivacyDialog(context),
                  ),
                  _settingsItemStatic(Icons.info_outline, l10n.appVersion, value: 'v1.0.0'),
                ]),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /* Commented out for basic-only version
  Widget _buildModeSelector(AppLocalizations l10n, SettingsState settings) {
    final currentMode = settings.appMode;
    final isKo = l10n.currentLanguage == '한국어';
    
    return Row(
          children: [
            Expanded(
              child: _modeCard(
                isKo ? '기본' : 'Basic',
                '',
                Icons.menu_book,
                currentMode == 'basic',
                () => ref.read(settingsProvider.notifier).updateAppMode('basic'),
              ),
            ),
            // Hide Creative and Business modes for initial Basic-only release.
            // They will be re-enabled in future updates.
            /*
            const SizedBox(width: 8),
            Expanded(
              child: _modeCard(
                isKo ? '창작' : 'Creative',
                '',
                Icons.edit_note,
                currentMode == 'creative',
                () => ref.read(settingsProvider.notifier).updateAppMode('creative'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _modeCard(
                isKo ? '경영' : 'Biz',
                '',
                Icons.analytics_outlined,
                currentMode == 'business',
                () => ref.read(settingsProvider.notifier).updateAppMode('business'),
              ),
            ),
            */
          ],
        );
  }

  Widget _modeCard(String title, String desc, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? ArtisanalTheme.surface : ArtisanalTheme.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.ink.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: ArtisanalTheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.ink.withValues(alpha: 0.3),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: ArtisanalTheme.hand(
                fontSize: 16,
                color: isSelected ? ArtisanalTheme.ink : ArtisanalTheme.ink.withValues(alpha: 0.4),
              ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildSettingsGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.6))
                    .copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 2),
              Container(height: 1.5, color: ArtisanalTheme.ink.withValues(alpha: 0.1), width: 60),
            ],
          ),
        ),
        PhysicalShape(
          clipper: ScallopedClipper(),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          color: ArtisanalTheme.surface,
          child: Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(IconData icon, String label, {String? trailer, VoidCallback? onTap, bool isDestructive = false, String? infoMessage}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isDestructive ? const Color(0xFFB33939) : ArtisanalTheme.ink,
                    size: 22,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: ArtisanalTheme.hand(
                              fontSize: 20,
                              color: isDestructive ? const Color(0xFFB33939) : ArtisanalTheme.ink,
                            ).copyWith(fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (infoMessage != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showInfoDialog(context, label, infoMessage),
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailer != null) ...[
                    Text(
                      trailer,
                      style: ArtisanalTheme.hand(fontSize: 17, color: ArtisanalTheme.secondary.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: ArtisanalTheme.ink.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isDestructive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              height: 1,
              color: ArtisanalTheme.ink.withValues(alpha: 0.05),
              thickness: 1,
            ),
          ),
      ],
    );
  }

  Widget _settingsItemStatic(IconData icon, String label, {String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: ArtisanalTheme.ink.withValues(alpha: 0.5), size: 22),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.ink.withValues(alpha: 0.6)),
            ),
          ),
          if (value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: ArtisanalTheme.receipt(
                  fontSize: 13,
                  color: ArtisanalTheme.ink,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtisanalTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink).copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: ArtisanalTheme.receipt(fontSize: 16, color: ArtisanalTheme.ink.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).ok,
              style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageTrailer(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'ko':
        return l10n.korean;
      default:
        return l10n.systemLanguage;
    }
  }

  void _showTermsAndPrivacyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isKo = l10n.currentLanguage == '한국어';

    final String title = isKo ? "이용약관 및 개인정보 정책" : "Terms & Privacy Policy";
    final String content = isKo 
      ? "■ 개인정보 처리방침\n\n"
        "1. 개인정보 수집 및 이용\n"
        "'My Atelier' 앱은 회원의 별도 가입 절차 없이 오프라인으로 작동하며, 서버로 어떠한 개인정보도 전송하거나 수집하지 않습니다. 모든 레시피, 재고 내역, 매입/매출 등의 데이터는 사용자의 스마트폰 기기 내부(Hive 로컬 데이터베이스)에만 안전하게 저장됩니다.\n\n"
        "2. 권한 사용 안내\n"
        "앱 내 레시피 사진 등록 및 스케치 저장을 위해 카메라 촬영 및 갤러리(사진첩) 접근 권한을 사용합니다. 권한은 해당 기능 실행 시에만 사용되며 수집되지 않습니다.\n\n"
        "3. 데이터 보관 및 파기\n"
        "사용자의 모든 데이터는 기기 내부에 저장되므로, 앱을 삭제하거나 설정의 '모든 데이터 초기화' 기능을 수행하면 모든 데이터가 영구 파기되어 복구할 수 없습니다.\n\n\n"
        "■ 서비스 이용약관\n\n"
        "1. 서비스 목적\n"
        "본 앱은 제과제빵 및 요리 레시피 기록, R&D 구상, 간이 재고 및 매출 관리를 돕는 개인용 노트 도구입니다.\n\n"
        "2. 면책 조항\n"
        "개발자는 사용자의 데이터 관리 소홀(기기 변경, 분실, 앱 무단 삭제 등)로 인한 데이터 유실에 책임을 지지 않습니다. 오프라인 앱의 특성상 주기적인 백업 관리를 권장합니다."
      : "■ Privacy Policy\n\n"
        "1. Collection of Information\n"
        "'My Atelier' operates completely offline. We do not collect, store, or transmit any of your personal data to external servers. All recipes, inventory lists, and ledger data are saved locally on your device.\n\n"
        "2. Permissions\n"
        "We request access to your Camera and Photo Gallery solely to allow you to take and attach photos to your recipes. We do not upload these photos to any server.\n\n"
        "3. Data Deletion\n"
        "Because all data is stored on your device, deleting the app or selecting 'Reset All Data' in settings will permanently delete all your records.\n\n\n"
        "■ Terms of Service\n\n"
        "1. Service Purpose\n"
        "This app is a personal notebook utility designed to help you organize recipes, log inventory, and track basic sales.\n\n"
        "2. Limitation of Liability\n"
        "The developer is not responsible for any data loss caused by device loss, app uninstallation, or lack of backups.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtisanalTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink).copyWith(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: ArtisanalTheme.receipt(fontSize: 14, color: ArtisanalTheme.ink.withValues(alpha: 0.8), height: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.ok,
              style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languages = [
      ('system', l10n.systemLanguage, l10n.systemLanguage, Icons.settings_suggest_outlined),
      ('en', l10n.english, "English", Icons.language_outlined),
      ('ko', l10n.korean, "한국어", Icons.language_outlined),
    ];

    _showArtisanalSelector(
      context,
      title: l10n.language,
      options: languages
          .map((lang) => _SelectorOption(
                value: lang.$1,
                label: lang.$2,
                description: lang.$3,
                icon: lang.$4,
              ))
          .toList(),
      onSelected: (value) =>
          ref.read(localeProvider.notifier).setLanguage(value),
      selectedValue: ref.read(localeProvider.notifier).currentLanguageCode,
    );
  }

  void _showUnitPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final systems = [
      ('metric', l10n.metricSystem, Icons.auto_awesome_mosaic_outlined),
      ('imperial', l10n.imperialSystem, Icons.architecture_outlined),
    ];

    _showArtisanalSelector(
      context,
      title: l10n.measurementUnit,
      options: systems
          .map((s) => _SelectorOption(
                value: s.$1,
                label: s.$2,
                description: s.$1 == 'metric' ? "g, kg" : "oz, lb",
                icon: s.$3,
              ))
          .toList(),
      onSelected: (value) =>
          ref.read(settingsProvider.notifier).updateMeasurementSystem(value),
      selectedValue: ref.read(settingsProvider).measurementSystem,
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencies = [
      (String.fromCharCode(8361), l10n.wonName),
      (r"$", l10n.dollarName),
      (String.fromCharCode(8364), l10n.euroName),
      (String.fromCharCode(165), l10n.yenName),
    ];
    
    _showArtisanalSelector(
      context,
      title: AppLocalizations.of(context).currencySymbolLabel,
      options: currencies.map((c) => _SelectorOption(
        value: c.$1,
        label: c.$1,
        description: c.$2,
        icon: Icons.payments_outlined,
      )).toList(),
      onSelected: (value) => ref.read(settingsProvider.notifier).updateCurrencySymbol(value),
      selectedValue: ref.read(settingsProvider).currencySymbol,
    );
  }

  void _showArtisanalSelector(
    BuildContext context, {
    required String title,
    required List<_SelectorOption> options,
    required Function(String) onSelected,
    required String selectedValue,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ArtisanalTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: ArtisanalTheme.hand(fontSize: 24, color: ArtisanalTheme.ink)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 40),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final opt = options[index];
                  final isSelected = opt.value == selectedValue;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onSelected(opt.value);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.ink.withValues(alpha: 0.1),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? ArtisanalTheme.primary.withValues(alpha: 0.05) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                opt.icon,
                                color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.ink.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: ArtisanalTheme.hand(
                                        fontSize: 20,
                                        color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.ink,
                                      ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                    ),
                                    Text(
                                      opt.description,
                                      style: ArtisanalTheme.hand(
                                        fontSize: 14,
                                        color: ArtisanalTheme.ink.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: ArtisanalTheme.primary, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileEditor(BuildContext context, SettingsState settings, AppLocalizations l10n) {
    final nameController = TextEditingController(text: settings.atelierName);
    final contactController = TextEditingController(text: settings.atelierContact);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: ArtisanalTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).atelierProfile,
                  style: ArtisanalTheme.hand(fontSize: 28, color: ArtisanalTheme.ink)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.customizeStudioDesc,
                  style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 32),
                _buildStylizedField(l10n.atelierNameLabel, nameController, Icons.store_outlined),
                const SizedBox(height: 20),
                _buildStylizedField(l10n.contactInfoLabel, contactController, Icons.alternate_email),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.4))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(settingsProvider.notifier).updateAtelierProfile(
                            name: nameController.text,
                            contact: contactController.text,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ArtisanalTheme.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.saveProfile, style: ArtisanalTheme.hand(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStylizedField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.ink.withValues(alpha: 0.4))
              .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.ink),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ArtisanalTheme.primary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showPermissionsManager(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: ArtisanalTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appPermissions,
                  style: ArtisanalTheme.hand(fontSize: 28, color: ArtisanalTheme.ink)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildPermissionItem(
                  Icons.camera_alt_outlined,
                  l10n.cameraAccess,
                  l10n.cameraAccessDesc,
                  _cameraStatus,
                  onCheck: () async {
                    await Permission.camera.request();
                    await _checkPermissions();
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(
                  Icons.photo_library_outlined,
                  l10n.galleryAccess,
                  l10n.galleryAccessDesc,
                  _photoStatus,
                  onCheck: () async {
                    await Permission.photos.request();
                    await _checkPermissions();
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await openAppSettings();
                      // Status will be re-checked when app resumes via Observer
                    },
                    icon: const Icon(Icons.settings_applications_outlined),
                    label: Text(l10n.systemSettings, style: ArtisanalTheme.hand(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArtisanalTheme.ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.iUnderstand, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.4))),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description, PermissionStatus status, {VoidCallback? onCheck}) {
    final isGranted = status.isGranted;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isGranted ? const Color(0xFF2D6A4F) : ArtisanalTheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.ink)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: ArtisanalTheme.hand(fontSize: 15, color: ArtisanalTheme.ink.withValues(alpha: 0.6)),
                ),
                if (!isGranted) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: onCheck,
                    child: Text(
                      "Tap to Request",
                      style: ArtisanalTheme.hand(
                        fontSize: 14,
                        color: ArtisanalTheme.primary,
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PermissionStatus status) {
    final isGranted = status.isGranted;
    final label = isGranted ? "GRANTED" : "DENIED";
    final color = isGranted ? const Color(0xFF2D6A4F) : const Color(0xFFB33939);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: ArtisanalTheme.hand(fontSize: 12, color: color).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtisanalTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFB33939)),
            const SizedBox(width: 12),
            Text(l10n.dangerousAction, style: ArtisanalTheme.hand(fontSize: 24, color: const Color(0xFFB33939))),
          ],
        ),
        content: Text(
          l10n.resetConfirmationMessage,
          style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.keepData, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              await _performReset();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.allDataWiped)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB33939),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.resetEverything, style: ArtisanalTheme.hand(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset() async {
    await Hive.box<Recipe>('recipes').clear();
    await Hive.box<PantryItem>('pantry').clear();
    await Hive.box<BusinessTransaction>('transactions').clear();
    await Hive.box('settings').delete('pantry_categories_map');
    
    ref.invalidate(pantryProvider);
    ref.invalidate(transactionProvider);
    ref.invalidate(recipeListProvider);
    ref.invalidate(pantryCategoriesProvider);
    ref.invalidate(recipeDraftProvider);
  }
}

class _SelectorOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  _SelectorOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}
