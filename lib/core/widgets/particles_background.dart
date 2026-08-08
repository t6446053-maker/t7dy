import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ParticlesBackground extends StatefulWidget {
  final int particleCount;
  final Color color;

  const ParticlesBackground({
    super.key,
    this.particleCount = 28,
    this.color = AppColors.goldPrimary,
  });

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _Particle {
  double x;
  double y;
  double radius;
  double speed;
  double drift;
  double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.phase,
  });
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        _Particle(
          x: _rand.nextDouble(),
          y: _rand.nextDouble(),
          radius: 1.0 + _rand.nextDouble() * 2.5,
          speed: 0.02 + _rand.nextDouble() * 0.05,
          drift: _rand.nextDouble() * 2 * pi,
          phase: _rand.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticlesPainter(
              particles: _particles,
              t: _controller.value,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  final Color color;

  _ParticlesPainter({required this.particles, required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final progress = (p.y - t * p.speed) % 1.0;
      final dx = (p.x + 0.03 * sin(2 * pi * t + p.drift)) * size.width;
      final dy = progress < 0 ? (progress + 1.0) * size.height : progress * size.height;
      final opacity = 0.15 + 0.35 * (0.5 + 0.5 * sin(2 * pi * t + p.phase));

      paint.color = color.withOpacity(opacity.clamp(0.0, 0.5));
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
