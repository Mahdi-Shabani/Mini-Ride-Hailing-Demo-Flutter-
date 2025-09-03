import 'dart:math' as math;
import 'package:flutter/material.dart';

class Dimens {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static double overlayHeightFor(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final tablet = isTablet(context);
    final ratio = tablet ? 0.62 : 0.72;
    final minH = tablet ? 520.0 : 480.0;
    final maxH = tablet ? 700.0 : 620.0;
    return _clamp(h * ratio, minH, maxH);
  }

  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final tablet = isTablet(context);
    final base = tablet ? 360.0 : 320.0;
    return math.min(base, w - 48.0);
  }

  static double titleSize(BuildContext context) => _clamp(20, 18, 22);
  static double bodySize(BuildContext context) => _clamp(16, 14, 18);

  static Size buttonSize(BuildContext context) {
    final maxW = contentMaxWidth(context);
    final width = _clamp(200, 180, math.min(220, maxW));
    final height = _clamp(45, 42, 50);
    return Size(width, height);
  }

  static Widget limitTextScale({
    required BuildContext context,
    required Widget child,
    double maxScale = 1.2,
  }) {
    final mq = MediaQuery.of(context);
    final clamped = math.min(mq.textScaleFactor, maxScale);
    return MediaQuery(
      data: mq.copyWith(textScaleFactor: clamped),
      child: child,
    );
  }

  static double _clamp(double v, double min, double max) =>
      math.max(min, math.min(max, v));
}
