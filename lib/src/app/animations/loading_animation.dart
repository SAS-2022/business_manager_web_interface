import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedArcLoader extends StatefulWidget {
  final double? progress;
  final Duration? timeoutDuration;
  final VoidCallback? onTimeout;
  final bool? showPercentage;
  final double? size;
  final double? fontSize;
  final Color? color;
  const AnimatedArcLoader(
      {super.key,
      this.progress,
      this.timeoutDuration,
      this.onTimeout,
      this.showPercentage,
      this.size,
      this.fontSize,
      this.color});

  @override
  State<AnimatedArcLoader> createState() => _AnimatedArcLoaderState();
}

class _AnimatedArcLoaderState extends State<AnimatedArcLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? timeoutTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.progress == null) {
      // Indefinite loading - repeat animation
      _controller.repeat();
    } else {
      // Determinate loading - animate to progress
      _controller.animateTo(widget.progress!,
          duration: const Duration(milliseconds: 300));
    }

    // Setup timeout if provided
    if (widget.timeoutDuration != null) {
      timeoutTimer = Timer(widget.timeoutDuration!, () {
        if (mounted) {
          widget.onTimeout?.call();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedArcLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation if progress changes
    if (widget.progress != oldWidget.progress) {
      if (widget.progress == null) {
        _controller.repeat();
      } else {
        _controller.animateTo(widget.progress!,
            duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.size ?? 100,
          height: widget.size ?? 100,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ArcPainter(
                  widget.progress == null
                      ? _controller.value
                      : widget.progress!,
                  widget.color,
                ),
              );
            },
          ),
        ),
        if (widget.showPercentage != null &&
            widget.showPercentage! &&
            widget.progress != null)
          Text(
            '${(widget.progress! * 100).toInt()}%',
            style: TextStyle(
              fontSize: widget.fontSize ?? 12,
              fontWeight: FontWeight.bold,
              color: widget.color ?? Colors.lightBlueAccent,
            ),
          ),
      ],
    );
  }
}

class ArcPainter extends CustomPainter {
  final double progress;
  final Color? color;

  ArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    // Draw the arc
    canvas.drawArc(
      rect,
      -pi / 2, // Start at top
      2 * pi * progress, // Sweep angle
      false,
      paint,
    );
    // Draw a subtle background circle for context
    final backgroundPaint = Paint()
      ..color = color != null
          ? color!.withValues(alpha: 0.1)
          : Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(ArcPainter oldDelegate) => true;
}
