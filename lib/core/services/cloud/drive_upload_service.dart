import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class DriveUploadService {
  DriveUploadService._();

  static const _scopes = ['https://www.googleapis.com/auth/drive.file'];
  static bool _initialized = false;

  static Future<GoogleSignInAccount> _signIn() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }

    final lightweightFuture = GoogleSignIn.instance.attemptLightweightAuthentication();
    final existingAccount = lightweightFuture != null ? await lightweightFuture : null;

    return existingAccount ?? GoogleSignIn.instance.authenticate();
  }

  /// Uploads [files] (fileName -> contents) into a new subfolder named [subfolderName]
  /// inside [parentFolderId] on the shared Google Drive, using the signed-in user's own quota.
  /// Returns the number of files uploaded.
  static Future<int> uploadFiles({
    required Map<String, String> files,
    required String parentFolderId,
    required String subfolderName,
  }) async {
    final account = await _signIn();
    final headers = await account.authorizationClient.authorizationHeaders(
      _scopes,
      promptIfNecessary: true,
    );

    if (headers == null) {
      throw Exception('Không lấy được quyền truy cập Google Drive');
    }

    final client = _AuthorizedClient(headers);

    try {
      final driveApi = drive.DriveApi(client);

      final subfolder = await driveApi.files.create(
        drive.File()
          ..name = subfolderName
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = [parentFolderId],
      );

      for (final entry in files.entries) {
        final bytes = utf8.encode(entry.value);

        await driveApi.files.create(
          drive.File()
            ..name = entry.key
            ..parents = [subfolder.id!],
          uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
        );
      }

      return files.length;
    } finally {
      client.close();
    }
  }
}

class _AuthorizedClient extends http.BaseClient {
  _AuthorizedClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
