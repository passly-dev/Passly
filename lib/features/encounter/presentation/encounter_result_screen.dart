import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syshack2026/common/widgets/encounter_loading_skeleton.dart';
import 'package:syshack2026/common/widgets/info_badge_card.dart';
import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/ble/ble_notifier.dart';
import 'package:syshack2026/features/encounter/domain/encounter_model.dart';
import 'package:syshack2026/features/encounter/domain/encounter_notifier.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';

/// すれ違い結果画面。
///
/// Figma node 1100:1602 に準拠。
/// - 自分と相手のアイコンを重ねて表示
/// - 相手の表示名
/// - 「出会った場所」= イベント名（未取得なら非表示）
/// - 「共通タグ」= 自分と相手の tech_stack の積集合（片方でも空なら非表示）
///
/// TODO(passly): 複数件の見せ方は未確定。
/// 現状は最新（先頭）1 件のみ表示している。
/// PageView や横スワイプ切替 / まとめ表示など、UX が決まったら書き換える。
class EncounterResultScreen extends ConsumerWidget {
  const EncounterResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encounterState = ref.watch(encounterNotifierProvider);
    final me = ref.watch(authNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: encounterState.when(
          data: (encounters) =>
              _EncounterCardStack(encounters: encounters, me: me),
          loading: () => const EncounterLoadingSkeleton(),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'すれ違い情報の取得に失敗しました\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EncounterCardStack extends StatefulWidget {
  final List<EncounterModel> encounters;
  final UserModel? me;
  const _EncounterCardStack({required this.encounters, required this.me});

  @override
  State<_EncounterCardStack> createState() => _EncounterCardStackState();
}

class _EncounterCardStackState extends State<_EncounterCardStack> {
  int _currentIndex = 0;

  void _nextCard() {
    if (_currentIndex < widget.encounters.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  Future<void> _close(WidgetRef ref) async {
    await ref.read(encounterNotifierProvider.notifier).confirmAll();
    ref.read(bleNotifierProvider.notifier).resetEncounterCount();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.encounters.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const SizedBox.shrink();
    }
    if (_currentIndex >= widget.encounters.length)
      return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '${_currentIndex + 1} / ${widget.encounters.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    for (
                      int i = widget.encounters.length - 1;
                      i >= _currentIndex;
                      i--
                    )
                      _buildCard(i, ref),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // TODO: このスキップボタンは仮置きのため、正式なUIが決まり次第修正する
              TextButton(
                onPressed: () => _close(ref),
                child: const Text(
                  'スキップ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, WidgetRef ref) {
    final encounter = widget.encounters[index];
    final isTop = index == _currentIndex;
    final offset = (index - _currentIndex) * 8.0;

    return Positioned(
      top: offset,
      left: offset,
      right: offset,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !isTop,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(
                myIconUrl: widget.me?.iconUrl ?? '',
                encounter: encounter,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _InfoCards(
                    myTechStack: widget.me?.techStack ?? '',
                    encounter: encounter,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ActionButtons(
                targetUserId: encounter.encounteredUser.id,
                isLast: index == widget.encounters.length - 1,
                onNext: _nextCard,
                onClose: () => _close(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// タイトル / 重ねアバター / 相手名を中央揃えで配置しつつ、
/// 周囲に Figma 準拠の装飾（4 つの丸 + 4 つの回転 pill）を Positioned で配置する。
class _HeroSection extends StatelessWidget {
  final String myIconUrl;
  final EncounterModel encounter;

  const _HeroSection({required this.myIconUrl, required this.encounter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // メインコンテンツを自然な高さで配置
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _TitleSection(),
              const SizedBox(height: 20),
              _AvatarPair(myIconUrl: myIconUrl, encounter: encounter),
              const SizedBox(height: 20),
              _EncounteredName(name: encounter.encounteredUser.name),
            ],
          ),
        ),
        // 装飾: 4 つの小さな丸（各コーナー付近）
        const Positioned(
          right: 28,
          top: 20,
          child: _DecoDot(color: Color(0xFFF59E0B)),
        ),
        const Positioned(
          left: 45,
          top: 55,
          child: _DecoDot(color: Color(0xFF3AAA3A)),
        ),
        const Positioned(
          right: 40,
          top: 110,
          child: _DecoDot(color: Color(0xFFEF4444)),
        ),
        const Positioned(
          left: 30,
          top: 140,
          child: _DecoDot(color: Color(0xFF3B82F6)),
        ),
        // 装飾: 4 つの回転した pill（Figma tokens 準拠の色）
        const Positioned(
          right: 20,
          top: 50,
          child: _DecoPill(color: Color(0xFFB7E5B4), rotationDeg: -65),
        ),
        const Positioned(
          left: 10,
          top: 85,
          child: _DecoPill(color: Color(0xFF9CA3AF), rotationDeg: -30),
        ),
        const Positioned(
          right: 5,
          top: 170,
          child: _DecoPill(color: Color(0xFFC9A6FF), rotationDeg: 30),
        ),
        const Positioned(
          left: 15,
          top: 210,
          child: _DecoPill(color: Color(0xFF7CC4FF), rotationDeg: -70),
        ),
      ],
    );
  }
}

/// 装飾の小さな丸（10px）。Figma の Frame461-464 に相当。
class _DecoDot extends StatelessWidget {
  final Color color;

  const _DecoDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 装飾の回転した pill（20x10）。Figma の rotated rounded rectangle に相当。
class _DecoPill extends StatelessWidget {
  final Color color;
  final double rotationDeg;

  const _DecoPill({required this.color, required this.rotationDeg});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDeg * 3.1415926535 / 180.0,
      child: Container(
        width: 20,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'すれ違いました!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 28.8 / 24,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'やったね!!',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 16.8 / 14,
          ),
        ),
      ],
    );
  }
}

/// 自分と相手のアイコンを 16px 分だけ重ねて表示するペア。
class _AvatarPair extends StatelessWidget {
  final String myIconUrl;
  final EncounterModel encounter;

  const _AvatarPair({required this.myIconUrl, required this.encounter});

  static const double _avatarSize = 100;
  static const double _overlap = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _avatarSize * 2 - _overlap,
      height: _avatarSize,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: _Avatar(iconUrl: myIconUrl)),
          Positioned(
            left: _avatarSize - _overlap,
            top: 0,
            child: _Avatar(iconUrl: encounter.encounteredUser.iconUrl),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String iconUrl;

  const _Avatar({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.backgroundWhite, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: iconUrl.isNotEmpty
            ? Image.network(
                iconUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.backgroundGrey,
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: AppColors.textLight, size: 48),
    );
  }
}

class _EncounteredName extends StatelessWidget {
  final String name;

  const _EncounteredName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 64),
      child: SingleChildScrollView(
        child: Text(
          name.isEmpty ? '名前未設定' : name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 24 / 20,
          ),
        ),
      ),
    );
  }
}

