import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/radio_controller.dart';

class EqualizerVisualizer extends StatelessWidget {
  final double height;
  final Color barColor;
  final double sensitivity; // حساسیت به تغییرات (۱ تا ۱۰)

  const EqualizerVisualizer({
    Key? key,
    this.height = 120,
    this.barColor = Colors.blueAccent,
    this.sensitivity = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RadioController>();

    return SizedBox(
      height: height,
      child: Obx(() {
        final bars = controller.bars.map((val) {
          // اعمال حساسیت به تغییرات
          double adjusted = pow(val, sensitivity).toDouble();
          return adjusted.clamp(0.0, 1.0);
        }).toList();

        return CustomPaint(
          painter: _EqualizerPainter(
            bars: bars,
            barColor: barColor,
          ),
          size: Size(MediaQuery.of(context).size.width, height),
        );
      }),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  final List<double> bars;
  final Color barColor;
  final double spacing;
  final double minHeight; // حداقل ارتفاع برای نمایش

  _EqualizerPainter({
    required this.bars,
    required this.barColor,
    this.spacing = 2.0,
    this.minHeight = 0.05, // 5% حداقل ارتفاع
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = barColor;

    final barWidth = size.width / bars.length;

    for (int i = 0; i < bars.length; i++) {
      // ترکیب مقدار با حداقل ارتفاع
      double height = (minHeight + (bars[i] * (1.0 - minHeight))) * size.height;
      height = height.clamp(size.height * minHeight * 1.8, size.height);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * barWidth + spacing,
            size.height - height,
            barWidth - spacing * 2,
            height,
          ),
          Radius.circular(barWidth / 4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter oldDelegate) => true;
}