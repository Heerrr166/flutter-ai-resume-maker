import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../models/resume_template.dart';

// Returns the chosen template id via Navigator.pop, or null if dismissed
// without a change. Selecting a card is instant — no separate confirm step.
class TemplatePickerScreen extends StatelessWidget {
  final String currentTemplateId;

  const TemplatePickerScreen({super.key, required this.currentTemplateId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Template')),
      body: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cross = width > 1200 ? 4 : (width > 900 ? 3 : (width > 600 ? 2 : 1));
        return RadioGroup<String>(
          groupValue: currentTemplateId,
          onChanged: (value) {
            if (value != null) Navigator.of(context).pop(value);
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.62,
            ),
            itemCount: ResumeTemplateType.values.length,
            itemBuilder: (context, index) {
              final type = ResumeTemplateType.values[index];
              return _TemplateCard(
                type: type,
                isSelected: type.id == currentTemplateId,
                onTap: () => Navigator.of(context).pop(type.id),
              );
            },
          ),
        );
    }),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ResumeTemplateType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _TemplateMockup(type: type)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    type.label,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isSelected)
                  Radio<String>(
                    value: type.id,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                else
                  Radio<String>(
                    value: type.id,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              type.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// Small stylized mockup sketching each template's layout shape — not a real
// PDF render (that would be slow to regenerate 5x just for a picker grid),
// but visually distinct enough to convey structure at a glance.
class _TemplateMockup extends StatelessWidget {
  final ResumeTemplateType type;

  const _TemplateMockup({required this.type});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: const Color(0xFFF3F4F8),
        padding: const EdgeInsets.all(8),
        child: switch (type) {
          ResumeTemplateType.modern => _modernMockup(),
          ResumeTemplateType.minimalAts => _minimalMockup(),
          ResumeTemplateType.professional => _professionalMockup(),
          ResumeTemplateType.creative => _creativeMockup(),
          ResumeTemplateType.executive => _executiveMockup(),
        },
      ),
    );
  }

  Widget _bar(double width, {double height = 6, Color color = const Color(0xFFB9C0D4)}) {
    return Container(width: width, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)));
  }

  Widget _modernMockup() {
    const accent = Color(0xFF2F6FED);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _bar(60, height: 10, color: accent),
      const SizedBox(height: 4),
      _bar(90),
      const SizedBox(height: 10),
      Container(width: double.infinity, height: 1.5, color: accent),
      const SizedBox(height: 8),
      _bar(40, height: 5, color: accent),
      const SizedBox(height: 4),
      _bar(double.infinity),
      const SizedBox(height: 3),
      _bar(double.infinity),
      const SizedBox(height: 8),
      _bar(40, height: 5, color: accent),
      const SizedBox(height: 4),
      _bar(double.infinity),
    ]);
  }

  Widget _minimalMockup() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _bar(70, height: 9, color: Colors.black87),
      const SizedBox(height: 6),
      _bar(100, color: Colors.black38),
      const SizedBox(height: 12),
      _bar(35, height: 5, color: Colors.black87),
      const SizedBox(height: 4),
      _bar(double.infinity, color: Colors.black38),
      const SizedBox(height: 3),
      _bar(double.infinity, color: Colors.black38),
      const SizedBox(height: 10),
      _bar(35, height: 5, color: Colors.black87),
      const SizedBox(height: 4),
      _bar(double.infinity, color: Colors.black38),
    ]);
  }

  Widget _professionalMockup() {
    return Column(children: [
      _bar(70, height: 9, color: const Color(0xFF1F2937)),
      const SizedBox(height: 6),
      Container(width: double.infinity, height: 1, color: Colors.grey.shade400),
      const SizedBox(height: 10),
      Align(alignment: Alignment.centerLeft, child: _bar(40, height: 5, color: const Color(0xFF1F2937))),
      const SizedBox(height: 4),
      _bar(double.infinity),
      const SizedBox(height: 3),
      _bar(double.infinity),
      const SizedBox(height: 10),
      Align(alignment: Alignment.centerLeft, child: _bar(40, height: 5, color: const Color(0xFF1F2937))),
      const SizedBox(height: 4),
      _bar(double.infinity),
    ]);
  }

  Widget _creativeMockup() {
    const accent = Color(0xFF7C3AED);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 26,
        height: double.infinity,
        color: accent.withAlpha((0.15 * 255).round()),
        padding: const EdgeInsets.all(4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _bar(18, height: 4, color: accent),
          const SizedBox(height: 6),
          _bar(18, height: 4, color: accent),
          const SizedBox(height: 6),
          _bar(18, height: 4, color: accent),
        ]),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _bar(50, height: 8, color: accent),
          const SizedBox(height: 4),
          _bar(60),
          const SizedBox(height: 10),
          _bar(double.infinity),
          const SizedBox(height: 3),
          _bar(double.infinity),
        ]),
      ),
    ]);
  }

  Widget _executiveMockup() {
    const navy = Color(0xFF0F2A4A);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        color: navy,
        padding: const EdgeInsets.all(6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _bar(60, height: 8, color: Colors.white),
          const SizedBox(height: 4),
          _bar(80, height: 4, color: Colors.white70),
        ]),
      ),
      const SizedBox(height: 10),
      _bar(35, height: 5, color: navy),
      const SizedBox(height: 4),
      _bar(double.infinity),
      const SizedBox(height: 3),
      _bar(double.infinity),
      const SizedBox(height: 8),
      _bar(35, height: 5, color: navy),
      const SizedBox(height: 4),
      _bar(double.infinity),
    ]);
  }
}
