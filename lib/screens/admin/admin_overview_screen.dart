import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/admin_stats_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import 'widgets/admin_scaffold.dart';

class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overviewState = ref.watch(adminOverviewProvider);
    final data = overviewState.data;
    final stats = data.stats;

    return AdminScaffold(
      title: 'Platform Overview',
      currentRoute: AppRoutes.adminOverview,
      actions: [
        IconButton(
          tooltip: 'Refresh Overview',
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: () => ref.read(adminOverviewProvider.notifier).fetchOverview(),
        ),
      ],
      body: overviewState.isLoading && stats.totalUsers == 0
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(adminOverviewProvider.notifier).fetchOverview(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Page Subtitle
                  Text(
                    'Monitor users, platform resumes, and real-time database signals.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Real KPI Grid
                  _buildKpiGrid(stats, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // Management Shortcut Tiles
                  Text(
                    'Quick Management',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildQuickManagementRow(context, stats, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // Two-column layout for Recent Users and Recent Resumes
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 800;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildRecentUsersCard(context, data.recentUsers, isDark)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildRecentResumesCard(context, data.recentResumes, isDark)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildRecentUsersCard(context, data.recentUsers, isDark),
                          const SizedBox(height: 20),
                          _buildRecentResumesCard(context, data.recentResumes, isDark),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiGrid(AdminStats stats, bool isDark) {
    final kpis = [
      _AdminKpiTile(
        title: 'Total Users',
        value: '${stats.totalUsers}',
        subtitle: '${stats.regularUsers} regular accounts',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF6366F1),
        isDark: isDark,
      ),
      _AdminKpiTile(
        title: 'Platform Resumes',
        value: '${stats.totalResumes}',
        subtitle: '${stats.publishedResumes} published • ${stats.draftResumes} drafts',
        icon: Icons.description_rounded,
        color: const Color(0xFF10B981),
        isDark: isDark,
      ),
      _AdminKpiTile(
        title: 'Verified Accounts',
        value: '${stats.verifiedUsers}',
        subtitle: 'Email verified users',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF06B6D4),
        isDark: isDark,
      ),
      _AdminKpiTile(
        title: 'System Admins',
        value: '${stats.totalAdmins}',
        subtitle: 'Console access enabled',
        icon: Icons.shield_rounded,
        color: const Color(0xFFF59E0B),
        isDark: isDark,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : (constraints.maxWidth >= 540 ? 2 : 1);

        if (columns == 4) {
          return Row(
            children: kpis
                .map((kpi) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: kpi,
                      ),
                    ))
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 2 ? 2.2 : 2.6,
          children: kpis,
        );
      },
    );
  }

  Widget _buildQuickManagementRow(BuildContext context, AdminStats stats, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        final actions = [
          _ManagementCard(
            title: 'User Management',
            subtitle: '${stats.totalUsers} registered user accounts',
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF6366F1),
            route: AppRoutes.adminUsers,
            isDark: isDark,
          ),
          _ManagementCard(
            title: 'Resume Database',
            subtitle: '${stats.totalResumes} platform resumes stored',
            icon: Icons.folder_open_rounded,
            color: const Color(0xFF10B981),
            route: AppRoutes.adminResumes,
            isDark: isDark,
          ),
          _ManagementCard(
            title: 'System Analytics',
            subtitle: 'Aggregate database breakdown',
            icon: Icons.insights_rounded,
            color: const Color(0xFFF59E0B),
            route: AppRoutes.adminAnalytics,
            isDark: isDark,
          ),
        ];

        if (isWide) {
          return Row(
            children: actions
                .map((act) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: act,
                      ),
                    ))
                .toList(),
          );
        }

        return Column(
          children: actions
              .map((act) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: act,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildRecentUsersCard(BuildContext context, List<UserModel> users, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Users',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.adminUsers),
                child: const Text('View All Users →', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No users in database yet.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, _) => Divider(
                height: 16,
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                final isAdmin = user.role == 'admin';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: isAdmin
                          ? AppColors.adminPrimary.withAlpha(isDark ? 50 : 25)
                          : const Color(0xFF6366F1).withAlpha(isDark ? 50 : 25),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: isAdmin ? AppColors.adminPrimary : const Color(0xFF6366F1),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isAdmin) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.adminPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentResumesCard(BuildContext context, List<AdminResumeItem> resumes, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Platform Resumes',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.adminResumes),
                child: const Text('View All Resumes →', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (resumes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No platform resumes created yet.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resumes.length,
              separatorBuilder: (_, _) => Divider(
                height: 16,
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final resume = resumes[index];
                final isPublished = resume.status == 'published';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(isDark ? 50 : 25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Owner: ${resume.ownerName} • ${resume.template}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPublished
                            ? AppColors.success.withAlpha(isDark ? 50 : 25)
                            : AppColors.warning.withAlpha(isDark ? 50 : 25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPublished ? 'PUBLISHED' : 'DRAFT',
                        style: TextStyle(
                          color: isPublished ? AppColors.success : AppColors.warning,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AdminKpiTile extends StatelessWidget {
  const _AdminKpiTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 50 : 25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 25 : 6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 50 : 25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
