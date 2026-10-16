import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import '../widgets/dynamic_island_pill.dart';
import 'qr_pairing_screen.dart';
import 'update_center_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showActiveTransfer = true;

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrPairingScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic Island Pill
            if (_showActiveTransfer)
              DynamicIslandPill(
                fileName: 'presentation_slides_4k.zip',
                progress: 68,
                speed: '18.4 MB/s',
                isUpload: false,
                onCancel: () => setState(() => _showActiveTransfer = false),
              ),

            // Big Send & Receive Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      title: 'SEND',
                      subtitle: 'Photos, videos, files',
                      icon: Icons.arrow_outward,
                      color: PixelColors.primary,
                      onTap: () {
                        // File picker flow
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      title: 'RECEIVE',
                      subtitle: 'Pair or scan QR code',
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

            // QR Fast Connect Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PixelColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PixelColors.border),
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
                    child: const Icon(Icons.qr_code_2, color: PixelColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Windows PC Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap to pair via 5-min QR token',
                          style: TextStyle(
                            color: PixelColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PixelColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrPairingScreen()),
                      );
                    },
                    child: const Text('PAIR', style: TextStyle(fontWeight: FontWeight.bold)),
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

            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTransferHistoryTile('Camera_RAW_2026.dng', '48.2 MB', '2m ago', true),
                _buildTransferHistoryTile('PIXELDROP-Setup.exe', '24.5 MB', '15m ago', false),
                _buildTransferHistoryTile('client_export.sql', '128.0 MB', '1h ago', true),
              ],
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
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
                    fontSize: 16,
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
