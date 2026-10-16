import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class GitHubReleaseInfo {
  final String version;
  final String releaseNotes;
  final String apkDownloadUrl;
  final int apkSize;
  final bool isNewer;

  GitHubReleaseInfo({
    required this.version,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.apkSize,
    required this.isNewer,
  });
}

class InAppUpdaterService {
  static const String repoOwner = 'MEYYYNASH';
  static const String repoName = 'TRANSFERAPP';
  static const String currentVersion = '1.0.1';

  final Dio _dio = Dio();

  /// 1. Check GitHub API for the latest published release
  Future<GitHubReleaseInfo?> checkForUpdate() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tagName = data['tag_name'] as String? ?? 'v1.0.1';
        final latestVersion = tagName.replaceAll(RegExp(r'^v'), '');

        final isNewer = _isVersionHigher(latestVersion, currentVersion);

        String apkUrl = '';
        int apkSize = 0;

        final assets = data['assets'] as List<dynamic>? ?? [];
        for (final asset in assets) {
          final name = (asset['name'] as String).toLowerCase();
          if (name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String;
            apkSize = asset['size'] as int? ?? 0;
            break;
          }
        }

        return GitHubReleaseInfo(
          version: latestVersion,
          releaseNotes: data['body'] as String? ?? 'New version available.',
          apkDownloadUrl: apkUrl,
          apkSize: apkSize,
          isNewer: isNewer,
        );
      }
    } catch (e) {
      debugPrint('Error checking GitHub updates: $e');
    }
    return null;
  }

  /// 2. Download APK directly in-app and trigger installation intent
  Future<bool> downloadAndInstallApk(
    String apkUrl,
    void Function(int received, int total) onProgress,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/PIXELDROP.apk';

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // In-app stream download with progress
      await _dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: onProgress,
      );

      // Trigger Android system package installer intent directly
      final result = await OpenFilex.open(
        savePath,
        type: 'application/vnd.android.package-archive',
      );

      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('In-app update download error: $e');
      return false;
    }
  }

  bool _isVersionHigher(String v1, String v2) {
    final p1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final p2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < p1.length && i < p2.length; i++) {
      if (p1[i] > p2[i]) return true;
      if (p1[i] < p2[i]) return false;
    }
    return p1.length > p2.length;
  }
}
