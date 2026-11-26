import 'package:flutter/material.dart';
import 'package:passly/common/widgets/sized_network_image.dart';
import 'package:passly/core/constants/passly_tokens.dart';

/// アプリを開いたまますれ違ったときに，画面の上から下りてくるバナー（Figma 表示案B）。
///
/// 画面は切り替えず，押したときだけすれ違い結果画面を開く。
/// 上にスワイプすると閉じる。次に新しくすれ違うとまた出る。
class EncounterBanner extends StatelessWidget {
  final bool visible;
  final String title;
  final String body;

  /// 重ねて出すアイコン（最大 2 つ）。空の URL は頭文字の丸にする。
  final List<({String iconUrl, String name})> people;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  const EncounterBanner({
    super.key,
    required this.visible,
    required this.title,
    required this.body,
    required this.people,
    required this.onOpen,
    required this.onDismiss,
  });

  static const Duration duration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        // 画面の上の外から，少し行き過ぎて戻るように下りてくる
        offset: visible ? Offset.zero : const Offset(0, -3),
        duration: duration,
        curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) < -100) onDismiss();
            },
            child: _card(),
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Material(
      color: PasslyBrand.primary,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.black,
      child: InkWell(
        key: const Key('encounter_banner'),
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(
            children: [
              if (people.isNotEmpty) ...[
                _Avatars(people: people),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        color: PasslyText.onBrand,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        color: PasslyText.onBrand,
                        fontSize: 11,
                        fontWeight: PasslyFont.medium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '見る',
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    color: PasslyBrand.primaryDark,
                    fontSize: 13,
                    fontWeight: PasslyFont.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatars extends StatelessWidget {
  final List<({String iconUrl, String name})> people;
  const _Avatars({required this.people});

  @override
  Widget build(BuildContext context) {
    final shown = people.take(2).toList();
    return SizedBox(
      width: 32 + (shown.length - 1) * 22,
      height: 32,
      child: Stack(
        children: [
          for (final (i, p) in shown.indexed)
            Positioned(
              left: i * 22,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
        fontSize: 13,
        fontWeight: PasslyFont.bold,
      ),
    ),
  );
}
