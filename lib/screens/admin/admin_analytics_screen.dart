import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/admin_stats_model.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import 'widgets/admin_scaffold.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overviewState = ref.watch(adminOverviewProvider);
    final stats = overviewState.data.stats;

    return AdminScaffold(
      title: 'Platform Analytics',
      currentRoute: AppRoutes.adminAnalytics,
      actions: [
        IconButton(
          tooltip: 'Refresh Analytics',
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
                  Text(
                    'Real-time database metrics and platform distribution breakdown.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Overview Metric Chips
                  _buildAnalyticsSummaryGrid(stats, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // Distribution Breakdown Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 750;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildUserDistributionCard(stats, isDark)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildResumeDistributionCard(stats, isDark)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildUserDistributionCard(stats, isDark),
                          const SizedBox(height: 20),
                          _buildResumeDistributionCard(stats, isDark),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // System Status Card
                  _buildSystemStatusCard(isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyticsSummaryGrid(AdminStats stats, bool isDark) {
    final chips = [
      _AnalyticsMetricChip(
        label: 'Total Users',
        value: '${stats.totalUsers}',
        color: const Color(0xFF6366F1),
        icon: Icons.people_rounded,
        isDark: isDark,
      ),
      _AnalyticsMetricChip(
        label: 'Total Resumes',
        value: '${stats.totalResumes}',
        color: const Color(0xFF10B981),
        icon: Icons.description_rounded,
        isDark: isDark,
      ),
      _AnalyticsMetricChip(
        label: 'Verified Ratio',
        value: stats.totalUsers > 0
            ? '${((stats.verifiedUsers / stats.totalUsers) * 100).round()}%'
            : '0%',
        color: const Color(0xFF06B6D4),
        icon: Icons.verified_rounded,
        isDark: isDark,
      ),
      _AnalyticsMetricChip(
        label: 'Publication Ratio',
        value: stats.totalResumes > 0
            ? '${((stats.publishedResumes / stats.totalResumes) * 100).round()}%'
            : '0%',
        color: const Color(0xFFF59E0B),
        icon: Icons.public_rounded,
        isDark: isDark,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 800 ? 4 : (constraints.maxWidth >= 480 ? 2 : 1);

        if (cols == 4) {
          return Row(
            children: chips
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: c,
                      ),
                    ))
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: chips,
        );
      },
    );
  }

  Widget _buildUserDistributionCard(AdminStats stats, bool isDark) {
    final total = stats.totalUsers > 0 ? stats.totalUsers : 1;
    final regularPct = stats.regularUsers / total;
    final adminPct = stats.totalAdmins / total;
    final verifiedPct = stats.verifiedUsers / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                'User Account Distribution',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildProgressIndicatorRow(
            label: 'Regular Users',
            valueText: '${stats.regularUsers} (${(regularPct * 100).round()}%)',
            percent: regularPct,
            color: const Color(0xFF6366F1),
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildProgressIndicatorRow(
            label: 'System Administrators',
            valueText: '${stats.totalAdmins} (${(adminPct * 100).round()}%)',
            percent: adminPct,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildProgressIndicatorRow(
            label: 'Verified Accounts',
            valueText: '${stats.verifiedUsers} (${(verifiedPct * 100).round()}%)',
            percent: verifiedPct,
            color: const Color(0xFF06B6D4),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildResumeDistributionCard(AdminStats stats, bool isDark) {
    final total = stats.totalResumes > 0 ? stats.totalResumes : 1;
    final publishedPct = stats.publishedResumes / total;
    final draftPct = stats.draftResumes / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Resume Status Distribution',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildProgressIndicatorRow(
            label: 'Published Resumes',
            valueText: '${stats.publishedResumes} (${(publishedPct * 100).round()}%)',
            percent: publishedPct,
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildProgressIndicatorRow(
            label: 'Draft Resumes',
            valueText: '${stats.draftResumes} (${(draftPct * 100).round()}%)',
            percent: draftPct,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildProgressIndicatorRow(
            label: 'Total Platform Resumes',
            valueText: '${stats.totalResumes} Documents',
            percent: stats.totalResumes > 0 ? 1.0 : 0.0,
            color: const Color(0xFF6366F1),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicatorRow({
    required String label,
    required String valueText,
    required double percent,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dns_rounded, color: Color(0xFF06B6D4), size: 20),
              const SizedBox(width: 8),
              Text(
                'Platform Infrastructure Status',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusItem('Database', 'MongoDB (ai_resume_maker)', 'CONNECTED', AppColors.success, isDark),
          const Divider(height: 16),
          _buildStatusItem('API Gateway', 'Node.js Express (Port 5000)', 'ACTIVE', AppColors.success, isDark),
          const Divider(height: 16),
          _buildStatusItem('Authentication Engine', 'JWT + Bcrypt Token Hashing', 'OPERATIONAL', AppColors.success, isDark),
          const Divider(height: 16),
          _buildStatusItem('AI Intelligence Engine', 'Google Gemini 2.0 Flash', 'CONFIGURED', const Color(0xFF6366F1), isDark),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, String description, String badge, Color badgeColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withAlpha(isDark ? 50 : 20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withAlpha(80)),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsMetricChip extends StatelessWidget {
  const _AnalyticsMetricChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 50 : 25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
