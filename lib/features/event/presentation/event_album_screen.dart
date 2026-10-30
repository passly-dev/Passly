import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:passly/common/widgets/loading_card_skeleton.dart';
import 'package:passly/common/widgets/passly_header.dart';
import 'package:passly/common/widgets/press_feedback.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/event/domain/event_album_notifier.dart';

/// イベント画面（旧カレンダー）。
///
/// Figma「カレンダー案A3：2列＋大きい表示との切り替え」(node 1962:2031)。
/// 上に「これから」のイベント、その下に参加したイベントを新しい順に並べる。
/// 並べ方は 1 列の大きいカード（案A, node 1959:44）が既定で、右上の切り替えで
/// 2 列のグリッドにできる。カードを押すとその日に出会った人の一覧へ。
class EventAlbumScreen extends ConsumerWidget {
  const EventAlbumScreen({super.key});

  static const List<String> _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

  static String dateLabel(DateTime d) =>
      '${d.month}/${d.day}（${_weekdays[d.weekday - 1]}）';

  Future<void> _openSearch(BuildContext context) async {
    final selected = await context.push<DateTime>('/events/search');
    if (selected == null || !context.mounted) return;
    context.push('/encounters/day/${eventDateParam(selected)}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(eventAlbumProvider);
    final grid = ref.watch(eventAlbumGridProvider);

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Column(
        children: [
          PasslyHeader.calendar(
            title: 'イベント',
            onSearchTap: () => _openSearch(context),
          ),
          Expanded(
            child: RefreshIndicator(
              color: PasslyBrand.primary,
              onRefresh: () => ref.refresh(eventAlbumProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: album.when(
                  loading: () => const [LoadingCardsSkeleton()],
                  error: (e, _) => [const _Message(text: 'イベントの取得に失敗しました')],
                  data: (data) => [
                    if (data.upcoming != null) ...[
                      _UpcomingCard(event: data.upcoming!),
                      const SizedBox(height: 20),
                    ],
                    _SectionHeader(
                      grid: grid,
                      onChanged: (g) =>
                          ref.read(eventAlbumGridProvider.notifier).set(g),
                    ),
                    const SizedBox(height: 12),
                    if (data.past.isEmpty)
                      const _Message(text: 'まだ参加したイベントはありません')
                    else if (grid)
                      _EventGrid(events: data.past)
                    else
                      for (final (i, e) in data.past.indexed) ...[
                        if (i > 0) const SizedBox(height: 16),
                        _LargeEventCard(event: e, index: i),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openDay(BuildContext context, EventSummary e) =>
    context.push('/encounters/day/${eventDateParam(e.day)}');

const Color _upcomingAccent = Color(0xFFF59E0A);
const Color _sameTagBg = Color(0xFFE8F5E8);
const Color _sameTagText = Color(0xFF1F7A1F);

final List<BoxShadow> _cardShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

/// 画像がないイベントに使うグラデーション（Figma の仮画像の色）。
const List<List<Color>> _fallbackGradients = [
  [Color(0xFF7BD389), Color(0xFF2E9E5B)],
  [Color(0xFFFFB86B), Color(0xFFF2668B)],
  [Color(0xFF9CC9F5), Color(0xFF5B8DEF)],
  [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
  [Color(0xFFFDE68A), Color(0xFFF59E0B)],
  [Color(0xFFA7F3D0), Color(0xFF0EA5A4)],
];

class _UpcomingCard extends StatelessWidget {
  final EventSummary event;

  const _UpcomingCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Container(width: 6, color: _upcomingAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'これから',
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    fontSize: 11,
                    fontWeight: PasslyFont.bold,
                    color: _upcomingAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${EventAlbumScreen.dateLabel(event.startAt)}${event.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: PasslyFont.family,
                    fontSize: 14,
                    fontWeight: PasslyFont.bold,
                    color: PasslyText.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3E2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '予定',
              style: TextStyle(
                fontFamily: PasslyFont.family,
                fontSize: 11,
                fontWeight: PasslyFont.bold,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 「参加したイベント」＋ 1 列 / 2 列の切り替え。
class _SectionHeader extends StatelessWidget {
  final bool grid;
  final ValueChanged<bool> onChanged;

  const _SectionHeader({required this.grid, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '参加したイベント',
            style: TextStyle(
              fontFamily: PasslyFont.family,
              fontSize: 15,
              fontWeight: PasslyFont.bold,
              color: PasslyText.primary,
            ),
          ),
        ),
        Container(
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: PasslyBorder.defaultBorder,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToggleSegment(
                selected: !grid,
                onTap: () => onChanged(false),
                child: const _ListIcon(),
              ),
              _ToggleSegment(
                selected: grid,
                onTap: () => onChanged(true),
                child: const _GridIcon(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _ToggleSegment({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? PasslyBg.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: IconTheme(
          data: IconThemeData(
            color: selected ? PasslyBrand.primary : PasslyText.tertiary,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 2 列のアイコン（7×7 の四角が 4 つ）。
class _GridIcon extends StatelessWidget {
  const _GridIcon();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    Widget sq() => Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return SizedBox(
      width: 16,
      height: 16,
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [sq(), sq(), sq(), sq()],
      ),
    );
  }
}

/// 1 列のアイコン（横線が 3 本）。
class _ListIcon extends StatelessWidget {
  const _ListIcon();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    Widget bar() => Container(
      width: 20,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        bar(),
        const SizedBox(height: 2),
        bar(),
        const SizedBox(height: 2),
        bar(),
      ],
    );
  }
}

/// イベントの画像。なければグラデーション。
class _EventImage extends StatelessWidget {
  final EventSummary event;
  final int index;
  final double height;

  const _EventImage({
    required this.event,
    required this.index,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _fallbackGradients[index % _fallbackGradients.length];
    final fallback = DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: event.imageUrl.isEmpty
          ? fallback
          : Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// 出会った人のアイコンを重ねて並べる。
class _AvatarStack extends StatelessWidget {
  final List<EventMetUser> users;
  final int max;
  final double size;
  final double step;
  final bool showMore;

  const _AvatarStack({
    required this.users,
    required this.max,
    required this.size,
    required this.step,
    this.showMore = false,
  });

  @override
  Widget build(BuildContext context) {
    final shown = users.take(max).toList();
    final rest = users.length - shown.length;
    final count = shown.length + (showMore && rest > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();
    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (final (i, u) in shown.indexed)
            Positioned(
              left: step * i,
              child: _Avatar(url: u.iconUrl, size: size),
            ),
          if (showMore && rest > 0)
            Positioned(
              left: step * shown.length,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PasslyBorder.defaultBorder,
                  shape: BoxShape.circle,
                  border: Border.all(color: PasslyBg.surface, width: 2),
                ),
                child: Text(
                  '+$rest',
                  style: const TextStyle(
                    fontFamily: PasslyFont.family,
                    fontSize: 11,
                    fontWeight: PasslyFont.bold,
                    color: PasslyText.secondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final double size;

  const _Avatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: PasslyBg.elevated,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: size * 0.6, color: PasslyText.tertiary),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PasslyBg.surface, width: 2),
      ),
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _SameTagChip extends StatelessWidget {
  final int count;
  final double fontSize;

  const _SameTagChip({required this.count, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _sameTagBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '共通タグ $count人',
        style: TextStyle(
          fontFamily: PasslyFont.family,
          fontSize: fontSize,
          fontWeight: PasslyFont.bold,
          color: _sameTagText,
        ),
      ),
    );
  }
}

/// 1 列表示の大きいカード（案A）。
class _LargeEventCard extends StatelessWidget {
  final EventSummary event;
  final int index;

  const _LargeEventCard({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    final metCount = event.metUsers.length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDay(context, event),
      child: PressFeedback(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: PasslyBg.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventImage(event: event, index: index, height: 120),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        fontSize: 17,
                        fontWeight: PasslyFont.bold,
                        color: PasslyText.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        EventAlbumScreen.dateLabel(event.startAt),
                        // 「会場名（住所）」は長いので会場名だけ出す
                        if (event.location.isNotEmpty)
                          event.location.split('（').first,
                      ].join('・'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        fontSize: 12,
                        color: PasslyText.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _AvatarStack(
                          users: event.metUsers,
                          max: 4,
                          size: 32,
                          step: 24,
                          showMore: true,
                        ),
                        if (metCount > 0) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$metCount人と出会った',
                            style: const TextStyle(
                              fontFamily: PasslyFont.family,
                              fontSize: 12,
                              fontWeight: PasslyFont.medium,
                              color: PasslyText.secondary,
                            ),
                          ),
                        ),
                        if (event.sameTagCount > 0)
                          _SameTagChip(count: event.sameTagCount, fontSize: 11),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2 列表示（案A3）。
class _EventGrid extends StatelessWidget {
  final List<EventSummary> events;

  const _EventGrid({required this.events});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final width = (constraints.maxWidth - gap) / 2;
        // 高さは固定せず中身に合わせる（文字サイズを大きくしてもはみ出さない）
        return Column(
          children: [
            for (var i = 0; i < events.length; i += 2) ...[
              if (i > 0) const SizedBox(height: gap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width,
                    child: _SmallEventCard(event: events[i], index: i),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: width,
                    child: i + 1 < events.length
                        ? _SmallEventCard(event: events[i + 1], index: i + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SmallEventCard extends StatelessWidget {
  final EventSummary event;
  final int index;

  const _SmallEventCard({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDay(context, event),
      child: PressFeedback(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: PasslyBg.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventImage(event: event, index: index, height: 96),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        fontSize: 13,
                        fontWeight: PasslyFont.bold,
                        color: PasslyText.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      EventAlbumScreen.dateLabel(event.startAt),
                      style: const TextStyle(
                        fontFamily: PasslyFont.family,
                        fontSize: 11,
                        color: PasslyText.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _AvatarStack(
                          users: event.metUsers,
                          max: 3,
                          size: 22,
                          step: 15,
                        ),
                        if (event.metUsers.isNotEmpty) const SizedBox(width: 6),
                        Text(
                          '${event.metUsers.length}人',
                          style: const TextStyle(
                            fontFamily: PasslyFont.family,
                            fontSize: 11,
                            fontWeight: PasslyFont.medium,
                            color: PasslyText.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (event.sameTagCount > 0)
                      _SameTagChip(count: event.sameTagCount, fontSize: 10)
                    else
                      const Text(
                        '共通タグの人なし',
                        style: TextStyle(
                          fontFamily: PasslyFont.family,
                          fontSize: 10,
                          color: PasslyText.tertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: PasslyFont.family,
            fontSize: 13,
            color: PasslyText.secondary,
          ),
        ),
      ),
    );
  }
}
