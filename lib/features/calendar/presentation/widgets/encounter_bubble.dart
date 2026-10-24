import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

/// 吹き出しの尻尾を描画するカスタムペインター
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 選択された日付のすれ違い情報を表示する吹き出しWidget
class EncounterBubble extends StatelessWidget {
  final int count;
  final String? eventName;

  const EncounterBubble({super.key, required this.count, this.eventName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 吹き出し本体（角丸矩形）
        Container(
          width: screenWidth * 0.6,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '$count人',
                style: const TextStyle(
                  color: AppColors.backgroundWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (eventName != null) ...[
                const SizedBox(height: 8),
                Text(
                  eventName!,
                  style: const TextStyle(
                    color: AppColors.backgroundWhite,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        // 吹き出しの尻尾（下向き三角形）
        CustomPaint(
          size: const Size(20, 10),
          painter: _BubbleTailPainter(color: AppColors.primary),
        ),
      ],
    );
  }
}
