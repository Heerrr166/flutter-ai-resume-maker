import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'premium_button.dart';

// Shared empty-state layout (icon + title + subtitle + optional action) so
// "no resumes yet", "no users found", "no matches" etc. all read as one
// consistent pattern instead of ad-hoc single lines of text per screen.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? AppSpacing.lg : AppSpacing.xxl, horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((0.10 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: compact ? 28 : 36, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.68 * 255).round())),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            PremiumButton(label: actionLabel!, onPressed: onAction!, icon: const Icon(Icons.add, size: 18)),
          ],
        ],
      ),
    );
  }
}
