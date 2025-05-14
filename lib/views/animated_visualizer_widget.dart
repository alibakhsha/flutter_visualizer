import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AnimatedVisualizerWidget extends StatefulWidget {
  final List<double> bars; // مقادیر میله‌ها
  final double height; // ارتفاع ویژوالایزر
  final Color barColor; // رنگ میله‌ها

  const AnimatedVisualizerWidget({
    Key? key,
    required this.bars,
    required this.height,
    required this.barColor,
  }) : super(key: key);

  @override
  _AnimatedVisualizerWidgetState createState() => _AnimatedVisualizerWidgetState();
}

class _AnimatedVisualizerWidgetState extends State<AnimatedVisualizerWidget>
    with TickerProviderStateMixin {
  static const int barCount = 30; // تعداد میله‌ها

  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      barCount,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = List.generate(
      barCount,
          (index) => Tween<double>(begin: 0.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOutSine,
        ),
      )..addListener(() {
        setState(() {}); // برای رفرش painter
      }),
    );
  }

  @override
  void didUpdateWidget(AnimatedVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isInvalidBars(widget.bars)) {
      for (int i = 0; i < barCount; i++) {
        final current = _animations[i].value;
        if (current != 0.0) {
          _animations[i] = Tween<double>(
            begin: current,
            end: 0.0,
          ).animate(
            CurvedAnimation(
              parent: _controllers[i],
              curve: Curves.easeInOutSine,
            ),
          );
          _controllers[i]
            ..reset()
            ..forward();
        }
      }
      return;
    }

    for (int i = 0; i < barCount; i++) {
      final newValue = i < widget.bars.length ? widget.bars[i].clamp(0.0, 1.0) : 0.0;
      final current = _animations[i].value;

      if ((newValue - current).abs() > 0.01) {
        _animations[i] = Tween<double>(
          begin: current,
          end: newValue,
        ).animate(
          CurvedAnimation(
            parent: _controllers[i],
            curve: Curves.easeInOutSine,
          ),
        )..addListener(() {
          setState(() {});
        });

        _controllers[i]
          ..reset()
          ..forward();
      }
    }
  }

  bool _isInvalidBars(List<double> bars) {
    if (bars.isEmpty || bars.length < barCount) return true;
    return bars.every((value) => value.abs() < 0.01);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VisualizerPainter(
        animations: _animations,
        barColor: widget.barColor,
      ),
      size: Size(double.infinity, widget.height),
    );
  }
}


class VisualizerPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final Color barColor;

  VisualizerPainter({required this.animations, required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final barWidth = size.width / animations.length;
    final centerY = size.height / 2; // خط مرکزی ویژوالایزر

    for (int i = 0; i < animations.length; i++) {
      // مقیاس ارتفاع: نصف به بالا، نصف به پایین
      final halfHeight = animations[i].value * (size.height / 2);
      // مستطیل از مرکز به بالا و پایین
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * barWidth,
            centerY - halfHeight, // شروع از مرکز به بالا
            barWidth - 4, // فاصله بین میله‌ها
            halfHeight * 2, // ارتفاع کل (بالا + پایین)
          ),
          const Radius.circular(8), // گوشه‌های گرد
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VisualizerPainter oldDelegate) => true;
}