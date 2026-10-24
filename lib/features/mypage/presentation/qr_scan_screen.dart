import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:syshack2026/common/widgets/passly_glass_circle.dart';
import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// QR コード読み取り画面 (Figma node 1530:5279 のヘッダー準拠 + 全面カメラビュー)。
///
/// 中央のガイド枠に相手の QR を合わせるとバックエンドの deep link
/// (`passly://profile/:userId`) を検出して `/profile/:id` に遷移する。
/// 認識しないコードは無視する (誤発火防止)。
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;
      final userId = _extractPasslyUserId(raw);
      if (userId != null) {
        _handled = true;
        _controller.stop();
        // pushReplacement ではなく push で、スキャン画面自体は残さず戻れる形にする。
        context.pushReplacement('/profile/$userId');
        return;
      }
    }
  }

  /// `passly://profile/:userId` 形式の deep link から userId を抜き出す。
  static String? _extractPasslyUserId(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme != 'passly') return null;
    if (uri.host != 'profile') return null;
    if (uri.pathSegments.isEmpty) return null;
    final id = uri.pathSegments.first;
    return id.isEmpty ? null : id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        // Positioned.fill が画面いっぱいに広がるように親 Stack を expand する。
        // これがないと非 Positioned な SafeArea 子 (70px) にサイズが揃ってしまう。
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
            errorBuilder: (context, error) => _CameraError(error: error),
          ),
          const _ScanGuideOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (context.canPop()) context.pop();
                  },
                  child: const PasslyGlassCircle(
                    child: PasslyIcon(
                      asset: PasslyIcons.chevron,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// カメラ映像の上に描くスキャンガイド。中央の 240x240 正方形を明るく残して
/// 周囲は半透明黒でマスクし、四隅に L 字のガイドを白線で描く。
class _ScanGuideOverlay extends StatelessWidget {
  const _ScanGuideOverlay();

  static const double _boxSize = 240;
  static const double _cornerLength = 24;
  static const double _cornerThickness = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final left = (w - _boxSize) / 2;
        final top = (h - _boxSize) / 2;
        return Stack(
          children: [
            // 中央の枠を除いた領域を半透明黒で覆う (フォトカードのフォーカス演出)。
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.45),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 四隅の L 字ガイド。
            for (final corner in _Corner.values)
              Positioned(
                left: corner.left(left),
                top: corner.top(top),
                child: CustomPaint(
                  size: const Size(_cornerLength, _cornerLength),
                  painter: _CornerPainter(
                    corner: corner,
                    thickness: _cornerThickness,
                  ),
                ),
              ),
            // 下部のガイドテキスト。
            Positioned(
              left: 0,
              right: 0,
              top: top + _boxSize + 24,
              child: const Center(
                child: Text(
                  '相手の QR コードを枠に合わせてください',
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: PasslyFont.medium,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  double left(double boxLeft) {
    switch (this) {
      case _Corner.topLeft:
      case _Corner.bottomLeft:
        return boxLeft;
      case _Corner.topRight:
      case _Corner.bottomRight:
        return boxLeft +
            _ScanGuideOverlay._boxSize -
            _ScanGuideOverlay._cornerLength;
    }
  }

  double top(double boxTop) {
    switch (this) {
      case _Corner.topLeft:
      case _Corner.topRight:
        return boxTop;
      case _Corner.bottomLeft:
      case _Corner.bottomRight:
        return boxTop +
            _ScanGuideOverlay._boxSize -
            _ScanGuideOverlay._cornerLength;
    }
  }
}

class _CornerPainter extends CustomPainter {
  final _Corner corner;
  final double thickness;

  _CornerPainter({required this.corner, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case _Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case _Corner.bottomRight:
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}

class _CameraError extends StatelessWidget {
  final MobileScannerException error;

  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        'カメラを起動できませんでした\n${error.errorCode.name}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: PasslyFont.family,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}
