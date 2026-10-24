import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

// 修正: 不要なコメントを削除、定数の最適化
class PlazaSearchBar extends StatelessWidget {
  const PlazaSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: TextField(
          style: const TextStyle(
            color: AppColors.textPrimary, // 入力文字を濃い色に
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            hintText: '人名・イベント名で検索',
            hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
