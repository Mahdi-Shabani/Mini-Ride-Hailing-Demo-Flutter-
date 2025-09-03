import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/car/car_cubit.dart';
import '../../bloc/car/car_state.dart';
import '../../widgets/top_bar.dart'; // TopBar خودت (تصویر Top_bar.png)
import '../car/car_details_screen.dart'; // مقصد: صفحه جزئیات خودرو

const double _kFigmaBaseW = 375.0; // مقیاس نسبت به عرض فیگما

// فیگما: Status overlay = 56px، Back icon = 24px، فاصله چپ = 12px
const double _kTopBarHpx = 56.0; // ارتفاع لایه‌ی تصویر بالایی
const double _kBackHitSize = 44.0; // تاچ‌تارگت استاندارد
const double _kBackLeftPx = 12.0; // فاصله چپ
const double _kBackBelowStatusPx =
    24.0; // فاصله اضافه «زیرِ ساعت» (مبنای اولیه)
const double _kBackUpCm =
    0.5; // الان نیم سانت بالاتر از مبنای اولیه می‌بریم (نسبت به قبل که 1cm بود، نیم‌سانت پایین‌تر می‌آید)
double _cmPx(double cm) => cm * 160.0 / 2.54; // ≈ 63px برای هر ۱ سانت

// نقاط مسیر (درصد از عرض/ارتفاع) — W 17th → 9th Ave → 10th Ave
const List<Offset> _kThinRoutePoints = [
  Offset(0.34, 0.48),
  Offset(0.55, 0.44),
  Offset(0.72, 0.44),
];

const bool _kShowRouteDebug = false;

class RidePreviewScreen extends StatefulWidget {
  final CarItem car;
  const RidePreviewScreen({super.key, required this.car});

  @override
  State<RidePreviewScreen> createState() => _RidePreviewScreenState();
}

class _RidePreviewScreenState extends State<RidePreviewScreen> {
  final _sheetCtrl = DraggableScrollableController();
  double _extent = 0.5;

