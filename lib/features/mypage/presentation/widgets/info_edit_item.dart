import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

/// 各情報を表示および編集するための汎用行Widget
class InfoEditItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const InfoEditItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 左側のアイコン
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 16),
            // ラベルと値
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 右側の編集アイコン
            const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
