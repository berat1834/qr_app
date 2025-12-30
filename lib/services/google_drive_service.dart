import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope],
  );

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<drive.DriveApi?> getDriveApi() async {
    final account = await signIn();
    if (account == null) return null;
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    return drive.DriveApi(authenticateClient);
  }

  Future<String?> uploadBackupFile(File file, String filename) async {
    final api = await getDriveApi();
    if (api == null) return null;
    final media = drive.Media(file.openRead(), file.lengthSync());
    final driveFile = drive.File()..name = filename;
    final result = await api.files.create(driveFile, uploadMedia: media);
    return result.id;
  }

  Future<File?> downloadBackupFile(String fileId, String savePath) async {
    final api = await getDriveApi();
    if (api == null) return null;
    final media =
        await api.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    final file = File(savePath);
    final sink = file.openWrite();
    await media.stream.pipe(sink);
    await sink.close();
    return file;
  }

  Future<List<drive.File>> listBackupFiles({String? query}) async {
    final api = await getDriveApi();
    if (api == null) return [];
    final files = await api.files.list(q: query);
    return files.files ?? [];
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = IOClient();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