  @override
  void initState() {
    super.initState();

    _sheetCtrl.addListener(() {
      if (!mounted) return;
      setState(() => _extent = _sheetCtrl.size);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<CarCubit>();
      if (cubit.state.selectedId != widget.car.id) {
        cubit.select(widget.car.id);
      }
    });
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  Future<void> _animateTo(double t) async {
    try {
      await _sheetCtrl.animateTo(
        t,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / _kFigmaBaseW; // scale نسبت به 375
    final padTop = MediaQuery.of(context).padding.top;
    final safeBtm = MediaQuery.of(context).padding.bottom;

    final peekPx = _computePeekHeightPx(
      context: context,
      s: s,
      safeBtm: safeBtm,
      title: widget.car.name,
    );
    final minChildSize = (peekPx / size.height).clamp(0.04, 0.16);
    final expandedPx = 500.0 * s;
    final maxChildSize = math.max(
      minChildSize + 0.05,
      math.min(0.95, expandedPx / size.height),
    );
    final midSnap = math.max(
      minChildSize + 0.01,
      math.min(maxChildSize - 0.01, 0.42),
    );

    final currentExtent = (_extent == 0.5) ? minChildSize : _extent;
    final sheetTop = size.height * (1 - currentExtent);

    final double backLeft = _kBackLeftPx * s;
    final double backTop = math.max(
      padTop + 2,
      padTop +
          (_kTopBarHpx * s) +
          (_kBackBelowStatusPx * s) -
          _cmPx(_kBackUpCm),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Map.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: minChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            snap: true,
            snapSizes: [minChildSize, midSnap, maxChildSize],
            builder: (_, scrollController) {
              final bool isPeek = _extent <= (minChildSize + 0.02);

              final double carW = 329 * s;
              final double carH = 149 * s;
              final double carBottom = 58 * s;
              final double chipsH = 24 * s;
              final double bottomBarH = 106 * s;
              final EdgeInsets horizPad = EdgeInsets.symmetric(
                horizontal: 16 * s,
              );
              final double contentBottomPad = isPeek
                  ? (8 + safeBtm)
                  : (16 * s + safeBtm);

              Widget header({required bool compact}) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final target = (_sheetCtrl.size <= (minChildSize + 0.02))
                        ? midSnap
                        : minChildSize;
                    _animateTo(target);
                  },
                  onVerticalDragUpdate: (d) {
                    final h = MediaQuery.of(context).size.height;
                    final delta = -(d.primaryDelta ?? 0) / h;
                    final next = (_sheetCtrl.size + delta).clamp(
                      minChildSize,
                      maxChildSize,
                    );
                    _sheetCtrl.jumpTo(next);
                  },
                  onVerticalDragEnd: (_) {
                    final sizes = [minChildSize, midSnap, maxChildSize];
                    double closest = sizes.first;
                    double dist = (sizes.first - _sheetCtrl.size).abs();
                    for (final sz in sizes.skip(1)) {
                      final d = (sz - _sheetCtrl.size).abs();
                      if (d < dist) {
                        dist = d;
                        closest = sz;
                      }
                    }
                    _animateTo(closest);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Center(
                        child: Container(
                          width: 44,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Padding(
                        padding: horizPad,
                        child: Text(
                          widget.car.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18 * s,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!compact) SizedBox(height: 6 * s),
                    ],
                  ),
                );
              }

              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF352C63), Color(0xFF201C3D)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: ScrollConfiguration(
                  behavior: const _NoGlowIOSBehavior(),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(bottom: contentBottomPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(compact: isPeek),

                        if (!isPeek) ...[
                          GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: horizPad,
                              child: Text(
                                'View car details',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFB085FF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14 * s,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 8 * s),

                          SizedBox(
                            height: chipsH,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/Min.png',
                                  height: chipsH,
                                ),
                                SizedBox(width: 8 * s),
                                Image.asset(
                                  'assets/images/Min (1).png',
                                  height: chipsH,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10 * s),

                          SizedBox(
                            height: (carH + carBottom),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: carBottom,
                                  child: SizedBox(
                                    width: carW,
                                    height: carH,
                                    child: Image.asset(
                                      widget.car.imageAsset,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Transform.translate(
                            offset: Offset(0, -54 * s),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/Content.png',
                                  height: 64 * s,
                                ),
                                SizedBox(width: 12 * s),
                                Image.asset(
                                  'assets/images/Content (1).png',
                                  height: 64 * s,
                                ),
                                SizedBox(width: 12 * s),
                                Image.asset(
                                  'assets/images/Content (2).png',
                                  height: 64 * s,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16 * s),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16 * s),
                            child: SizedBox(
                              height: bottomBarH,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/Bottom.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    right: 16 * s,
                                    top: 16 * s,
                                    bottom: 16 * s,
                                    width: 124 * s,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          14 * s,
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CarDetailsScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // مسیر نازک انیمیشنی (بالای شیت)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                clipper: _TopClipper(bottom: sheetTop),
                child: AnimatedThinRouteOverlay(
                  padTop: padTop,
                  pointsNormalized: _kThinRoutePoints,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: TopBar(assetPath: 'assets/images/Top_bar.png'),
            ),
          ),

          Positioned(
            left: backLeft,
            top: backTop,
            child: _BackChevron(onTap: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }

  double _computePeekHeightPx({
    required BuildContext context,
    required double s,
    required double safeBtm,
    required String title,
  }) {
    final textStyle = TextStyle(
      fontSize: 18 * s,
      height: 1.2,
      fontWeight: FontWeight.w800,
    );

    final tp = TextPainter(
      text: TextSpan(text: title, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32 * s);

    return 4 + 6 + 4 + tp.height + 8 + safeBtm;
  }
}

class AnimatedThinRouteOverlay extends StatefulWidget {
  final double padTop;
  final List<Offset> pointsNormalized;

  const AnimatedThinRouteOverlay({
    super.key,
    required this.padTop,
    required this.pointsNormalized,
  });

  @override
  State<AnimatedThinRouteOverlay> createState() =>
      _AnimatedThinRouteOverlayState();
}

class _AnimatedThinRouteOverlayState extends State<AnimatedThinRouteOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final pts = widget.pointsNormalized
        .map((p) => Offset(w * p.dx, widget.padTop + h * p.dy))
        .toList(growable: false);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final hue = (_ctrl.value * 360) % 360;
        return Stack(
          children: [
            CustomPaint(
              painter: _ThinRoutePainter(
                points: pts,
                strokeWidth: 2.0,
                hue: hue,
              ),
              size: Size.infinite,
            ),

            if (_kShowRouteDebug)
              for (final p in pts)
                Positioned(
                  left: p.dx - 3,
                  top: p.dy - 3,
                  width: 6,
                  height: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

            Positioned(
              left: pts.first.dx - 12,
              top: pts.first.dy - 12,
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/Group1.png'),
            ),
            Positioned(
              left: pts.last.dx - 12,
              top: pts.last.dy - 12,
              width: 24,
              height: 24,
              child: Image.asset('assets/icons/Group2.png'),
            ),
          ],
        );
      },
    );
  }
}

class _ThinRoutePainter extends CustomPainter {
  final List<Offset> points;
  final double strokeWidth;
  final double hue;

  _ThinRoutePainter({
    required this.points,
    required this.strokeWidth,
    required this.hue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final bounds = path.getBounds();

    final c1 = HSVColor.fromAHSV(1.0, hue, 0.85, 1.0).toColor();
    final c2 = HSVColor.fromAHSV(1.0, (hue + 45) % 360, 0.85, 1.0).toColor();
    final c3 = HSVColor.fromAHSV(1.0, (hue + 90) % 360, 0.85, 1.0).toColor();

    final glow = Paint()
      ..color = c1.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final line = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2, c3],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ThinRoutePainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.points != points;
  }
}

class _TopClipper extends CustomClipper<Rect> {
  final double bottom;
  _TopClipper({required this.bottom});

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width, bottom);

  @override
  bool shouldReclip(covariant _TopClipper oldClipper) =>
      bottom != oldClipper.bottom;
}

class _NoGlowIOSBehavior extends MaterialScrollBehavior {
  const _NoGlowIOSBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _BackChevron extends StatelessWidget {
  final VoidCallback onTap;
  const _BackChevron({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: _kBackHitSize,
          height: _kBackHitSize,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/icons/Chevron.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
