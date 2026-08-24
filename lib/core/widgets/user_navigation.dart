import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class UserNavigationDrawer extends ConsumerWidget {
  const UserNavigationDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out of AI Resume Maker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).user;
    final isAdmin = user?.role == 'admin';
    final name = (user?.fullName.isNotEmpty == true) ? user!.fullName : 'AI Resume Maker';
    final email = (user?.email.isNotEmpty == true) ? user!.email : 'career@studio.app';
    final avatarLetter = (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : 'A';

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                      : [AppColors.primary, const Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(80), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Text(
                        avatarLetter,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAdmin) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.adminPrimary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                children: [
                  _sectionHeader(theme, isDark, 'WORKSPACE'),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    route: AppRoutes.dashboard,
                  ),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Resume Builder',
                    icon: Icons.edit_note_outlined,
                    activeIcon: Icons.edit_note_rounded,
                    route: AppRoutes.resume,
                  ),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Templates',
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    route: AppRoutes.resume,
                  ),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Resume Intelligence',
                    icon: Icons.auto_awesome_outlined,
                    activeIcon: Icons.auto_awesome_rounded,
                    route: AppRoutes.resume,
                  ),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Library & Resumes',
                    icon: Icons.folder_open_outlined,
                    activeIcon: Icons.folder_rounded,
                    route: AppRoutes.resumeList,
                  ),

                  const SizedBox(height: 12),
                  _sectionHeader(theme, isDark, 'ACCOUNT & SETTINGS'),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    route: AppRoutes.profile,
                  ),
                  _item(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    route: AppRoutes.settings,
                  ),

                  if (isAdmin) ...[
                    const SizedBox(height: 12),
                    _sectionHeader(theme, isDark, 'ADMINISTRATION'),
                    _adminItem(
                      context: context,
                      theme: theme,
                      isDark: isDark,
                      label: 'Admin Console',
                      icon: Icons.admin_panel_settings_rounded,
                      route: AppRoutes.adminOverview,
                    ),
                  ],
                ],
              ),
            ),

            // Logout & Version Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : theme.colorScheme.outline.withAlpha((0.15 * 255).round()),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showLogoutDialog(context, ref),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              size: 19,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'v1.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, bool isDark, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDark ? Colors.white54 : theme.colorScheme.onSurface.withAlpha(140),
        ),
      ),
    );
  }

  Widget _item({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required String route,
  }) {
    final selected = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop();
            if (!selected) context.go(route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark
                      ? AppColors.accent.withAlpha(40)
                      : theme.colorScheme.primary.withAlpha(24))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(
                      color: isDark
                          ? AppColors.accent.withAlpha(80)
                          : theme.colorScheme.primary.withAlpha(50),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: selected
                      ? (isDark ? AppColors.accent : theme.colorScheme.primary)
                      : (isDark ? Colors.white70 : theme.colorScheme.onSurface.withAlpha(200)),
                  size: 21,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? (isDark ? Colors.white : theme.colorScheme.primary)
                          : (isDark ? Colors.white.withAlpha(220) : theme.colorScheme.onSurface),
                      fontSize: 14,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark ? AppColors.accent : theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminItem({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required String label,
    required IconData icon,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop();
            context.go(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.adminPrimary.withAlpha(isDark ? 80 : 60),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: AppColors.adminPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.adminPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.adminPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserBottomNavigation extends StatelessWidget {
  const UserBottomNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(20)
                : theme.colorScheme.outline.withAlpha((0.15 * 255).round()),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        height: 62,
        elevation: 0,
        backgroundColor: Colors.transparent,
        onDestinationSelected: (index) {
          final routes = [AppRoutes.dashboard, AppRoutes.profile, AppRoutes.settings];
          context.go(routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}