import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/home/presentation/widgets/comment_item_widget.dart';

// 修正: 不要コメントの削除、UI構成のメソッド化
class CommentCardWidget extends StatelessWidget {
  final List<Map<String, String>> comments;

  const CommentCardWidget({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'みんなの一言 💬',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCommentListCard(),
      ],
    );
  }

  Widget _buildCommentListCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1A3AAA3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4D3AAA3A)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: Color(0x203AAA3A),
          ),
        ],
      ),
      child: comments.isEmpty
          ? const Center(
              child: Text(
                'まだコメントがありません',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            )
          : Column(children: _buildCommentItems()),
    );
  }

  // 修正: リスト生成ロジックの整理
  List<Widget> _buildCommentItems() {
    return List.generate(comments.length, (i) {
      final item = CommentItemWidget(
        name: comments[i]['name'] ?? '',
        comment: comments[i]['comment'] ?? '',
        iconUrl: comments[i]['iconUrl'] ?? '',
      );

      // 最後のアイテム以外は余白を下に追加
      if (i < comments.length - 1) {
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: item);
      }
      return item;
    });
  }
}
