import 'dart:math' as math;
import 'package:flutter/material.dart';

class SquigglyCircularProgressIndicator extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  const SquigglyCircularProgressIndicator({
    super.key,
    required this.value,
    this.strokeWidth = 4.0,
    this.color,
    this.backgroundColor,
  });

  @override
  State<SquigglyCircularProgressIndicator> createState() => _SquigglyCircularProgressIndicatorState();
}

class _SquigglyCircularProgressIndicatorState extends State<SquigglyCircularProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void didUpdateWidget(SquigglyCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If progress completes, maybe stop animating, but it's fine to keep repeating
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SquigglyPainter(
            progress: widget.value,
            phase: _controller.value * 2 * math.pi,
            strokeWidth: widget.strokeWidth,
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      },
    );
  }
}

class _SquigglyPainter extends CustomPainter {
  final double progress;
  final double phase;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  _SquigglyPainter({
    required this.progress,
    required this.phase,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double sweepAngle = progress * 2 * math.pi;
    
    // Determine dynamic segments based on progress so it's always smooth
    final int segments = math.max(10, (100 * progress).toInt());
    
    // Number of squiggles around the full circle
    const double ripples = 18.0;
    // Amplitude of the squiggle
    final double amplitude = strokeWidth * 0.6;

    for (int i = 0; i <= segments; i++) {
      final double t = i / segments; // 0.0 to 1.0 along the drawn arc
      final double angle = -math.pi / 2 + (sweepAngle * t);
      
      // Calculate the squiggly offset
      // Multiply by 'ripples' so the wave frequency matches the circle perimeter
      // Subtract phase to make it animate forward
      final double waveOffset = math.sin((angle * ripples) - phase) * amplitude;
      
      // Taper the wave at the start and end of the stroke for a cleaner look
      double taper = 1.0;
      if (progress < 1.0) {
        if (t < 0.15) taper = t / 0.15;
        if (t > 0.85) taper = (1.0 - t) / 0.15;
      }
      
      // Ease in the tapering
      taper = Curves.easeInOut.transform(taper);

      final currentRadius = radius + (waveOffset * taper);

      final double x = center.dx + currentRadius * math.cos(angle);
      final double y = center.dy + currentRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SquigglyPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase || oldDelegate.color != color;
  }
}

class SquigglyLinearProgressIndicator extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  const SquigglyLinearProgressIndicator({
    super.key,
    required this.value,
    this.strokeWidth = 4.0,
    this.color,
    this.backgroundColor,
  });

  @override
  State<SquigglyLinearProgressIndicator> createState() => _SquigglyLinearProgressIndicatorState();
}

class _SquigglyLinearProgressIndicatorState extends State<SquigglyLinearProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.strokeWidth * 3), // height gives room for wave
          painter: _SquigglyLinearPainter(
            progress: widget.value,
            phase: _controller.value * 2 * math.pi,
            strokeWidth: widget.strokeWidth,
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      },
    );
  }
}

class _SquigglyLinearPainter extends CustomPainter {
  final double progress;
  final double phase;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  _SquigglyLinearPainter({
    required this.progress,
    required this.phase,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double totalWidth = size.width;

    // Background track (straight line)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, centerY), Offset(totalWidth, centerY), bgPaint);

    if (progress <= 0) return;

    final double activeWidth = totalWidth * progress;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Wave properties for authentic Android 13 Media Player look
    final double amplitude = strokeWidth * 0.6;
    final double frequency = (math.pi * 2) / 45.0; // wave length of 45 pixels

    for (double x = 0; x <= activeWidth; x += 1) {
      // sine wave
      final double waveOffset = math.sin((x * frequency) - phase) * amplitude;
      
      // Taper at start and end for smooth connection to center line
      double taper = 1.0;
      if (progress < 1.0) {
        if (x < 10) taper = x / 10;
        if (x > activeWidth - 10) taper = (activeWidth - x) / 10;
      }

      taper = Curves.easeInOut.transform(taper.clamp(0.0, 1.0));
      
      final double y = centerY + (waveOffset * taper);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SquigglyLinearPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.phase != phase || 
           oldDelegate.color != color || 
           oldDelegate.backgroundColor != backgroundColor;
  }
}

