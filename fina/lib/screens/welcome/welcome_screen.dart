import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/top_bar.dart';
import '../../core/responsive/dimens.dart';
import '../onboarding/intro_pager.dart';

// گرادیان بک‌گراند مخصوص Welcome
const Color _kBgStart = Color(0xFF2C2750);
const Color _kBgEnd = Color(0xFF0E0B1D);

// گرادیان متن ELITE
const LinearGradient _kEliteGradient = LinearGradient(
  colors: [Color(0xFFFF6A00), Color(0xFFFF3D81)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// رنگ‌های ۸‌گانه
const List<Color> _kLoaderColors = [
  Color(0xFFFF6A00),
  Color(0xFFFF7A2E),
  Color(0xFFFF8B5C),
  Color(0xFFFF9C8A),
  Color(0xFFFF3D81),
  Color(0xFFE53DF2),
  Color(0xFFB24EF8),
  Color(0xFF7D5CFF),
];

// آیکن دایره توخالی
const String _kEllipseAsset = 'assets/icons/Ellipse.png';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _navTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const IntroPager()));
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kBgStart, _kBgEnd],
          ),
        ),
        child: Stack(
          children: [
            const SafeArea(child: TopBar()),

            // محدودکردن textScale برای ثبات روی تبلت/گوشی
            Dimens.limitTextScale(
              context: context,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(height: 120),
                      ),
                      const SizedBox(height: 12),
                      const _GradientText(
                        'ELITE',
                        gradient: _kEliteGradient,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'RIDE IN STYLE',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: _WelcomeLoader(
                  size: 72,
                  dotSize: 14,
                  innerFillRatio: 0.62,
                  intervalMs: 220,
                  ringOpacity: 0.95,
                  activeBoost: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const _GradientText(this.text, {required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class _WelcomeLoader extends StatefulWidget {
  final double size;
  final double dotSize;
  final double innerFillRatio;
  final int intervalMs;
  final double ringOpacity;
  final double activeBoost;

  const _WelcomeLoader({
    super.key,
    required this.size,
    required this.dotSize,
    this.innerFillRatio = 0.6,
    this.intervalMs = 220,
    this.ringOpacity = 0.95,
    this.activeBoost = 1.0,
  });

  @override
  State<_WelcomeLoader> createState() => _WelcomeLoaderState();
}

class _WelcomeLoaderState extends State<_WelcomeLoader> {
  late Timer _timer;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
      setState(() => _active = (_active + 1) % 8);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = (widget.size - widget.dotSize) / 2;
    final center = widget.size / 2;
    final inner = widget.dotSize * widget.innerFillRatio;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: List.generate(8, (i) {
          final angle = -math.pi / 2 + i * (2 * math.pi / 8);
          final dx = center + radius * math.cos(angle) - widget.dotSize / 2;
          final dy = center + radius * math.sin(angle) - widget.dotSize / 2;

          final ringColor = _kLoaderColors[i].withOpacity(
            i == _active ? widget.activeBoost : widget.ringOpacity,
          );

          return Positioned(
            left: dx,
            top: dy,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_active == i)
                  AnimatedScale(
                    duration: const Duration(milliseconds: 140),
                    scale: 1.0,
                    child: Container(
                      width: inner,
                      height: inner,
                      decoration: BoxDecoration(
                        color: _kLoaderColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Image.asset(
                  _kEllipseAsset,
                  width: widget.dotSize,
                  height: widget.dotSize,
                  color: ringColor,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
