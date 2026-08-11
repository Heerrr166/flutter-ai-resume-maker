import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// A single color-coded circular score indicator, shared by the dashboard
// progress card and the Resume Score sheet so both read consistently instead
// of each screen drawing its own CircularProgressIndicator+Text stack.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.value,
    this.size = 96,
    this.strokeWidth = 9,
    this.label,
    this.trackColor,
    this.valueColor,
  });

  /// 0-100.
  final num value;
  final double size;
  final double strokeWidth;
  final String? label;
  final Color? trackColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = valueColor ?? AppColors.forScore(value);
    final track = trackColor ?? color.withAlpha((0.16 * 255).round());

    // The number must stay strictly inside the ring's hole (size minus the
    // stroke on both sides, plus a little breathing room) - without this,
    // 3-digit values like "100" could crowd right up against the stroke and
    // read as a smudged blob rather than a crisp ring-with-number.
    final holeDiameter = size - (strokeWidth * 2) - 8;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (value.clamp(0, 100)) / 100.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: track,
              );
            },
          ),
          // A same-color ring stroke and number text (e.g. an all-white
          // "on a gradient card" treatment) would make the digits unreadable
          // right where they cross the stroke, so the number always sits on
          // its own small opaque backdrop instead of the bare transparent
          // hole - that backdrop is what actually guarantees contrast, not
          // the text color choice.
          Container(
            width: holeDiameter,
            height: holeDiameter,
            decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.surface),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.round()}',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    if (label != null)
                      Text(
                        label!,
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
