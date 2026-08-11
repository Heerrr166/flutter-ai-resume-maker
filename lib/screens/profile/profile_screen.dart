import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/premium_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(authNotifierProvider).user;
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PremiumTextField(
                  controller: nameCtrl,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  validator: Validators.validateName,
                ),
                const SizedBox(height: AppSpacing.md),
                PremiumTextField(
                  controller: phoneCtrl,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  validator: Validators.validatePhone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                Navigator.of(ctx).pop();

                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .updateProfile(fullName: name, phone: phone);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Profile updated successfully'
                            : 'Failed to update profile',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final avatarLetter =
        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'A';
    final email = user?.email ?? 'Not available';
    final phone = user?.phone ?? 'Not available';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              PremiumCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        avatarLetter,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user?.fullName ?? 'User',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withAlpha((0.7 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account details',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileDetailRow(
                        label: 'Full name', value: user?.fullName ?? 'Not available'),
                    const Divider(height: 32),
                    _ProfileDetailRow(label: 'Email', value: email),
                    const Divider(height: 32),
                    _ProfileDetailRow(label: 'Phone', value: phone),
                    const Divider(height: 32),
                    _ProfileDetailRow(
                        label: 'Role', value: user?.role.toUpperCase() ?? 'USER'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumButton(
                label: 'Edit profile',
                onPressed: () => _showEditProfileDialog(context, ref),
                icon: const Icon(Icons.edit_outlined),
                backgroundColor: theme.colorScheme.primary,
              ),
              if (user?.role == 'admin') ...[
                const SizedBox(height: AppSpacing.md),
                PremiumButton(
                  label: 'Admin Panel',
                  onPressed: () => context.push(AppRoutes.adminUsers),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  backgroundColor: theme.colorScheme.secondary,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              PremiumButton(
                label: 'Logout',
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: NavigationBar(
          selectedIndex: 1,
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

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
