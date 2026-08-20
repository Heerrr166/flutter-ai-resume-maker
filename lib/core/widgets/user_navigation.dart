import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class UserNavigationDrawer extends ConsumerWidget {
  const UserNavigationDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final isAdmin = user?.role == 'admin';
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'AI Resume Maker';
    final email = user?.email.isNotEmpty == true ? user!.email : 'Build a resume that moves with you';
    final avatarLetter = user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'A';

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      avatarLetter,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
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
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _item(context, 'Home', Icons.home_outlined, AppRoutes.dashboard),
                  _item(context, 'Resume Builder', Icons.edit_note_outlined, AppRoutes.resume),
                  _item(context, 'Templates', Icons.grid_view_outlined, AppRoutes.resume),
                  _item(context, 'Resume Intelligence', Icons.insights_outlined, AppRoutes.resume),
                  _item(context, 'Library', Icons.folder_open_outlined, AppRoutes.resumeList),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _item(context, 'Profile', Icons.person_outline, AppRoutes.profile),
                  _item(context, 'Settings', Icons.settings_outlined, AppRoutes.settings),
                  if (isAdmin) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            'ADMINISTRATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: theme.colorScheme.onSurface.withAlpha(160),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _adminItem(context, 'Admin Console', Icons.admin_panel_settings_outlined, AppRoutes.adminOverview),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String label, IconData icon, String route) {
    final selected = currentRoute == route;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: selected,
        selectedTileColor: theme.colorScheme.primary.withAlpha(20),
        leading: Icon(
          icon,
          color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(190),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontSize: 14.5,
          ),
        ),
        trailing: selected
            ? Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.primary)
            : null,
        onTap: () {
          Navigator.of(context).pop();
          if (!selected) context.go(route);
        },
      ),
    );
  }

  Widget _adminItem(BuildContext context, String label, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withAlpha(90)),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: const Icon(
            Icons.shield,
            color: AppColors.accent,
            size: 20,
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.accent),
          onTap: () {
            Navigator.of(context).pop();
            context.go(route);
          },
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
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        final routes = [AppRoutes.dashboard, AppRoutes.profile, AppRoutes.settings];
        context.go(routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}