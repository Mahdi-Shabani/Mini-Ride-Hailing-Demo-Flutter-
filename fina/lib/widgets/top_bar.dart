import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry margin;
  final String assetPath;

  const TopBar({
    super.key,
    this.height, // null = ارتفاع خودکار
    this.margin = EdgeInsets.zero,
    this.assetPath = 'assets/images/Top_bar.png',
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: margin,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return Image.asset(
                assetPath,
                width: w,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
              );
            },
          ),
        ),
      ),
    );
  }
}
