import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:syshack2026/common/widgets/encounter_meta_pill.dart';
import 'package:syshack2026/common/widgets/loading_card_skeleton.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/close_friend/domain/close_friend_list_notifier.dart';
import 'package:syshack2026/features/user/data/user_repository.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/core/utils/app_time.dart';

final profileProvider = FutureProvider.family<UserModel, String>((ref, userId) {
  return ref.read(userRepositoryProvider).getUser(userId);
});

/// 相手プロフィール画面。BLE で出会った相手を「親しい友達」に追加・解除できる。
///
/// レイアウトは Figma node 1237:1385（未追加）/ 1305:2107（親しい友達）に準拠。
/// 色・タイポは AppColors を通じてプロジェクトのデザイントークンに寄せている。
class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        body: Center(child: Text('プロフィールIDが不正です')),
      );
    }

    final profileAsync = ref.watch(profileProvider(userId));
    final closeFriendList = ref.watch(closeFriendListProvider);
    final isBusy = closeFriendList.isLoading;
    final isCloseFriend =
        closeFriendList.asData?.value.any((u) => u.id == userId) ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: profileAsync.when(
        data: (profile) => _ProfileBody(
          userId: userId,
          profile: profile,
          isCloseFriend: isCloseFriend,
          isBusy: isBusy,
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingCardsSkeleton(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'プロフィールの取得に失敗しました\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

/// プロフィール本体。スクロール可能な上部と、固定表示のボタン領域を Column で分ける。
class _ProfileBody extends StatelessWidget {
  final String userId;
  final UserModel profile;
  final bool isCloseFriend;
  final bool isBusy;

  const _ProfileBody({
    required this.userId,
    required this.profile,
    required this.isCloseFriend,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CoverAndAvatar(profile: profile),
                const SizedBox(height: 16),
                _NameSection(profile: profile),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _EncounterCard(
                    profile: profile,
                    isCloseFriend: isCloseFriend,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: _AboutSection(profile: profile),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: _TechTagSection(profile: profile),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: _LinkSection(profile: profile),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 16),
            child: _CloseFriendActions(
              userId: userId,
              isCloseFriend: isCloseFriend,
              isBusy: isBusy,
            ),
          ),
        ),
      ],
    );
  }
}

/// カバー画像 + 戻るボタン + 半分重なるアバターを 1 つの Stack で構成する。
class _CoverAndAvatar extends StatelessWidget {
  static const double _coverHeight = 190;
  static const double _avatarSize = 100;

  final UserModel profile;

  const _CoverAndAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: _coverHeight + _avatarSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: _coverHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: _buildCover(),
            ),
          ),
          Positioned(top: topPadding + 12, left: 20, child: _BackButton()),
          Positioned(
            top: _coverHeight - _avatarSize / 2,
            left: 0,
            right: 0,
            child: Center(child: _Avatar(iconUrl: profile.iconUrl)),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    if (profile.coverUrl.isNotEmpty) {
      return Image.network(
        profile.coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _coverFallback(),
      );
    }
    return _coverFallback();
  }

  Widget _coverFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.6),
            AppColors.primary.withValues(alpha: 0.9),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white, size: 48),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.divider,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          if (context.canPop()) {
            context.pop();
          }
        },
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
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
        border: Border.all(color: AppColors.backgroundWhite, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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

class _NameSection extends StatelessWidget {
  final UserModel profile;

  const _NameSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          profile.name.isEmpty ? '名前未設定' : profile.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 24 / 20,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          profile.oneWord.isEmpty ? '一言未設定' : profile.oneWord,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: profile.oneWord.isEmpty
                ? AppColors.textDisabled
                : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 16.8 / 14,
          ),
        ),
      ],
    );
  }
}

/// 出会いカード：親しい友達判定で 2 パターンに切り替わる横長ピル。
/// Figma node 1240:1405 の [EncounterMetaPill] にテキストを流し込むだけの薄いラッパ。
class _EncounterCard extends StatelessWidget {
  final UserModel profile;
  final bool isCloseFriend;

  const _EncounterCard({required this.profile, required this.isCloseFriend});

  @override
  Widget build(BuildContext context) {
    return EncounterMetaPill(text: _buildLabel());
  }

  String _buildLabel() {
    if (isCloseFriend) {
      // TODO(passly): API 未実装のため次回参加イベントはハードコード。
      // UserModel に upcomingEvent フィールドが追加されたら差し替える。
      return '3月24日のMatsuribaに参加します';
    }
    return _formatLastEncounter();
  }

  String _formatLastEncounter() {
    final last = profile.lastEncounter;
    if (last == null) {
      return 'SysHack2026 で出会いました';
    }
    final local = AppTime.toAppLocal(last.metAt);
    final month = local.month;
    final day = local.day;
    final eventName = last.eventName.isEmpty ? 'イベント' : last.eventName;
    return '$month月$day日 $eventName で出会いました';
  }
}

class _SectionHeading extends StatelessWidget {
  final String label;

