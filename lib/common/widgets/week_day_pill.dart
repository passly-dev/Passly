import 'package:flutter/material.dart';

import 'package:passly/common/widgets/press_feedback.dart';
import 'package:passly/core/constants/passly_tokens.dart';

/// Figma node 1185:1000 「日にちごとのコンポーネント」1 日分のピル。
///
/// 縦長 pill (46x76) の中に「日番号入りの丸」を上部に重ねた 2 段構造。
/// 丸には 1.4 幅の境界線が入る (Figma node 1185:958 / 1185:1082 準拠)。
///
/// - [isSelected]=true (当日 / 選択中):
///   - 外側 pill: `PasslyBrand.primaryDark (#1E7F1E)`
///   - 上部の丸: fill `#1EE266` / stroke `PasslyBrand.primaryMuted (#C7E9C7)` 1.4
///   - テキスト: 白
/// - [isSelected]=false (デフォルト):
///   - 外側 pill: `PasslyBorder.strong (#D1D5DB)`
///   - 上部の丸: fill `PasslyBg.elevated (#F2F4F6)` / stroke `PasslyBorder.strong (#D1D5DB)` 1.4
///   - テキスト: `PasslyText.tertiary (#9CA3AF)`
///
/// タップ時のリップル等モーションは付けず、色替えのみで反応する。
class WeekDayPill extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  /// 右上の目印の色。null なら出さない（イベントがない日）。
  final Color? badgeColor;

  const WeekDayPill({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
    this.badgeColor,
  });

  /// 参加したイベントの日（今日まで）の目印。
  static const Color pastEventBadge = PasslyBrand.primary;

  /// これからのイベントの日の目印。
  static const Color upcomingEventBadge = Color(0xFFF59E0A);

  static const double _pillWidth = 46;
  static const double _pillHeight = 76;
  static const double _circleStrokeWidth = 1.4;

  /// Figma で当日の丸に使われる鮮やかな緑 (#1EE266)。
  /// [PasslyBrand.primary]/[PasslyBrand.primaryLight] とは別系統のアクセント色。
  static const Color _todayCircleFill = Color(0xFF1EE266);

  @override
  Widget build(BuildContext context) {
    final outerColor = isSelected
        ? PasslyBrand.primaryDark
        : PasslyBorder.strong;
    final innerCircleFill = isSelected ? _todayCircleFill : PasslyBg.elevated;
    final innerCircleStroke = isSelected
        ? PasslyBrand.primaryMuted
        : PasslyBorder.strong;
    final textColor = isSelected ? PasslyText.onBrand : PasslyText.tertiary;

    final pill = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PressFeedback(
        child: Container(
          width: _pillWidth,
          height: _pillHeight,
          decoration: BoxDecoration(
            color: outerColor,
            borderRadius: BorderRadius.circular(100),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: _pillWidth,
                  height: _pillWidth,
                  decoration: BoxDecoration(
                    color: innerCircleFill,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: innerCircleStroke,
                      width: _circleStrokeWidth,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: PasslyFont.family,
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 19.93 / 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: Text(
                    _weekdayLabel(date.weekday),
                    style: TextStyle(
                      fontFamily: PasslyFont.family,
                      color: textColor,
                      fontSize: 14,
                      fontWeight: PasslyFont.medium,
                      height: 17.44 / 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final badge = badgeColor;
    if (badge == null) return pill;
    // Figma node 1953:1697「目印案C」: 右上に少しはみ出す直径 14 の丸（白い縁 2）。
    // はみ出した部分は表示だけで、タップはピル本体で受ける。
    return Stack(
      clipBehavior: Clip.none,
      children: [
        pill,
        Positioned(
          top: -4,
          right: -3,
          child: IgnorePointer(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: badge,
                shape: BoxShape.circle,
                border: Border.all(color: PasslyBg.surface, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _weekdayLabel(int weekday) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[weekday - 1];
  }
}
