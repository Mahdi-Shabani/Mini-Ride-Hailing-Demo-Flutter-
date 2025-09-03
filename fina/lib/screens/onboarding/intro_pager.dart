import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/top_bar.dart';
import '../../core/responsive/dimens.dart';
import '../map/map_screen.dart';

const Color _kIntroBgStart = Color(0xFF2A2348);
const Color _kIntroBgEnd = Color(0xFF070613);

const double _kFadeStartRel = 525 / 585; // ≈ 0.897

const Color _kOrange = Color(0xFFFF6A00);
const Color _kPink = Color(0xFFFF3D81);
const Color _kPurpleDot = Color(0xFFB24EF8);

class IntroPager extends StatefulWidget {
  const IntroPager({super.key});
  @override
  State<IntroPager> createState() => _IntroPagerState();
}

class _IntroPagerState extends State<IntroPager> {
  final _controller = PageController();
  double _page = 0.0;

  final _pages = const [
    _IntroData(
      image: 'assets/images/back.png',
      title: 'ORDER A RIDE',
      subtitle:
          'Order a luxury ride immediately, or book a car for upcoming event.',
    ),
    _IntroData(
      image: 'assets/images/back2.png',
      title: 'SELECT A CAR',
      subtitle:
          'Sport, Limousine, Terrain… whatever your preference is, we have it.',
    ),
    _IntroData(
      image: 'assets/images/back3.png',
      title: 'RIDE IN STYLE',
      subtitle: 'Enjoy the ride in luxury car, with a professional driver.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = _page.round().clamp(0, _pages.length - 1);
    final overlayHeight = Dimens.overlayHeightFor(context);
    final contentMaxW = Dimens.contentMaxWidth(context);
    final titleSize = Dimens.titleSize(context);
    final bodySize = Dimens.bodySize(context);
    final btnSize = Dimens.buttonSize(context);

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

          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (_, i) => _IntroSlide(
              imagePath: _pages[i].image,
              overlayHeight: overlayHeight,
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black26,
                      Colors.black54,
                    ],
                    stops: [0.60, 0.80, 1.00],
                  ),
                ),
              ),
            ),
          ),

          const SafeArea(child: TopBar()),

          Dimens.limitTextScale(
            context: context,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    const Spacer(),

                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxW),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            WormDotsIndicator(
                              controller: _controller,
                              count: _pages.length,
                              dotSize: 8,
                              spacing: 6,
                              inactiveColor: _kPurpleDot,
                              activeColor: _kOrange,
                              onDotTap: _goTo,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              _pages[idx].title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              width: math.min(284, contentMaxW),
                              child: Text(
                                _pages[idx].subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: bodySize,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            SizedBox(
                              width: btnSize.width,
                              height: btnSize.height,
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
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const MapScreen(),
                                        ),
                                      );
                                    },
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroData {
  final String image;
  final String title;
  final String subtitle;
  const _IntroData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class _IntroSlide extends StatelessWidget {
  final String imagePath;
  final double overlayHeight;
  const _IntroSlide({required this.imagePath, required this.overlayHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                  stops: const [0.0, _kFadeStartRel, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
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
      ],
    );
  }
}

class WormDotsIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final double dotSize;
  final double spacing;
  final Color inactiveColor;
  final Color activeColor;
  final void Function(int index)? onDotTap;

  const WormDotsIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.dotSize = 8,
    this.spacing = 6,
    required this.inactiveColor,
    required this.activeColor,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    final trackWidth = count * dotSize + (count - 1) * spacing;

    return SizedBox(
      width: trackWidth,
      height: dotSize,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final page = controller.hasClients
              ? (controller.page ?? controller.initialPage.toDouble())
              : 0.0;
          int seg = page.floor().clamp(0, (count - 1));
          double t = page - seg;
          if (seg == count - 1) {
            seg = (count - 2).clamp(0, count - 2);
            t = 1.0;
          }

          final distance = dotSize + spacing;
          final leftBase = seg * distance;

          double left;
          double width;
          if (t <= 0.5) {
            left = leftBase;
            width = dotSize + (distance * 2 * t);
          } else {
            left = leftBase + distance * (2 * t - 1);
            width = dotSize + (distance * 2 * (1 - t));
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  count,
                  (i) => Container(
                    width: dotSize,
                    height: dotSize,
                    margin: EdgeInsets.only(
                      right: i == count - 1 ? 0 : spacing,
                    ),
                    decoration: BoxDecoration(
                      color: inactiveColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: 0,
                child: Container(
                  width: width,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(dotSize),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: List.generate(count, (i) {
                    final w = i == count - 1 ? dotSize : dotSize + spacing;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDotTap == null ? null : () => onDotTap!(i),
                      child: SizedBox(width: w, height: dotSize),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
