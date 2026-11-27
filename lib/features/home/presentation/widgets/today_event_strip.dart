import 'package:flutter/material.dart';

import 'package:passly/common/widgets/sized_network_image.dart';
import 'package:passly/core/constants/passly_tokens.dart';

/// ホームの一番上に出す，今日参加しているイベントの 1 行の帯（Figma 今日のイベント案B）。
///
/// ふだんは「参加中・イベント名・今日すれ違った人数」。
/// まだ見ていないすれ違いがまとまった人数になったら（[newCount] が null でない），
/// 同じ形のまま緑に変わり「新しく N 人とすれ違いました」と知らせる。
/// 上に別のバナーを重ねないので，下の内容が押し下げられない。
class TodayEventStrip extends StatelessWidget {
  final String eventName;

  /// 今日すれ違った人数。
  final int todayCount;

  /// 帯に並べるアイコン（最大 3 つ）。
  final List<({String iconUrl, String name})> people;

  /// まとめて知らせる新しいすれ違いの人数。知らせないときは null。
  final int? newCount;

  /// 開始前なら「今日」，始まっていれば「参加中」。
  final bool started;

  final VoidCallback onTap;

  const TodayEventStrip({
    super.key,
    required this.eventName,
    required this.todayCount,
    required this.people,
    required this.onTap,
    this.newCount,
    this.started = true,
  });

  bool get _isNew => newCount != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -0.25),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: _strip(key: ValueKey(_isNew)),
    );
  }

  Widget _strip({required Key key}) {
    final fg = _isNew ? PasslyText.onBrand : PasslyBrand.primaryDark;
    return Material(
      key: key,
      color: _isNew ? PasslyBrand.primary : PasslyBg.surface,
      shape: StadiumBorder(
        side: _isNew
            ? BorderSide.none
            : const BorderSide(color: PasslyBrand.primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key(_isNew ? 'today_event_strip_new' : 'today_event_strip'),
        onTap: onTap,
        child: SizedBox(
          height: 49,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isNew ? Colors.white : PasslyBrand.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isNew ? 'NEW' : (started ? '参加中' : '今日'),
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    color: fg,
                    fontSize: 12,
                    fontWeight: PasslyFont.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isNew ? '新しく$newCount人とすれ違いました' : eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: PasslyFont.family,
                      color: _isNew ? PasslyText.onBrand : PasslyText.primary,
                      fontSize: 13,
                      fontWeight: PasslyFont.bold,
                    ),
                  ),
                ),
                if (people.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _StripAvatars(people: people),
                ],
                const SizedBox(width: 8),
                Text(
                  _isNew ? '見る ›' : '$todayCount人 ›',
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    color: fg,
                    fontSize: 12,
                    fontWeight: PasslyFont.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StripAvatars extends StatelessWidget {
  final List<({String iconUrl, String name})> people;
  const _StripAvatars({required this.people});

  static const double _size = 22;
  static const double _step = 15;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(3).toList();
    return SizedBox(
      width: _size + (shown.length - 1) * _step,
      height: _size,
      child: Stack(
        children: [
          for (final (i, p) in shown.indexed)
            Positioned(
              left: i * _step,
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  color: PasslyBrand.primarySurface,
                ),
                clipBehavior: Clip.antiAlias,
                child: p.iconUrl.isEmpty
                    ? _initial(p.name)
                    : SizedNetworkImage(
                        url: p.iconUrl,
                        fit: BoxFit.cover,
                        fallback: (_) => _initial(p.name),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _initial(String name) => Center(
    child: Text(
      name.trim().isEmpty ? '?' : name.trim().characters.first,
      style: const TextStyle(
        fontFamily: PasslyFont.family,
        color: PasslyBrand.primaryDark,
        fontSize: 10,
        fontWeight: PasslyFont.bold,
      ),
    ),
  );
}
