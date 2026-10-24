import 'package:flutter/material.dart';
import 'package:syshack2026/features/home/presentation/widgets/plaza_count_card.dart';
import 'package:syshack2026/features/home/presentation/widgets/today_encounter_card.dart';

// 修正: 不要なコメントを削除、コードを最小化
class StatsRowWidget extends StatelessWidget {
  final int plazaCount;
  final int todayCount;

  const StatsRowWidget({
    super.key,
    required this.plazaCount,
    required this.todayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PlazaCountCard(count: plazaCount),
        const SizedBox(width: 8),
        TodayEncounterCard(todayCount: todayCount),
      ],
    );
  }
}
