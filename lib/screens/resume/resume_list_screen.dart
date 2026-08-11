import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/premium_text_field.dart';
import '../../models/resume_model.dart';
import '../../providers/resume_progress_provider.dart';
import '../../providers/resume_provider.dart';
import '../../routes/app_routes.dart';

class ResumeListScreen extends ConsumerStatefulWidget {
  const ResumeListScreen({super.key});

  @override
  ConsumerState<ResumeListScreen> createState() => _ResumeListScreenState();
}

class _ResumeListScreenState extends ConsumerState<ResumeListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _createResume(String title) async {
    await ref.read(resumeNotifierProvider.notifier).createResume(title);
    final newest = ref.read(resumeNotifierProvider).value?.last;
    if (!mounted || newest == null) return;
    context.push(AppRoutes.resumeEditorPath(newest.id));
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Resume'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await ref.read(resumeNotifierProvider.notifier).deleteResume(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resume deleted')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(resumeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PremiumTextField(
              controller: _searchCtrl,
              label: 'Search Library',
              hintText: 'Filter by resume title...',
              prefixIcon: const Icon(Icons.search),
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.when(
                data: (list) {
                  final filtered = _searchQuery.isEmpty
                      ? list
                      : list
                          .where((r) => r.title.toLowerCase().contains(_searchQuery))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _searchQuery.isEmpty
                                ? 'No resumes created yet'
                                : 'No resumes matching "$_searchQuery"',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          PremiumButton(
                            label: 'Create Resume',
                            onPressed: () => _showCreateDialog(context),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ResumeModel r = filtered[index];
                      final progress = ref.watch(resumeProgressProvider(r));
                      final isPublished = r.status == 'published';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: PremiumCard(
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            onTap: () =>
                                context.push(AppRoutes.resumeEditorPath(r.id)),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: theme.colorScheme.primary
                                        .withAlpha((0.14 * 255).round()),
                                    child: Text(
                                      '${progress.percent}%',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.title,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (isPublished
                                                        ? AppColors.success
                                                        : AppColors.warning)
                                                    .withAlpha((0.14 * 255).round()),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                isPublished ? 'Published' : 'Draft',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: isPublished
                                                      ? AppColors.success
                                                      : AppColors.warning,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                '${r.sections.length} sections',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: theme.colorScheme.onSurface
                                                      .withAlpha((0.6 * 255).round()),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => context
                                        .push(AppRoutes.resumeEditorPath(r.id)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20, color: Colors.redAccent),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () =>
                                        _confirmDelete(context, r.id, r.title),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    const Center(child: Text('Failed to load resumes')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Resume'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter resume title (e.g. Software Engineer)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = controller.text.trim();
                if (title.isEmpty) return;
                Navigator.of(ctx).pop();
                await _createResume(title);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    // Deliberately not disposed here: .then() on the dialog's Future fires
    // as soon as the route is popped, before its exit-transition animation
    // finishes rebuilding the still-focused TextField, and hits "A
    // TextEditingController was used after being disposed." This is a
    // small, short-lived controller - once this closure is released it's
    // eligible for normal garbage collection without an explicit dispose().
  }
}
