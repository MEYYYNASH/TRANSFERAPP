import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/pixel_theme.dart';
import '../widgets/dynamic_island_pill.dart';
import 'qr_pairing_screen.dart';
import 'qr_scanner_screen.dart';
import 'update_center_screen.dart';

class TransferHistoryItem {
  final String name;
  final String size;
  final String time;
  final bool isCompleted;

  TransferHistoryItem({
    required this.name,
    required this.size,
    required this.time,
    required this.isCompleted,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Active Transfer State
  bool _hasActiveTransfer = false;
  String _activeFileName = '';
  int _activeProgress = 0;
  String _activeSpeed = '0 MB/s';
  bool _isUploading = true;
  Timer? _transferTimer;

  // Paired Windows device state
  String _pairedDeviceName = 'Windows PC (Not Paired)';
  bool _isDevicePaired = false;

  // Recent Transfers List
  final List<TransferHistoryItem> _recentTransfers = [
    TransferHistoryItem(name: 'Camera_RAW_2026.dng', size: '48.2 MB', time: '2m ago', isCompleted: true),
    TransferHistoryItem(name: 'client_database.sql', size: '128.0 MB', time: '1h ago', isCompleted: true),
  ];

  @override
  void dispose() {
    _transferTimer?.cancel();
    super.dispose();
  }

  // 1. FILE PICKER & SEND WORKFLOW
  Future<void> _handleSendFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileSizeMb = ((file.size) / (1024 * 1024)).toStringAsFixed(1);
        final displaySize = file.size > (1024 * 1024)
            ? '$fileSizeMb MB'
            : '${(file.size / 1024).toStringAsFixed(1)} KB';

        _startLiveTransfer(fileName, displaySize);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PixelColors.surface,
            content: Text('File selection error: $e', style: const TextStyle(color: Colors.redAccent)),
          ),
        );
      }
    }
  }

  void _startLiveTransfer(String fileName, String fileSize) {
    _transferTimer?.cancel();
    setState(() {
      _hasActiveTransfer = true;
      _activeFileName = fileName;
      _activeProgress = 0;
      _activeSpeed = '24.6 MB/s';
      _isUploading = true;
    });

    // Simulate realistic transfer progression
    _transferTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_activeProgress >= 100) {
          timer.cancel();
          _hasActiveTransfer = false;
          _recentTransfers.insert(
            0,
            TransferHistoryItem(
              name: fileName,
              size: fileSize,
              time: 'Just now',
              isCompleted: true,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: PixelColors.surface,
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: PixelColors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Successfully sent $fileName!',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          _activeProgress += 8;
          if (_activeProgress > 100) _activeProgress = 100;
          _activeSpeed = '${(18 + (_activeProgress % 7)).toStringAsFixed(1)} MB/s';
        }
      });
    });
  }

  // 2. QR SCANNER CAMERA WORKFLOW
  Future<void> _handleScanQr() async {
    final scannedData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (scannedData != null && mounted) {
      setState(() {
        _isDevicePaired = true;
        _pairedDeviceName = 'Windows PC (Connected)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PixelColors.surface,
          content: Text(
            'Paired with PC: $scannedData',
            style: const TextStyle(color: PixelColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: PixelColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flash_on, color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('PIXELDROP'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: PixelColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateCenterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: 'Scan Windows PC QR',
            onPressed: _handleScanQr,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic Island Pill for Active Transfer
            if (_hasActiveTransfer)
              DynamicIslandPill(
                fileName: _activeFileName,
                progress: _activeProgress,
                speed: _activeSpeed,
                isUpload: _isUploading,
                onCancel: () {
                  _transferTimer?.cancel();
                  setState(() => _hasActiveTransfer = false);
                },
              ),

            // Big Send & Receive Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'SEND FILES',
                      subtitle: 'Photos, videos, files, APKs',
                      icon: Icons.arrow_outward,
                      color: PixelColors.primary,
                      onTap: _handleSendFiles,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      title: 'RECEIVE',
                      subtitle: 'Pair or show my QR code',
                      icon: Icons.south_west,
                      color: PixelColors.cyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrPairingScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Camera QR Scan & Pairing Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PixelColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isDevicePaired ? PixelColors.green : PixelColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PixelColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PixelColors.border),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: _isDevicePaired ? PixelColors.green : PixelColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pairedDeviceName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isDevicePaired
                            ? 'Ready for direct high-speed transfer'
                            : 'Scan QR on PC screen to connect',
                          style: const TextStyle(
                            color: PixelColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDevicePaired ? PixelColors.green : PixelColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: _handleScanQr,
                    child: Text(
                      _isDevicePaired ? 'SCAN AGAIN' : 'SCAN QR',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Transfers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'RECENT TRANSFERS',
                style: TextStyle(
                  color: PixelColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recentTransfers.length,
              itemBuilder: (context, index) {
                final item = _recentTransfers[index];
                return _buildTransferHistoryTile(item.name, item.size, item.time, item.isCompleted);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PixelColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: PixelColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferHistoryTile(String title, String size, String time, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PixelColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PixelColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: PixelColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('$size · $time', style: const TextStyle(color: PixelColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: PixelColors.green, size: 16),
        ],
      ),
    );
  }
}
