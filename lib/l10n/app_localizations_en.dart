// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QR Code App';

  @override
  String get settings => 'Settings';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get premium => 'Premium';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get helpFaq => 'Help / FAQ';

  @override
  String get feedback => 'Feedback';

  @override
  String get about => 'About App';

  @override
  String get rateApp => 'Rate App';

  @override
  String get onboardingTitle => 'Welcome!';

  @override
  String get onboardingDescription => 'Create, manage, and share QR codes.';

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingWelcomeDescription => 'Welcome to the QR code app.';

  @override
  String get onboardingThemePremiumTitle => 'Theme and Premium Features';

  @override
  String get onboardingThemePremiumDescription =>
      'Improve your experience with customizable themes and premium benefits.';

  @override
  String get onboardingCloudBackupTitle => 'Cloud Backup';

  @override
  String get onboardingCloudBackupDescription =>
      'Back up your data securely with your Google account.';

  @override
  String get onboardingPrivacyTitle => 'Privacy and Security';

  @override
  String get onboardingPrivacyDescription =>
      'Your data stays secure on your device, and you can review our privacy policy.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get premiumPurchaseTitle => 'Buy Premium';

  @override
  String get premiumPurchasePlaceholder =>
      'Premium purchase actions will appear here.';

  @override
  String get premiumPurchaseHeadingInactive => 'Upgrade to Premium';

  @override
  String get premiumPurchaseHeadingActive => 'Premium Active';

  @override
  String get premiumPurchaseUnlockSubtitle => 'Unlock all features';

  @override
  String get premiumPurchaseFeaturesHeading => 'Premium Features';

  @override
  String get premiumPurchaseOptionsHeading => 'Options';

  @override
  String get premiumPurchaseStoreUnavailable => 'Store Unavailable';

  @override
  String get premiumPurchaseProcessing => 'Processing...';

  @override
  String get premiumPurchaseBuyButton => 'Go Premium';

  @override
  String get premiumPurchaseRestoreButton => 'Restore Purchases';

  @override
  String get premiumPurchaseRestoreSuccess =>
      'Purchases restored. Premium is active.';

  @override
  String get premiumPurchaseRestoreNotFound =>
      'No purchases were found to restore.';

  @override
  String get premiumPurchaseSuccessTitle => 'Premium Activated!';

  @override
  String get premiumPurchaseSuccessBody =>
      'Congratulations. Your premium access is now active.';

  @override
  String get premiumPurchaseSuccessAction => 'Great';

  @override
  String get premiumPurchaseLegalNote =>
      'The purchase is charged to your Google Play / App Store account. Subscriptions renew automatically until cancelled.';

  @override
  String get premiumFeatureAdFree => 'Ad-free usage';

  @override
  String get premiumFeatureUnlimitedHistory => 'Unlimited QR history';

  @override
  String get premiumFeatureCustomStyles => 'Custom QR colors and shapes';

  @override
  String get premiumFeatureCloudBackup => 'Cloud backup';

  @override
  String get premiumFeatureBatchScan => 'Batch scanning';

  @override
  String get premiumFeatureAdvancedAnalytics => 'Advanced analytics';

  @override
  String get themeSettingsSubtitle => 'Color, dark/light mode and style';

  @override
  String get themeQuickColorPicker => 'Quick Color Picker';

  @override
  String get themeCurrentTheme => 'Current Theme';

  @override
  String get themeModeTitle => 'Theme Mode';

  @override
  String get themeColorThemeTitle => 'Color Theme';

  @override
  String themeSelectedColor(Object color) {
    return 'Selected: $color';
  }

  @override
  String get themePreviewTitle => 'Theme Preview';

  @override
  String get themePreviewSubtitle => 'Theme preview';

  @override
  String get themeColorBlue => 'Blue';

  @override
  String get themeColorGreen => 'Green';

  @override
  String get themeColorPurple => 'Purple';

  @override
  String get themeColorOrange => 'Orange';

  @override
  String get themeColorPink => 'Pink';

  @override
  String get themeColorTeal => 'Teal';

  @override
  String get themeColorIndigo => 'Indigo';

  @override
  String get themeColorRed => 'Red';

  @override
  String get themeModeLight => 'Light Theme';

  @override
  String get themeModeDark => 'Dark Theme';

  @override
  String get themeModeSystem => 'System Theme';

  @override
  String get themeModeLightDescription => 'Always uses the light theme';

  @override
  String get themeModeDarkDescription => 'Always uses the dark theme';

  @override
  String get themeModeSystemDescription => 'Follows the device settings';

  @override
  String get cloudBackupSubtitle => 'Store your data in the cloud';

  @override
  String get feedbackSubtitle => 'Send your feedback and suggestions';

  @override
  String get aboutSubtitle => 'Version, developer and contact';

  @override
  String get helpFaqSubtitle => 'Frequently asked questions and help';

  @override
  String get rateAppSubtitle => 'Rate if you are satisfied';

  @override
  String get homeScanCreateDescription => 'Scan and create QR codes';

  @override
  String get homePriceAlertTestTooltip => 'Price Alert Test';

  @override
  String get homeLightMode => 'Light Mode';

  @override
  String get homeDarkMode => 'Dark Mode';

  @override
  String get homeStatsScanned => 'Scanned';

  @override
  String get homeStatsCreated => 'Created';

  @override
  String get homeStatsTheme => 'Theme';

  @override
  String get homeFeaturesTitle => 'Features';

  @override
  String get homeActionScanQr => 'Scan QR';

  @override
  String get homeActionCreateQr => 'Create QR';

  @override
  String get homeActionSavedRecords => 'Saved Items';

  @override
  String get homeActionFavorites => 'Favorites';

  @override
  String get homeActionBatchScan => 'Batch Scan';

  @override
  String get homeActionAdvancedBarcode => 'Advanced Barcode';

  @override
  String get homeActionCustomizeQr => 'Customize QR';

  @override
  String get homeActionPriceAlerts => 'Price Alerts';

  @override
  String get homeActionAnalytics => 'Analytics';

  @override
  String get analyticsRefresh => 'Refresh';

  @override
  String get analyticsOverview => 'Overview';

  @override
  String get analyticsTotalQr => 'Total QR';

  @override
  String get analyticsScanned => 'Scanned';

  @override
  String get analyticsCreated => 'Created';

  @override
  String get analyticsArchived => 'Archived';

  @override
  String get analyticsActive => 'Active';

  @override
  String get analyticsTypeDistribution => 'Type Distribution';

  @override
  String get analyticsCategoryDistribution => 'Category Distribution';

  @override
  String get analyticsLast7Days => 'Last 7 Days Activity';

  @override
  String get analyticsNoData => 'No data yet';

  @override
  String get analyticsUncategorized => 'Uncategorized';

  @override
  String get homeActionPremiumSubtitle => 'Ad-free and extra features';

  @override
  String get homeNoAlerts => 'No alerts';

  @override
  String homeAlertsSummary(Object total, Object triggered) {
    return '$triggered triggered • $total total';
  }

  @override
  String get batchTitle => 'Batch Scan';

  @override
  String get batchSubtitle => 'Scan multiple QR codes quickly';

  @override
  String get batchPausedTitle => 'SCANNING PAUSED';

  @override
  String get batchPause => 'Pause';

  @override
  String get batchStart => 'Start';

  @override
  String get batchDuplicateControlTooltip => 'Duplicate Control';

  @override
  String get batchDuplicateEnabled => 'Duplicate prevention enabled';

  @override
  String get batchDuplicateDisabled => 'Duplicate prevention disabled';

  @override
  String get batchEmptyTitle => 'Scan QR codes';

  @override
  String get batchEmptySubtitle => 'Scanned codes will appear here';

  @override
  String get homePriceAlertTestSent => 'Test price alert notification sent';

  @override
  String get homePriceAlertNeedAlertFirst =>
      'Create at least 1 price alert first for testing';

  @override
  String get settingsStoreListingNotOpened =>
      'Store listing could not be opened';

  @override
  String settingsStoreOpenFailed(Object error) {
    return 'Store could not be opened: $error';
  }

  @override
  String get settingsPurchaseErrorTitle => 'Purchase Error';

  @override
  String get settingsLanguageLabel => 'Language:';

  @override
  String get settingsLanguageTurkish => 'Turkish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsPremiumUpgradeSubtitle =>
      'Unlock ad-free experience and extra features';

  @override
  String get settingsPremiumActiveSubtitle => 'Premium is active';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDelete => 'Delete';

  @override
  String get batchCameraPermissionRequiredTitle => 'Camera Permission Required';

  @override
  String get batchCameraPermissionRequiredMessage =>
      'You must grant camera permission to scan QR codes. Please allow permission in settings.';

  @override
  String batchDeletedMessage(Object type) {
    return '$type QR code removed';
  }

  @override
  String batchScannedAtLabel(Object dateTime) {
    return 'Scanned at: $dateTime';
  }

  @override
  String get batchContentLabel => 'Content:';

  @override
  String get batchSavedToHistory => 'Saved to history';

  @override
  String batchScannedCodesCount(Object count) {
    return 'Scanned Codes ($count)';
  }

  @override
  String get batchSaveButton => 'Save';

  @override
  String get batchFlashTooltip => 'Flash';

  @override
  String get batchSwitchCameraTooltip => 'Switch Camera';

  @override
  String get scannerTitle => 'QR Code Scanner';

  @override
  String get scannerScanFromGalleryTooltip => 'Scan QR from Gallery';

  @override
  String get scannerHeaderTitle => 'QR Code Scanning';

  @override
  String get scannerHeaderSubtitle => 'Point your camera at the QR code';

  @override
  String get scannerCameraStarting => 'Starting camera...';

  @override
  String get scannerResultTitle => 'Scan Result:';

  @override
  String get scannerBringCodeIntoView =>
      'Bring the QR code into the camera view';

  @override
  String get scannerStop => 'Stop';

  @override
  String get scannerDetails => 'Details';

  @override
  String get scannerBarcodeType => 'Barcode';

  @override
  String get scannerScannedDialogTitle => 'QR Code Scanned';

  @override
  String scannerTypeLabel(Object qrType) {
    return 'Type: $qrType';
  }

  @override
  String get scannerComparePriceAction => 'Compare Price';

  @override
  String get scannerOpenUseAction => 'Open/Use';

  @override
  String get scannerSetAlertAction => 'Set Alert';

  @override
  String get scannerAddFavoriteAction => 'Add Favorite';

  @override
  String get scannerQrNotFoundInGallery => 'QR code not found';

  @override
  String get scannerGalleryAccessFailed => 'Gallery access failed';

  @override
  String get scannerPriceNotFound => 'Price information not found';

  @override
  String get scannerSetPriceAlertTitle => 'Set Price Alert';

  @override
  String get scannerUnknownProduct => 'Product';

  @override
  String scannerCurrentLowestPrice(Object price) {
    return 'Current lowest price: ₺$price';
  }

  @override
  String get scannerPreset5Below => '5% below';

  @override
  String get scannerPreset10Below => '10% below';

  @override
  String get scannerPreset15Below => '15% below';

  @override
  String get scannerCurrentPricePreset => 'Current price';

  @override
  String get scannerTargetPriceLabel => 'Target price';

  @override
  String get scannerEnterValidPrice => 'Enter a valid price';

  @override
  String get scannerPriceAlertCreated => 'Price alert created';

  @override
  String get scannerPriceAlertNotCreated => 'Price alert could not be created';

  @override
  String scannerAlertCreateError(Object error) {
    return 'Alert creation error: $error';
  }

  @override
  String get advancedScannerTitle => 'Advanced Barcode Scanner';

  @override
  String get advancedFormatOptions => 'Format Options';

  @override
  String get advancedDetectionActive => 'Detection Active';

  @override
  String get advancedContinuousMode => 'Continuous Mode';

  @override
  String get advancedDetails => 'Details';

  @override
  String get advancedBarcodeFormats => 'Barcode Formats';

  @override
  String get advancedSelectAll => 'Select All';

  @override
  String get advancedApply => 'Apply';

  @override
  String get advancedDetectedData => 'Detected Data:';

  @override
  String get advancedPerformAction => 'Perform Action';

  @override
  String get advancedDescQrCode => 'Commonly used 2D code';

  @override
  String get advancedDescProductBarcode => 'Product barcodes (Europe)';

  @override
  String get advancedDescIndustrial => 'Industrial use';

  @override
  String get advancedDescSpecialPurpose => 'Special purpose use';

  @override
  String advancedDetectionCount(int count) {
    return 'Detections: $count';
  }

  @override
  String advancedDetectionCountLabel(int count) {
    return 'Detection Count: $count';
  }

  @override
  String advancedLastDetection(Object time) {
    return 'Last Detection: $time';
  }

  @override
  String advancedActiveFormats(Object formats) {
    return 'Active Formats: $formats';
  }

  @override
  String get aboutTitle => 'About App';

  @override
  String get aboutAppName => 'QR Code App';

  @override
  String get aboutDescription =>
      'With this app you can create, scan QR codes, and manage your history and favorites.';

  @override
  String get aboutVersion => 'Version: 1.0.0';

  @override
  String get aboutDeveloper => 'Developer: QRKOD Project Team';

  @override
  String get aboutSupport => 'For support and contact: support@qrkodproje.com';

  @override
  String get aboutOpenSourceNote =>
      'For open source libraries and privacy policy, check the FAQ section in app settings.';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackHeading => 'Your Opinions and Suggestions';

  @override
  String get feedbackBody =>
      'You can share any opinions, suggestions, and bug reports about the app with us.';

  @override
  String get feedbackEmailButton => 'Send Feedback via Email';

  @override
  String get feedbackEmailSubject => 'Feedback';

  @override
  String get feedbackEmailBody => 'My thoughts about the app:';

  @override
  String get feedbackEmailAddress => 'Email: info@qrkodproje.com';

  @override
  String get helpFaqTitle => 'Help / FAQ';

  @override
  String get helpFaqHeading => 'Frequently Asked Questions';

  @override
  String get helpFaqQ1 => 'How can I create a QR code with the app?';

  @override
  String get helpFaqA1 =>
      'You can easily create a QR code by tapping the create QR code button on the main screen.';

  @override
  String get helpFaqQ2 => 'How can I scan a QR code?';

  @override
  String get helpFaqA2 =>
      'Use the scan QR code button on the main screen to open the camera and scan the code.';

  @override
  String get helpFaqQ3 => 'Is my data safe?';

  @override
  String get helpFaqA3 =>
      'All your data is stored on your device and can optionally be backed up to the cloud with your Google account.';

  @override
  String get helpFaqQ4 => 'What is Premium?';

  @override
  String get helpFaqA4 =>
      'With Premium you can use the app ad-free and access additional features.';

  @override
  String get helpFaqQ5 =>
      'I want to send support or suggestions, how can I reach you?';

  @override
  String get helpFaqA5 =>
      'You can reach our contact address from Settings > About App section.';

  @override
  String get helpFaqMoreHelp => 'For more help: info@qrkodproje.com';

  @override
  String get cloudSignInSuccess => 'Signed in to Google account successfully.';

  @override
  String cloudSignInFailedWithDetail(Object detail) {
    return 'Sign-in failed. Detail: $detail';
  }

  @override
  String get cloudSignInFailedGeneric =>
      'Sign-in failed. Confirm account selection and try again.';

  @override
  String get cloudSignOutSuccess => 'Signed out.';

  @override
  String get cloudBackupSuccess => 'Backup successful.';

  @override
  String get cloudBackupFailed => 'Backup failed!';

  @override
  String get cloudBackupFailedDetail =>
      'Backup failed. Check your internet connection and Google account.';

  @override
  String get cloudRestoreSuccess => 'Restore successful.';

  @override
  String get cloudRestoreFailed => 'Restore failed!';

  @override
  String get cloudRestoreFailedDetail =>
      'Restore failed. Backup file not found or connection error.';

  @override
  String get cloudErrorTitle => 'Error';

  @override
  String get cloudRetry => 'Retry';

  @override
  String get cloudSendFeedback => 'Send Feedback';

  @override
  String cloudLastBackupLabel(Object dateTime) {
    return 'Last backup: $dateTime';
  }

  @override
  String get cloudSignInWithGoogle => 'Sign in with Google';

  @override
  String get cloudBackupData => 'Backup Data';

  @override
  String get cloudRestoreBackup => 'Restore Backup';

  @override
  String get cloudSignOut => 'Sign Out';

  @override
  String get historyAddedToFavorites => 'Added to favorites';

  @override
  String get historyAddToFavorites => 'Add to favorites';

  @override
  String get historyShare => 'Share';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyQrCopiedForShare =>
      'QR data copied to clipboard (share integration pending)';

  @override
  String get historyRecordDeleted => 'Record deleted';

  @override
  String historyTypeLabel(Object type) {
    return 'Type: $type';
  }

  @override
  String historyDateLabel(Object date) {
    return 'Date: $date';
  }

  @override
  String historyCategoryLabel(Object category) {
    return 'Category: $category';
  }

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptySubtitle =>
      'Scanned or created QR codes will be listed here.';

  @override
  String get historyTitle => 'Records';

  @override
  String get historyFilter => 'Filter';

  @override
  String get historySort => 'Sort';

  @override
  String get historySortByDate => 'By date';

  @override
  String get historySortByName => 'By name';

  @override
  String get historySortByType => 'By type';

  @override
  String get historyDeleteSelected => 'Delete Selected';

  @override
  String get historyToFavorites => 'To Favorites';

  @override
  String get historyClearAll => 'Clear All';

  @override
  String get historyAll => 'All';

  @override
  String get historyType => 'Type';

  @override
  String get historyTag => 'Tag';

  @override
  String get historyCategory => 'Category';

  @override
  String get historyDateRangeNotSelected => 'No date range selected';

  @override
  String get historySelectDate => 'Select Date';

  @override
  String get historyCancel => 'Cancel';

  @override
  String get historyApply => 'Apply';

  @override
  String historyAddedAndSkippedMessage(Object added, Object skipped) {
    return '$added added, $skipped already favorite';
  }

  @override
  String historyAddedToFavoritesCount(Object count) {
    return '$count added to favorites';
  }

  @override
  String get historyDeleteSelectedTitle => 'Delete Selected QR Codes';

  @override
  String historyDeleteSelectedConfirm(Object count) {
    return 'Are you sure you want to delete $count QR codes?';
  }

  @override
  String get historySelectedDeleted => 'Selected QR codes deleted';

  @override
  String get historyUndo => 'UNDO';

  @override
  String get historyClearAllTitle => 'Clear All';

  @override
  String get historyClearAllConfirm =>
      'Are you sure you want to delete all records? This action cannot be undone.';

  @override
  String get historyAllCleared => 'All records cleared';

  @override
  String get favoritesEditNoteTitle => 'Edit Favorite Note';

  @override
  String get favoritesOptionalNoteLabel => 'Note (optional)';

  @override
  String get favoritesCancel => 'Cancel';

  @override
  String get favoritesNoteUpdated => 'Favorite note updated';

  @override
  String get favoritesAdvancedFilter => 'Advanced Filter';

  @override
  String get favoritesAll => 'All';

  @override
  String get favoritesType => 'Type';

  @override
  String get favoritesTag => 'Tag';

  @override
  String get favoritesDateRangeNotSelected => 'No date range selected';

  @override
  String get favoritesSelectDate => 'Select Date';

  @override
  String get favoritesApply => 'Apply';

  @override
  String favoritesSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get favoritesCancelSelection => 'Cancel Selection';

  @override
  String get favoritesDeleteSelectedTitle => 'Delete Selected Favorites';

  @override
  String favoritesDeleteSelectedConfirm(Object count) {
    return 'Are you sure you want to delete $count favorites?';
  }

  @override
  String get favoritesDelete => 'Delete';

  @override
  String get favoritesSelectedDeleted => 'Selected favorites deleted';

  @override
  String get favoritesSearchHint => 'Search in favorites...';

  @override
  String get favoritesTypeFilter => 'Type Filter';

  @override
  String get favoritesNoSearchResults => 'No search results found';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesTryDifferentKeywords => 'Try different keywords';

  @override
  String get favoritesEmptySubtitle =>
      'You can scan QR codes and add them to favorites';

  @override
  String get favoritesAddedAt => 'Added';

  @override
  String get favoritesContentLabel => 'Content:';

  @override
  String get favoritesUse => 'Use';

  @override
  String get favoritesShare => 'Share';

  @override
  String get favoritesEditNameTitle => 'Rename Favorite';

  @override
  String get favoritesOptionalCustomNameLabel => 'Custom name (optional)';

  @override
  String get favoritesNameUpdated => 'Favorite name updated';

  @override
  String get favoritesCopiedToClipboard => 'Copied to clipboard';

  @override
  String favoritesRemovedMessage(Object name) {
    return '$name removed from favorites';
  }

  @override
  String get favoritesUndo => 'Undo';

  @override
  String get favoritesClearAllTitle => 'Clear All Favorites';

  @override
  String get favoritesClearAllConfirm =>
      'Are you sure you want to delete all favorites?';

  @override
  String get favoritesAllCleared => 'All favorites cleared';

  @override
  String get favoritesShowQr => 'Show QR';

  @override
  String get favoritesRename => 'Rename';

  @override
  String get favoritesEditNote => 'Edit Note';

  @override
  String get favoritesCopy => 'Copy';

  @override
  String favoritesTodayAt(Object time) {
    return 'Today $time';
  }

  @override
  String favoritesYesterdayAt(Object time) {
    return 'Yesterday $time';
  }

  @override
  String favoritesDaysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get priceAlertDetailTitle => 'Alert Detail';

  @override
  String get priceAlertDetailDeleteTitle => 'Delete Alert';

  @override
  String get priceAlertDetailDeleteConfirm =>
      'Are you sure you want to delete this price alert?';

  @override
  String get priceAlertDetailDeleteButton => 'Delete';

  @override
  String get priceAlertDetailBarcodeCopied => 'Barcode copied!';

  @override
  String get priceAlertDetailShareFormat => 'Share Format';

  @override
  String get priceAlertDetailShareFormatQuestion =>
      'Which format would you like to share in?';

  @override
  String get priceAlertDetailShareCompact => 'Compact Format';

  @override
  String get priceAlertDetailShareDetailed => 'Detailed Format';

  @override
  String get priceAlertDetailUnknownProduct => 'Unknown Product';

  @override
  String get priceAlertDetailUnknownSource => 'Unknown';

  @override
  String get priceAlertDetailNotFound => 'Alert not found';

  @override
  String get priceAlertDetailBack => 'Go Back';

  @override
  String get priceAlertDetailTriggered => 'Price Target Reached!';

  @override
  String get priceAlertDetailProductName => 'Product Name';

  @override
  String get priceAlertDetailTargetPrice => 'Target Price';

  @override
  String get priceAlertDetailCurrentPrice => 'Current Price';

  @override
  String get priceAlertDetailSource => 'Source';

  @override
  String get priceAlertDetailBarcode => 'Barcode';

  @override
  String get priceAlertDetailTapToCopy => 'Tap to Copy';

  @override
  String priceAlertDetailCreatedAt(String date) {
    return 'Created: $date';
  }

  @override
  String get priceAlertDetailShare => 'Share';

  @override
  String get customQrTitle => 'QR Customization';

  @override
  String get customQrShareTooltip => 'Share';

  @override
  String get customQrSaveTooltip => 'Save';

  @override
  String get customQrTabColors => 'Colors';

  @override
  String get customQrTabLogo => 'Logo';

  @override
  String get customQrTabStyle => 'Style';

  @override
  String get customQrTabSettings => 'Settings';

  @override
  String get customQrPresetColors => 'Preset Colors';

  @override
  String get customQrCustomColors => 'Custom Colors';

  @override
  String get customQrColorFg => 'QR Color';

  @override
  String get customQrColorBg => 'Background';

  @override
  String get customQrAddLogo => 'Add Logo';

  @override
  String get customQrLogoSize => 'Logo Size';

  @override
  String get customQrSelectLogo => 'Select Logo';

  @override
  String get customQrCornerRadius => 'Corner Radius';

  @override
  String get customQrErrorLevel => 'Error Correction Level';

  @override
  String get customQrErrorLow => 'Low (L) - 7%';

  @override
  String get customQrErrorMid => 'Medium (M) - 15%';

  @override
  String get customQrErrorHigh => 'High (Q) - 25%';

  @override
  String get customQrErrorMax => 'Highest (H) - 30%';

  @override
  String get customQrErrorTitle => 'Error Correction';

  @override
  String get customQrErrorDesc =>
      'Higher level means the QR code remains readable even with more damage, but looks more complex.';

  @override
  String get customQrInfo => 'QR Code Info';

  @override
  String customQrInfoData(String data) {
    return 'Data: $data';
  }

  @override
  String customQrInfoCharCount(int count) {
    return 'Character count: $count';
  }

  @override
  String customQrInfoErrorLevel(String level) {
    return 'Error Correction: $level';
  }

  @override
  String get customQrPresets => 'Predefined Styles';

  @override
  String get customQrPresetClassic => 'Classic';

  @override
  String get customQrPresetModern => 'Modern';

  @override
  String get customQrPresetMinimal => 'Minimal';

  @override
  String get customQrPresetPremium => 'Premium';

  @override
  String get customQrColorPickerFg => 'QR Code Color';

  @override
  String get customQrColorPickerBg => 'Background Color';

  @override
  String get customQrErrorCreate => 'Could not create QR code!';

  @override
  String get customQrErrorImage => 'Could not create QR code image!';

  @override
  String get customQrShareText => 'Here is my custom QR code!';

  @override
  String customQrShareError(String error) {
    return 'Share error: $error';
  }

  @override
  String get customQrSaved => 'Custom QR code saved to history!';

  @override
  String customQrSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get customQrErrorLowName => 'Low (L)';

  @override
  String get customQrErrorMidName => 'Medium (M)';

  @override
  String get customQrErrorHighName => 'High (Q)';

  @override
  String get customQrErrorMaxName => 'Highest (H)';

  @override
  String get priceAlertsTitle => 'Price Alerts';

  @override
  String get priceAlertsDeleteTitle => 'Delete Alert';

  @override
  String get priceAlertsDeleteContent =>
      'Are you sure you want to delete this price alert?';

  @override
  String get priceAlertsDeleteButton => 'Delete';

  @override
  String get priceAlertsDeletedMsg => 'Price alert deleted';

  @override
  String get priceAlertsBarcodecopied => 'Barcode copied';

  @override
  String get priceAlertsProductNameCopied => 'Product name copied';

  @override
  String get priceAlertsShareSubject => 'Price Alert Share';

  @override
  String get priceAlertsShareTitle => 'Price Alert';

  @override
  String priceAlertsShareProduct(String name) {
    return 'Product: $name';
  }

  @override
  String priceAlertsShareBarcode(String barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String priceAlertsShareSource(String source) {
    return 'Source: $source';
  }

  @override
  String priceAlertsShareTargetPrice(String price) {
    return 'Target Price: $price';
  }

  @override
  String priceAlertsShareCurrentPrice(String price) {
    return 'Current Price: $price';
  }

  @override
  String get priceAlertsRefreshTooltip => 'Refresh';

  @override
  String get priceAlertsFilterAll => 'All';

  @override
  String get priceAlertsFilterTriggered => 'Triggered';

  @override
  String get priceAlertsFilterPending => 'Pending';

  @override
  String get priceAlertsSortNewest => 'Newest';

  @override
  String get priceAlertsSortClosest => 'Closest to Target';

  @override
  String get priceAlertsSortHighest => 'Highest Difference';

  @override
  String get priceAlertsEmptyTriggered => 'No triggered alerts yet.';

  @override
  String get priceAlertsEmptyPending => 'No pending alerts.';

  @override
  String get priceAlertsEmptyAll => 'No price alerts yet';

  @override
  String get priceAlertsTotal => 'Total';

  @override
  String get priceAlertsEmptyHint =>
      'Scan a product barcode and set an alert from the \"Price Compare\" tab.';

  @override
  String get priceAlertsAllSources => 'All Sources';

  @override
  String get priceAlertsUnknownProduct => 'Unknown Product';

  @override
  String priceAlertsCreatedAt(String date) {
    return 'Created: $date';
  }

  @override
  String get priceAlertsNewBadge => 'New';

  @override
  String get priceAlertsQuickActions => 'Quick actions';

  @override
  String get priceAlertsCopyBarcodeItem => 'Copy Barcode';

  @override
  String get priceAlertsCopyProductNameItem => 'Copy Product Name';

  @override
  String get priceAlertsShareAlertItem => 'Share Alert';

  @override
  String get priceAlertsDeleteTooltip => 'Delete alert';

  @override
  String priceAlertsSourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String priceAlertsBarcodeLabel(String barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get priceAlertsTargetPrice => 'Target Price';

  @override
  String get priceAlertsCurrentPrice => 'Current Price';

  @override
  String get priceAlertsPriceReached => 'Price has reached the target!';

  @override
  String get qrDetailImageShared => 'QR code image shared';

  @override
  String qrDetailShareError(String error) {
    return 'Share error: $error';
  }

  @override
  String get qrDetailSelectShareType => 'Select Share Type';

  @override
  String get qrDetailShareTextTitle => 'Share Text';

  @override
  String get qrDetailShareTextSubtitle => 'Share QR code content as text';

  @override
  String get qrDetailShareImageTitle => 'Share Image';

  @override
  String get qrDetailShareImageSubtitle => 'Share QR code as an image';

  @override
  String get qrDetailTitle => 'QR Code Details';

  @override
  String get qrDetailCopyTooltip => 'Copy';

  @override
  String get qrDetailCopiedToClipboard => 'Copied to clipboard';

  @override
  String get qrDetailShareTooltip => 'Share';

  @override
  String get qrDetailCheapestWhere => 'Where is it cheapest?';

  @override
  String get qrDetailType => 'Type';

  @override
  String get qrDetailCategory => 'Category';

  @override
  String get qrDetailNoCategory => 'No category';

  @override
  String get qrDetailName => 'Name';

  @override
  String get qrDetailData => 'Data';

  @override
  String get qrDetailDate => 'Date';

  @override
  String get qrDetailStatus => 'Status';

  @override
  String get qrDetailScanned => 'Scanned';

  @override
  String get qrDetailCreated => 'Created';

  @override
  String get qrDetailArchive => 'Archive';

  @override
  String get qrDetailYes => 'Yes';

  @override
  String get qrDetailNo => 'No';

  @override
  String get qrDetailPriceComparison => 'Price Comparison';

  @override
  String get qrDetailPriceInfoUnavailable =>
      'Price information could not be retrieved.';

  @override
  String get qrDetailClose => 'Close';

  @override
  String qrDetailBrand(String brand) {
    return 'Brand: $brand';
  }

  @override
  String qrDetailCategoryLabel(String category) {
    return 'Category: $category';
  }

  @override
  String get qrDetailBuy => 'Buy';

  @override
  String get qrDetailPriceHistory30Days => 'Last 30 Days Price History';

  @override
  String get qrDetailOtherPrices => 'Other Prices';

  @override
  String get qrDetailNoPriceHistory => 'No price history data found.';

  @override
  String get qrDetailMin => 'Min';

  @override
  String get qrDetailMax => 'Max';

  @override
  String get qrDetailPriceAlert => 'Price Alert';

  @override
  String get qrDetailSetTargetHint =>
      'Set a target price for this product. You can track it in your watch list when price drops.';

  @override
  String qrDetailTargetPriceLabel(String price) {
    return 'Target price: $price';
  }

  @override
  String get qrDetailSetAlert => 'Set Alert';

  @override
  String get qrDetailUpdateAlert => 'Update Alert';

  @override
  String get qrDetailAlertDeleted => 'Price alert deleted.';

  @override
  String get qrDetailAlertDeleteFailed => 'Price alert could not be deleted.';

  @override
  String get qrDetailSetPriceAlertTitle => 'Set Price Alert';

  @override
  String get qrDetailEnterTargetPrice =>
      'Enter a target price for this product.';

  @override
  String get qrDetailTargetPriceInput => 'Target price';

  @override
  String get qrDetailEnterValidPrice => 'Enter a valid price.';

  @override
  String get qrDetailAlertSaved => 'Price alert saved.';

  @override
  String get qrDetailAlertSaveFailed => 'Price alert could not be saved.';

  @override
  String get qrDetailSave => 'Save';

  @override
  String get enhancedQrGenTitle => 'QR Code Generator';

  @override
  String get enhancedQrGenHelpTooltip => 'Help';

  @override
  String get enhancedQrGenHeaderTitle => 'Create QR Code';

  @override
  String get enhancedQrGenHeaderSubtitle =>
      'Easily create different types of QR codes';

  @override
  String get enhancedQrGenTypeSelect => 'Select QR Code Type:';

  @override
  String get enhancedQrGenTypeText => 'Text';

  @override
  String get enhancedQrGenTypeUrl => 'URL';

  @override
  String get enhancedQrGenTypeWifi => 'WiFi';

  @override
  String get enhancedQrGenTypePhone => 'Phone';

  @override
  String get enhancedQrGenTypeEmail => 'E-mail';

  @override
  String get enhancedQrGenTypeSms => 'SMS';

  @override
  String get enhancedQrGenTypeLocation => 'Location';

  @override
  String get enhancedQrGenTypeVcard => 'vCard';

  @override
  String get enhancedQrGenTextInput => 'Text Input:';

  @override
  String get enhancedQrGenTextHint => 'Type the text to encode as QR...';

  @override
  String get enhancedQrGenUrlInput => 'URL Input:';

  @override
  String get enhancedQrGenUrlHint => 'https://www.example.com';

  @override
  String get enhancedQrGenHttps => 'HTTPS';

  @override
  String get enhancedQrGenHttp => 'HTTP';

  @override
  String get enhancedQrGenWifiInfo => 'WiFi Information:';

  @override
  String get enhancedQrGenWifiSsid => 'Network Name (SSID)';

  @override
  String get enhancedQrGenWifiSsidHint => 'Enter WiFi network name';

  @override
  String get enhancedQrGenWifiPassword => 'Password';

  @override
  String get enhancedQrGenWifiPasswordHint => 'Enter WiFi password';

  @override
  String get enhancedQrGenWifiSecurity => 'Security Type';

  @override
  String get enhancedQrGenWifiOpenNetwork => 'Open Network';

  @override
  String get enhancedQrGenPhoneNumber => 'Phone Number:';

  @override
  String get enhancedQrGenEmailAddress => 'E-mail Address:';

  @override
  String get enhancedQrGenEmailHint => 'example@email.com';

  @override
  String get enhancedQrGenSmsInfo => 'SMS Information:';

  @override
  String get enhancedQrGenPhoneNumberLabel => 'Phone Number';

  @override
  String get enhancedQrGenSmsMessage => 'Message';

  @override
  String get enhancedQrGenSmsHint => 'Type your SMS message...';

  @override
  String get enhancedQrGenLocationInfo => 'Location Information:';

  @override
  String get enhancedQrGenLatitude => 'Latitude';

  @override
  String get enhancedQrGenLongitude => 'Longitude';

  @override
  String get enhancedQrGenVcardInfo => 'vCard Information:';

  @override
  String get enhancedQrGenFullName => 'Full Name';

  @override
  String get enhancedQrGenPhone => 'Phone';

  @override
  String get enhancedQrGenEmail => 'E-mail';

  @override
  String get enhancedQrGenCompany => 'Company/Organization';

  @override
  String get enhancedQrGenWebsite => 'Website';

  @override
  String get enhancedQrGenAdvancedSettings =>
      'Advanced Settings (Logo & Tolerance)';

  @override
  String get enhancedQrGenErrorCorrection => 'Error Correction Level';

  @override
  String get enhancedQrGenErrorCorrectionHint =>
      'High level (H) is recommended when adding logo or for damaged codes.';

  @override
  String get enhancedQrGenErrorLow => 'Low (%7)';

  @override
  String get enhancedQrGenErrorMedium => 'Medium (%15)';

  @override
  String get enhancedQrGenErrorQuality => 'Quality (%25)';

  @override
  String get enhancedQrGenErrorHigh => 'High (%30)';

  @override
  String get enhancedQrGenAddLogo => 'Add Logo';

  @override
  String get enhancedQrGenChangeLogo => 'Change Logo';

  @override
  String get enhancedQrGenRemoveLogo => 'Remove Logo';

  @override
  String get enhancedQrGenPreview => 'QR Code Preview';

  @override
  String get enhancedQrGenCopy => 'Copy';

  @override
  String get enhancedQrGenShare => 'Share';

  @override
  String get enhancedQrGenSave => 'Save';

  @override
  String get enhancedQrGenFavoriteNoteTitle => 'Favorite Note/Tag';

  @override
  String get enhancedQrGenFavoriteNoteHint => 'Short note or tag (optional)';

  @override
  String get enhancedQrGenAdd => 'Add';

  @override
  String get enhancedQrGenAddedToFavorites => '⭐ Added to favorites!';

  @override
  String enhancedQrGenFavoriteError(String error) {
    return 'Already in favorites or error: $error';
  }

  @override
  String get enhancedQrGenFavorited => 'Favorited';

  @override
  String get enhancedQrGenAddToFavorites => 'Add to Favorites';

  @override
  String get enhancedQrGenCopiedToClipboard =>
      'QR code data copied to clipboard';

  @override
  String get enhancedQrGenSavedToHistory => 'QR code saved to history';

  @override
  String get enhancedQrGenCreateFirst => 'Create a QR code first';

  @override
  String get enhancedQrGenHelpTitle => 'About QR Code Types';

  @override
  String get enhancedQrGenHelpTextTitle => '📝 Text';

  @override
  String get enhancedQrGenHelpTextDesc => 'Simple text content';

  @override
  String get enhancedQrGenHelpUrlTitle => '🔗 URL';

  @override
  String get enhancedQrGenHelpUrlDesc => 'Website links';

  @override
  String get enhancedQrGenHelpWifiTitle => '📶 WiFi';

  @override
  String get enhancedQrGenHelpWifiDesc => 'WiFi network info (SSID, password)';

  @override
  String get enhancedQrGenHelpPhoneTitle => '📞 Phone';

  @override
  String get enhancedQrGenHelpPhoneDesc => 'Phone numbers';

  @override
  String get enhancedQrGenHelpEmailTitle => '📧 E-mail';

  @override
  String get enhancedQrGenHelpEmailDesc => 'E-mail addresses';

  @override
  String get enhancedQrGenHelpSmsTitle => '💬 SMS';

  @override
  String get enhancedQrGenHelpSmsDesc => 'SMS sending info';

  @override
  String get enhancedQrGenHelpLocationTitle => '📍 Location';

  @override
  String get enhancedQrGenHelpLocationDesc => 'GPS coordinates';

  @override
  String get enhancedQrGenHelpVcardTitle => '👤 vCard';

  @override
  String get enhancedQrGenHelpVcardDesc => 'Contact information';

  @override
  String get shareTitle => 'Share';

  @override
  String get shareGeneral => 'General Share';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareTelegram => 'Telegram';

  @override
  String get shareEmail => 'E-mail';

  @override
  String get shareSms => 'SMS';

  @override
  String get securityWarningTitle => 'Security Warning';

  @override
  String get securityWarningUrlLabel => 'URL:';

  @override
  String get securityWarningConfirm =>
      'Are you sure you want to proceed despite this warning?';

  @override
  String get securityWarningCancel => 'Cancel';

  @override
  String get securityWarningProceedHigh => 'Proceed at Risk';

  @override
  String get securityWarningProceedMedium => 'Proceed with Caution';

  @override
  String get securitySiteOpened => 'Site opened in browser. Stay safe.';

  @override
  String securityUrlOpenError(String error) {
    return 'Could not open URL: $error';
  }

  @override
  String get qrActionClose => 'Close';

  @override
  String get qrActionWifiTitle => 'WiFi Network';

  @override
  String get qrActionWifiSsid => 'Network Name (SSID)';

  @override
  String get qrActionWifiPassword => 'Password';

  @override
  String get qrActionWifiSecurity => 'Security';

  @override
  String get qrActionWifiConnect => 'Connect';

  @override
  String get qrActionWifiParseError => 'Could not read WiFi details';

  @override
  String get qrActionWifiInstructionsTitle => 'WiFi Connection';

  @override
  String get qrActionWifiInstructionsContent => 'To connect to WiFi:';

  @override
  String get qrActionWifiStep1 => '1. Go to Settings > WiFi';

  @override
  String qrActionWifiStep2(String ssid) {
    return '2. Find the network: \"$ssid\"';
  }

  @override
  String qrActionWifiStep3(String password) {
    return '3. Enter the password: \"$password\"';
  }

  @override
  String qrActionWifiPasswordLabel(String password) {
    return 'Password: $password';
  }

  @override
  String get qrActionContactTitle => 'Contact Card';

  @override
  String get qrActionContactName => 'Name';

  @override
  String get qrActionContactPhone => 'Phone';

  @override
  String get qrActionContactEmail => 'E-mail';

  @override
  String get qrActionContactOrg => 'Company';

  @override
  String get qrActionContactWeb => 'Web';

  @override
  String get qrActionAddToContacts => 'Add to Contacts';

  @override
  String get qrActionContactsOpened =>
      'Contacts app opened. You can add manually.';

  @override
  String get qrActionContactParseError => 'Could not read contact details';

  @override
  String get qrActionVcardTitle => 'Contact Details';

  @override
  String get qrActionVcardContent =>
      'You can copy the contact details manually:';

  @override
  String get qrActionEventTitle => 'Calendar Event';

  @override
  String get qrActionEventSummary => 'Title';

  @override
  String get qrActionEventDate => 'Date';

  @override
  String get qrActionEventDesc => 'Description';

  @override
  String get qrActionAddToCalendar => 'Add to Calendar';

  @override
  String get qrActionCalendarOpenError => 'Could not open calendar app';

  @override
  String qrActionCalendarError(String error) {
    return 'Error opening calendar: $error';
  }

  @override
  String get qrActionMeCardTitle => 'MeCard';

  @override
  String get qrActionTextTitle => 'Text';

  @override
  String get qrActionErrorTitle => 'Error';

  @override
  String get qrActionPhoneOpenError => 'Could not open phone app';

  @override
  String qrActionPhoneError(String error) {
    return 'Error opening phone: $error';
  }

  @override
  String get qrActionEmailOpenError => 'Could not open email app';

  @override
  String qrActionEmailError(String error) {
    return 'Error opening email: $error';
  }

  @override
  String get qrActionSmsOpenError => 'Could not open SMS app';

  @override
  String qrActionSmsError(String error) {
    return 'Error opening SMS: $error';
  }

  @override
  String get qrActionLocationParseError => 'Could not read location details';

  @override
  String get qrActionMapsOpenError => 'Could not open maps app';

  @override
  String qrActionMapsError(String error) {
    return 'Error opening maps: $error';
  }

  @override
  String get permCameraTitle => 'Camera Permission';

  @override
  String get permCameraWhyTitle => 'Why Is Camera Permission Needed?';

  @override
  String get permCameraWhyContent =>
      '🔍 Camera access is needed to scan QR codes.\n📱 The app uses the camera only to recognize QR codes.\n🚫 No photos or videos are recorded.\n🔒 Your privacy is protected.';

  @override
  String get permCameraDataSafe => 'Your data is secure';

  @override
  String get permCameraSettingsNote =>
      'You can revoke this permission anytime from device settings.';

  @override
  String get permGrant => 'Grant Permission';

  @override
  String get permDecline => 'Deny';

  @override
  String get permCancel => 'Cancel';

  @override
  String get permGoToSettings => 'Go to Settings';

  @override
  String get permUnderstood => 'Understood';

  @override
  String get permContinue => 'Continue';

  @override
  String get permSettingsTitle => 'Permission Required';

  @override
  String get permManualRequired => 'Manual Permission Setting Required';

  @override
  String get permManualContent =>
      'Camera permission was previously denied permanently.\n\nTo scan QR codes:\n1. Settings > Apps\n2. QR App > Permissions\n3. Enable Camera permission';

  @override
  String get permDeniedTitle => 'Permission Denied';

  @override
  String get permDeniedScanningImpossible => 'QR Scanning Unavailable';

  @override
  String get permDeniedContent =>
      'We cannot use the QR scanning feature without camera permission.\n\nYou can try again later or grant the permission manually from device settings.';

  @override
  String get permGalleryTitle => 'Gallery Access';

  @override
  String get permGalleryWhyTitle => 'Why Gallery Access?';

  @override
  String get permGalleryWhyContent =>
      '📷 To let you select images containing QR codes from your gallery.\n🔍 To read QR codes from the selected image.\n🔒 Only the selected image is processed; your other photos are not accessed.';

  @override
  String get aiRepairTitle => 'Select Image for AI Repair';

  @override
  String get aiRepairOptionCamera => 'Take Photo from Camera';

  @override
  String get aiRepairOptionCameraSubtitle =>
      'Take a clear, close-up photo of the damaged QR';

  @override
  String get aiRepairOptionGallery => 'Select from Gallery';

  @override
  String get aiRepairOptionGallerySubtitle => 'Select a previously taken photo';

  @override
  String get aiRepairWithAI => 'Repair Damaged QR with AI';

  @override
  String get aiDamagedQrPrompt => 'QR Damaged? Repair with AI';

  @override
  String get aiScanFailed => 'AI could not decode a QR from this image.';

  @override
  String get aiServerUnreachable =>
      'Server is unreachable. The image has been added to the offline queue.';

  @override
  String aiServerError(String error) {
    return 'AI Server Error: $error';
  }
}
