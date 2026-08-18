import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/l10n/app_localizations.dart';
import 'package:qr_app/screens/cloud_backup_screen.dart';
import 'package:qr_app/services/cloud_backup_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloudBackupGateway implements CloudBackupGateway {
  DateTime? lastBackupTimestamp;
  bool silentSignedIn = false;
  CloudSignInResult signInResult = const CloudSignInResult(success: false);
  bool backupResult = true;
  bool restoreResult = true;
  int signOutCallCount = 0;

  @override
  Future<bool> backupData() async => backupResult;

  @override
  Future<DateTime?> getLastBackupTimestamp() async => lastBackupTimestamp;

  @override
  Future<bool> restoreData() async => restoreResult;

  @override
  Future<CloudSignInResult> signIn() async => signInResult;

  @override
  Future<void> signOut() async {
    signOutCallCount++;
  }

  @override
  Future<bool> trySilentSignIn() async => silentSignedIn;
}

Widget _createApp({Locale? locale, CloudBackupGateway? gateway}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('tr'), Locale('en')],
    home: CloudBackupScreen(gateway: gateway),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CloudBackupScreen Widget Tests', () {
    testWidgets('TR locale shows localized title and sign-in CTA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_createApp(locale: const Locale('tr')));
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;

      expect(find.text(loc.cloudBackup), findsOneWidget);
      expect(find.text(loc.cloudSignInWithGoogle), findsOneWidget);
    });

    testWidgets('EN locale shows localized title and sign-in CTA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_createApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;

      expect(find.text(loc.cloudBackup), findsOneWidget);
      expect(find.text(loc.cloudSignInWithGoogle), findsOneWidget);
    });

    testWidgets('Shows last backup label when timestamp exists', (
      WidgetTester tester,
    ) async {
      final saved = DateTime(2026, 4, 17, 12, 30, 0).toIso8601String();
      SharedPreferences.setMockInitialValues({'last_backup_timestamp': saved});

      await tester.pumpWidget(_createApp(locale: const Locale('tr')));
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;
      final expected = loc.cloudLastBackupLabel(
        DateTime.parse(saved).toLocal().toString(),
      );

      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('Does not show last backup label for malformed timestamp', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'last_backup_timestamp': 'invalid-date',
      });

      await tester.pumpWidget(_createApp(locale: const Locale('tr')));
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;

      expect(find.textContaining('invalid-date'), findsNothing);
      expect(find.text(loc.cloudSignInWithGoogle), findsOneWidget);
    });

    testWidgets('Sign-in success shows success status and cloud actions', (
      WidgetTester tester,
    ) async {
      final fakeGateway = _FakeCloudBackupGateway()
        ..signInResult = const CloudSignInResult(success: true);

      await tester.pumpWidget(
        _createApp(locale: const Locale('tr'), gateway: fakeGateway),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;

      await tester.tap(find.text(loc.cloudSignInWithGoogle));
      await tester.pumpAndSettle();

      expect(find.text(loc.cloudSignInSuccess), findsOneWidget);
      expect(find.text(loc.cloudBackupData), findsOneWidget);
      expect(find.text(loc.cloudRestoreBackup), findsOneWidget);
      expect(find.text(loc.cloudSignOut), findsOneWidget);
    });

    testWidgets('Sign-in cancel shows generic failure message', (
      WidgetTester tester,
    ) async {
      final fakeGateway = _FakeCloudBackupGateway()
        ..signInResult = const CloudSignInResult(
          success: false,
          errorDetail: 'PlatformException(sign_in_canceled, user canceled)',
        );

      await tester.pumpWidget(
        _createApp(locale: const Locale('tr'), gateway: fakeGateway),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;

      await tester.tap(find.text(loc.cloudSignInWithGoogle));
      await tester.pumpAndSettle();

      expect(find.text(loc.cloudSignInFailedGeneric), findsOneWidget);
      expect(find.text(loc.cloudBackupData), findsNothing);
    });

    testWidgets('Sign-in technical failure shows detailed failure message', (
      WidgetTester tester,
    ) async {
      const detail = 'network timeout';
      final fakeGateway = _FakeCloudBackupGateway()
        ..signInResult = const CloudSignInResult(
          success: false,
          errorDetail: detail,
        );

      await tester.pumpWidget(
        _createApp(locale: const Locale('tr'), gateway: fakeGateway),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(CloudBackupScreen)),
      )!;

      await tester.tap(find.text(loc.cloudSignInWithGoogle));
      await tester.pumpAndSettle();

      expect(
        find.text(loc.cloudSignInFailedWithDetail(detail)),
        findsOneWidget,
      );
      expect(find.text(loc.cloudBackupData), findsNothing);
    });
  });
}
