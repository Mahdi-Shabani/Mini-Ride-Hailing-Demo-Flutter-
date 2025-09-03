// lib/screens/car/car_details_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/top_bar.dart';

class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({super.key});

  static const Color pageBg = Color(0xFF2A2F40);

  static double _cmPx(double cm) => cm * 160.0 / 2.54;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padTop = MediaQuery.of(context).padding.top;
    final safeB = MediaQuery.of(context).padding.bottom;
    final s = size.width / 375.0;

    final double headerH = (size.height * 0.55 + _cmPx(1.5)).clamp(
      0.0,
      size.height * 0.8,
    );
    final double navTop = padTop + _cmPx(0.5);

    final double specW = (size.width - 32 * s).clamp(0, 335 * s);
    final double specH = specW * (108 / 335);

    final double ctaH = 106 * s;
    final EdgeInsets pageHPad = EdgeInsets.symmetric(horizontal: 16 * s);

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: const _NoGlowIOSBehavior(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.only(bottom: safeB + 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: headerH,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/bmw.png',
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, 0.50),
                          ),
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: const [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Color(0x33000000),
                                    pageBg,
                                  ],
                                  stops: const [0.0, 0.6, 0.85, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12 * s),

                    Center(
                      child: SizedBox(
                        width: specW,
                        height: specH,
                        child: Image.asset(
                          'assets/icons/Spec.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    Padding(
                      padding: pageHPad.copyWith(top: 16 * s),
                      child: SizedBox(
                        height: ctaH,
                        child: Image.asset(
                          'assets/images/Bottom.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
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
            left: 0,
            right: 0,
            top: navTop,
            child: _HeaderOverlay(s: s),
          ),
        ],
      ),
    );
  }
}

class _HeaderOverlay extends StatelessWidget {
  final double s;
  const _HeaderOverlay({required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.all(10 * s),
                    child: Image.asset(
                      'assets/icons/Chevron.png',
                      width: 24 * s,
                      height: 24 * s,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'BMW 840i',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(10 * s),
                    child: Image.asset(
                      'assets/icons/Heart.png',
                      width: 22 * s,
                      height: 22 * s,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * s),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '110 reviews',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                  decorationThickness: 1.4 * s,
                ),
              ),
              SizedBox(width: 6 * s),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (_) => Image.asset(
                    'assets/icons/star.png',
                    width: 14 * s,
                    height: 14 * s,
                    color: const Color(0xFFFF6A00),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * s),

          SizedBox(
            height: 26 * s,
            child: Image.asset('assets/icons/Tags.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
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
  ) => child;
}
