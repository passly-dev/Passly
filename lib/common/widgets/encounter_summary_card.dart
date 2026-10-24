import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1300:1490 「その日に出会った人 / 親しい友達」リスト行。
///
/// 382x115 の 1 行分。上段: タイトル + サブタイトル、下段: 6 個のアバター +
/// 残りを示す「+N」チップ。行下端に区切り線を描画する。
///
/// カレンダー画面の日別サマリー、親しい友達サマリー等で再利用する。
class EncounterSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> avatarUrls;

  /// 表示する最大アバター数。超過分は「+N」チップに集約する。
  final int maxVisible;

  final bool showBottomDivider;

  /// 行全体をタップ可能にする場合のコールバック。
  final VoidCallback? onTap;

  const EncounterSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarUrls,
    this.maxVisible = 6,
    this.showBottomDivider = true,
    this.onTap,
  });

  static const double _height = 115;
  static const double _avatarSize = 45;

  @override
  Widget build(BuildContext context) {
    final visible = avatarUrls.take(maxVisible).toList();
    final overflow = avatarUrls.length - visible.length;

    Widget content = Container(
      height: _height,
      decoration: BoxDecoration(
        border: showBottomDivider
            ? const Border(
                bottom: BorderSide(color: PasslyBorder.divider, width: 1),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleBlock(title: title, subtitle: subtitle),
          const SizedBox(height: PasslySpace.s8),
          _AvatarRow(urls: visible, overflow: overflow),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(onTap: onTap, child: content);
    }
    return content;
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TitleBlock({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 19.2 / 16,
          ),
        ),
        const SizedBox(height: PasslySpace.s8),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: PasslyText.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 16.8 / 14,
          ),
        ),
      ],
    );
  }
}

class _AvatarRow extends StatelessWidget {
  final List<String> urls;
  final int overflow;

  const _AvatarRow({required this.urls, required this.overflow});

  // Figma spec: 6 avatars + overflow chip を w=382 に space-between で並べると
  // アイテム間ギャップは (382 - 7*45) / 6 ≒ 11.17px。左詰め時もこの値に揃える。
  static const double _gap = 11;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (final url in urls) _AvatarCircle(url: url),
      if (overflow > 0) _OverflowChip(count: overflow),
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    // オーバーフローがある = 7 個フルに詰まる → Figma 準拠で space-between。
    // オーバーフローなし = 左詰めで固定ギャップ。
    if (overflow > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          children[i],
        ],
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String url;
  const _AvatarCircle({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: EncounterSummaryCard._avatarSize,
        height: EncounterSummaryCard._avatarSize,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: PasslyBg.elevated,
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              color: PasslyText.tertiary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  final int count;
  const _OverflowChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: EncounterSummaryCard._avatarSize,
      height: EncounterSummaryCard._avatarSize,
      decoration: const BoxDecoration(
        color: PasslyBorder.strong,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: const TextStyle(
          color: PasslyText.secondary,
          fontSize: 10.8,
          fontWeight: FontWeight.w500,
          height: 12.96 / 10.8,
        ),
      ),
    );
  }
}
