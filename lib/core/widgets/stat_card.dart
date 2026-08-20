import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(minWidth: 140, minHeight: 84),
        child: Row(
          children: [
            if (icon != null)
              CircleAvatar(
                radius: 22,
                backgroundColor: (color ?? theme.colorScheme.primary).withOpacity(0.12),
                child: Icon(icon, color: color ?? theme.colorScheme.primary, size: 20),
              ),
            if (icon != null) const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 6),
                  Text(value, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
