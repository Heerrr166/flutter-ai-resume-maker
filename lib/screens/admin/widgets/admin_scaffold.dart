import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class AdminScaffold extends ConsumerWidget {
  const AdminScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String currentRoute;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

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
        content: const Text('Are you sure you want to sign out of the Admin Console?'),
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
    final isOverview = currentRoute == AppRoutes.adminOverview;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          drawer: isDesktop
              ? null
              : _buildAdminDrawer(
                  context: context,
                  ref: ref,
                  theme: theme,
                  isDark: isDark,
                  user: user,
                ),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  leading: isOverview
                      ? Builder(
                          builder: (innerCtx) => IconButton(
                            icon: const Icon(Icons.menu_rounded),
                            tooltip: 'Menu',
                            onPressed: () => Scaffold.of(innerCtx).openDrawer(),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back to Overview',
                          onPressed: () => context.go(AppRoutes.adminOverview),
                        ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.4,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Exit to Dashboard',
                      icon: const Icon(Icons.home_outlined, size: 22),
                      onPressed: () => context.go(AppRoutes.dashboard),
                    ),
                    IconButton(
                      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        final next = isDark ? ThemeMode.light : ThemeMode.dark;
                        ref.read(themeModeProvider.notifier).setMode(next);
                      },
                    ),
                    ...?actions,
                    const SizedBox(width: 6),
                  ],
                ),
          body: isDesktop
              ? Row(
                  children: [
                    _buildDesktopSidebar(
                      context: context,
                      ref: ref,
                      theme: theme,
                      isDark: isDark,
                      user: user,
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _buildDesktopTopBar(
                            context: context,
                            ref: ref,
                            theme: theme,
                            isDark: isDark,
                            user: user,
                            isOverview: isOverview,
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                          ),
                          Expanded(child: body),
                        ],
                      ),
                    ),
                  ],
                )
              : body,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }

  Widget _buildDesktopTopBar({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required bool isDark,
    required dynamic user,
    required bool isOverview,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isOverview) ...[
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.adminOverview),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Back to Overview'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.adminPrimary.withAlpha(isDark ? 60 : 30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.adminPrimary.withAlpha(80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 12, color: AppColors.adminPrimary),
                    SizedBox(width: 4),
                    Text(
                      'ADMIN CONSOLE',
                      style: TextStyle(
                        color: AppColors.adminPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.exit_to_app_rounded, size: 16),
                label: const Text('Exit to Dashboard'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  size: 20,
                ),
                onPressed: () {
                  final next = isDark ? ThemeMode.light : ThemeMode.dark;
                  ref.read(themeModeProvider.notifier).setMode(next);
                },
              ),
              const SizedBox(width: 8),
              ...?actions,
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.adminPrimary,
                        child: Text(
                          (user?.fullName.isNotEmpty == true) ? user.fullName[0].toUpperCase() : 'A',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (user?.fullName.isNotEmpty == true) ? user.fullName : 'Admin',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required bool isDark,
    required dynamic user,
  }) {
    return Container(
      width: 250,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Branding Tile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Resume',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'ADMIN PANEL',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          letterSpacing: 1.1,
                          color: isDark ? AppColors.accent : AppColors.adminPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Admin Menu
          _sidebarSectionHeader(isDark, 'MANAGEMENT'),
          const SizedBox(height: 4),
          _sidebarItem(
            context: context,
            label: 'Overview',
            icon: Icons.dashboard_rounded,
            route: AppRoutes.adminOverview,
            isDark: isDark,
          ),
          _sidebarItem(
            context: context,
            label: 'Users',
            icon: Icons.people_alt_rounded,
            route: AppRoutes.adminUsers,
            isDark: isDark,
          ),
          _sidebarItem(
            context: context,
            label: 'Resumes',
            icon: Icons.description_rounded,
            route: AppRoutes.adminResumes,
            isDark: isDark,
          ),
          _sidebarItem(
            context: context,
            label: 'Analytics',
            icon: Icons.insights_rounded,
            route: AppRoutes.adminAnalytics,
            isDark: isDark,
          ),

          const SizedBox(height: 18),
          _sidebarSectionHeader(isDark, 'QUICK ESCAPE'),
          const SizedBox(height: 4),
          _sidebarItem(
            context: context,
            label: 'Return to Dashboard',
            icon: Icons.arrow_back_rounded,
            route: AppRoutes.dashboard,
            isDark: isDark,
          ),

          const Spacer(),

          // Logout Action Tile
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showLogoutDialog(context, ref),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required bool isDark,
    required dynamic user,
  }) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF312E81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Text(
                      (user?.fullName.isNotEmpty == true) ? user.fullName[0].toUpperCase() : 'A',
                      style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user?.fullName.isNotEmpty == true) ? user.fullName : 'Administrator',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN ROLE',
                            style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                children: [
                  _sidebarSectionHeader(isDark, 'ADMIN CONSOLE'),
                  _drawerItem(context, 'Overview', Icons.dashboard_rounded, AppRoutes.adminOverview, isDark),
                  _drawerItem(context, 'Users', Icons.people_alt_rounded, AppRoutes.adminUsers, isDark),
                  _drawerItem(context, 'Resumes', Icons.description_rounded, AppRoutes.adminResumes, isDark),
                  _drawerItem(context, 'Analytics', Icons.insights_rounded, AppRoutes.adminAnalytics, isDark),

                  const SizedBox(height: 12),
                  _sidebarSectionHeader(isDark, 'QUICK ACTIONS'),
                  _drawerItem(context, 'Return to Dashboard', Icons.arrow_back_rounded, AppRoutes.dashboard, isDark),
                ],
              ),
            ),

            // Sign Out
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withAlpha(isDark ? 50 : 25),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLogoutDialog(context, ref);
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarSectionHeader(bool isDark, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6, bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String route,
    required bool isDark,
  }) {
    final active = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (!active) context.go(route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? (isDark ? const Color(0xFF4338CA) : const Color(0xFFEEF2FF))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: active
                  ? Border.all(
                      color: isDark ? const Color(0xFF6366F1) : const Color(0xFFC7D2FE),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: active
                      ? (isDark ? Colors.white : const Color(0xFF4338CA))
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13.5,
                      color: active
                          ? (isDark ? Colors.white : const Color(0xFF4338CA))
                          : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String label, IconData icon, String route, bool isDark) {
    final active = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).pop();
            if (!active) context.go(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: active
                  ? (isDark ? const Color(0xFF4338CA) : const Color(0xFFEEF2FF))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: active
                      ? (isDark ? Colors.white : const Color(0xFF4338CA))
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                    color: active
                        ? (isDark ? Colors.white : const Color(0xFF4338CA))
                        : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
