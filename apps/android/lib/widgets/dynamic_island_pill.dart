import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class DynamicIslandPill extends StatefulWidget {
  final String fileName;
  final int progress;
  final String speed;
  final bool isUpload;
  final VoidCallback onCancel;

  const DynamicIslandPill({
    super.key,
    required this.fileName,
    required this.progress,
    required this.speed,
    required this.isUpload,
    required this.onCancel,
  });

  @override
  State<DynamicIslandPill> createState() => _DynamicIslandPillState();
}

class _DynamicIslandPillState extends State<DynamicIslandPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: PixelColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: PixelColors.primary.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: PixelColors.primary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Glowing status indicator
          FadeTransition(
            opacity: _animController,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: PixelColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Transfer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.isUpload ? "Sending" : "Receiving"} · ${widget.progress}% · ${widget.speed}',
                  style: TextStyle(
                    color: PixelColors.primary.withOpacity(0.9),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Cancel button
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: PixelColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }
}
