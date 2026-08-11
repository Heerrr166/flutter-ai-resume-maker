import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/widgets/premium_card.dart';
import '../../providers/app_providers.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final weeklySummaryEnabled = ref.watch(weeklySummaryEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              _SettingsSection(
                title: 'Preferences',
                children: [
                  _SettingsSwitchTile(
                    label: 'Dark mode',
                    subtitle: 'Use the premium dark theme',
                    icon: Icons.dark_mode_outlined,
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).setMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  _SettingsSwitchTile(
                    label: 'Notifications',
                    subtitle: 'Get resume reminders and tips',
                    icon: Icons.notifications_outlined,
                    value: notificationsEnabled,
                    onChanged: (value) {
                      ref.read(notificationsEnabledProvider.notifier).set(value);
                    },
                  ),
                  _SettingsSwitchTile(
                    label: 'Weekly summary',
                    subtitle: 'Receive a weekly progress report',
                    icon: Icons.calendar_month_outlined,
                    value: weeklySummaryEnabled,
                    onChanged: (value) {
                      ref.read(weeklySummaryEnabledProvider.notifier).set(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(
                title: 'Support',
                children: [
                  _SettingsLinkTile(
                    title: 'Account',
                    subtitle: 'Manage your account settings',
                    icon: Icons.person_outline,
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                  _SettingsLinkTile(
                    title: 'Privacy policy',
                    subtitle: 'Read our privacy commitments',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => _showInfoDialog(
                      context,
                      'Privacy Policy',
                      'AI Resume Maker takes your personal data privacy seriously. All data transmitted between your device and our servers is encrypted over SSL/TLS. We do not sell or share your personal resume details with third parties. Some AI writing/analysis features send only the minimum necessary resume content to Google\'s Gemini API to generate a result; when that provider is unavailable, those features fall back to on-device/local processing automatically.',
                    ),
                  ),
                  _SettingsLinkTile(
                    title: 'Terms of service',
                    subtitle: 'View app terms and conditions',
                    icon: Icons.article_outlined,
                    onTap: () => _showInfoDialog(
                      context,
                      'Terms of Service',
                      'By using AI Resume Maker, you agree to generate truthful and professional content. The app and its AI/resume intelligence suggestions are provided to assist job applicants in creating ATS-compliant resumes and never invent facts you did not provide.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(
                title: 'About',
                children: [
                  _SettingsLinkTile(
                    title: 'App version',
                    subtitle: '1.0.0+1',
                    icon: Icons.info_outline,
                    trailing: const Text('Latest',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () => _showInfoDialog(
                      context,
                      'About AI Resume Maker',
                      'AI Resume Maker v1.0.0+1\n\nBuilt with Flutter & a Node.js/Express backend, with hybrid AI (Gemini + a local resume intelligence engine). Features AI-assisted writing, job-match analysis, resume tailoring, ATS score guidance, and instant draft auto-saving.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: NavigationBar(
          selectedIndex: 2,
          onDestinationSelected: (index) {
            if (index == 0) {
              context.go(AppRoutes.dashboard);
            } else if (index == 1) {
              context.go(AppRoutes.profile);
            } else if (index == 2) {
              context.go(AppRoutes.settings);
            }
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          decoration: BoxDecoration(
              color: theme.colorScheme.primary
                  .withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(label,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary),
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
            color: theme.colorScheme.secondary
                .withAlpha((0.14 * 255).round()),
            borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: theme.colorScheme.secondary),
      ),
      title: Text(title,
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: trailing ?? const Icon(Icons.chevron_right_outlined),
      onTap: onTap,
    );
  }
}