  const _SectionHeading(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        height: 19.2 / 16,
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final UserModel profile;

  const _AboutSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final text = profile.about.isEmpty ? '自己紹介は未設定です' : profile.about;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('ABOUT'),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: profile.about.isEmpty
                ? AppColors.textDisabled
                : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 16.8 / 14,
          ),
        ),
      ],
    );
  }
}

class _TechTagSection extends StatelessWidget {
  final UserModel profile;

  const _TechTagSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final tags = _parseTags(profile.techStack);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('TECH TAG'),
        const SizedBox(height: 8),
        if (tags.isEmpty)
          const Text(
            '未設定',
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _TagChip(label: tag)).toList(),
          ),
      ],
    );
  }

  static List<String> _parseTags(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(RegExp(r'[,、/／・\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _TagChip({required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 12 : 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textSecondary, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 14.4 / 12,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: chip,
    );
  }
}

class _LinkSection extends StatelessWidget {
  final UserModel profile;

  const _LinkSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final links = <_LinkEntry>[
      if (profile.twitterUrl.isNotEmpty)
        _LinkEntry(
          label: 'X',
          icon: Icons.alternate_email,
          url: _normalizeTwitterUrl(profile.twitterUrl),
        ),
      if (profile.githubUrl.isNotEmpty)
        _LinkEntry(
          label: 'GitHub',
          icon: Icons.code,
          url: _normalizeGitHubUrl(profile.githubUrl),
        ),
      if (profile.portfolioUrl.isNotEmpty)
        _LinkEntry(
          label: 'Portfolio',
          icon: Icons.link,
          url: profile.portfolioUrl,
        ),
      if (profile.connpassUrl.isNotEmpty)
        _LinkEntry(
          label: 'Connpass',
          icon: Icons.event,
          url: _normalizeConnpassUrl(profile.connpassUrl),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('LINK'),
        const SizedBox(height: 8),
        if (links.isEmpty)
          const Text(
            '未設定',
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: links
                .map(
                  (link) => _TagChip(
                    label: link.label,
                    icon: link.icon,
                    onTap: () => _launchUrl(link.url),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _LinkEntry {
  final String label;
  final IconData icon;
  final String url;

  const _LinkEntry({
    required this.label,
    required this.icon,
    required this.url,
  });
}

/// 状態別ボタン領域：未追加は 1 ボタン、親しい友達は緑枠 disabled + 赤塗り解除の 2 段。
class _CloseFriendActions extends ConsumerWidget {
  final String userId;
  final bool isCloseFriend;
  final bool isBusy;

  const _CloseFriendActions({
    required this.userId,
    required this.isCloseFriend,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isCloseFriend) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _OutlinedStatusButton(label: 'すでに親しい友達です'),
          const SizedBox(height: 9),
          _RemoveButton(
            enabled: !isBusy,
            onTap: () => _handleRemove(context, ref),
          ),
        ],
      );
    }

    return _AddButton(enabled: !isBusy, onTap: () => _handleAdd(context, ref));
  }

  Future<void> _handleAdd(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(closeFriendListProvider.notifier).addFriend(userId);
    } catch (e) {
      if (context.mounted) {
        _showError(context, '親しい友達の追加に失敗しました');
      }
    }
  }

  Future<void> _handleRemove(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(closeFriendListProvider.notifier).removeFriend(userId);
    } catch (e) {
      if (context.mounted) {
        _showError(context, '親しい友達の解除に失敗しました');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _AddButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      backgroundColor: enabled
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.5),
      onTap: enabled ? onTap : null,
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
      child: const Text(
        '親しい友達に追加する',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 16.8 / 18,
        ),
      ),
    );
  }
}

class _OutlinedStatusButton extends StatelessWidget {
  final String label;

  const _OutlinedStatusButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      backgroundColor: AppColors.backgroundWhite,
      onTap: null,
      border: Border.all(color: AppColors.primary, width: 1.5),
      shadow: BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.4),
        blurRadius: 6,
        offset: const Offset(0, 0),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 16.8 / 18,
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _RemoveButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      backgroundColor: enabled
          ? AppColors.error
          : AppColors.error.withValues(alpha: 0.5),
      onTap: enabled ? onTap : null,
      child: const Text(
        '親しい友達を解除する',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 16.8 / 18,
        ),
      ),
    );
  }
}

/// 共通のピル型ボタン骨格。カラーだけ差し替えて 3 種のボタンを実装する。
class _PillButton extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback? onTap;
  final Widget child;
  final BoxBorder? border;
  final BoxShadow? shadow;

  const _PillButton({
    required this.backgroundColor,
    required this.onTap,
    required this.child,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(100),
            border: border,
            boxShadow: shadow == null ? null : [shadow!],
          ),
          child: child,
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _normalizeTwitterUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  final handle = value.startsWith('@') ? value.substring(1) : value;
  return 'https://x.com/$handle';
}

String _normalizeGitHubUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  if (value.startsWith('github.com/')) return 'https://$value';
  return 'https://github.com/$value';
}

String _normalizeConnpassUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  final username = value.startsWith('@') ? value.substring(1) : value;
  return 'https://connpass.com/user/$username/';
}
