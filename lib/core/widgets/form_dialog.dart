import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';

class FormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const FormDialog({Key? key, required this.title, required this.child, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Flexible(child: SingleChildScrollView(child: child)),
              if (actions != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
