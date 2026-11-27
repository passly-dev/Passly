import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:passly/common/widgets/common_tag_person_card.dart';
import 'package:passly/common/widgets/loading_card_skeleton.dart';
import 'package:passly/common/widgets/passly_header.dart';
import 'package:passly/core/constants/app_colors.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/close_friend/domain/close_friend_list_notifier.dart';
import 'package:passly/features/home/domain/home_notifier.dart';
import 'package:passly/features/home/domain/recent_encounter.dart';
import 'package:passly/features/memo/domain/partner_memo.dart';
import 'package:passly/features/user/data/tech_tag_catalog.dart';
import 'package:passly/features/user/domain/common_tags.dart';
import 'package:passly/features/user/domain/user_model.dart';

/// 検索の対象になる 1 人。
class SearchPerson {
  final String userId;
  final String name;
  final String iconUrl;
  final String eventName;
  final String techStack;

  const SearchPerson({
    required this.userId,
    required this.name,
    required this.iconUrl,
    required this.eventName,
    required this.techStack,
  });
}

/// 名前・タグ・自分の付箋メモで絞り込む。
///
/// クエリはスペース / カンマ / スラッシュで区切って複数キーワードを受け付ける
/// (AND 条件)。1 キーワードは 名前 / タグ / 付箋 のどれかに当てはまれば OK (OR)。
/// ひらがなとカタカナ，大文字と小文字は区別しない。
List<SearchPerson> filterSearchPeople(
  List<SearchPerson> people,
  String rawQuery, {
  required List<String> Function(SearchPerson) tagsOf,
  PartnerMemo? Function(SearchPerson)? memoOf,
}) {
  final keywords = rawQuery
      .split(RegExp(r'[,、/／・\s]+'))
      .map(_fold)
      .where((s) => s.isNotEmpty)
      .toList();
  if (keywords.isEmpty) return people;

  return people.where((p) {
    final name = _fold(p.name);
    final tags = tagsOf(p).map((t) => _fold(TechTagCatalog.normalize(t)));
    final memo = memoOf?.call(p);
    final memoText = memo == null ? '' : _fold('${memo.title} ${memo.body}');
    return keywords.every(
      (kw) =>
          name.contains(kw) ||
          tags.any((t) => t.contains(kw)) ||
          memoText.contains(kw),
    );
  }).toList();
}

/// 小文字にし，カタカナをひらがなにそろえる。
String _fold(String s) {
  final lower = s.trim().toLowerCase();
  final buf = StringBuffer();
  for (final r in lower.runes) {
    buf.writeCharCode(r >= 0x30A1 && r <= 0x30F6 ? r - 0x60 : r);
  }
  return buf.toString();
}

/// 広場ヘッダーの検索アイコンから開く「友達検索」画面。
///
/// 検索対象は，今まですれ違った人全員（[homeNotifierProvider] の
/// recent_encounters）と，お気に入りの人（[closeFriendListProvider]）。
/// バックエンドに検索 API が無いため，クライアント側で
/// 名前・技術タグ・自分の付箋メモを部分一致で絞り込む。
/// タグは recent_encounters が返さないときは GET /users/:id から補う。
class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim();
      if (next != _query) setState(() => _query = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeNotifierProvider);
    final favorites =
        ref.watch(closeFriendListProvider).asData?.value ?? const <UserModel>[];

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasslyHeader.search(
            onBack: () {
              if (context.canPop()) context.pop();
            },
            controller: _controller,
            hintText: '名前 / タグ / メモで検索',
          ),
          Expanded(
            child: homeAsync.when(
              data: (data) =>
                  _buildResults(_people(data.recentEncounters, favorites)),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingCardsSkeleton(),
              ),
              error: (err, _) => favorites.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'すれ違った人の取得に失敗しました',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: PasslyFont.family,
                            color: PasslyText.secondary,
                          ),
                        ),
                      ),
                    )
                  : _buildResults(
                      _people(const <RecentEncounter>[], favorites),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// すれ違った人（新しい順，同じ人は 1 件）＋まだ入っていないお気に入り。
  List<SearchPerson> _people(
    List<RecentEncounter> encounters,
    List<UserModel> favorites,
  ) {
    final sorted = [...encounters]..sort((a, b) => b.metAt.compareTo(a.metAt));
    final seen = <String>{};
    final people = <SearchPerson>[
      for (final e in sorted)
        if (seen.add(e.userId))
          SearchPerson(
            userId: e.userId,
            name: e.name,
            iconUrl: e.iconUrl,
            eventName: e.eventName.trim(),
            techStack: e.techStack,
          ),
    ];
    for (final u in favorites) {
      if (seen.add(u.id)) {
        people.add(
          SearchPerson(
            userId: u.id,
            name: u.name,
            iconUrl: u.iconUrl,
            eventName: u.lastEncounter?.eventName.trim() ?? '',
            techStack: u.techStack,
          ),
        );
      }
    }
    return people;
  }

  Widget _buildResults(List<SearchPerson> people) {
    final favoriteIds = {
      for (final u
          in ref.watch(closeFriendListProvider).asData?.value ??
              const <UserModel>[])
        u.id,
    };
    List<String>? tagsOf(SearchPerson p) => ref
        .watch(techTagsOfProvider((userId: p.userId, techStack: p.techStack)))
        .asData
        ?.value;
    List<String>? commonOf(SearchPerson p) => ref
        .watch(commonTagsProvider((userId: p.userId, techStack: p.techStack)))
        .asData
        ?.value;

    final matches = filterSearchPeople(
      people,
      _query,
      tagsOf: (p) => tagsOf(p) ?? parseTechTags(p.techStack),
      memoOf: (p) => ref.watch(partnerMemoProvider(p.userId)),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 24),
      children: [
        Text(
          _query.isEmpty
              ? 'すれ違った人 ${people.length} 人'
              : '「$_query」の検索結果 ${matches.length} 人',
          style: const TextStyle(
            fontFamily: PasslyFont.family,
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 19.2 / 16,
          ),
        ),
        const SizedBox(height: PasslySpace.s12),
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _query.isEmpty ? 'まだすれ違った人がいません' : '該当する人はいません',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: PasslyFont.family,
                color: PasslyText.secondary,
                fontSize: 14,
                fontWeight: PasslyFont.medium,
              ),
            ),
          )
        else
          for (final p in matches)
            Padding(
              key: ValueKey(p.userId),
              padding: const EdgeInsets.only(bottom: PasslySpace.s4),
              child: CommonTagPersonCard(
                name: p.name,
                iconUrl: p.iconUrl,
                subtitle: p.eventName,
                commonTags: commonOf(p),
                allTags: tagsOf(p),
                isFavorite: favoriteIds.contains(p.userId),
                memo: ref.watch(partnerMemoProvider(p.userId)),
                onTap: () => context.push('/profile/${p.userId}'),
              ),
            ),
      ],
    );
  }
}
