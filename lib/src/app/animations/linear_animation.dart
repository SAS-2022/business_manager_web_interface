import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBlockLoader extends StatefulWidget {
  final double? progress;
  final Duration? timeoutDuration;
  final VoidCallback? onTimeout;
  final bool? showPercentage;
  final double? size;
  final double? fontSize;
  final Color? color;
  final BlockAnimationType? animationType;

  const AnimatedBlockLoader({
    super.key,
    this.progress,
    this.timeoutDuration,
    this.onTimeout,
    this.showPercentage,
    this.size,
    this.fontSize,
    this.color,
    this.animationType,
  });

  @override
  State<AnimatedBlockLoader> createState() => _AnimatedBlockLoaderState();
}

enum BlockAnimationType {
  pulse,
  bounce,
  rotate,
  wave,
  morph,
}

class _AnimatedBlockLoaderState extends State<AnimatedBlockLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _morphAnimation;
  Timer? timeoutTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Scale animation for pulse and bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for rotate type
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Wave animation for wave type
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Morph animation for morph type
    _morphAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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
  void didUpdateWidget(AnimatedBlockLoader oldWidget) {
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
    final animationType = widget.animationType ?? BlockAnimationType.pulse;
    final size = widget.size ?? 100;
    final color = widget.color ?? Colors.blue;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BlockPainter(
                  progress: widget.progress == null
                      ? _controller.value
                      : widget.progress!,
                  color: color,
                  scale: animationType == BlockAnimationType.pulse ||
                          animationType == BlockAnimationType.bounce
                      ? _scaleAnimation.value
                      : 1.0,
                  rotation: animationType == BlockAnimationType.rotate
                      ? _rotationAnimation.value
                      : 0.0,
                  waveOffset: animationType == BlockAnimationType.wave
                      ? _waveAnimation.value
                      : 0.0,
                  morphValue: animationType == BlockAnimationType.morph
                      ? _morphAnimation.value
                      : 0.0,
                  animationType: animationType,
                ),
              );
            },
          ),
        ),
        if (widget.showPercentage == true && widget.progress != null)
          Text(
            '${(widget.progress! * 100).toInt()}%',
            style: TextStyle(
              fontSize: widget.fontSize ?? 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
      ],
    );
  }
}

class BlockPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double scale;
  final double rotation;
  final double waveOffset;
  final double morphValue;
  final BlockAnimationType animationType;

  BlockPainter({
    required this.progress,
    required this.color,
    required this.scale,
    required this.rotation,
    required this.waveOffset,
    required this.morphValue,
    required this.animationType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRectSize = size.width * 0.6;

    // Apply scaling
    final scaledSize = baseRectSize * scale;
    final rect = Rect.fromCenter(
      center: center,
      width: scaledSize,
      height: scaledSize,
    );

    // Save canvas state for rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Create paint with gradient based on progress
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          color.withValues(alpha: 0.7),
          color.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw different shapes based on animation type
    switch (animationType) {
      case BlockAnimationType.pulse:
        _drawRoundedRect(canvas, rect, paint);
        break;
      case BlockAnimationType.bounce:
        // Add shadow for bounce effect
        canvas.drawShadow(Path()..addRect(rect), Colors.black26, 8.0, true);
        _drawRoundedRect(canvas, rect, paint);
        break;
      case BlockAnimationType.rotate:
        _drawRoundedRect(canvas, rect, paint);
        break;
      case BlockAnimationType.wave:
        _drawWaveShape(canvas, rect, paint);
        break;
      case BlockAnimationType.morph:
        _drawMorphShape(canvas, rect, paint, morphValue);
        break;
    }

    // Draw progress indicator outline
    if (progress < 1.0) {
      final progressPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final progressRect = Rect.fromCenter(
        center: center,
        width: scaledSize * progress,
        height: scaledSize * progress,
      );
      canvas.drawRect(progressRect, progressPaint);
    }

    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, Rect rect, Paint paint) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12.0));
    canvas.drawRRect(rrect, paint);
  }

  void _drawWaveShape(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final waveHeight = 8.0 * sin(waveOffset);

    path.moveTo(rect.left, rect.top);

    // Top edge with wave
    for (double x = rect.left; x <= rect.right; x += 5) {
      final y = rect.top + waveHeight * sin((x - rect.left) / 10 + waveOffset);
      path.lineTo(x, y);
    }

    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawMorphShape(
      Canvas canvas, Rect rect, Paint paint, double morphValue) {
    if (morphValue < 0.33) {
      // Square to circle morph
      final t = morphValue / 0.33;
      final radius = 12.0 * (1 - t) + (rect.width / 2) * t;
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(rrect, paint);
    } else if (morphValue < 0.66) {
      // Circle to triangle morph
      final center = rect.center;
      final radius = rect.width / 2;

      final circlePath = Path()..addOval(rect);

      final trianglePath = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius * 0.866, center.dy + radius * 0.5)
        ..lineTo(center.dx - radius * 0.866, center.dy + radius * 0.5)
        ..close();

      final interpolatedPath = Path.combine(
        PathOperation.xor,
        circlePath,
        trianglePath,
      );
      canvas.drawPath(interpolatedPath, paint);
    } else {
      // Triangle back to square
      final t = (morphValue - 0.66) / 0.34;
      final rrect =
          RRect.fromRectAndRadius(rect, Radius.circular(12.0 * (1 - t)));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(BlockPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scale != scale ||
        oldDelegate.rotation != rotation ||
        oldDelegate.waveOffset != waveOffset ||
        oldDelegate.morphValue != morphValue ||
        oldDelegate.animationType != animationType;
  }
}
