import 'package:flutter/material.dart';

import '../constants/app_radius.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.color,
    this.borderRadius = AppRadius.lg,
    this.elevation = 10,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final double borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: elevation,
      shadowColor: theme.colorScheme.shadow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.surface,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow,
              blurRadius: elevation,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
