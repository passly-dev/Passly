import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

// 修正: 不要なコメントの削除と階層の整理
class InfoListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String value;
  final bool isUrl;
  final bool showDivider;

  const InfoListItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.value,
    this.isUrl = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildIcon(), // 修正: メソッド化してネストを浅く
              const SizedBox(width: 16),
              Expanded(child: _buildTextContent()),
              if (isUrl) _buildUrlArrow(),
            ],
          ),
        ),
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlArrow() {
    return const Padding(
      padding: EdgeInsets.only(left: 8),
      child: Icon(Icons.chevron_right, color: AppColors.textDisabled),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.divider,
      indent: 16,
      endIndent: 16,
    );
  }
}
