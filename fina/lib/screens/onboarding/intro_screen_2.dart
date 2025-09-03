import 'package:flutter/material.dart';
import '../../widgets/top_bar.dart';

const Color _kIntroBgStart = Color(0xFF2A2348);
const Color _kIntroBgEnd = Color(0xFF070613);

const double _kOverlayRatio = 585 / 812; // ≈ 0.720 از ارتفاع
const double _kFadeStartRel = 525 / 585; // ≈ 0.897 شروع فید در داخل ناحیه تصویر

const Color _kOrange = Color(0xFFFF6A00);
const Color _kPink = Color(0xFFFF3D81);
const Color _kPurpleDot = Color(0xFFB24EF8);

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    final overlayHeight = size.height * (isTablet ? 0.62 : _kOverlayRatio);
    final fadeStart = _kFadeStartRel.clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kIntroBgStart, _kIntroBgEnd],
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: overlayHeight,
              width: double.infinity,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, fadeStart, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/back2.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.20),
                            Colors.black.withOpacity(0.40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.60, 0.80, 1.00],
                  ),
                ),
              ),
            ),
          ),

          const SafeArea(child: TopBar()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _Dot(), // صفحه 1
                      SizedBox(width: 6),
                      _Dot(active: true), // صفحه 2 (کشیده)
                      SizedBox(width: 6),
                      _Dot(), // صفحه 3
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'SELECT A CAR',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(
                    width: 284,
                    child: Text(
                      'Sport, Limousine, Terrain… whatever your preference is, we have it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // دکمه Create Account (200×45) — بدون پیام تستی
                  SizedBox(
                    width: 200,
                    height: 45,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kOrange, _kPink],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {}, // بدون SnackBar
                          child: const Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: _kOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 8,
      width: active ? 22 : 8,
      decoration: BoxDecoration(
        color: active ? _kOrange : _kPurpleDot,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
