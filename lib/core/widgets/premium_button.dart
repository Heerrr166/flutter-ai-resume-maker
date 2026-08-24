import 'package:flutter/material.dart';

import '../constants/app_radius.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.borderSide,
    this.borderRadius = AppRadius.md,
    this.elevation = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;
  final Widget? trailingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final BorderSide? borderSide;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = backgroundColor ?? theme.colorScheme.primary;
    final textColor = foregroundColor ?? theme.colorScheme.onPrimary;
    final isInteractive = enabled && !isLoading;

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: textColor,
                strokeWidth: 2.4,
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: (textStyle ??
                            theme.textTheme.labelLarge?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ))
                        ?.copyWith(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 10),
                  trailingIcon!,
                ],
              ],
            ),
    );

    if (gradient != null) {
      return Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
            boxShadow: [
              if (elevation > 0 && enabled)
                BoxShadow(
                  color: (backgroundColor ?? theme.colorScheme.primary).withAlpha((0.28 * 255).round()),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isInteractive ? onPressed : null,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(
                padding: padding,
                child: Center(child: content),
              ),
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: ElevatedButton(
        onPressed: isInteractive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          side: borderSide,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: padding,
          elevation: elevation,
          shadowColor: theme.colorScheme.shadow,
        ),
        child: content,
      ),
    );
  }
}
