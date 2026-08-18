import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/cloud_backup_gateway.dart';
import 'feedback_screen.dart';

class CloudBackupScreen extends StatefulWidget {
  final CloudBackupGateway? gateway;

  const CloudBackupScreen({super.key, this.gateway});

  @override
  State<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  late final CloudBackupGateway _gateway;
  bool _isLoading = false;
  String? _status;
  bool? _statusSuccess;
  DateTime? _lastBackup;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _gateway = widget.gateway ?? const DefaultCloudBackupGateway();
    _loadLastBackup();
    _checkSignedIn();
  }

  Future<void> _loadLastBackup() async {
    final last = await _gateway.getLastBackupTimestamp();
    if (!mounted) return;
    setState(() => _lastBackup = last);
  }

  Future<void> _checkSignedIn() async {
    final signedIn = await _gateway.trySilentSignIn();
    if (!mounted) return;
    setState(() => _signedIn = signedIn);
  }

  Future<void> _handleSignIn() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _status = null;
      _statusSuccess = null;
    });
    final signInResult = await _gateway.signIn();
    if (!mounted) return;
    final errorDetail = signInResult.errorDetail;
    final isUserCancelled =
        errorDetail != null &&
        RegExp(
          r'cancell?ed|12501|sign_in_canceled',
          caseSensitive: false,
        ).hasMatch(errorDetail);

    setState(() {
      _signedIn = signInResult.success;
      _isLoading = false;
      _status = signInResult.success
          ? loc.cloudSignInSuccess
          : (errorDetail != null && !isUserCancelled
                ? loc.cloudSignInFailedWithDetail(errorDetail)
                : loc.cloudSignInFailedGeneric);
      _statusSuccess = signInResult.success;
    });
  }

  Future<void> _handleSignOut() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _status = null;
      _statusSuccess = null;
    });
    await _gateway.signOut();
    if (!mounted) return;
    setState(() {
      _signedIn = false;
      _isLoading = false;
      _status = loc.cloudSignOutSuccess;
      _statusSuccess = true;
    });
  }

  Future<void> _handleBackup() async {
    final loc = AppLocalizations.of(context)!;
    if (!_signedIn) {
      await _handleSignIn();
      if (!_signedIn) return;
    }

    setState(() {
      _isLoading = true;
      _status = null;
      _statusSuccess = null;
    });
    final ok = await _gateway.backupData();
    await _loadLastBackup();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _status = ok ? loc.cloudBackupSuccess : loc.cloudBackupFailed;
      _statusSuccess = ok;
    });
    if (!ok) {
      _showErrorDialog(loc.cloudBackupFailedDetail);
    }
  }

  Future<void> _handleRestore() async {
    final loc = AppLocalizations.of(context)!;
    if (!_signedIn) {
      await _handleSignIn();
      if (!_signedIn) return;
    }

    setState(() {
      _isLoading = true;
      _status = null;
      _statusSuccess = null;
    });
    final ok = await _gateway.restoreData();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _status = ok ? loc.cloudRestoreSuccess : loc.cloudRestoreFailed;
      _statusSuccess = ok;
    });
    if (!ok) {
      _showErrorDialog(loc.cloudRestoreFailedDetail);
    }
  }

  void _showErrorDialog(String message) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.cloudErrorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry
            },
            child: Text(loc.cloudRetry),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));
            },
            child: Text(loc.cloudSendFeedback),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.commonClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.cloudBackup)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
            ],
            if (_status != null) ...[
              Text(
                _status!,
                style: TextStyle(
                  color: _statusSuccess == null
                      ? Theme.of(context).colorScheme.onSurface
                      : (_statusSuccess! ? Colors.green : Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_lastBackup != null)
              Text(loc.cloudLastBackupLabel(_lastBackup!.toLocal().toString())),
            const SizedBox(height: 24),
            if (!_signedIn)
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: Text(loc.cloudSignInWithGoogle),
                onPressed: _isLoading ? null : _handleSignIn,
              ),
            if (_signedIn) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: Text(loc.cloudBackupData),
                onPressed: _isLoading ? null : _handleBackup,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: Text(loc.cloudRestoreBackup),
                onPressed: _isLoading ? null : _handleRestore,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(loc.cloudSignOut),
                onPressed: _isLoading ? null : _handleSignOut,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
