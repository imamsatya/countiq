import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated floating math symbols background.
/// Uses operators, digits, and math symbols as particles with rotation.
class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_MathParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    _particles = List.generate(25, (_) => _MathParticle());
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
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MathParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MathParticle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;
  final double phase;
  final double rotationSpeed;
  final String symbol;

  static const _symbols = [
    '+', '−', '×', '÷', '=',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '%', 'π', '√', '#', '∑',
  ];

  _MathParticle()
      : x = Random().nextDouble(),
        y = Random().nextDouble(),
        speed = 0.12 + Random().nextDouble() * 0.35,
        size = 10 + Random().nextDouble() * 16,
        opacity = 0.03 + Random().nextDouble() * 0.06,
        phase = Random().nextDouble() * 2 * pi,
        rotationSpeed = (Random().nextDouble() - 0.5) * 0.8,
        symbol = _symbols[Random().nextInt(_symbols.length)];
}

class _MathParticlePainter extends CustomPainter {
  final List<_MathParticle> particles;
  final double progress;
  final Color color;

  _MathParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final px = p.x * size.width + sin(t * 2 * pi) * 30;
      final py = ((p.y + t * p.speed) % 1.0) * size.height;
      final rotation = progress * p.rotationSpeed * 2 * pi;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rotation);

      final textPainter = TextPainter(
        text: TextSpan(
          text: p.symbol,
          style: TextStyle(
            color: color.withValues(alpha: p.opacity),
            fontSize: p.size,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MathParticlePainter old) => true;
}
