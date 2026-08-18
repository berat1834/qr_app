import 'cloud_backup_service.dart';

class CloudSignInResult {
  final bool success;
  final String? errorDetail;

  const CloudSignInResult({required this.success, this.errorDetail});
}

abstract class CloudBackupGateway {
  Future<DateTime?> getLastBackupTimestamp();
  Future<bool> trySilentSignIn();
  Future<CloudSignInResult> signIn();
  Future<void> signOut();
  Future<bool> backupData();
  Future<bool> restoreData();
}

class DefaultCloudBackupGateway implements CloudBackupGateway {
  const DefaultCloudBackupGateway();

  @override
  Future<DateTime?> getLastBackupTimestamp() {
    return CloudBackupService.getLastBackupTimestamp();
  }

  @override
  Future<bool> trySilentSignIn() async {
    final user = await CloudBackupService.trySilentSignIn();
    return user != null;
  }

  @override
  Future<CloudSignInResult> signIn() async {
    final user = await CloudBackupService.signIn();
    return CloudSignInResult(
      success: user != null,
      errorDetail: CloudBackupService.lastSignInError,
    );
  }

  @override
  Future<void> signOut() {
    return CloudBackupService.signOut();
  }

  @override
  Future<bool> backupData() {
    return CloudBackupService.backupData();
  }

  @override
  Future<bool> restoreData() {
    return CloudBackupService.restoreData();
  }
}
