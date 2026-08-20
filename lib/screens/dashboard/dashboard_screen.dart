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
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/user_navigation.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final resumeState = ref.watch(resumeNotifierProvider);
    final greetingName = user?.fullName.split(' ').first ?? 'there';
    final avatarLetter = user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const UserNavigationDrawer(currentRoute: AppRoutes.dashboard),
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
                        Builder(
                          builder: (innerContext) => Container(
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: theme.colorScheme.outline.withAlpha((0.15 * 255).round()),
                              ),
                            ),
                            child: IconButton(
                              tooltip: 'Open navigation menu',
                              icon: Icon(Icons.menu, color: theme.colorScheme.onSurface, size: 22),
                              onPressed: () => Scaffold.of(innerContext).openDrawer(),
                            ),
                          ),
                        ),
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
                    if (user?.role == 'admin') ...[
                      const SizedBox(height: AppSpacing.md),
                      PremiumCard(
                        padding: const EdgeInsets.all(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 600;
                            final content = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Admin Console',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Manage your platform, users, resumes, and system metrics.',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            );

                            final actionButton = ElevatedButton.icon(
                              onPressed: () => context.go(AppRoutes.adminOverview),
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Open Admin Console'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            );

                            if (isCompact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withAlpha(40),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: content),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: actionButton,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withAlpha(40),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: content),
                                const SizedBox(width: 16),
                                actionButton,
                              ],
                            );
                          },
                        ),
                      ),
                    ],
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
                    const SizedBox(height: AppSpacing.xl),
                    Text('Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.sm),
                    // KPI Row (responsive grid)
                    resumeState.when(
                      data: (resumes) {
                        final total = resumes.length;
                        final published = resumes.where((r) => r.status == 'published').length;
                        final drafts = total - published;
                        return LayoutBuilder(builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 800;
                          final children = [
                            StatCard(label: 'Resumes', value: '$total', icon: Icons.description_outlined),
                            StatCard(label: 'Published', value: '$published', icon: Icons.public, color: AppColors.success),
                            StatCard(label: 'Drafts', value: '$drafts', icon: Icons.edit, color: AppColors.warning),
                          ];
                          if (isWide) {
                            return Row(
                              children: children
                                  .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
                                  .toList(),
                            );
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: children
                                  .map((c) => Padding(padding: const EdgeInsets.only(right: 12), child: SizedBox(width: 200, child: c)))
                                  .toList(),
                            ),
                          );
                        });
                      },
                      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Workspace', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.sm),
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 620 ? 2 : 1;
                      final gap = AppSpacing.md;
                      final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
                      final actions = [
                        _QuickActionCard(color: theme.colorScheme.primary, icon: Icons.edit_note_outlined, title: 'Create Resume', subtitle: 'Start a new draft', onTap: _createResume),
                        _QuickActionCard(color: theme.colorScheme.secondary, icon: Icons.insights_outlined, title: 'Resume Intelligence', subtitle: 'Score and improve', onTap: () => context.push(AppRoutes.resume)),
                        _QuickActionCard(color: AppColors.success, icon: Icons.grid_view_outlined, title: 'Templates', subtitle: 'Choose a layout', onTap: () => context.push(AppRoutes.resume)),
                        _QuickActionCard(color: AppColors.warning, icon: Icons.folder_open_outlined, title: 'Library', subtitle: 'Browse all resumes', onTap: () => context.push(AppRoutes.resumeList)),
                      ];
                      return Wrap(spacing: gap, runSpacing: gap, children: actions.map((action) => SizedBox(width: itemWidth, height: 142, child: action)).toList());
                    }),
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
      bottomNavigationBar: const UserBottomNavigation(selectedIndex: 0),
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
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Container(
        constraints: const BoxConstraints(minHeight: 142),
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
          mainAxisSize: MainAxisSize.max,
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
