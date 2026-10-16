import 'package:flutter/material.dart';
import '../services/in_app_updater.dart';
import '../theme/pixel_theme.dart';

class UpdateCenterScreen extends StatefulWidget {
  const UpdateCenterScreen({super.key});

  @override
  State<UpdateCenterScreen> createState() => _UpdateCenterScreenState();
}

class _UpdateCenterScreenState extends State<UpdateCenterScreen> {
  final InAppUpdaterService _updater = InAppUpdaterService();
  GitHubReleaseInfo? _releaseInfo;
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    setState(() => _isLoading = true);
    final info = await _updater.checkForUpdate();
    setState(() {
      _releaseInfo = info;
      _isLoading = false;
    });
  }

  Future<void> _startInAppUpdate() async {
    if (_releaseInfo?.apkDownloadUrl.isEmpty ?? true) return;

    setState(() {
      _isDownloading = true;
      _downloadPercent = 0.0;
    });

    final success = await _updater.downloadAndInstallApk(
      _releaseInfo!.apkDownloadUrl,
      (received, total) {
        if (total > 0) {
          setState(() {
            _downloadPercent = received / total;
          });
        }
      },
    );

    setState(() => _isDownloading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Installation failed or cancelled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPDATE CENTER'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current & Latest Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PixelColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PixelColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('INSTALLED', style: TextStyle(color: PixelColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('v${InAppUpdaterService.currentVersion}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(height: 35, width: 1, color: PixelColors.border),
                  Column(
                    children: [
                      const Text('GITHUB LATEST', style: TextStyle(color: PixelColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        _releaseInfo != null ? 'v${_releaseInfo!.version}' : 'v${InAppUpdaterService.currentVersion}',
                        style: const TextStyle(color: PixelColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(color: PixelColors.primary),
                ),
              )
            else if (_releaseInfo != null && _releaseInfo!.isNewer) ...[
              // Update Available Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PixelColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PixelColors.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.new_releases, color: PixelColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('NEW VERSION READY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _releaseInfo!.releaseNotes,
                      style: const TextStyle(color: PixelColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    if (_isDownloading) ...[
                      LinearProgressIndicator(
                        value: _downloadPercent,
                        backgroundColor: PixelColors.card,
                        valueColor: const AlwaysStoppedAnimation(PixelColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Downloading in-app APK: ${(_downloadPercent * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: PixelColors.primary, fontSize: 11),
                      ),
                    ] else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PixelColors.primary,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _startInAppUpdate,
                        child: const Text('UPDATE NOW (IN-APP)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PixelColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PixelColors.border),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.check_circle_outline, color: PixelColors.green, size: 40),
                    SizedBox(height: 8),
                    Text('You are on the latest version', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('PIXELDROP is up to date with GitHub Releases.', style: TextStyle(color: PixelColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),

            const Spacer(),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: PixelColors.textSecondary,
                side: const BorderSide(color: PixelColors.border),
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('CHECK FOR UPDATES'),
              onPressed: _checkUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
