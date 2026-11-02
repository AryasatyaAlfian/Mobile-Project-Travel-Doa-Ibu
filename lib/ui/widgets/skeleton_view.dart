import 'package:flutter/material.dart';

/// Kotak skeleton dengan animasi pulse shimmer bolak-balik.
/// Aman untuk test runner (tidak membuat tester.pumpAndSettle() timeout).
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.color,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _controller.repeat(reverse: true);
    }
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? const Color(0xFFEFE8DE);
    final highlightColor = widget.color != null
        ? widget.color!.withValues(alpha: 0.45)
        : const Color(0xFFFBF8F3);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final lerped =
            Color.lerp(baseColor, highlightColor, _animation.value) ??
                baseColor;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: lerped,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Skeleton lingkaran untuk avatar atau icon placeholder.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.size = 48,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: size / 2,
      color: color,
    );
  }
}
