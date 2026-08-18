import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Uygulaması'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @themeSettings.
  ///
  /// In tr, this message translates to:
  /// **'Tema Ayarları'**
  String get themeSettings;

  /// No description provided for @premium.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @cloudBackup.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Yedekleme'**
  String get cloudBackup;

  /// No description provided for @helpFaq.
  ///
  /// In tr, this message translates to:
  /// **'Yardım / SSS'**
  String get helpFaq;

  /// No description provided for @feedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedback;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Hakkında'**
  String get about;

  /// No description provided for @rateApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Puanla'**
  String get rateApp;

  /// No description provided for @onboardingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz!'**
  String get onboardingTitle;

  /// No description provided for @onboardingDescription.
  ///
  /// In tr, this message translates to:
  /// **'QR kod oluşturun, yönetin ve paylaşın.'**
  String get onboardingDescription;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In tr, this message translates to:
  /// **'QR kod uygulamasına hoş geldiniz.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingThemePremiumTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema ve Premium Özellikler'**
  String get onboardingThemePremiumTitle;

  /// No description provided for @onboardingThemePremiumDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kişiselleştirilebilir tema ve premium avantajlarla deneyiminizi geliştirin.'**
  String get onboardingThemePremiumDescription;

  /// No description provided for @onboardingCloudBackupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Yedekleme'**
  String get onboardingCloudBackupTitle;

  /// No description provided for @onboardingCloudBackupDescription.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi Google hesabınızla güvenle yedekleyin.'**
  String get onboardingCloudBackupDescription;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyDescription.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz cihazınızda güvende, gizlilik politikamıza göz atın.'**
  String get onboardingPrivacyDescription;

  /// No description provided for @onboardingNext.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get onboardingStart;

  /// No description provided for @premiumPurchaseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium Satın Al'**
  String get premiumPurchaseTitle;

  /// No description provided for @premiumPurchasePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Premium satın alma işlemleri burada olacak.'**
  String get premiumPurchasePlaceholder;

  /// No description provided for @premiumPurchaseHeadingInactive.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Yükselt'**
  String get premiumPurchaseHeadingInactive;

  /// No description provided for @premiumPurchaseHeadingActive.
  ///
  /// In tr, this message translates to:
  /// **'Premium Aktif'**
  String get premiumPurchaseHeadingActive;

  /// No description provided for @premiumPurchaseUnlockSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm özelliklerin kilidini aç'**
  String get premiumPurchaseUnlockSubtitle;

  /// No description provided for @premiumPurchaseFeaturesHeading.
  ///
  /// In tr, this message translates to:
  /// **'Premium Özellikler'**
  String get premiumPurchaseFeaturesHeading;

  /// No description provided for @premiumPurchaseOptionsHeading.
  ///
  /// In tr, this message translates to:
  /// **'Seçenekler'**
  String get premiumPurchaseOptionsHeading;

  /// No description provided for @premiumPurchaseStoreUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza Kullanılamıyor'**
  String get premiumPurchaseStoreUnavailable;

  /// No description provided for @premiumPurchaseProcessing.
  ///
  /// In tr, this message translates to:
  /// **'İşleniyor...'**
  String get premiumPurchaseProcessing;

  /// No description provided for @premiumPurchaseBuyButton.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Geç'**
  String get premiumPurchaseBuyButton;

  /// No description provided for @premiumPurchaseRestoreButton.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get premiumPurchaseRestoreButton;

  /// No description provided for @premiumPurchaseRestoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımlar geri yüklendi. Premium aktif.'**
  String get premiumPurchaseRestoreSuccess;

  /// No description provided for @premiumPurchaseRestoreNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Geri yüklenecek satın alım bulunamadı.'**
  String get premiumPurchaseRestoreNotFound;

  /// No description provided for @premiumPurchaseSuccessTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium Aktif!'**
  String get premiumPurchaseSuccessTitle;

  /// No description provided for @premiumPurchaseSuccessBody.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler. Premium özelliklerine erişiminiz açıldı.'**
  String get premiumPurchaseSuccessBody;

  /// No description provided for @premiumPurchaseSuccessAction.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get premiumPurchaseSuccessAction;

  /// No description provided for @premiumPurchaseLegalNote.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma Google Play / App Store hesabınızdan çekilir. Abonelikler iptal edilene kadar otomatik yenilenir.'**
  String get premiumPurchaseLegalNote;

  /// No description provided for @premiumFeatureAdFree.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız kullanım'**
  String get premiumFeatureAdFree;

  /// No description provided for @premiumFeatureUnlimitedHistory.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız QR geçmişi'**
  String get premiumFeatureUnlimitedHistory;

  /// No description provided for @premiumFeatureCustomStyles.
  ///
  /// In tr, this message translates to:
  /// **'Özel QR renk ve şekilleri'**
  String get premiumFeatureCustomStyles;

  /// No description provided for @premiumFeatureCloudBackup.
  ///
  /// In tr, this message translates to:
  /// **'Bulut yedekleme'**
  String get premiumFeatureCloudBackup;

  /// No description provided for @premiumFeatureBatchScan.
  ///
  /// In tr, this message translates to:
  /// **'Toplu tarama'**
  String get premiumFeatureBatchScan;

  /// No description provided for @premiumFeatureAdvancedAnalytics.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş analitik'**
  String get premiumFeatureAdvancedAnalytics;

  /// No description provided for @themeSettingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Renk, koyu/açık mod ve stil'**
  String get themeSettingsSubtitle;

  /// No description provided for @themeQuickColorPicker.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Renk Seçimi'**
  String get themeQuickColorPicker;

  /// No description provided for @themeCurrentTheme.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Tema'**
  String get themeCurrentTheme;

  /// No description provided for @themeModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema Modu'**
  String get themeModeTitle;

  /// No description provided for @themeColorThemeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Renk Teması'**
  String get themeColorThemeTitle;

  /// No description provided for @themeSelectedColor.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen: {color}'**
  String themeSelectedColor(Object color);

  /// No description provided for @themePreviewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema Önizleme'**
  String get themePreviewTitle;

  /// No description provided for @themePreviewSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema önizlemesi'**
  String get themePreviewSubtitle;

  /// No description provided for @themeColorBlue.
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get themeColorBlue;

  /// No description provided for @themeColorGreen.
  ///
  /// In tr, this message translates to:
  /// **'Yeşil'**
  String get themeColorGreen;

  /// No description provided for @themeColorPurple.
  ///
  /// In tr, this message translates to:
  /// **'Mor'**
  String get themeColorPurple;

  /// No description provided for @themeColorOrange.
  ///
  /// In tr, this message translates to:
  /// **'Turuncu'**
  String get themeColorOrange;

  /// No description provided for @themeColorPink.
  ///
  /// In tr, this message translates to:
  /// **'Pembe'**
  String get themeColorPink;

  /// No description provided for @themeColorTeal.
  ///
  /// In tr, this message translates to:
  /// **'Teal'**
  String get themeColorTeal;

  /// No description provided for @themeColorIndigo.
  ///
  /// In tr, this message translates to:
  /// **'İndigo'**
  String get themeColorIndigo;

  /// No description provided for @themeColorRed.
  ///
  /// In tr, this message translates to:
  /// **'Kırmızı'**
  String get themeColorRed;

  /// No description provided for @themeModeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Teması'**
  String get themeModeSystem;

  /// No description provided for @themeModeLightDescription.
  ///
  /// In tr, this message translates to:
  /// **'Her zaman aydınlık tema kullanır'**
  String get themeModeLightDescription;

  /// No description provided for @themeModeDarkDescription.
  ///
  /// In tr, this message translates to:
  /// **'Her zaman karanlık tema kullanır'**
  String get themeModeDarkDescription;

  /// No description provided for @themeModeSystemDescription.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz ayarlarını takip eder'**
  String get themeModeSystemDescription;

  /// No description provided for @cloudBackupSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi bulutta saklayın'**
  String get cloudBackupSubtitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüş ve önerilerinizi iletin'**
  String get feedbackSubtitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm, geliştirici ve iletişim'**
  String get aboutSubtitle;

  /// No description provided for @helpFaqSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıkça sorulan sorular ve yardım'**
  String get helpFaqSubtitle;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Memnun kaldıysanız puan verin'**
  String get rateAppSubtitle;

  /// No description provided for @homeScanCreateDescription.
  ///
  /// In tr, this message translates to:
  /// **'QR kodlarını tarayın ve oluşturun'**
  String get homeScanCreateDescription;

  /// No description provided for @homePriceAlertTestTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmı Testi'**
  String get homePriceAlertTestTooltip;

  /// No description provided for @homeLightMode.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık Mod'**
  String get homeLightMode;

  /// No description provided for @homeDarkMode.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get homeDarkMode;

  /// No description provided for @homeStatsScanned.
  ///
  /// In tr, this message translates to:
  /// **'Tarama'**
  String get homeStatsScanned;

  /// No description provided for @homeStatsCreated.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturma'**
  String get homeStatsCreated;

  /// No description provided for @homeStatsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get homeStatsTheme;

  /// No description provided for @homeFeaturesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özellikler'**
  String get homeFeaturesTitle;

  /// No description provided for @homeActionScanQr.
  ///
  /// In tr, this message translates to:
  /// **'QR Tara'**
  String get homeActionScanQr;

  /// No description provided for @homeActionCreateQr.
  ///
  /// In tr, this message translates to:
  /// **'QR Oluştur'**
  String get homeActionCreateQr;

  /// No description provided for @homeActionSavedRecords.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get homeActionSavedRecords;

  /// No description provided for @homeActionFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get homeActionFavorites;

  /// No description provided for @homeActionBatchScan.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Tarama'**
  String get homeActionBatchScan;

  /// No description provided for @homeActionAdvancedBarcode.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Barkod'**
  String get homeActionAdvancedBarcode;

  /// No description provided for @homeActionCustomizeQr.
  ///
  /// In tr, this message translates to:
  /// **'QR Özelleştir'**
  String get homeActionCustomizeQr;

  /// No description provided for @homeActionPriceAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmları'**
  String get homeActionPriceAlerts;

  /// No description provided for @homeActionAnalytics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get homeActionAnalytics;

  /// No description provided for @analyticsRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get analyticsRefresh;

  /// No description provided for @analyticsOverview.
  ///
  /// In tr, this message translates to:
  /// **'Genel İstatistikler'**
  String get analyticsOverview;

  /// No description provided for @analyticsTotalQr.
  ///
  /// In tr, this message translates to:
  /// **'Toplam QR'**
  String get analyticsTotalQr;

  /// No description provided for @analyticsScanned.
  ///
  /// In tr, this message translates to:
  /// **'Tarandı'**
  String get analyticsScanned;

  /// No description provided for @analyticsCreated.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturuldu'**
  String get analyticsCreated;

  /// No description provided for @analyticsArchived.
  ///
  /// In tr, this message translates to:
  /// **'Arşivlendi'**
  String get analyticsArchived;

  /// No description provided for @analyticsActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get analyticsActive;

  /// No description provided for @analyticsTypeDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Tür Dağılımı'**
  String get analyticsTypeDistribution;

  /// No description provided for @analyticsCategoryDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Dağılımı'**
  String get analyticsCategoryDistribution;

  /// No description provided for @analyticsLast7Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 Gün Aktivitesi'**
  String get analyticsLast7Days;

  /// No description provided for @analyticsNoData.
  ///
  /// In tr, this message translates to:
  /// **'Henüz veri yok'**
  String get analyticsNoData;

  /// No description provided for @analyticsUncategorized.
  ///
  /// In tr, this message translates to:
  /// **'Kategorisiz'**
  String get analyticsUncategorized;

  /// No description provided for @homeActionPremiumSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız ve ekstra özellikler'**
  String get homeActionPremiumSubtitle;

  /// No description provided for @homeNoAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Alarm yok'**
  String get homeNoAlerts;

  /// No description provided for @homeAlertsSummary.
  ///
  /// In tr, this message translates to:
  /// **'{triggered} tetiklenen • {total} toplam'**
  String homeAlertsSummary(Object total, Object triggered);

  /// No description provided for @batchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Tarama'**
  String get batchTitle;

  /// No description provided for @batchSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla QR kodu hızlıca tarayın'**
  String get batchSubtitle;

  /// No description provided for @batchPausedTitle.
  ///
  /// In tr, this message translates to:
  /// **'TARAMA DURAKLATILDI'**
  String get batchPausedTitle;

  /// No description provided for @batchPause.
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get batchPause;

  /// No description provided for @batchStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlat'**
  String get batchStart;

  /// No description provided for @batchDuplicateControlTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Duplikasyon Kontrolü'**
  String get batchDuplicateControlTooltip;

  /// No description provided for @batchDuplicateEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Duplikasyon engelleme aktif'**
  String get batchDuplicateEnabled;

  /// No description provided for @batchDuplicateDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Duplikasyon engelleme pasif'**
  String get batchDuplicateDisabled;

  /// No description provided for @batchEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR kodları tarayın'**
  String get batchEmptyTitle;

  /// No description provided for @batchEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Taranan kodlar burada görünecek'**
  String get batchEmptySubtitle;

  /// No description provided for @homePriceAlertTestSent.
  ///
  /// In tr, this message translates to:
  /// **'Test fiyat alarmı bildirimi gönderildi'**
  String get homePriceAlertTestSent;

  /// No description provided for @homePriceAlertNeedAlertFirst.
  ///
  /// In tr, this message translates to:
  /// **'Test için önce en az 1 fiyat alarmı oluşturun'**
  String get homePriceAlertNeedAlertFirst;

  /// No description provided for @settingsStoreListingNotOpened.
  ///
  /// In tr, this message translates to:
  /// **'Store listing açılamadı'**
  String get settingsStoreListingNotOpened;

  /// No description provided for @settingsStoreOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza açılamadı: {error}'**
  String settingsStoreOpenFailed(Object error);

  /// No description provided for @settingsPurchaseErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alma Hatası'**
  String get settingsPurchaseErrorTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dil:'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTurkish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsPremiumUpgradeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız deneyim ve ek özelliklerin kilidini açın'**
  String get settingsPremiumUpgradeSubtitle;

  /// No description provided for @settingsPremiumActiveSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium aktif'**
  String get settingsPremiumActiveSubtitle;

  /// No description provided for @commonOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get commonBack;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @batchCameraPermissionRequiredTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kamera İzni Gerekli'**
  String get batchCameraPermissionRequiredTitle;

  /// No description provided for @batchCameraPermissionRequiredMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kamera ile QR kod tarayabilmek için kamera izni vermelisiniz. Lütfen ayarlardan izin verin.'**
  String get batchCameraPermissionRequiredMessage;

  /// No description provided for @batchDeletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'{type} QR kodu silindi'**
  String batchDeletedMessage(Object type);

  /// No description provided for @batchScannedAtLabel.
  ///
  /// In tr, this message translates to:
  /// **'Taranma: {dateTime}'**
  String batchScannedAtLabel(Object dateTime);

  /// No description provided for @batchContentLabel.
  ///
  /// In tr, this message translates to:
  /// **'İçerik:'**
  String get batchContentLabel;

  /// No description provided for @batchSavedToHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişe kaydedildi'**
  String get batchSavedToHistory;

  /// No description provided for @batchScannedCodesCount.
  ///
  /// In tr, this message translates to:
  /// **'Taranan Kodlar ({count})'**
  String batchScannedCodesCount(Object count);

  /// No description provided for @batchSaveButton.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get batchSaveButton;

  /// No description provided for @batchFlashTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Flaş'**
  String get batchFlashTooltip;

  /// No description provided for @batchSwitchCameraTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kamera Değiştir'**
  String get batchSwitchCameraTooltip;

  /// No description provided for @scannerTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Tarayıcı'**
  String get scannerTitle;

  /// No description provided for @scannerScanFromGalleryTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden QR Tara'**
  String get scannerScanFromGalleryTooltip;

  /// No description provided for @scannerHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Tarama'**
  String get scannerHeaderTitle;

  /// No description provided for @scannerHeaderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kameranızı QR kodun üzerine getirin'**
  String get scannerHeaderSubtitle;

  /// No description provided for @scannerCameraStarting.
  ///
  /// In tr, this message translates to:
  /// **'Kamera başlatılıyor...'**
  String get scannerCameraStarting;

  /// No description provided for @scannerResultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarama Sonucu:'**
  String get scannerResultTitle;

  /// No description provided for @scannerBringCodeIntoView.
  ///
  /// In tr, this message translates to:
  /// **'QR kodu kameranın görüş alanına getirin'**
  String get scannerBringCodeIntoView;

  /// No description provided for @scannerStop.
  ///
  /// In tr, this message translates to:
  /// **'Durdur'**
  String get scannerStop;

  /// No description provided for @scannerDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar'**
  String get scannerDetails;

  /// No description provided for @scannerBarcodeType.
  ///
  /// In tr, this message translates to:
  /// **'Barkod'**
  String get scannerBarcodeType;

  /// No description provided for @scannerScannedDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Tarandı'**
  String get scannerScannedDialogTitle;

  /// No description provided for @scannerTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tür: {qrType}'**
  String scannerTypeLabel(Object qrType);

  /// No description provided for @scannerComparePriceAction.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Karşılaştır'**
  String get scannerComparePriceAction;

  /// No description provided for @scannerOpenUseAction.
  ///
  /// In tr, this message translates to:
  /// **'Aç/Kullan'**
  String get scannerOpenUseAction;

  /// No description provided for @scannerSetAlertAction.
  ///
  /// In tr, this message translates to:
  /// **'Alarm Kur'**
  String get scannerSetAlertAction;

  /// No description provided for @scannerAddFavoriteAction.
  ///
  /// In tr, this message translates to:
  /// **'Favorile'**
  String get scannerAddFavoriteAction;

  /// No description provided for @scannerQrNotFoundInGallery.
  ///
  /// In tr, this message translates to:
  /// **'QR kod bulunamadı'**
  String get scannerQrNotFoundInGallery;

  /// No description provided for @scannerGalleryAccessFailed.
  ///
  /// In tr, this message translates to:
  /// **'Galeri erişimi başarısız'**
  String get scannerGalleryAccessFailed;

  /// No description provided for @scannerPriceNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat bilgisi bulunamadı'**
  String get scannerPriceNotFound;

  /// No description provided for @scannerSetPriceAlertTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmı Kur'**
  String get scannerSetPriceAlertTitle;

  /// No description provided for @scannerUnknownProduct.
  ///
  /// In tr, this message translates to:
  /// **'Ürün'**
  String get scannerUnknownProduct;

  /// No description provided for @scannerCurrentLowestPrice.
  ///
  /// In tr, this message translates to:
  /// **'Güncel en düşük fiyat: ₺{price}'**
  String scannerCurrentLowestPrice(Object price);

  /// No description provided for @scannerPreset5Below.
  ///
  /// In tr, this message translates to:
  /// **'%5 altı'**
  String get scannerPreset5Below;

  /// No description provided for @scannerPreset10Below.
  ///
  /// In tr, this message translates to:
  /// **'%10 altı'**
  String get scannerPreset10Below;

  /// No description provided for @scannerPreset15Below.
  ///
  /// In tr, this message translates to:
  /// **'%15 altı'**
  String get scannerPreset15Below;

  /// No description provided for @scannerCurrentPricePreset.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut fiyat'**
  String get scannerCurrentPricePreset;

  /// No description provided for @scannerTargetPriceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef fiyat'**
  String get scannerTargetPriceLabel;

  /// No description provided for @scannerEnterValidPrice.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir fiyat girin'**
  String get scannerEnterValidPrice;

  /// No description provided for @scannerPriceAlertCreated.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı oluşturuldu'**
  String get scannerPriceAlertCreated;

  /// No description provided for @scannerPriceAlertNotCreated.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı oluşturulamadı'**
  String get scannerPriceAlertNotCreated;

  /// No description provided for @scannerAlertCreateError.
  ///
  /// In tr, this message translates to:
  /// **'Alarm oluşturma hatası: {error}'**
  String scannerAlertCreateError(Object error);

  /// No description provided for @advancedScannerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Barkod Tarayıcı'**
  String get advancedScannerTitle;

  /// No description provided for @advancedFormatOptions.
  ///
  /// In tr, this message translates to:
  /// **'Format Seçenekleri'**
  String get advancedFormatOptions;

  /// No description provided for @advancedDetectionActive.
  ///
  /// In tr, this message translates to:
  /// **'Tespit Aktif'**
  String get advancedDetectionActive;

  /// No description provided for @advancedContinuousMode.
  ///
  /// In tr, this message translates to:
  /// **'Sürekli Mod'**
  String get advancedContinuousMode;

  /// No description provided for @advancedDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get advancedDetails;

  /// No description provided for @advancedBarcodeFormats.
  ///
  /// In tr, this message translates to:
  /// **'Barkod Formatları'**
  String get advancedBarcodeFormats;

  /// No description provided for @advancedSelectAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Seç'**
  String get advancedSelectAll;

  /// No description provided for @advancedApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get advancedApply;

  /// No description provided for @advancedDetectedData.
  ///
  /// In tr, this message translates to:
  /// **'Tespit Edilen Veri:'**
  String get advancedDetectedData;

  /// No description provided for @advancedPerformAction.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Yap'**
  String get advancedPerformAction;

  /// No description provided for @advancedDescQrCode.
  ///
  /// In tr, this message translates to:
  /// **'Yaygın kullanılan 2D kod'**
  String get advancedDescQrCode;

  /// No description provided for @advancedDescProductBarcode.
  ///
  /// In tr, this message translates to:
  /// **'Ürün barkodları (Avrupa)'**
  String get advancedDescProductBarcode;

  /// No description provided for @advancedDescIndustrial.
  ///
  /// In tr, this message translates to:
  /// **'Endüstriyel kullanım'**
  String get advancedDescIndustrial;

  /// No description provided for @advancedDescSpecialPurpose.
  ///
  /// In tr, this message translates to:
  /// **'Özel amaçlı kullanım'**
  String get advancedDescSpecialPurpose;

  /// No description provided for @advancedDetectionCount.
  ///
  /// In tr, this message translates to:
  /// **'Tespit: {count}'**
  String advancedDetectionCount(int count);

  /// No description provided for @advancedDetectionCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tespit Sayısı: {count}'**
  String advancedDetectionCountLabel(int count);

  /// No description provided for @advancedLastDetection.
  ///
  /// In tr, this message translates to:
  /// **'Son Tespit: {time}'**
  String advancedLastDetection(Object time);

  /// No description provided for @advancedActiveFormats.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Formatlar: {formats}'**
  String advancedActiveFormats(Object formats);

  /// No description provided for @aboutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Hakkında'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Uygulaması'**
  String get aboutAppName;

  /// No description provided for @aboutDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu uygulama ile QR kod oluşturabilir, tarayabilir, geçmişinizi ve favorilerinizi yönetebilirsiniz.'**
  String get aboutDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm: 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutDeveloper.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici: QRKOD Proje Ekibi'**
  String get aboutDeveloper;

  /// No description provided for @aboutSupport.
  ///
  /// In tr, this message translates to:
  /// **'Destek ve iletişim için: support@qrkodproje.com'**
  String get aboutSupport;

  /// No description provided for @aboutOpenSourceNote.
  ///
  /// In tr, this message translates to:
  /// **'Açık kaynak kütüphaneler ve gizlilik politikası için uygulama ayarlarından SSS bölümüne bakabilirsiniz.'**
  String get aboutOpenSourceNote;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get aboutPrivacyPolicy;

  /// No description provided for @feedbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedbackTitle;

  /// No description provided for @feedbackHeading.
  ///
  /// In tr, this message translates to:
  /// **'Görüş ve Önerileriniz'**
  String get feedbackHeading;

  /// No description provided for @feedbackBody.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama ile ilgili her türlü görüş, öneri ve hata bildirimlerinizi bize iletebilirsiniz.'**
  String get feedbackBody;

  /// No description provided for @feedbackEmailButton.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile Geri Bildirim Gönder'**
  String get feedbackEmailButton;

  /// No description provided for @feedbackEmailSubject.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedbackEmailSubject;

  /// No description provided for @feedbackEmailBody.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama hakkında görüşlerim:'**
  String get feedbackEmailBody;

  /// No description provided for @feedbackEmailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta: info@qrkodproje.com'**
  String get feedbackEmailAddress;

  /// No description provided for @helpFaqTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yardım / SSS'**
  String get helpFaqTitle;

  /// No description provided for @helpFaqHeading.
  ///
  /// In tr, this message translates to:
  /// **'Sıkça Sorulan Sorular'**
  String get helpFaqHeading;

  /// No description provided for @helpFaqQ1.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama ile nasıl QR kod oluşturabilir miyim?'**
  String get helpFaqQ1;

  /// No description provided for @helpFaqA1.
  ///
  /// In tr, this message translates to:
  /// **'Ana ekrandaki QR kod oluştur butonuna tıklayarak kolayca QR kod oluşturabilirsiniz.'**
  String get helpFaqA1;

  /// No description provided for @helpFaqQ2.
  ///
  /// In tr, this message translates to:
  /// **'QR kodu nasıl tarayabilirim?'**
  String get helpFaqQ2;

  /// No description provided for @helpFaqA2.
  ///
  /// In tr, this message translates to:
  /// **'Ana ekrandaki QR kod tara butonunu kullanarak kameralı okutabilirsiniz.'**
  String get helpFaqA2;

  /// No description provided for @helpFaqQ3.
  ///
  /// In tr, this message translates to:
  /// **'Verilerim güvende mi?'**
  String get helpFaqQ3;

  /// No description provided for @helpFaqA3.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileriniz cihazınızda saklanır ve isteğe bağlı olarak Google hesabınızla buluta yedeklenebilir.'**
  String get helpFaqA3;

  /// No description provided for @helpFaqQ4.
  ///
  /// In tr, this message translates to:
  /// **'Premium nedir?'**
  String get helpFaqQ4;

  /// No description provided for @helpFaqA4.
  ///
  /// In tr, this message translates to:
  /// **'Premium ile reklamsız kullanım ve ek özelliklere erişebilirsiniz.'**
  String get helpFaqA4;

  /// No description provided for @helpFaqQ5.
  ///
  /// In tr, this message translates to:
  /// **'Destek veya öneri iletmek istiyorum, nasıl ulaşabilirim?'**
  String get helpFaqQ5;

  /// No description provided for @helpFaqA5.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar > Uygulama Hakkında bölümünden iletişim adresimize ulaşabilirsiniz.'**
  String get helpFaqA5;

  /// No description provided for @helpFaqMoreHelp.
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla yardım için: info@qrkodproje.com'**
  String get helpFaqMoreHelp;

  /// No description provided for @cloudSignInSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Google hesabına giriş başarılı.'**
  String get cloudSignInSuccess;

  /// No description provided for @cloudSignInFailedWithDetail.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız. Detay: {detail}'**
  String cloudSignInFailedWithDetail(Object detail);

  /// No description provided for @cloudSignInFailedGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız. Hesap seçimini onaylayıp tekrar deneyin.'**
  String get cloudSignInFailedGeneric;

  /// No description provided for @cloudSignOutSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapıldı.'**
  String get cloudSignOutSuccess;

  /// No description provided for @cloudBackupSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme başarılı.'**
  String get cloudBackupSuccess;

  /// No description provided for @cloudBackupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme başarısız!'**
  String get cloudBackupFailed;

  /// No description provided for @cloudBackupFailedDetail.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme başarısız oldu. İnternet bağlantınızı ve Google hesabınızı kontrol edin.'**
  String get cloudBackupFailedDetail;

  /// No description provided for @cloudRestoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme başarılı.'**
  String get cloudRestoreSuccess;

  /// No description provided for @cloudRestoreFailed.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme başarısız!'**
  String get cloudRestoreFailed;

  /// No description provided for @cloudRestoreFailedDetail.
  ///
  /// In tr, this message translates to:
  /// **'Geri yükleme başarısız oldu. Yedek dosyası bulunamadı veya bağlantı hatası.'**
  String get cloudRestoreFailedDetail;

  /// No description provided for @cloudErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get cloudErrorTitle;

  /// No description provided for @cloudRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get cloudRetry;

  /// No description provided for @cloudSendFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim Gönder'**
  String get cloudSendFeedback;

  /// No description provided for @cloudLastBackupLabel.
  ///
  /// In tr, this message translates to:
  /// **'Son yedek: {dateTime}'**
  String cloudLastBackupLabel(Object dateTime);

  /// No description provided for @cloudSignInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get cloudSignInWithGoogle;

  /// No description provided for @cloudBackupData.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Yedekle'**
  String get cloudBackupData;

  /// No description provided for @cloudRestoreBackup.
  ///
  /// In tr, this message translates to:
  /// **'Yedeği Geri Yükle'**
  String get cloudRestoreBackup;

  /// No description provided for @cloudSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get cloudSignOut;

  /// No description provided for @historyAddedToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere eklendi'**
  String get historyAddedToFavorites;

  /// No description provided for @historyAddToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get historyAddToFavorites;

  /// No description provided for @historyShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get historyShare;

  /// No description provided for @historyDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get historyDelete;

  /// No description provided for @historyQrCopiedForShare.
  ///
  /// In tr, this message translates to:
  /// **'QR verisi panoya kopyalandı (paylaşım eklenecek)'**
  String get historyQrCopiedForShare;

  /// No description provided for @historyRecordDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt silindi'**
  String get historyRecordDeleted;

  /// No description provided for @historyTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tür: {type}'**
  String historyTypeLabel(Object type);

  /// No description provided for @historyDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih: {date}'**
  String historyDateLabel(Object date);

  /// No description provided for @historyCategoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori: {category}'**
  String historyCategoryLabel(Object category);

  /// No description provided for @historyEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz geçmiş yok'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Burada taradığınız veya oluşturduğunuz QR kodlar listelenecek.'**
  String get historyEmptySubtitle;

  /// No description provided for @historyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlar'**
  String get historyTitle;

  /// No description provided for @historyFilter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get historyFilter;

  /// No description provided for @historySort.
  ///
  /// In tr, this message translates to:
  /// **'Sırala'**
  String get historySort;

  /// No description provided for @historySortByDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarihe göre'**
  String get historySortByDate;

  /// No description provided for @historySortByName.
  ///
  /// In tr, this message translates to:
  /// **'İsme göre'**
  String get historySortByName;

  /// No description provided for @historySortByType.
  ///
  /// In tr, this message translates to:
  /// **'Türe göre'**
  String get historySortByType;

  /// No description provided for @historyDeleteSelected.
  ///
  /// In tr, this message translates to:
  /// **'Seçilenleri Sil'**
  String get historyDeleteSelected;

  /// No description provided for @historyToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere'**
  String get historyToFavorites;

  /// No description provided for @historyClearAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Temizle'**
  String get historyClearAll;

  /// No description provided for @historyAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get historyAll;

  /// No description provided for @historyType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get historyType;

  /// No description provided for @historyTag.
  ///
  /// In tr, this message translates to:
  /// **'Etiket'**
  String get historyTag;

  /// No description provided for @historyCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get historyCategory;

  /// No description provided for @historyDateRangeNotSelected.
  ///
  /// In tr, this message translates to:
  /// **'Tarih aralığı seçilmedi'**
  String get historyDateRangeNotSelected;

  /// No description provided for @historySelectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seç'**
  String get historySelectDate;

  /// No description provided for @historyCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get historyCancel;

  /// No description provided for @historyApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get historyApply;

  /// No description provided for @historyAddedAndSkippedMessage.
  ///
  /// In tr, this message translates to:
  /// **'{added} eklendi, {skipped} zaten favori'**
  String historyAddedAndSkippedMessage(Object added, Object skipped);

  /// No description provided for @historyAddedToFavoritesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} favorilere eklendi'**
  String historyAddedToFavoritesCount(Object count);

  /// No description provided for @historyDeleteSelectedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seçili QR Kodları Sil'**
  String get historyDeleteSelectedTitle;

  /// No description provided for @historyDeleteSelectedConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{count} QR kodunu silmek istediğinize emin misiniz?'**
  String historyDeleteSelectedConfirm(Object count);

  /// No description provided for @historySelectedDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Seçili QR kodlar silindi'**
  String get historySelectedDeleted;

  /// No description provided for @historyUndo.
  ///
  /// In tr, this message translates to:
  /// **'GERİ AL'**
  String get historyUndo;

  /// No description provided for @historyClearAllTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Temizle'**
  String get historyClearAllTitle;

  /// No description provided for @historyClearAllConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtları silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String get historyClearAllConfirm;

  /// No description provided for @historyAllCleared.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtlar temizlendi'**
  String get historyAllCleared;

  /// No description provided for @favoritesEditNoteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Favori Notunu Düzenle'**
  String get favoritesEditNoteTitle;

  /// No description provided for @favoritesOptionalNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Not (boş bırakılabilir)'**
  String get favoritesOptionalNoteLabel;

  /// No description provided for @favoritesCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get favoritesCancel;

  /// No description provided for @favoritesNoteUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Favori notu güncellendi'**
  String get favoritesNoteUpdated;

  /// No description provided for @favoritesAdvancedFilter.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Filtrele'**
  String get favoritesAdvancedFilter;

  /// No description provided for @favoritesAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get favoritesAll;

  /// No description provided for @favoritesType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get favoritesType;

  /// No description provided for @favoritesTag.
  ///
  /// In tr, this message translates to:
  /// **'Etiket'**
  String get favoritesTag;

  /// No description provided for @favoritesDateRangeNotSelected.
  ///
  /// In tr, this message translates to:
  /// **'Tarih aralığı seçilmedi'**
  String get favoritesDateRangeNotSelected;

  /// No description provided for @favoritesSelectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seç'**
  String get favoritesSelectDate;

  /// No description provided for @favoritesApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get favoritesApply;

  /// No description provided for @favoritesSelectedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} seçili'**
  String favoritesSelectedCount(Object count);

  /// No description provided for @favoritesCancelSelection.
  ///
  /// In tr, this message translates to:
  /// **'Seçimi İptal Et'**
  String get favoritesCancelSelection;

  /// No description provided for @favoritesDeleteSelectedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seçili Favorileri Sil'**
  String get favoritesDeleteSelectedTitle;

  /// No description provided for @favoritesDeleteSelectedConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{count} favoriyi silmek istediğinize emin misiniz?'**
  String favoritesDeleteSelectedConfirm(Object count);

  /// No description provided for @favoritesDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get favoritesDelete;

  /// No description provided for @favoritesSelectedDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Seçili favoriler silindi'**
  String get favoritesSelectedDeleted;

  /// No description provided for @favoritesSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerde ara...'**
  String get favoritesSearchHint;

  /// No description provided for @favoritesTypeFilter.
  ///
  /// In tr, this message translates to:
  /// **'Tür Filtresi'**
  String get favoritesTypeFilter;

  /// No description provided for @favoritesNoSearchResults.
  ///
  /// In tr, this message translates to:
  /// **'Arama sonucu bulunamadı'**
  String get favoritesNoSearchResults;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori yok'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesTryDifferentKeywords.
  ///
  /// In tr, this message translates to:
  /// **'Farklı kelimeler deneyin'**
  String get favoritesTryDifferentKeywords;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'QR kodları tarayıp favorilere ekleyebilirsiniz'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesAddedAt.
  ///
  /// In tr, this message translates to:
  /// **'Eklenme'**
  String get favoritesAddedAt;

  /// No description provided for @favoritesContentLabel.
  ///
  /// In tr, this message translates to:
  /// **'İçerik:'**
  String get favoritesContentLabel;

  /// No description provided for @favoritesUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullan'**
  String get favoritesUse;

  /// No description provided for @favoritesShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get favoritesShare;

  /// No description provided for @favoritesEditNameTitle.
  ///
  /// In tr, this message translates to:
  /// **'Favori Adını Değiştir'**
  String get favoritesEditNameTitle;

  /// No description provided for @favoritesOptionalCustomNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Özel ad (boş bırakılabilir)'**
  String get favoritesOptionalCustomNameLabel;

  /// No description provided for @favoritesNameUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Favori adı güncellendi'**
  String get favoritesNameUpdated;

  /// No description provided for @favoritesCopiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyalandı'**
  String get favoritesCopiedToClipboard;

  /// No description provided for @favoritesRemovedMessage.
  ///
  /// In tr, this message translates to:
  /// **'{name} favorilerden silindi'**
  String favoritesRemovedMessage(Object name);

  /// No description provided for @favoritesUndo.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get favoritesUndo;

  /// No description provided for @favoritesClearAllTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Favorileri Temizle'**
  String get favoritesClearAllTitle;

  /// No description provided for @favoritesClearAllConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm favorileri silmek istediğinizden emin misiniz?'**
  String get favoritesClearAllConfirm;

  /// No description provided for @favoritesAllCleared.
  ///
  /// In tr, this message translates to:
  /// **'Tüm favoriler temizlendi'**
  String get favoritesAllCleared;

  /// No description provided for @favoritesShowQr.
  ///
  /// In tr, this message translates to:
  /// **'QR Göster'**
  String get favoritesShowQr;

  /// No description provided for @favoritesRename.
  ///
  /// In tr, this message translates to:
  /// **'Adını Değiştir'**
  String get favoritesRename;

  /// No description provided for @favoritesEditNote.
  ///
  /// In tr, this message translates to:
  /// **'Notu Düzenle'**
  String get favoritesEditNote;

  /// No description provided for @favoritesCopy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get favoritesCopy;

  /// No description provided for @favoritesTodayAt.
  ///
  /// In tr, this message translates to:
  /// **'Bugün {time}'**
  String favoritesTodayAt(Object time);

  /// No description provided for @favoritesYesterdayAt.
  ///
  /// In tr, this message translates to:
  /// **'Dün {time}'**
  String favoritesYesterdayAt(Object time);

  /// No description provided for @favoritesDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce'**
  String favoritesDaysAgo(Object days);

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get commonCancel;

  /// No description provided for @priceAlertDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alarm Detayı'**
  String get priceAlertDetailTitle;

  /// No description provided for @priceAlertDetailDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı Sil'**
  String get priceAlertDetailDeleteTitle;

  /// No description provided for @priceAlertDetailDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu fiyat alarmını silmek istediğinizden emin misiniz?'**
  String get priceAlertDetailDeleteConfirm;

  /// No description provided for @priceAlertDetailDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get priceAlertDetailDeleteButton;

  /// No description provided for @priceAlertDetailBarcodeCopied.
  ///
  /// In tr, this message translates to:
  /// **'Barkod kopyalandı!'**
  String get priceAlertDetailBarcodeCopied;

  /// No description provided for @priceAlertDetailShareFormat.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım Formatı'**
  String get priceAlertDetailShareFormat;

  /// No description provided for @priceAlertDetailShareFormatQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hangi formatta paylaşmak istiyorsunuz?'**
  String get priceAlertDetailShareFormatQuestion;

  /// No description provided for @priceAlertDetailShareCompact.
  ///
  /// In tr, this message translates to:
  /// **'Kısa Format'**
  String get priceAlertDetailShareCompact;

  /// No description provided for @priceAlertDetailShareDetailed.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı Format'**
  String get priceAlertDetailShareDetailed;

  /// No description provided for @priceAlertDetailUnknownProduct.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Ürün'**
  String get priceAlertDetailUnknownProduct;

  /// No description provided for @priceAlertDetailUnknownSource.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get priceAlertDetailUnknownSource;

  /// No description provided for @priceAlertDetailNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Alarm bulunamadı'**
  String get priceAlertDetailNotFound;

  /// No description provided for @priceAlertDetailBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön'**
  String get priceAlertDetailBack;

  /// No description provided for @priceAlertDetailTriggered.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Hedefine Ulaştı!'**
  String get priceAlertDetailTriggered;

  /// No description provided for @priceAlertDetailProductName.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Adı'**
  String get priceAlertDetailProductName;

  /// No description provided for @priceAlertDetailTargetPrice.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Fiyat'**
  String get priceAlertDetailTargetPrice;

  /// No description provided for @priceAlertDetailCurrentPrice.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Fiyat'**
  String get priceAlertDetailCurrentPrice;

  /// No description provided for @priceAlertDetailSource.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak'**
  String get priceAlertDetailSource;

  /// No description provided for @priceAlertDetailBarcode.
  ///
  /// In tr, this message translates to:
  /// **'Barkod'**
  String get priceAlertDetailBarcode;

  /// No description provided for @priceAlertDetailTapToCopy.
  ///
  /// In tr, this message translates to:
  /// **'Dokunarak Kopyala'**
  String get priceAlertDetailTapToCopy;

  /// No description provided for @priceAlertDetailCreatedAt.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulma: {date}'**
  String priceAlertDetailCreatedAt(String date);

  /// No description provided for @priceAlertDetailShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get priceAlertDetailShare;

  /// No description provided for @customQrTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Özelleştirme'**
  String get customQrTitle;

  /// No description provided for @customQrShareTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get customQrShareTooltip;

  /// No description provided for @customQrSaveTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get customQrSaveTooltip;

  /// No description provided for @customQrTabColors.
  ///
  /// In tr, this message translates to:
  /// **'Renkler'**
  String get customQrTabColors;

  /// No description provided for @customQrTabLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logo'**
  String get customQrTabLogo;

  /// No description provided for @customQrTabStyle.
  ///
  /// In tr, this message translates to:
  /// **'Stil'**
  String get customQrTabStyle;

  /// No description provided for @customQrTabSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get customQrTabSettings;

  /// No description provided for @customQrPresetColors.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Renkler'**
  String get customQrPresetColors;

  /// No description provided for @customQrCustomColors.
  ///
  /// In tr, this message translates to:
  /// **'Özel Renkler'**
  String get customQrCustomColors;

  /// No description provided for @customQrColorFg.
  ///
  /// In tr, this message translates to:
  /// **'QR Rengi'**
  String get customQrColorFg;

  /// No description provided for @customQrColorBg.
  ///
  /// In tr, this message translates to:
  /// **'Arkaplan'**
  String get customQrColorBg;

  /// No description provided for @customQrAddLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logo Ekle'**
  String get customQrAddLogo;

  /// No description provided for @customQrLogoSize.
  ///
  /// In tr, this message translates to:
  /// **'Logo Boyutu'**
  String get customQrLogoSize;

  /// No description provided for @customQrSelectLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logo Seçin'**
  String get customQrSelectLogo;

  /// No description provided for @customQrCornerRadius.
  ///
  /// In tr, this message translates to:
  /// **'Köşe Yuvarlağı'**
  String get customQrCornerRadius;

  /// No description provided for @customQrErrorLevel.
  ///
  /// In tr, this message translates to:
  /// **'Hata Düzetme Seviyesi'**
  String get customQrErrorLevel;

  /// No description provided for @customQrErrorLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük (L) - %7'**
  String get customQrErrorLow;

  /// No description provided for @customQrErrorMid.
  ///
  /// In tr, this message translates to:
  /// **'Orta (M) - %15'**
  String get customQrErrorMid;

  /// No description provided for @customQrErrorHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek (Q) - %25'**
  String get customQrErrorHigh;

  /// No description provided for @customQrErrorMax.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek (H) - %30'**
  String get customQrErrorMax;

  /// No description provided for @customQrErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hata Düzetme'**
  String get customQrErrorTitle;

  /// No description provided for @customQrErrorDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek seviye, QR kodun daha fazla hasar alsa bile okunabilir olmasını sağlar, ancak daha karmaşık görünür.'**
  String get customQrErrorDesc;

  /// No description provided for @customQrInfo.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Bilgileri'**
  String get customQrInfo;

  /// No description provided for @customQrInfoData.
  ///
  /// In tr, this message translates to:
  /// **'Veri: {data}'**
  String customQrInfoData(String data);

  /// No description provided for @customQrInfoCharCount.
  ///
  /// In tr, this message translates to:
  /// **'Karakter Sayısı: {count}'**
  String customQrInfoCharCount(int count);

  /// No description provided for @customQrInfoErrorLevel.
  ///
  /// In tr, this message translates to:
  /// **'Hata Düzetme: {level}'**
  String customQrInfoErrorLevel(String level);

  /// No description provided for @customQrPresets.
  ///
  /// In tr, this message translates to:
  /// **'Önceden Tanımlı Stiller'**
  String get customQrPresets;

  /// No description provided for @customQrPresetClassic.
  ///
  /// In tr, this message translates to:
  /// **'Klasik'**
  String get customQrPresetClassic;

  /// No description provided for @customQrPresetModern.
  ///
  /// In tr, this message translates to:
  /// **'Modern'**
  String get customQrPresetModern;

  /// No description provided for @customQrPresetMinimal.
  ///
  /// In tr, this message translates to:
  /// **'Minimal'**
  String get customQrPresetMinimal;

  /// No description provided for @customQrPresetPremium.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get customQrPresetPremium;

  /// No description provided for @customQrColorPickerFg.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Rengi'**
  String get customQrColorPickerFg;

  /// No description provided for @customQrColorPickerBg.
  ///
  /// In tr, this message translates to:
  /// **'Arkaplan Rengi'**
  String get customQrColorPickerBg;

  /// No description provided for @customQrErrorCreate.
  ///
  /// In tr, this message translates to:
  /// **'QR kod oluşturulamadı!'**
  String get customQrErrorCreate;

  /// No description provided for @customQrErrorImage.
  ///
  /// In tr, this message translates to:
  /// **'QR kod resmi oluşturulamadı!'**
  String get customQrErrorImage;

  /// No description provided for @customQrShareText.
  ///
  /// In tr, this message translates to:
  /// **'İşte özelleştirilmiş QR kodum!'**
  String get customQrShareText;

  /// No description provided for @customQrShareError.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım hatası: {error}'**
  String customQrShareError(String error);

  /// No description provided for @customQrSaved.
  ///
  /// In tr, this message translates to:
  /// **'Özelleştirilmiş QR kod geçmişe kaydedildi!'**
  String get customQrSaved;

  /// No description provided for @customQrSaveError.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetme hatası: {error}'**
  String customQrSaveError(String error);

  /// No description provided for @customQrErrorLowName.
  ///
  /// In tr, this message translates to:
  /// **'Düşük (L)'**
  String get customQrErrorLowName;

  /// No description provided for @customQrErrorMidName.
  ///
  /// In tr, this message translates to:
  /// **'Orta (M)'**
  String get customQrErrorMidName;

  /// No description provided for @customQrErrorHighName.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek (Q)'**
  String get customQrErrorHighName;

  /// No description provided for @customQrErrorMaxName.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek (H)'**
  String get customQrErrorMaxName;

  /// No description provided for @priceAlertsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmları'**
  String get priceAlertsTitle;

  /// No description provided for @priceAlertsDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı Sil'**
  String get priceAlertsDeleteTitle;

  /// No description provided for @priceAlertsDeleteContent.
  ///
  /// In tr, this message translates to:
  /// **'Bu fiyat alarmını silmek istediğinizden emin misiniz?'**
  String get priceAlertsDeleteContent;

  /// No description provided for @priceAlertsDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get priceAlertsDeleteButton;

  /// No description provided for @priceAlertsDeletedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı silindi'**
  String get priceAlertsDeletedMsg;

  /// No description provided for @priceAlertsBarcodecopied.
  ///
  /// In tr, this message translates to:
  /// **'Barkod kopyalandı'**
  String get priceAlertsBarcodecopied;

  /// No description provided for @priceAlertsProductNameCopied.
  ///
  /// In tr, this message translates to:
  /// **'Ürün adı kopyalandı'**
  String get priceAlertsProductNameCopied;

  /// No description provided for @priceAlertsShareSubject.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmı Paylaşımı'**
  String get priceAlertsShareSubject;

  /// No description provided for @priceAlertsShareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmı'**
  String get priceAlertsShareTitle;

  /// No description provided for @priceAlertsShareProduct.
  ///
  /// In tr, this message translates to:
  /// **'Ürün: {name}'**
  String priceAlertsShareProduct(String name);

  /// No description provided for @priceAlertsShareBarcode.
  ///
  /// In tr, this message translates to:
  /// **'Barkod: {barcode}'**
  String priceAlertsShareBarcode(String barcode);

  /// No description provided for @priceAlertsShareSource.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: {source}'**
  String priceAlertsShareSource(String source);

  /// No description provided for @priceAlertsShareTargetPrice.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Fiyat: {price}'**
  String priceAlertsShareTargetPrice(String price);

  /// No description provided for @priceAlertsShareCurrentPrice.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Fiyat: {price}'**
  String priceAlertsShareCurrentPrice(String price);

  /// No description provided for @priceAlertsRefreshTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get priceAlertsRefreshTooltip;

  /// No description provided for @priceAlertsFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get priceAlertsFilterAll;

  /// No description provided for @priceAlertsFilterTriggered.
  ///
  /// In tr, this message translates to:
  /// **'Tetiklenen'**
  String get priceAlertsFilterTriggered;

  /// No description provided for @priceAlertsFilterPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen'**
  String get priceAlertsFilterPending;

  /// No description provided for @priceAlertsSortNewest.
  ///
  /// In tr, this message translates to:
  /// **'En Yeni'**
  String get priceAlertsSortNewest;

  /// No description provided for @priceAlertsSortClosest.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe En Yakın'**
  String get priceAlertsSortClosest;

  /// No description provided for @priceAlertsSortHighest.
  ///
  /// In tr, this message translates to:
  /// **'Farkı En Yüksek'**
  String get priceAlertsSortHighest;

  /// No description provided for @priceAlertsEmptyTriggered.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tetiklenen alarm yok.'**
  String get priceAlertsEmptyTriggered;

  /// No description provided for @priceAlertsEmptyPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen alarm bulunmuyor.'**
  String get priceAlertsEmptyPending;

  /// No description provided for @priceAlertsEmptyAll.
  ///
  /// In tr, this message translates to:
  /// **'Henüz fiyat alarmı yok'**
  String get priceAlertsEmptyAll;

  /// No description provided for @priceAlertsTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get priceAlertsTotal;

  /// No description provided for @priceAlertsEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir ürün barkodunu tarayın ve \"Fiyat Karşılaştır\" sekmesinden alarm kurun.'**
  String get priceAlertsEmptyHint;

  /// No description provided for @priceAlertsAllSources.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kaynaklar'**
  String get priceAlertsAllSources;

  /// No description provided for @priceAlertsUnknownProduct.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Ürün'**
  String get priceAlertsUnknownProduct;

  /// No description provided for @priceAlertsCreatedAt.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulma: {date}'**
  String priceAlertsCreatedAt(String date);

  /// No description provided for @priceAlertsNewBadge.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get priceAlertsNewBadge;

  /// No description provided for @priceAlertsQuickActions.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı aksiyonlar'**
  String get priceAlertsQuickActions;

  /// No description provided for @priceAlertsCopyBarcodeItem.
  ///
  /// In tr, this message translates to:
  /// **'Barkodu Kopyala'**
  String get priceAlertsCopyBarcodeItem;

  /// No description provided for @priceAlertsCopyProductNameItem.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Adını Kopyala'**
  String get priceAlertsCopyProductNameItem;

  /// No description provided for @priceAlertsShareAlertItem.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı Paylaş'**
  String get priceAlertsShareAlertItem;

  /// No description provided for @priceAlertsDeleteTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı sil'**
  String get priceAlertsDeleteTooltip;

  /// No description provided for @priceAlertsSourceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: {source}'**
  String priceAlertsSourceLabel(String source);

  /// No description provided for @priceAlertsBarcodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Barkod: {barcode}'**
  String priceAlertsBarcodeLabel(String barcode);

  /// No description provided for @priceAlertsTargetPrice.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Fiyat'**
  String get priceAlertsTargetPrice;

  /// No description provided for @priceAlertsCurrentPrice.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Fiyat'**
  String get priceAlertsCurrentPrice;

  /// No description provided for @priceAlertsPriceReached.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat hedefe ulaştı!'**
  String get priceAlertsPriceReached;

  /// No description provided for @qrDetailImageShared.
  ///
  /// In tr, this message translates to:
  /// **'QR kod resmi paylaşıldı'**
  String get qrDetailImageShared;

  /// No description provided for @qrDetailShareError.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşma hatası: {error}'**
  String qrDetailShareError(String error);

  /// No description provided for @qrDetailSelectShareType.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım Türü Seç'**
  String get qrDetailSelectShareType;

  /// No description provided for @qrDetailShareTextTitle.
  ///
  /// In tr, this message translates to:
  /// **'Metin Paylaş'**
  String get qrDetailShareTextTitle;

  /// No description provided for @qrDetailShareTextSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'QR kod içeriğini metin olarak paylaş'**
  String get qrDetailShareTextSubtitle;

  /// No description provided for @qrDetailShareImageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Resim Paylaş'**
  String get qrDetailShareImageTitle;

  /// No description provided for @qrDetailShareImageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'QR kodu resim olarak paylaş'**
  String get qrDetailShareImageSubtitle;

  /// No description provided for @qrDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Detayı'**
  String get qrDetailTitle;

  /// No description provided for @qrDetailCopyTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get qrDetailCopyTooltip;

  /// No description provided for @qrDetailCopiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyalandı'**
  String get qrDetailCopiedToClipboard;

  /// No description provided for @qrDetailShareTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get qrDetailShareTooltip;

  /// No description provided for @qrDetailCheapestWhere.
  ///
  /// In tr, this message translates to:
  /// **'En ucuz nerede?'**
  String get qrDetailCheapestWhere;

  /// No description provided for @qrDetailType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get qrDetailType;

  /// No description provided for @qrDetailCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get qrDetailCategory;

  /// No description provided for @qrDetailNoCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori yok'**
  String get qrDetailNoCategory;

  /// No description provided for @qrDetailName.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get qrDetailName;

  /// No description provided for @qrDetailData.
  ///
  /// In tr, this message translates to:
  /// **'Veri'**
  String get qrDetailData;

  /// No description provided for @qrDetailDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get qrDetailDate;

  /// No description provided for @qrDetailStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get qrDetailStatus;

  /// No description provided for @qrDetailScanned.
  ///
  /// In tr, this message translates to:
  /// **'Tarandı'**
  String get qrDetailScanned;

  /// No description provided for @qrDetailCreated.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturuldu'**
  String get qrDetailCreated;

  /// No description provided for @qrDetailArchive.
  ///
  /// In tr, this message translates to:
  /// **'Arşiv'**
  String get qrDetailArchive;

  /// No description provided for @qrDetailYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get qrDetailYes;

  /// No description provided for @qrDetailNo.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get qrDetailNo;

  /// No description provided for @qrDetailPriceComparison.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Karşılaştırma'**
  String get qrDetailPriceComparison;

  /// No description provided for @qrDetailPriceInfoUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat bilgisi alınamadı.'**
  String get qrDetailPriceInfoUnavailable;

  /// No description provided for @qrDetailClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get qrDetailClose;

  /// No description provided for @qrDetailBrand.
  ///
  /// In tr, this message translates to:
  /// **'Marka: {brand}'**
  String qrDetailBrand(String brand);

  /// No description provided for @qrDetailCategoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori: {category}'**
  String qrDetailCategoryLabel(String category);

  /// No description provided for @qrDetailBuy.
  ///
  /// In tr, this message translates to:
  /// **'Satın Al'**
  String get qrDetailBuy;

  /// No description provided for @qrDetailPriceHistory30Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 30 Gün Fiyat Geçmişi'**
  String get qrDetailPriceHistory30Days;

  /// No description provided for @qrDetailOtherPrices.
  ///
  /// In tr, this message translates to:
  /// **'Diğer Fiyatlar'**
  String get qrDetailOtherPrices;

  /// No description provided for @qrDetailNoPriceHistory.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat geçmişi verisi bulunamadı.'**
  String get qrDetailNoPriceHistory;

  /// No description provided for @qrDetailMin.
  ///
  /// In tr, this message translates to:
  /// **'Min'**
  String get qrDetailMin;

  /// No description provided for @qrDetailMax.
  ///
  /// In tr, this message translates to:
  /// **'Max'**
  String get qrDetailMax;

  /// No description provided for @qrDetailPriceAlert.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmı'**
  String get qrDetailPriceAlert;

  /// No description provided for @qrDetailSetTargetHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün için hedef fiyat belirleyin. Fiyat düşünce takip listesinde görebileceksiniz.'**
  String get qrDetailSetTargetHint;

  /// No description provided for @qrDetailTargetPriceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef fiyat: {price}'**
  String qrDetailTargetPriceLabel(String price);

  /// No description provided for @qrDetailSetAlert.
  ///
  /// In tr, this message translates to:
  /// **'Alarm Kur'**
  String get qrDetailSetAlert;

  /// No description provided for @qrDetailUpdateAlert.
  ///
  /// In tr, this message translates to:
  /// **'Alarmı Güncelle'**
  String get qrDetailUpdateAlert;

  /// No description provided for @qrDetailAlertDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı silindi.'**
  String get qrDetailAlertDeleted;

  /// No description provided for @qrDetailAlertDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı silinemedi.'**
  String get qrDetailAlertDeleteFailed;

  /// No description provided for @qrDetailSetPriceAlertTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat Alarmı Kur'**
  String get qrDetailSetPriceAlertTitle;

  /// No description provided for @qrDetailEnterTargetPrice.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün için hedef fiyat girin.'**
  String get qrDetailEnterTargetPrice;

  /// No description provided for @qrDetailTargetPriceInput.
  ///
  /// In tr, this message translates to:
  /// **'Hedef fiyat'**
  String get qrDetailTargetPriceInput;

  /// No description provided for @qrDetailEnterValidPrice.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir fiyat girin.'**
  String get qrDetailEnterValidPrice;

  /// No description provided for @qrDetailAlertSaved.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı kaydedildi.'**
  String get qrDetailAlertSaved;

  /// No description provided for @qrDetailAlertSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat alarmı kaydedilemedi.'**
  String get qrDetailAlertSaveFailed;

  /// No description provided for @qrDetailSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get qrDetailSave;

  /// No description provided for @enhancedQrGenTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Üretici'**
  String get enhancedQrGenTitle;

  /// No description provided for @enhancedQrGenHelpTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get enhancedQrGenHelpTooltip;

  /// No description provided for @enhancedQrGenHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Oluştur'**
  String get enhancedQrGenHeaderTitle;

  /// No description provided for @enhancedQrGenHeaderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Farklı türde QR kodları kolayca oluşturun'**
  String get enhancedQrGenHeaderSubtitle;

  /// No description provided for @enhancedQrGenTypeSelect.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Türü Seçin:'**
  String get enhancedQrGenTypeSelect;

  /// No description provided for @enhancedQrGenTypeText.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get enhancedQrGenTypeText;

  /// No description provided for @enhancedQrGenTypeUrl.
  ///
  /// In tr, this message translates to:
  /// **'URL'**
  String get enhancedQrGenTypeUrl;

  /// No description provided for @enhancedQrGenTypeWifi.
  ///
  /// In tr, this message translates to:
  /// **'WiFi'**
  String get enhancedQrGenTypeWifi;

  /// No description provided for @enhancedQrGenTypePhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get enhancedQrGenTypePhone;

  /// No description provided for @enhancedQrGenTypeEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-mail'**
  String get enhancedQrGenTypeEmail;

  /// No description provided for @enhancedQrGenTypeSms.
  ///
  /// In tr, this message translates to:
  /// **'SMS'**
  String get enhancedQrGenTypeSms;

  /// No description provided for @enhancedQrGenTypeLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get enhancedQrGenTypeLocation;

  /// No description provided for @enhancedQrGenTypeVcard.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizit'**
  String get enhancedQrGenTypeVcard;

  /// No description provided for @enhancedQrGenTextInput.
  ///
  /// In tr, this message translates to:
  /// **'Metin Girişi:'**
  String get enhancedQrGenTextInput;

  /// No description provided for @enhancedQrGenTextHint.
  ///
  /// In tr, this message translates to:
  /// **'QR kod olacak metni yazın...'**
  String get enhancedQrGenTextHint;

  /// No description provided for @enhancedQrGenUrlInput.
  ///
  /// In tr, this message translates to:
  /// **'URL Girişi:'**
  String get enhancedQrGenUrlInput;

  /// No description provided for @enhancedQrGenUrlHint.
  ///
  /// In tr, this message translates to:
  /// **'https://www.ornek.com'**
  String get enhancedQrGenUrlHint;

  /// No description provided for @enhancedQrGenHttps.
  ///
  /// In tr, this message translates to:
  /// **'HTTPS'**
  String get enhancedQrGenHttps;

  /// No description provided for @enhancedQrGenHttp.
  ///
  /// In tr, this message translates to:
  /// **'HTTP'**
  String get enhancedQrGenHttp;

  /// No description provided for @enhancedQrGenWifiInfo.
  ///
  /// In tr, this message translates to:
  /// **'WiFi Bilgileri:'**
  String get enhancedQrGenWifiInfo;

  /// No description provided for @enhancedQrGenWifiSsid.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Adı (SSID)'**
  String get enhancedQrGenWifiSsid;

  /// No description provided for @enhancedQrGenWifiSsidHint.
  ///
  /// In tr, this message translates to:
  /// **'WiFi ağ adını girin'**
  String get enhancedQrGenWifiSsidHint;

  /// No description provided for @enhancedQrGenWifiPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get enhancedQrGenWifiPassword;

  /// No description provided for @enhancedQrGenWifiPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'WiFi şifresini girin'**
  String get enhancedQrGenWifiPasswordHint;

  /// No description provided for @enhancedQrGenWifiSecurity.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Türü'**
  String get enhancedQrGenWifiSecurity;

  /// No description provided for @enhancedQrGenWifiOpenNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Açık Ağ'**
  String get enhancedQrGenWifiOpenNetwork;

  /// No description provided for @enhancedQrGenPhoneNumber.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası:'**
  String get enhancedQrGenPhoneNumber;

  /// No description provided for @enhancedQrGenEmailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-mail Adresi:'**
  String get enhancedQrGenEmailAddress;

  /// No description provided for @enhancedQrGenEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'ornek@email.com'**
  String get enhancedQrGenEmailHint;

  /// No description provided for @enhancedQrGenSmsInfo.
  ///
  /// In tr, this message translates to:
  /// **'SMS Bilgileri:'**
  String get enhancedQrGenSmsInfo;

  /// No description provided for @enhancedQrGenPhoneNumberLabel.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get enhancedQrGenPhoneNumberLabel;

  /// No description provided for @enhancedQrGenSmsMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get enhancedQrGenSmsMessage;

  /// No description provided for @enhancedQrGenSmsHint.
  ///
  /// In tr, this message translates to:
  /// **'SMS mesajınızı yazın...'**
  String get enhancedQrGenSmsHint;

  /// No description provided for @enhancedQrGenLocationInfo.
  ///
  /// In tr, this message translates to:
  /// **'Konum Bilgileri:'**
  String get enhancedQrGenLocationInfo;

  /// No description provided for @enhancedQrGenLatitude.
  ///
  /// In tr, this message translates to:
  /// **'Enlem (Latitude)'**
  String get enhancedQrGenLatitude;

  /// No description provided for @enhancedQrGenLongitude.
  ///
  /// In tr, this message translates to:
  /// **'Boylam (Longitude)'**
  String get enhancedQrGenLongitude;

  /// No description provided for @enhancedQrGenVcardInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizit Bilgileri:'**
  String get enhancedQrGenVcardInfo;

  /// No description provided for @enhancedQrGenFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get enhancedQrGenFullName;

  /// No description provided for @enhancedQrGenPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get enhancedQrGenPhone;

  /// No description provided for @enhancedQrGenEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-mail'**
  String get enhancedQrGenEmail;

  /// No description provided for @enhancedQrGenCompany.
  ///
  /// In tr, this message translates to:
  /// **'Şirket/Organizasyon'**
  String get enhancedQrGenCompany;

  /// No description provided for @enhancedQrGenWebsite.
  ///
  /// In tr, this message translates to:
  /// **'Web Sitesi'**
  String get enhancedQrGenWebsite;

  /// No description provided for @enhancedQrGenAdvancedSettings.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Ayarlar (Logo & Hassasiyet)'**
  String get enhancedQrGenAdvancedSettings;

  /// No description provided for @enhancedQrGenErrorCorrection.
  ///
  /// In tr, this message translates to:
  /// **'Hata Düzeltme Seviyesi'**
  String get enhancedQrGenErrorCorrection;

  /// No description provided for @enhancedQrGenErrorCorrectionHint.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek seviye (H), logo eklerken veya hasarlı kodlar için önerilir.'**
  String get enhancedQrGenErrorCorrectionHint;

  /// No description provided for @enhancedQrGenErrorLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük (%7)'**
  String get enhancedQrGenErrorLow;

  /// No description provided for @enhancedQrGenErrorMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta (%15)'**
  String get enhancedQrGenErrorMedium;

  /// No description provided for @enhancedQrGenErrorQuality.
  ///
  /// In tr, this message translates to:
  /// **'Kaliteli (%25)'**
  String get enhancedQrGenErrorQuality;

  /// No description provided for @enhancedQrGenErrorHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek (%30)'**
  String get enhancedQrGenErrorHigh;

  /// No description provided for @enhancedQrGenAddLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logo Ekle'**
  String get enhancedQrGenAddLogo;

  /// No description provided for @enhancedQrGenChangeLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logoyu Değiştir'**
  String get enhancedQrGenChangeLogo;

  /// No description provided for @enhancedQrGenRemoveLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logoyu Kaldır'**
  String get enhancedQrGenRemoveLogo;

  /// No description provided for @enhancedQrGenPreview.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Önizleme'**
  String get enhancedQrGenPreview;

  /// No description provided for @enhancedQrGenCopy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get enhancedQrGenCopy;

  /// No description provided for @enhancedQrGenShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get enhancedQrGenShare;

  /// No description provided for @enhancedQrGenSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get enhancedQrGenSave;

  /// No description provided for @enhancedQrGenFavoriteNoteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Favori Notu/Etiketi'**
  String get enhancedQrGenFavoriteNoteTitle;

  /// No description provided for @enhancedQrGenFavoriteNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Kısa not veya etiket (isteğe bağlı)'**
  String get enhancedQrGenFavoriteNoteHint;

  /// No description provided for @enhancedQrGenAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get enhancedQrGenAdd;

  /// No description provided for @enhancedQrGenAddedToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'⭐ Favorilere eklendi!'**
  String get enhancedQrGenAddedToFavorites;

  /// No description provided for @enhancedQrGenFavoriteError.
  ///
  /// In tr, this message translates to:
  /// **'Zaten favorilerde veya hata: {error}'**
  String enhancedQrGenFavoriteError(String error);

  /// No description provided for @enhancedQrGenFavorited.
  ///
  /// In tr, this message translates to:
  /// **'Favoride'**
  String get enhancedQrGenFavorited;

  /// No description provided for @enhancedQrGenAddToFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere Ekle'**
  String get enhancedQrGenAddToFavorites;

  /// No description provided for @enhancedQrGenCopiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'QR kod verisi panoya kopyalandı'**
  String get enhancedQrGenCopiedToClipboard;

  /// No description provided for @enhancedQrGenSavedToHistory.
  ///
  /// In tr, this message translates to:
  /// **'QR kod geçmişe kaydedildi'**
  String get enhancedQrGenSavedToHistory;

  /// No description provided for @enhancedQrGenCreateFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce bir QR kod oluşturun'**
  String get enhancedQrGenCreateFirst;

  /// No description provided for @enhancedQrGenHelpTitle.
  ///
  /// In tr, this message translates to:
  /// **'QR Kod Türleri Hakkında'**
  String get enhancedQrGenHelpTitle;

  /// No description provided for @enhancedQrGenHelpTextTitle.
  ///
  /// In tr, this message translates to:
  /// **'📝 Metin'**
  String get enhancedQrGenHelpTextTitle;

  /// No description provided for @enhancedQrGenHelpTextDesc.
  ///
  /// In tr, this message translates to:
  /// **'Basit metin içeriği'**
  String get enhancedQrGenHelpTextDesc;

  /// No description provided for @enhancedQrGenHelpUrlTitle.
  ///
  /// In tr, this message translates to:
  /// **'🔗 URL'**
  String get enhancedQrGenHelpUrlTitle;

  /// No description provided for @enhancedQrGenHelpUrlDesc.
  ///
  /// In tr, this message translates to:
  /// **'Web sitesi bağlantıları'**
  String get enhancedQrGenHelpUrlDesc;

  /// No description provided for @enhancedQrGenHelpWifiTitle.
  ///
  /// In tr, this message translates to:
  /// **'📶 WiFi'**
  String get enhancedQrGenHelpWifiTitle;

  /// No description provided for @enhancedQrGenHelpWifiDesc.
  ///
  /// In tr, this message translates to:
  /// **'WiFi ağ bilgileri (SSID, şifre)'**
  String get enhancedQrGenHelpWifiDesc;

  /// No description provided for @enhancedQrGenHelpPhoneTitle.
  ///
  /// In tr, this message translates to:
  /// **'📞 Telefon'**
  String get enhancedQrGenHelpPhoneTitle;

  /// No description provided for @enhancedQrGenHelpPhoneDesc.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numaraları'**
  String get enhancedQrGenHelpPhoneDesc;

  /// No description provided for @enhancedQrGenHelpEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'📧 E-mail'**
  String get enhancedQrGenHelpEmailTitle;

  /// No description provided for @enhancedQrGenHelpEmailDesc.
  ///
  /// In tr, this message translates to:
  /// **'E-mail adresleri'**
  String get enhancedQrGenHelpEmailDesc;

  /// No description provided for @enhancedQrGenHelpSmsTitle.
  ///
  /// In tr, this message translates to:
  /// **'💬 SMS'**
  String get enhancedQrGenHelpSmsTitle;

  /// No description provided for @enhancedQrGenHelpSmsDesc.
  ///
  /// In tr, this message translates to:
  /// **'SMS gönderme bilgileri'**
  String get enhancedQrGenHelpSmsDesc;

  /// No description provided for @enhancedQrGenHelpLocationTitle.
  ///
  /// In tr, this message translates to:
  /// **'📍 Konum'**
  String get enhancedQrGenHelpLocationTitle;

  /// No description provided for @enhancedQrGenHelpLocationDesc.
  ///
  /// In tr, this message translates to:
  /// **'GPS koordinatları'**
  String get enhancedQrGenHelpLocationDesc;

  /// No description provided for @enhancedQrGenHelpVcardTitle.
  ///
  /// In tr, this message translates to:
  /// **'👤 Kartvizit'**
  String get enhancedQrGenHelpVcardTitle;

  /// No description provided for @enhancedQrGenHelpVcardDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kişi iletişim bilgileri'**
  String get enhancedQrGenHelpVcardDesc;

  /// No description provided for @shareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get shareTitle;

  /// No description provided for @shareGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel Paylaşım'**
  String get shareGeneral;

  /// No description provided for @shareWhatsApp.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram'**
  String get shareTelegram;

  /// No description provided for @shareEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-mail'**
  String get shareEmail;

  /// No description provided for @shareSms.
  ///
  /// In tr, this message translates to:
  /// **'SMS'**
  String get shareSms;

  /// No description provided for @securityWarningTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Uyarısı'**
  String get securityWarningTitle;

  /// No description provided for @securityWarningUrlLabel.
  ///
  /// In tr, this message translates to:
  /// **'URL:'**
  String get securityWarningUrlLabel;

  /// No description provided for @securityWarningConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu uyarıyı dikkate alarak devam etmek istediğinizden emin misiniz?'**
  String get securityWarningConfirm;

  /// No description provided for @securityWarningCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get securityWarningCancel;

  /// No description provided for @securityWarningProceedHigh.
  ///
  /// In tr, this message translates to:
  /// **'Risk Alarak Devam Et'**
  String get securityWarningProceedHigh;

  /// No description provided for @securityWarningProceedMedium.
  ///
  /// In tr, this message translates to:
  /// **'Dikkatli Devam Et'**
  String get securityWarningProceedMedium;

  /// No description provided for @securitySiteOpened.
  ///
  /// In tr, this message translates to:
  /// **'Site tarayıcıda açıldı. Güvenliğiniz için dikkatli olun.'**
  String get securitySiteOpened;

  /// No description provided for @securityUrlOpenError.
  ///
  /// In tr, this message translates to:
  /// **'URL açılamadı: {error}'**
  String securityUrlOpenError(String error);

  /// No description provided for @qrActionClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get qrActionClose;

  /// No description provided for @qrActionWifiTitle.
  ///
  /// In tr, this message translates to:
  /// **'WiFi Ağı'**
  String get qrActionWifiTitle;

  /// No description provided for @qrActionWifiSsid.
  ///
  /// In tr, this message translates to:
  /// **'Ağ Adı (SSID)'**
  String get qrActionWifiSsid;

  /// No description provided for @qrActionWifiPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get qrActionWifiPassword;

  /// No description provided for @qrActionWifiSecurity.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get qrActionWifiSecurity;

  /// No description provided for @qrActionWifiConnect.
  ///
  /// In tr, this message translates to:
  /// **'Bağlan'**
  String get qrActionWifiConnect;

  /// No description provided for @qrActionWifiParseError.
  ///
  /// In tr, this message translates to:
  /// **'WiFi bilgileri okunamadı'**
  String get qrActionWifiParseError;

  /// No description provided for @qrActionWifiInstructionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'WiFi Bağlantısı'**
  String get qrActionWifiInstructionsTitle;

  /// No description provided for @qrActionWifiInstructionsContent.
  ///
  /// In tr, this message translates to:
  /// **'WiFi bağlantısı için:'**
  String get qrActionWifiInstructionsContent;

  /// No description provided for @qrActionWifiStep1.
  ///
  /// In tr, this message translates to:
  /// **'1. Ayarlar > WiFi\'ye gidin'**
  String get qrActionWifiStep1;

  /// No description provided for @qrActionWifiStep2.
  ///
  /// In tr, this message translates to:
  /// **'2. Ağı bulun: \"{ssid}\"'**
  String qrActionWifiStep2(String ssid);

  /// No description provided for @qrActionWifiStep3.
  ///
  /// In tr, this message translates to:
  /// **'3. Şifreyi girin: \"{password}\"'**
  String qrActionWifiStep3(String password);

  /// No description provided for @qrActionWifiPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre: {password}'**
  String qrActionWifiPasswordLabel(String password);

  /// No description provided for @qrActionContactTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizit'**
  String get qrActionContactTitle;

  /// No description provided for @qrActionContactName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get qrActionContactName;

  /// No description provided for @qrActionContactPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get qrActionContactPhone;

  /// No description provided for @qrActionContactEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-mail'**
  String get qrActionContactEmail;

  /// No description provided for @qrActionContactOrg.
  ///
  /// In tr, this message translates to:
  /// **'Şirket'**
  String get qrActionContactOrg;

  /// No description provided for @qrActionContactWeb.
  ///
  /// In tr, this message translates to:
  /// **'Web'**
  String get qrActionContactWeb;

  /// No description provided for @qrActionAddToContacts.
  ///
  /// In tr, this message translates to:
  /// **'Rehbere Ekle'**
  String get qrActionAddToContacts;

  /// No description provided for @qrActionContactsOpened.
  ///
  /// In tr, this message translates to:
  /// **'Kişiler uygulaması açıldı. Manuel olarak ekleyebilirsiniz.'**
  String get qrActionContactsOpened;

  /// No description provided for @qrActionContactParseError.
  ///
  /// In tr, this message translates to:
  /// **'Kartvizit bilgileri okunamadı'**
  String get qrActionContactParseError;

  /// No description provided for @qrActionVcardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Bilgileri'**
  String get qrActionVcardTitle;

  /// No description provided for @qrActionVcardContent.
  ///
  /// In tr, this message translates to:
  /// **'Kişi bilgilerini manuel olarak kopyalayabilirsiniz:'**
  String get qrActionVcardContent;

  /// No description provided for @qrActionEventTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takvim Etkinliği'**
  String get qrActionEventTitle;

  /// No description provided for @qrActionEventSummary.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get qrActionEventSummary;

  /// No description provided for @qrActionEventDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get qrActionEventDate;

  /// No description provided for @qrActionEventDesc.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get qrActionEventDesc;

  /// No description provided for @qrActionAddToCalendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvime Ekle'**
  String get qrActionAddToCalendar;

  /// No description provided for @qrActionCalendarOpenError.
  ///
  /// In tr, this message translates to:
  /// **'Takvim uygulaması açılamadı'**
  String get qrActionCalendarOpenError;

  /// No description provided for @qrActionCalendarError.
  ///
  /// In tr, this message translates to:
  /// **'Takvim açılırken hata oluştu: {error}'**
  String qrActionCalendarError(String error);

  /// No description provided for @qrActionMeCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'MeCard'**
  String get qrActionMeCardTitle;

  /// No description provided for @qrActionTextTitle.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get qrActionTextTitle;

  /// No description provided for @qrActionErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get qrActionErrorTitle;

  /// No description provided for @qrActionPhoneOpenError.
  ///
  /// In tr, this message translates to:
  /// **'Telefon uygulaması açılamadı'**
  String get qrActionPhoneOpenError;

  /// No description provided for @qrActionPhoneError.
  ///
  /// In tr, this message translates to:
  /// **'Telefon açılırken hata oluştu: {error}'**
  String qrActionPhoneError(String error);

  /// No description provided for @qrActionEmailOpenError.
  ///
  /// In tr, this message translates to:
  /// **'E-mail uygulaması açılamadı'**
  String get qrActionEmailOpenError;

  /// No description provided for @qrActionEmailError.
  ///
  /// In tr, this message translates to:
  /// **'E-mail açılırken hata oluştu: {error}'**
  String qrActionEmailError(String error);

  /// No description provided for @qrActionSmsOpenError.
  ///
  /// In tr, this message translates to:
  /// **'SMS uygulaması açılamadı'**
  String get qrActionSmsOpenError;

  /// No description provided for @qrActionSmsError.
  ///
  /// In tr, this message translates to:
  /// **'SMS açılırken hata oluştu: {error}'**
  String qrActionSmsError(String error);

  /// No description provided for @qrActionLocationParseError.
  ///
  /// In tr, this message translates to:
  /// **'Konum bilgileri okunamadı'**
  String get qrActionLocationParseError;

  /// No description provided for @qrActionMapsOpenError.
  ///
  /// In tr, this message translates to:
  /// **'Harita uygulaması açılamadı'**
  String get qrActionMapsOpenError;

  /// No description provided for @qrActionMapsError.
  ///
  /// In tr, this message translates to:
  /// **'Harita açılırken hata oluştu: {error}'**
  String qrActionMapsError(String error);

  /// No description provided for @permCameraTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kamera İzni'**
  String get permCameraTitle;

  /// No description provided for @permCameraWhyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Neden Kamera İzni Gerekli?'**
  String get permCameraWhyTitle;

  /// No description provided for @permCameraWhyContent.
  ///
  /// In tr, this message translates to:
  /// **'🔍 QR kodları taramak için kamera erişimi gereklidir.\n📱 Uygulama sadece QR kod tanımak için kamerayı kullanır.\n🚫 Hiçbir fotoğraf veya video kaydedilmez.\n🔒 Kişisel gizliliğiniz korunur.'**
  String get permCameraWhyContent;

  /// No description provided for @permCameraDataSafe.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz güvendedir'**
  String get permCameraDataSafe;

  /// No description provided for @permCameraSettingsNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu izni istediğiniz zaman cihaz ayarlarından geri alabilirsiniz.'**
  String get permCameraSettingsNote;

  /// No description provided for @permGrant.
  ///
  /// In tr, this message translates to:
  /// **'İzin Ver'**
  String get permGrant;

  /// No description provided for @permDecline.
  ///
  /// In tr, this message translates to:
  /// **'İzin Verme'**
  String get permDecline;

  /// No description provided for @permCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get permCancel;

  /// No description provided for @permGoToSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlara Git'**
  String get permGoToSettings;

  /// No description provided for @permUnderstood.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get permUnderstood;

  /// No description provided for @permContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get permContinue;

  /// No description provided for @permSettingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzin Gerekli'**
  String get permSettingsTitle;

  /// No description provided for @permManualRequired.
  ///
  /// In tr, this message translates to:
  /// **'Manuel İzin Ayarı Gerekli'**
  String get permManualRequired;

  /// No description provided for @permManualContent.
  ///
  /// In tr, this message translates to:
  /// **'Kamera izni daha önce kalıcı olarak reddedilmiş.\n\nQR kod tarayabilmek için:\n1. Ayarlar > Uygulamalar\n2. QR App > İzinler\n3. Kamera izni açın'**
  String get permManualContent;

  /// No description provided for @permDeniedTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzin Reddedildi'**
  String get permDeniedTitle;

  /// No description provided for @permDeniedScanningImpossible.
  ///
  /// In tr, this message translates to:
  /// **'QR Tarama Yapılamıyor'**
  String get permDeniedScanningImpossible;

  /// No description provided for @permDeniedContent.
  ///
  /// In tr, this message translates to:
  /// **'Kamera izni olmadan QR kod tarama özelliğini kullanamıyoruz.\n\nİsterseniz daha sonra tekrar deneyebilir veya cihaz ayarlarından manuel olarak izin verebilirsiniz.'**
  String get permDeniedContent;

  /// No description provided for @permGalleryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Galeri Erişimi'**
  String get permGalleryTitle;

  /// No description provided for @permGalleryWhyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Neden Galeri Erişimi?'**
  String get permGalleryWhyTitle;

  /// No description provided for @permGalleryWhyContent.
  ///
  /// In tr, this message translates to:
  /// **'📷 Galerinizden QR kod içeren resimleri seçebilmek için.\n🔍 Seçtiğiniz resimden QR kod okumak için.\n🔒 Sadece seçtiğiniz resim işlenir, diğer fotoğraflarınıza erişilmez.'**
  String get permGalleryWhyContent;

  /// No description provided for @aiRepairTitle.
  ///
  /// In tr, this message translates to:
  /// **'AI Onarımı İçin Görsel Seçin'**
  String get aiRepairTitle;

  /// No description provided for @aiRepairOptionCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kameradan Fotoğraf Çek'**
  String get aiRepairOptionCamera;

  /// No description provided for @aiRepairOptionCameraSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hasarlı QR kodu yakından net çekin'**
  String get aiRepairOptionCameraSubtitle;

  /// No description provided for @aiRepairOptionGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get aiRepairOptionGallery;

  /// No description provided for @aiRepairOptionGallerySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Önceden çekilmiş bir fotoğrafı seçin'**
  String get aiRepairOptionGallerySubtitle;

  /// No description provided for @aiRepairWithAI.
  ///
  /// In tr, this message translates to:
  /// **'AI ile Hasarlı QR Onar'**
  String get aiRepairWithAI;

  /// No description provided for @aiDamagedQrPrompt.
  ///
  /// In tr, this message translates to:
  /// **'QR Hasarlı mı? AI ile Onar'**
  String get aiDamagedQrPrompt;

  /// No description provided for @aiScanFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka bu görselden QR çözemedi.'**
  String get aiScanFailed;

  /// No description provided for @aiServerUnreachable.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamıyor. Görsel çevrimdışı kuyruğa eklendi.'**
  String get aiServerUnreachable;

  /// No description provided for @aiServerError.
  ///
  /// In tr, this message translates to:
  /// **'AI Sunucu Hatası: {error}'**
  String aiServerError(String error);
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
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