class _InfoCards extends StatelessWidget {
  final String myTechStack;
  final EncounterModel encounter;

  const _InfoCards({required this.myTechStack, required this.encounter});

  @override
  Widget build(BuildContext context) {
    final commonTags = _commonTags(
      myTechStack,
      encounter.encounteredUser.techStack,
    );
    final eventName = encounter.eventName.trim();

    return Column(
      children: [
        if (eventName.isNotEmpty)
          InfoBadgeCard(
            iconAsset: PasslyIcons.location,
            label: '出会った場所',
            value: eventName,
          ),
        if (eventName.isNotEmpty && commonTags.isNotEmpty)
          const SizedBox(height: 12),
        if (commonTags.isNotEmpty)
          InfoBadgeCard(
            iconAsset: PasslyIcons.tag,
            label: '共通タグ',
            value: commonTags.join(' '),
            valueColor: PasslyBrand.primaryDark,
          ),
      ],
    );
  }

  /// 大文字小文字を無視して積集合を返す。表示順は自分側の順序を維持。
  List<String> _commonTags(String mine, String other) {
    final mineTags = _parseTags(mine);
    final otherTagsLower = _parseTags(other)
        .map((t) => t.toLowerCase())
        .toSet();
    return mineTags
        .where((t) => otherTagsLower.contains(t.toLowerCase()))
        .toList();
  }

  /// カンマ / スラッシュ / 中点 / 空白 で区切られた文字列をタグ配列にする。
  /// profile_screen.dart の tech tag パースと同じロジック。
  List<String> _parseTags(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(RegExp(r'[,、/／・\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

class _ActionButtons extends StatelessWidget {
  final String targetUserId;
  final bool isLast;
  final VoidCallback onNext;
  final Future<void> Function() onClose;

  const _ActionButtons({
    required this.targetUserId,
    required this.isLast,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillButton(
          backgroundColor: PasslyBrand.primaryLight,
          textColor: Colors.white,
          label: 'プロフィールを見る',
          shadow: BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          onTap: targetUserId.isEmpty
              ? null
              : () => context.push('/profile/$targetUserId'),
        ),
        const SizedBox(height: 9),
        _PillButton(
          backgroundColor: PasslyBg.surface,
          textColor: PasslyText.secondary,
          label: isLast ? '閉じる' : '次へ',
          onTap: () async {
            if (isLast) {
              await onClose();
            } else {
              onNext();
            }
          },
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String label;
  final VoidCallback? onTap;
  final BoxShadow? shadow;

  const _PillButton({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.onTap,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(100),
            boxShadow: shadow == null ? null : [shadow!],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 16.8 / 20,
            ),
          ),
        ),
      ),
    );
  }
}
