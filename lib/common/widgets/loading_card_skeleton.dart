import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingCardsSkeleton extends StatelessWidget {
  final int count;

  const LoadingCardsSkeleton({super.key, this.count = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          const LoadingCardSkeleton(),
        ],
      ],
    );
  }
}

class LoadingCardSkeleton extends StatelessWidget {
  const LoadingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Row(
          children: [
            _SkeletonCircle(size: 50),
            SizedBox(width: 19),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonLine(width: 124, height: 14),
                  SizedBox(height: 6),
                  _SkeletonLine(width: 92, height: 10),
                ],
              ),
            ),
            SizedBox(width: 8),
            _SkeletonLine(width: 10, height: 18),
          ],
        ),
      ),
    );
  }
}

class LoadingEventCardsSkeleton extends StatelessWidget {
  final int count;

  const LoadingEventCardsSkeleton({super.key, this.count = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) const SizedBox(height: 16),
          const LoadingEventCardSkeleton(),
        ],
      ],
    );
  }
}

class LoadingEventCardSkeleton extends StatelessWidget {
  const LoadingEventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            const _SkeletonBlock(width: 96, height: 110),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonLine(width: double.infinity, height: 16),
                  SizedBox(height: 12),
                  _SkeletonLine(width: 92, height: 10),
                  SizedBox(height: 8),
                  _SkeletonLine(width: 128, height: 10),
                  SizedBox(height: 12),
                  _SkeletonLine(width: 76, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBlock({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
