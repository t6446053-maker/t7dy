import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;

  const ConfettiOverlay({super.key, required this.child});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class _ConfettiPiece {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_ConfettiPiece> _pieces = [];
  final Random _rand = Random();

  static const _colors = [
    AppColors.goldPrimary,
    AppColors.goldLight,
    AppColors.teamRed,
    AppColors.teamBlue,
    AppColors.success,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  void burst() {
    _pieces = List.generate(60, (i) {
      final angle = _rand.nextDouble() * pi - pi;
      final speed = 2.5 + _rand.nextDouble() * 4.5;
      return _ConfettiPiece(
        x: 0.5,
        y: 0.42,
        vx: cos(angle) * speed * 0.35,
        vy: -sin(angle).abs() * speed * 0.6 - 2,
        rotation: _rand.nextDouble() * 2 * pi,
        rotationSpeed: (_rand.nextDouble() - 0.5) * 10,
        color: _colors[_rand.nextInt(_colors.length)],
        size: 5 + _rand.nextDouble() * 6,
      );
    });
    _controller
      ..reset()
      ..forward();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.value == 0 || _pieces.isEmpty) {
                return const SizedBox.shrink();
              }
              return CustomPaint(
                painter: _ConfettiPainter(pieces: _pieces, t: _controller.value),
                size: Size.infinite,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double t;

  _ConfettiPainter({required this.pieces, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const gravity = 9.0;

    for (final p in pieces) {
      final time = t * 1.6;
      final dx = (p.x * size.width) + p.vx * time * 60;
      final dy = (p.y * size.height) + p.vy * time * 60 + 0.5 * gravity * time * time * 60;
      final fadeOpacity = (1.0 - t).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rotation + p.rotationSpeed * time);
      paint.color = p.color.withOpacity(fadeOpacity);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
