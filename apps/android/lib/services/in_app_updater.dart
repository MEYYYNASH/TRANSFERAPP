import 'dart:convert';
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
  static const String currentVersion = '1.0.6';

  // Fast direct CDN endpoints without GitHub API 60 req/hr rate limits!
  static const String cdnManifestUrl =
      'https://raw.githubusercontent.com/MEYYYNASH/TRANSFERAPP/main/latest.json';
  static const String releaseManifestUrl =
      'https://github.com/MEYYYNASH/TRANSFERAPP/releases/latest/download/latest.json';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Check for new version using rate-limit-free Raw CDN manifest
  Future<GitHubReleaseInfo?> checkForUpdate() async {
    // 1. Try raw CDN manifest first (zero rate limits, instant updates upon normal git push!)
    try {
      final response = await _dio.get(cdnManifestUrl);
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data : jsonDecode(response.data);
        final latestVersion = (data['version'] as String? ?? '1.0.2').replaceAll('v', '');
        final isNewer = _isVersionHigher(latestVersion, currentVersion);
        final apkUrl = (data['apk_url'] as String? ??
            'https://github.com/MEYYYNASH/TRANSFERAPP/releases/download/v$latestVersion/PIXELDROP.apk');

        return GitHubReleaseInfo(
          version: latestVersion,
          releaseNotes: data['release_notes'] as String? ?? 'New version available.',
          apkDownloadUrl: apkUrl,
          apkSize: 97 * 1024 * 1024,
          isNewer: isNewer,
        );
      }
    } catch (e) {
      debugPrint('CDN check failed: $e. Trying fallback...');
    }

    // 2. Try release asset manifest fallback
    try {
      final response = await _dio.get(releaseManifestUrl);
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data : jsonDecode(response.data);
        final latestVersion = (data['version'] as String? ?? '1.0.2').replaceAll('v', '');
        final isNewer = _isVersionHigher(latestVersion, currentVersion);
        final apkUrl = (data['apk_url'] as String? ??
            'https://github.com/MEYYYNASH/TRANSFERAPP/releases/download/v$latestVersion/PIXELDROP.apk');

        return GitHubReleaseInfo(
          version: latestVersion,
          releaseNotes: data['release_notes'] as String? ?? 'New version available.',
          apkDownloadUrl: apkUrl,
          apkSize: 97 * 1024 * 1024,
          isNewer: isNewer,
        );
      }
    } catch (e) {
      debugPrint('Release manifest check failed: $e');
    }

    return null;
  }

  /// Download APK directly in-app and trigger Android package installer
  Future<bool> downloadAndInstallApk(
    String apkUrl,
    void Function(int received, int total) onProgress,
  ) async {
    try {
      Directory dir;
      try {
        dir = (await getExternalStorageDirectory()) ?? (await getTemporaryDirectory());
      } catch (_) {
        dir = await getTemporaryDirectory();
      }
      final savePath = '${dir.path}/PIXELDROP.apk';

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Download APK stream directly with progress
      await _dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: onProgress,
      );

      // Trigger Android system package installer intent
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
