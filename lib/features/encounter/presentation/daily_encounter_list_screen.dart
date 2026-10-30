import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:passly/common/widgets/common_tag_person_card.dart';
import 'package:passly/common/widgets/loading_card_skeleton.dart';
import 'package:passly/common/widgets/passly_header.dart';
import 'package:passly/common/widgets/passly_segmented_switch.dart';
import 'package:passly/core/constants/app_colors.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/calendar/domain/calendar_notifier.dart';
import 'package:passly/features/user/domain/common_tags.dart';

/// 指定日のすれ違い相手一覧画面。
///
/// イベント詳細の「この日に出会った人」などから遷移。データは
/// calendarNotifierProvider の該当日エントリから引く（開いたときに月を読み込む）。
///
/// 「共通点のある人 / すべて」で切り替えられ，開いたときは共通点のある人を出す。
/// その日に共通点のある人が 1 人もいなければ，空の画面にしないよう「すべて」で開く。
class DailyEncounterListScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const DailyEncounterListScreen({super.key, required this.date});

  @override
  ConsumerState<DailyEncounterListScreen> createState() =>
      _DailyEncounterListScreenState();
}

class _DailyEncounterListScreenState
    extends ConsumerState<DailyEncounterListScreen> {
  /// ユーザーが切り替えた後のタブ。null の間は自動で決める。
  int? _selectedTab;

  @override
  void initState() {
    super.initState();
    // 以前はカレンダー画面が月のデータを読み込んでいたが、イベント画面に
    // 変わって読み込まれなくなったので、この画面を開いたときに読み込む。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(calendarNotifierProvider.notifier)
          .fetchMonthData(DateTime(widget.date.year, widget.date.month));
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final dayData = _findDayData(calendarState.encounterDays);
    final people = _extractPeople(dayData);
    final count = (dayData?['count'] as int?) ?? people.length;
    final eventName = (dayData?['event'] as String?)?.trim() ?? '';
    final date = widget.date;

    final tagsByUser = <String, AsyncValue<List<String>>>{
      for (final p in people)
        p.userId: ref.watch(
          commonTagsProvider((userId: p.userId, techStack: p.techStack)),
        ),
    };
    List<String>? tagsOf(_DayPerson p) => tagsByUser[p.userId]?.asData?.value;

    final stillLoading = tagsByUser.values.any((v) => v.isLoading);
    final withCommon = people
        .where((p) => (tagsOf(p) ?? const []).isNotEmpty)
        .toList();
    final tab = _selectedTab ?? (withCommon.isEmpty && !stillLoading ? 1 : 0);
    final visible = tab == 0 ? withCommon : people;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasslyHeader(
            leading: PasslyBackButton(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: 'その日に出会った人',
            subtitle: '気になる人を見つけよう！',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
              children: [
                _SectionHeading(
                  title: '${date.month}月${date.day}日の出会い',
                  subtitle: eventName.isEmpty
                      ? '$count人と出会いました'
                      : '$count人と出会いました · $eventName',
                ),
                const SizedBox(height: PasslySpace.s12),
                if (calendarState.isLoading)
                  const LoadingCardsSkeleton()
                else if (people.isEmpty)
                  const _EmptyMessage(text: 'この日はまだ出会いがありません')
                else ...[
                  PasslySegmentedSwitch(
                    labels: [
                      '共通点のある人　${withCommon.length}',
                      'すべて　${people.length}',
                    ],
                    selectedIndex: tab,
                    onChanged: (i) => setState(() => _selectedTab = i),
                  ),
                  const SizedBox(height: PasslySpace.s4),
                  if (visible.isEmpty)
                    stillLoading
                        ? const LoadingCardsSkeleton(count: 2)
                        : const _EmptyMessage(text: '共通点のある人はいませんでした')
                  else
                    for (final p in visible)
                      Padding(
                        key: ValueKey(p.userId),
                        padding: const EdgeInsets.only(top: PasslySpace.s4),
                        child: CommonTagPersonCard(
                          name: p.name,
                          iconUrl: p.iconUrl,
                          commonTags: tagsOf(p),
                          onTap: () => context.push('/profile/${p.userId}'),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _findDayData(
    Map<DateTime, Map<String, dynamic>> encounterDays,
  ) {
    final date = widget.date;
    for (final entry in encounterDays.entries) {
      if (entry.key.year == date.year &&
          entry.key.month == date.month &&
          entry.key.day == date.day) {
        return entry.value;
      }
    }
    return null;
  }

  List<_DayPerson> _extractPeople(Map<String, dynamic>? dayData) {
    if (dayData == null) return const [];
    final rawUsers = dayData['users'];
    if (rawUsers is! List) return const [];

    return rawUsers
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return _DayPerson(
            userId: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            iconUrl: map['iconUrl']?.toString() ?? '',
            techStack: map['techStack']?.toString() ?? '',
          );
        })
        .where((p) => p.userId.isNotEmpty)
        .toList();
  }
}

class _DayPerson {
  final String userId;
  final String name;
  final String iconUrl;
  final String techStack;

  const _DayPerson({
    required this.userId,
    required this.name,
    required this.iconUrl,
    required this.techStack,
  });
}

/// セクション見出し（「3月11日の出会い / 3人と出会いました」）
class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 19.2 / 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
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

class _EmptyMessage extends StatelessWidget {
  final String text;
  const _EmptyMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
