import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syshack2026/features/plaza/presentation/widgets/friend_grid_item.dart';

class _IconPosition {
  final double x, y;
  const _IconPosition(this.x, this.y);
}

class FriendListView extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  const FriendListView({super.key, required this.friends});

  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  static const double _pad = 16.0;
  static const double _itemWidth = 96.0;
  static const double _itemHeight = 104.0;
  static const double _itemGap = 8.0;

  List<_IconPosition>? _positions;
  double? _lastWidth;
  double? _lastHeight;
  String _lastLayoutKey = '';

  List<_IconPosition> _generatePositions(double width, double height) {
    final rand = Random();
    final count = widget.friends.length;
    if (count == 0) return [];

    final usableWidth = max(0.0, width - _pad * 2);
    final usableHeight = max(0.0, height - _pad * 2);
    final minCellWidth = _itemWidth + _itemGap;
    final minCellHeight = _itemHeight + _itemGap;
    final maxColsByWidth = max(1, (usableWidth / minCellWidth).floor());

    int columns = maxColsByWidth;
    for (int c = maxColsByWidth; c >= 1; c--) {
      final rows = (count / c).ceil();
      final cellHeight = usableHeight / rows;
      if (cellHeight >= minCellHeight) {
        columns = c;
        break;
      }
    }

    final rows = (count / columns).ceil();
    final cellWidth = usableWidth / columns;
    final cellHeight = usableHeight / rows;

    final cells = List<int>.generate(rows * columns, (i) => i)..shuffle(rand);
    final selectedCells = cells.take(count);
    final positions = <_IconPosition>[];

    for (final cellIndex in selectedCells) {
      final col = cellIndex % columns;
      final row = cellIndex ~/ columns;

      final cellLeft = _pad + col * cellWidth;
      final cellTop = _pad + row * cellHeight;

      final extraX = max(0.0, cellWidth - _itemWidth);
      final extraY = max(0.0, cellHeight - _itemHeight);
      final x = cellLeft + rand.nextDouble() * extraX;
      final y = cellTop + rand.nextDouble() * extraY;

      positions.add(_IconPosition(x, y));
    }

    return positions;
  }

  String _buildLayoutKey() {
    return widget.friends
        .map((f) => '${f['id'] ?? ''}:${f['name'] ?? ''}')
        .join('|');
  }

  Widget _buildFriendItem(int index) {
    if (index >= _positions!.length) return const SizedBox.shrink();

    final pos = _positions![index];
    return Positioned(
      left: pos.x,
      top: pos.y,
      child: FriendGridItem(
        name: widget.friends[index]['name']?.toString() ?? '',
        userId: widget.friends[index]['id']?.toString() ?? '',
        iconUrl:
            (widget.friends[index]['iconUrl'] ??
                    widget.friends[index]['icon_url'])
                ?.toString() ??
            '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final layoutKey = _buildLayoutKey();

        final needsRebuild =
            _positions == null ||
            _lastWidth != width ||
            _lastHeight != height ||
            _lastLayoutKey != layoutKey;

        if (needsRebuild) {
          _positions = _generatePositions(width, height);
          _lastWidth = width;
          _lastHeight = height;
          _lastLayoutKey = layoutKey;
        }

        return Stack(
          children: List.generate(widget.friends.length, _buildFriendItem),
        );
      },
    );
  }
}
