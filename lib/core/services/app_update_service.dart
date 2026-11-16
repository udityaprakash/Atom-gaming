import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class AppUpdateInfo {
  final String latestVersion;
  final String tagName;
  final String releaseName;
  final String releaseNotes;
  final DateTime publishedAt;
  final String downloadUrl;
  final String fileName;
  final int fileSizeBytes;
  final String htmlUrl;
  final bool hasUpdate;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.tagName,
    required this.releaseName,
    required this.releaseNotes,
    required this.publishedAt,
    required this.downloadUrl,
    required this.fileName,
    required this.fileSizeBytes,
    required this.htmlUrl,
    required this.hasUpdate,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class AppUpdateService {
  AppUpdateService._();

  static const String repoOwner = 'udityaprakash';
  static const String repoName = 'Atom-gaming';
  static const String apiUrl = 'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';
  static const _channel = MethodChannel('com.example.atom/file_picker');

  /// Fetches latest release metadata from public GitHub Releases API
  static Future<AppUpdateInfo> checkForUpdate() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    try {
      final request = await client.getUrl(Uri.parse(apiUrl));
      request.headers.set(HttpHeaders.userAgentHeader, 'atom-gaming-app');
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('GitHub API returned error code ${response.statusCode}');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      final tagName = json['tag_name'] as String? ?? '';
      final releaseName = json['name'] as String? ?? tagName;
      final releaseNotes = json['body'] as String? ?? 'No release notes provided.';
      final publishedAtStr = json['published_at'] as String?;
      final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) ?? DateTime.now() : DateTime.now();
      final htmlUrl = json['html_url'] as String? ?? 'https://github.com/$repoOwner/$repoName/releases';

      final cleanLatest = tagName.replaceAll(RegExp(r'^[vV]'), '').trim();
      final cleanCurrent = AppConstants.appVersion.replaceAll(RegExp(r'^[vV]'), '').trim();

      // Find APK assets
      final assets = (json['assets'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final apkAssets = assets.where((a) {
        final name = (a['name'] as String? ?? '').toLowerCase();
        return name.endsWith('.apk');
      }).toList();

      if (apkAssets.isEmpty) {
        throw Exception('No APK assets found in latest GitHub release.');
      }

      // Prioritize modern arm64-v8a APK, fallback to any non-x86 APK, then first APK
      var chosenAsset = apkAssets.firstWhere(
        (a) => (a['name'] as String? ?? '').toLowerCase().contains('arm64-v8a'),
        orElse: () => apkAssets.firstWhere(
          (a) => !(a['name'] as String? ?? '').toLowerCase().contains('x86'),
          orElse: () => apkAssets.first,
        ),
      );

      final downloadUrl = chosenAsset['browser_download_url'] as String? ?? '';
      final fileName = chosenAsset['name'] as String? ?? 'atom_update.apk';
      final fileSizeBytes = chosenAsset['size'] as int? ?? 0;

      final hasUpdate = isNewerVersion(cleanLatest, cleanCurrent);

      return AppUpdateInfo(
        latestVersion: cleanLatest,
        tagName: tagName,
        releaseName: releaseName,
        releaseNotes: releaseNotes,
        publishedAt: publishedAt,
        downloadUrl: downloadUrl,
        fileName: fileName,
        fileSizeBytes: fileSizeBytes,
        htmlUrl: htmlUrl,
        hasUpdate: hasUpdate,
      );
    } finally {
      client.close();
    }
  }

  /// Compares version strings
  static bool isNewerVersion(String latestVersion, String currentVersion) {
    if (latestVersion == currentVersion) return false;

    // If current was initial 1.1.0 and latest is date-based 0.x.x.x, consider it an update
    if (currentVersion == '1.1.0' && latestVersion.startsWith('0.')) {
      return true;
    }

    final latestParts = latestVersion.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final currentParts = currentVersion.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    final maxLen = latestParts.length > currentParts.length ? latestParts.length : currentParts.length;

    for (int i = 0; i < maxLen; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }

    return latestVersion != currentVersion;
  }

  /// Downloads the release APK with progress tracking
  static Future<File> downloadApk({
    required String downloadUrl,
    required String fileName,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(downloadUrl));
    request.headers.set(HttpHeaders.userAgentHeader, 'atom-gaming-app');

    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Failed to download APK: HTTP ${response.statusCode}');
    }

    final totalBytes = response.contentLength;
    int receivedBytes = 0;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }

    final sink = file.openWrite();

    await response.listen((chunk) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      final progress = totalBytes > 0 ? (receivedBytes / totalBytes) : 0.0;
      onProgress(progress, receivedBytes, totalBytes);
    }).asFuture();

    await sink.flush();
    await sink.close();
    client.close();

    return file;
  }

  /// Triggers native Android Package Installer for in-place app update
  static Future<void> installApk(File apkFile) async {
    try {
      await _channel.invokeMethod('installApk', {'filePath': apkFile.path});
    } catch (e) {
      debugPrint('Install APK error: $e');
      rethrow;
    }
  }

  /// Opens the release page in the device's web browser
  static Future<void> openReleasePage(String url) async {
    try {
      await _channel.invokeMethod('openUrl', {'url': url});
    } catch (e) {
      debugPrint('Open URL error: $e');
    }
  }
}
