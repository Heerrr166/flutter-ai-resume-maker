import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/premium_text_field.dart';
import '../../core/widgets/score_ring.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_progress_provider.dart';
import '../../providers/resume_provider.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.stars, color: Colors.amber),
                title: Text('Resume Intelligence Ready'),
                subtitle: Text(
                    'Generate summaries and get content suggestions right in the editor.'),
              ),
              const ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Auto-save Active'),
                subtitle: Text(
                    'Your resume edits are saved automatically every 10 seconds.'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createResume() async {
    await ref.read(resumeNotifierProvider.notifier).createResume('Untitled');
    final newest = ref.read(resumeNotifierProvider).value?.last;
    if (!mounted || newest == null) return;
    context.push(AppRoutes.resumeEditorPath(newest.id));
  }

  void _navigateTo(int index) {
    if (index == 0) {
      context.go(AppRoutes.dashboard);
    } else if (index == 1) {
      context.go(AppRoutes.profile);
    } else if (index == 2) {
      context.go(AppRoutes.settings);
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final resumeState = ref.watch(resumeNotifierProvider);
    final greetingName = user?.fullName.split(' ').first ?? 'there';
    final avatarLetter = user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, $greetingName',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your resume experience is ready to launch.',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.62 * 255).round())),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.profile),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.primary.withAlpha((0.28 * 255).round()), width: 1.5),
                            ),
                            padding: const EdgeInsets.all(1.5),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(avatarLetter, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: PremiumTextField(
                            controller: _searchController,
                            label: 'Search resumes',
                            hintText: 'Search templates, skills...',
                            prefixIcon: const Icon(Icons.search_outlined),
                            validator: (_) => null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          child: IconButton(
                            onPressed: _showNotificationsSheet,
                            icon: Icon(Icons.notifications_none, color: theme.colorScheme.onSurface, size: 20),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              color: theme.colorScheme.primary,
                              icon: Icons.edit_note_outlined,
                              title: 'Create Resume',
                              subtitle: 'New draft',
                              onTap: _createResume,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _QuickActionCard(
                              color: theme.colorScheme.secondary,
                              icon: Icons.insights_outlined,
                              title: 'Resume Intelligence',
                              subtitle: 'Score & suggestions',
                              onTap: () => context.push(AppRoutes.resume),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              color: AppColors.success,
                              icon: Icons.grid_view_outlined,
                              title: 'Templates',
                              subtitle: 'Pick layout',
                              onTap: () => context.push(AppRoutes.resume),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _QuickActionCard(
                              color: AppColors.warning,
                              icon: Icons.folder_open_outlined,
                              title: 'Library',
                              subtitle: 'All resumes',
                              onTap: () => context.push(AppRoutes.resumeList),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    resumeState.when(
                      data: (resumes) {
                        if (resumes.isEmpty) {
                          // No actionLabel here - the screen's own
                          // persistent "Create Resume" FAB sits directly
                          // below this card and would otherwise render a
                          // second, overlapping "Create Resume" button.
                          return const PremiumCard(
                            padding: EdgeInsets.all(8),
                            child: EmptyState(
                              icon: Icons.trending_up,
                              title: 'No resume progress yet',
                              subtitle: 'Create your first resume to track progress here.',
                              compact: true,
                            ),
                          );
                        }
                        final latest = resumes.first;
                        final progress = ref.watch(resumeProgressProvider(latest));
                        return PremiumCard(
                          padding: const EdgeInsets.all(20),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withAlpha((0.98 * 255).round()),
                              theme.colorScheme.secondary.withAlpha((0.95 * 255).round()),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.resumeEditorPath(latest.id)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Resume Progress', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const Icon(Icons.trending_up, color: Colors.white70),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(latest.title, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${progress.percent}% complete',
                                            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ScoreRing(
                                      value: progress.percent,
                                      size: 84,
                                      strokeWidth: 7,
                                      valueColor: Colors.white,
                                      trackColor: Colors.white24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const PremiumCard(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent resumes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        TextButton(onPressed: () => context.push(AppRoutes.resumeList), child: const Text('View all')),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: resumeState.when(
                data: (resumes) {
                  final filtered = _searchQuery.isEmpty
                      ? resumes
                      : resumes.where((r) => r.title.toLowerCase().contains(_searchQuery)).toList();
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: _searchQuery.isEmpty ? Icons.description_outlined : Icons.search_off,
                      title: _searchQuery.isEmpty ? 'No resumes yet' : 'No matches found',
                      subtitle: _searchQuery.isEmpty
                          ? 'Tap Create Resume to get started.'
                          : 'No resumes matching "$_searchQuery".',
                      compact: true,
                    );
                  }
                  final recent = filtered.take(5).toList();
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final resume = recent[index];
                        final progress = ref.watch(resumeProgressProvider(resume));
                        return _RecentResumeCard(
                          title: resume.title,
                          subtitle: resume.status == 'published' ? 'Published' : 'Draft in progress',
                          progress: progress.percent / 100,
                          onTap: () => context.push(AppRoutes.resumeEditorPath(resume.id)),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.xl),
                child: Column(
                  children: [
                    PremiumCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Smart suggestions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Icon(Icons.auto_awesome_mosaic, color: theme.colorScheme.primary),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Open the resume builder to use smart content suggestions.',
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.78 * 255).round()), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PremiumCard(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily tip', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Use action verbs to make your experience stand out to hiring managers.',
                                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.78 * 255).round()), height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            child: Icon(Icons.lightbulb_outline, color: theme.colorScheme.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _navigateTo,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createResume,
        icon: const Icon(Icons.add),
        label: const Text('Create Resume'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.color, required this.icon, required this.title, required this.subtitle, required this.onTap});

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 116),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outline.withAlpha((0.10 * 255).round())),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: color.withAlpha((0.14 * 255).round()), borderRadius: BorderRadius.circular(AppRadius.sm)),
              padding: const EdgeInsets.all(9),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.62 * 255).round())),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentResumeCard extends StatelessWidget {
  const _RecentResumeCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha((0.06 * 255).round()), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.72 * 255).round())),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 10),
            Text('${(progress * 100).round()}% completed', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
