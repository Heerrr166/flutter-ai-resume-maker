import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/admin_provider.dart';
import '../../providers/resume_provider.dart';
import '../../routes/app_routes.dart';

class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(adminUsersProvider);
    final resumesState = ref.watch(resumeNotifierProvider);

    final resumeCount = resumesState.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        foregroundColor: Colors.white,
        title: const Text('ADMIN CONSOLE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Chip(
              avatar: Icon(Icons.verified_user_outlined, size: 16, color: Colors.white),
              label: Text('Administrator'),
              backgroundColor: AppColors.primary,
              labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final content = ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Platform overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Monitor the people and resumes moving through your workspace.', style: TextStyle(color: Colors.white.withAlpha(180))),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(builder: (context, cardConstraints) {
              final columns = cardConstraints.maxWidth >= 900 ? 4 : cardConstraints.maxWidth >= 560 ? 2 : 1;
              final gap = AppSpacing.md;
              final width = (cardConstraints.maxWidth - gap * (columns - 1)) / columns;
              final cards = [
                StatCard(label: 'Total users', value: '${usersState.total}', icon: Icons.people_outline, color: AppColors.accent),
                StatCard(label: 'Accessible resumes', value: '$resumeCount', icon: Icons.description_outlined, color: AppColors.success),
                StatCard(label: 'Visible admins', value: '${usersState.users.where((u) => u.role == 'admin').length}', icon: Icons.admin_panel_settings_outlined, color: AppColors.warning),
              ];
              return Wrap(spacing: gap, runSpacing: gap, children: cards.map((card) => SizedBox(width: width, height: 120, child: card)).toList());
            }),
            const SizedBox(height: AppSpacing.xl),
            Text('Manage', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.md),
            _AdminAction(title: 'Users', subtitle: '${usersState.total} registered accounts', icon: Icons.people_alt_outlined, onTap: () => context.go(AppRoutes.adminUsers)),
            const SizedBox(height: AppSpacing.sm),
            _AdminAction(title: 'Resumes', subtitle: '$resumeCount resumes currently accessible', icon: Icons.description_outlined, onTap: () => context.go(AppRoutes.adminResumes)),
            const SizedBox(height: AppSpacing.sm),
            _AdminAction(title: 'Analytics', subtitle: 'Review platform usage signals', icon: Icons.insights_outlined, onTap: () => context.go(AppRoutes.adminAnalytics)),
          ],
        );
        if (!wide) return content;
        return Row(children: [
          SizedBox(width: 230, child: _AdminSidebar()),
          const VerticalDivider(width: 1, color: Colors.white12),
          Expanded(child: content),
        ]);
      }),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF151B2D),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppSpacing.md),
          const Icon(Icons.shield_outlined, color: AppColors.accent, size: 36),
          const SizedBox(height: AppSpacing.sm),
          const Text('Resume Maker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xl),
          _AdminNavItem(label: 'Overview', icon: Icons.dashboard_outlined, active: true, onTap: () {}),
          _AdminNavItem(label: 'Users', icon: Icons.people_outline, onTap: () => context.go(AppRoutes.adminUsers)),
          _AdminNavItem(label: 'Resumes', icon: Icons.description_outlined, onTap: () => context.go(AppRoutes.adminResumes)),
          _AdminNavItem(label: 'Analytics', icon: Icons.insights_outlined, onTap: () => context.go(AppRoutes.adminAnalytics)),
        ]),
      );
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({required this.label, required this.icon, required this.onTap, this.active = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        onTap: onTap,
        leading: Icon(icon, color: active ? Colors.white : Colors.white60, size: 20),
        title: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        tileColor: active ? AppColors.primary.withAlpha(210) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF1B2236),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: CircleAvatar(backgroundColor: AppColors.accent.withAlpha(35), child: Icon(icon, color: AppColors.accent)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        ),
      );
}
