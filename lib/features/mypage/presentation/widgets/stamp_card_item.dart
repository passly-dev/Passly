import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

/// マイページの「MY INFORMATION」内に表示するスタンプカード行のWidget
class StampCardItem extends StatelessWidget {
  final VoidCallback onTap;

  const StampCardItem({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 左側のアイコン（黄色背景）
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.stampGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            // ラベルとサブテキスト
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'スタンプカード',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '実績の確認',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 右側の矢印
            const Icon(Icons.chevron_right, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
