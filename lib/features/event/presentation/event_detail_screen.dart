import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/common/widgets/loading_card_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/event/data/event_repository.dart';
import 'package:syshack2026/features/event/domain/event_model.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// イベント詳細画面のプロバイダー。
///
/// eventId をキーに `eventRepositoryProvider.fetchEventDetail()` を叩く。
/// FeatureFlags.useMockEventDetail によりモック / 実 API を切替。
final eventDetailProvider = FutureProvider.family<EventModel, int>((
  ref,
  eventId,
) {
  return ref.read(eventRepositoryProvider).fetchEventDetail(eventId);
});

/// イベント詳細画面（スタブ実装）。
///
/// Figma デザインが未提供のため、最小限のレイアウトで
/// EventRepository が返す情報をそのまま並べる。デザイン提供時に
/// 本 PR とは別で作り直す想定。
class EventDetailScreen extends ConsumerWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'イベント詳細',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: eventAsync.when(
        data: (event) => _buildContent(context, event),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingEventCardsSkeleton(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'イベント情報の取得に失敗しました\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventModel event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          if (event.startAt != null)
            _MetaRow(
              icon: Icons.event,
              label: _formatDateRange(event.startAt!, event.endAt),
            ),
          if (event.location.isNotEmpty)
            _MetaRow(icon: Icons.location_on_outlined, label: event.location),
          _MetaRow(
            icon: Icons.groups,
            label:
                '参加者 ${event.accepted}人${event.limit > 0 ? ' / 定員 ${event.limit}人' : ''}${event.waiting > 0 ? '（キャンセル待ち ${event.waiting}人）' : ''}',
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              event.description,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
          if (event.eventUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openUrl(context, event.eventUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('イベントページを開く'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Text(
            '参加者',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (event.participants.isEmpty)
            const Text(
              '参加者情報がまだありません',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ...event.participants.map(_buildParticipantTile),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(EventParticipant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundGrey,
            ),
            child: participant.iconUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      participant.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, color: AppColors.textLight),
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.textLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name.isEmpty ? '名前未設定' : participant.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (participant.oneWord.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    participant.oneWord,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateRange(DateTime startUtc, DateTime? endUtc) {
    final start = AppTime.toAppLocal(startUtc);
    final end = endUtc != null ? AppTime.toAppLocal(endUtc) : null;
    final startStr =
        '${start.year}/${start.month.toString().padLeft(2, '0')}/${start.day.toString().padLeft(2, '0')} '
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    if (end == null) return startStr;
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr – $endStr';
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('URL を開けませんでした')));
    }
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
