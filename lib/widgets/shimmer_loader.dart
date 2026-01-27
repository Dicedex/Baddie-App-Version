import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsets margin;

  const ShimmerLoader({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = 8,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerTextLoader extends StatelessWidget {
  final int lineCount;
  final EdgeInsets padding;

  const ShimmerTextLoader({
    super.key,
    this.lineCount = 3,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          lineCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ShimmerLoader(
              height: index == lineCount - 1 ? 12 : 16,
              width: index == lineCount - 1 ? 200 : double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
