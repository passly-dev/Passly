import 'package:flutter/material.dart';

import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/common/widgets/press_feedback.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1196:1207 「イベント表示カード」。
///
/// 白背景 / border divider / 角丸 20、内部に画像 110x110 + イベント名 +
/// 日付 + 場所 + 参加者数 + 右端の chevron。カレンダー画面のその日のイベント
/// 表示や、イベント検索結果カードで使用する。
///
/// タップ時のリップル等モーションは付けず、色替えなしのタップ検知のみ。
class DayEventCard extends StatelessWidget {
  final String eventName;
  final String? imageUrl;
  final DateTime date;
  final String location;
  final int participantCount;
  final VoidCallback onTap;

  const DayEventCard({
    super.key,
    required this.eventName,
    required this.date,
    required this.location,
    required this.participantCount,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PressFeedback(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PasslyBg.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PasslyBorder.divider, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _EventImage(imageUrl: imageUrl),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eventName.isEmpty ? 'イベント名未設定' : eventName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 19.2 / 16,
                      ),
                    ),
                    const SizedBox(height: PasslySpace.s8),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        color: PasslyText.secondary,
                        fontSize: 12,
                        fontWeight: PasslyFont.regular,
                        height: 14.4 / 12,
                      ),
                    ),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const PasslyIcon(
                            asset: PasslyIcons.location,
                            size: 15,
                            color: PasslyText.secondary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: PasslyFont.family,
                                color: PasslyText.secondary,
                                fontSize: 12,
                                fontWeight: PasslyFont.regular,
                                height: 14.4 / 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: PasslySpace.s8),
                    Row(
                      children: [
                        const Text(
                          '参加者',
                          style: TextStyle(
                            fontFamily: PasslyFont.family,
                            color: PasslyText.secondary,
                            fontSize: 12,
                            fontWeight: PasslyFont.regular,
                            height: 14.4 / 12,
                          ),
                        ),
                        const SizedBox(width: PasslySpace.s8),
                        Text(
                          '$participantCount人',
                          style: const TextStyle(
                            fontFamily: PasslyFont.family,
                            color: PasslyBrand.primaryDark,
                            fontSize: 12,
                            fontWeight: PasslyFont.medium,
                            height: 14.4 / 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const PasslyIcon(
                asset: PasslyIcons.chevron,
                size: 23.77,
                color: PasslyText.secondary,
                flipHorizontal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}

class _EventImage extends StatelessWidget {
  final String? imageUrl;

  const _EventImage({this.imageUrl});

  static const Color _placeholderBg = Color(0xFFF2F2F2);
  static const double _size = 110;
  static const double _radius = 10.23;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: _placeholderBg,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(_radius),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              ),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.event, color: PasslyText.tertiary, size: 40),
    );
  }
}
