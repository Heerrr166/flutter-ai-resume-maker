import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_provider.dart';
import '../../providers/resume_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/stat_card.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);
    final resumes = ref.watch(resumeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        foregroundColor: Colors.white,
        title: const Text('ADMIN CONSOLE / ANALYTICS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
      body: resumes.when(
        data: (list) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Platform signals', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Aggregate data currently available to the admin client.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
              SizedBox(width: 220, child: StatCard(label: 'Users', value: '${users.total}', icon: Icons.people_outline, color: AppColors.accent)),
              SizedBox(width: 220, child: StatCard(label: 'Accessible resumes', value: '${list.length}', icon: Icons.description_outlined, color: AppColors.success)),
              SizedBox(width: 220, child: StatCard(label: 'Published', value: '${list.where((r) => r.status == 'published').length}', icon: Icons.public_outlined, color: AppColors.warning)),
            ]),
            const SizedBox(height: AppSpacing.lg),
            PremiumCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('Analytics endpoint limitation', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('The current backend exposes user-scoped resumes but no platform-wide timestamps, growth series, template aggregates, or audit log. Charts and activity feeds are intentionally unavailable until those endpoints exist.'),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load analytics')),
      ),
    );
  }
}
