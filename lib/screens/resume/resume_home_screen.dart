import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/premium_card.dart';
import '../../models/resume_template.dart';
import '../../providers/resume_provider.dart';
import '../../routes/app_routes.dart';

class ResumeHomeScreen extends ConsumerStatefulWidget {
  const ResumeHomeScreen({super.key});

  static const sectionKeys = [
    'personal',
    'summary',
    'education',
    'experience',
    'projects',
    'skills',
    'certifications',
    'languages',
    'achievements',
    'references',
  ];

  @override
  ConsumerState<ResumeHomeScreen> createState() => _ResumeHomeScreenState();
}

class _ResumeHomeScreenState extends ConsumerState<ResumeHomeScreen> {
  Future<void> _createAndOpenEditor([String? title, String? template]) async {
    final resumeTitle = title ?? 'Untitled Resume';
    await ref.read(resumeNotifierProvider.notifier).createResume(resumeTitle, template: template);
    final newest = ref.read(resumeNotifierProvider).value?.last;
    if (!mounted || newest == null) return;
    context.push(AppRoutes.resumeEditorPath(newest.id));
  }

  void _showResumeIntelligenceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resume Intelligence Tools',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.analytics_outlined, color: Colors.indigo),
                title: const Text('Smart Resume Score'),
                subtitle: const Text('Score your resume from the editor'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _createAndOpenEditor();
                },
              ),
              ListTile(
                leading: const Icon(Icons.psychology, color: Colors.purple),
                title: const Text('Skill Recommendations'),
                subtitle: const Text('Get skill suggestions from the editor'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _createAndOpenEditor();
                },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('Summary Generator'),
                subtitle: const Text('Generate a professional summary in the editor'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _createAndOpenEditor();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(resumeNotifierProvider);

    IconData getTemplateIcon(ResumeTemplateType t) {
      switch (t) {
        case ResumeTemplateType.modern:
          return Icons.space_dashboard_outlined;
        case ResumeTemplateType.minimalAts:
        case ResumeTemplateType.compactAts:
          return Icons.fact_check_outlined;
        case ResumeTemplateType.professional:
        case ResumeTemplateType.corporate:
        case ResumeTemplateType.finance:
          return Icons.badge_outlined;
        case ResumeTemplateType.creative:
        case ResumeTemplateType.marketing:
          return Icons.palette_outlined;
        case ResumeTemplateType.executive:
        case ResumeTemplateType.boldHeader:
          return Icons.workspace_premium_outlined;
        case ResumeTemplateType.techDeveloper:
        case ResumeTemplateType.dataAnalytics:
          return Icons.code_rounded;
        case ResumeTemplateType.studentFresher:
          return Icons.school_outlined;
        case ResumeTemplateType.academic:
          return Icons.menu_book_rounded;
        case ResumeTemplateType.elegantMonochrome:
        case ResumeTemplateType.cleanTwoColumn:
          return Icons.view_column_outlined;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: const Text('Resume Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'All Resumes',
            onPressed: () => context.push(AppRoutes.resumeList),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 88.0 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumCard(
              padding: const EdgeInsets.all(18),
              borderRadius: AppRadius.lg,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Flexible(
                        child: Text(
                          'Resume Intelligence',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.insights_outlined, color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Resume Score, tailored summaries, and skill recommendations - all built in.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _showResumeIntelligenceModal(context),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Explore', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Template Layout (${ResumeTemplateType.values.length} Templates)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final cardWidth = isMobile
                    ? ((constraints.maxWidth - 12) / 2.15).clamp(145.0, 185.0)
                    : 165.0;
                final cardHeight = isMobile ? 154.0 : 150.0;

                return SizedBox(
                  height: cardHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: ResumeTemplateType.values.length,
                    itemBuilder: (context, index) {
                      final type = ResumeTemplateType.values[index];
                      final color = Color(type.primaryColorValue);
                      return GestureDetector(
                        onTap: () => _createAndOpenEditor('Untitled Resume', type.id),
                        child: Container(
                          width: cardWidth,
                          margin: EdgeInsets.only(
                            right: index == ResumeTemplateType.values.length - 1 ? 0 : 12,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: color.withAlpha((0.3 * 255).round()),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.04 * 255).round()),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(getTemplateIcon(type), color: color, size: 24),
                              const Spacer(),
                              Text(
                                type.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                type.category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Resumes',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.resumeList),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            state.when(
              data: (list) {
                if (list.isEmpty) {
                  // No actionLabel here - the screen's own persistent "New
                  // Resume" FAB provides the same action and would otherwise
                  // render a second, overlapping create-resume button.
                  return const PremiumCard(
                    padding: EdgeInsets.all(8),
                    child: EmptyState(
                      icon: Icons.description_outlined,
                      title: 'No resumes yet',
                      subtitle: 'Create your first resume to get started.',
                      compact: true,
                    ),
                  );
                }
                final recent = list.take(4).toList();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
                    childAspectRatio: 3.2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final r = recent[index];
                    return PremiumCard(
                      child: InkWell(
                        onTap: () => context.push(AppRoutes.resumeEditorPath(r.id)),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primary
                                    .withAlpha((0.14 * 255).round()),
                                child: Icon(Icons.article_outlined,
                                    color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${r.sections.length} sections completed',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () =>
                                    context.push(AppRoutes.resumeEditorPath(r.id)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(child: Text('Failed to load resumes')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAndOpenEditor(),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('New Resume', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        elevation: 4,
      ),
    );
  }
}
