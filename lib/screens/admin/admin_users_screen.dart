import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/premium_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/form_dialog.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  String _roleFilter = 'any';

  void _confirmDelete(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete "${user.fullName}" (${user.email})? Their resumes will also be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final success = await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'User deleted' : 'Failed to delete user')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(adminUsersProvider);
    final currentUserId = ref.watch(authNotifierProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        foregroundColor: Colors.white,
        title: const Text('ADMIN CONSOLE / USERS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminUsersProvider.notifier).fetchPage(state.page),
        child: state.isLoading && state.users.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.users.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(state.error!, style: theme.textTheme.bodyLarge)),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Manage users', style: theme.textTheme.titleLarge),
                                Text('${state.total} total users', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // KPI row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  StatCard(label: 'Total users', value: '${state.total}', icon: Icons.people),
                                  const SizedBox(width: 12),
                                  StatCard(
                                    label: 'Admins',
                                    value: '${state.users.where((u) => u.role == 'admin').length}',
                                    icon: Icons.admin_panel_settings,
                                  ),
                                  const SizedBox(width: 12),
                                  StatCard(label: 'Verified', value: '${state.users.where((u) => u.isVerified).length}', icon: Icons.verified, color: theme.colorScheme.primary),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Filters
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name or email'),
                                    onChanged: (v) {
                                      setState(() => _searchQuery = v.trim().toLowerCase());
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                DropdownButton<String>(
                                  value: _roleFilter,
                                  items: const [
                                    DropdownMenuItem(value: 'any', child: Text('Any role')),
                                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                    DropdownMenuItem(value: 'user', child: Text('User')),
                                  ],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() => _roleFilter = v);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final filtered = state.users.where((u) {
                            if (_searchQuery.isNotEmpty) {
                              final q = _searchQuery;
                              if (!u.fullName.toLowerCase().contains(q) && !u.email.toLowerCase().contains(q)) return false;
                            }
                            if (_roleFilter != 'any' && u.role != _roleFilter) return false;
                            return true;
                          }).toList();

                          if (state.isLoading && filtered.isEmpty) return const Center(child: CircularProgressIndicator());
                          if (filtered.isEmpty) return const Center(child: Text('No users found'));

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final user = filtered[index];
                              final isSelf = user.id == currentUserId;
                              final isDeleting = state.deletingIds.contains(user.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    // show details dialog
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => FormDialog(
                                        title: 'User details',
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              CircleAvatar(radius: 28, child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?')),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(user.fullName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 4),
                                                  Text(user.email, style: theme.textTheme.bodySmall),
                                                ],
                                              )),
                                            ]),
                                            const SizedBox(height: 12),
                                            Text('Role: ${user.role}'),
                                            const SizedBox(height: 8),
                                            Text('Verified: ${user.isVerified ? 'Yes' : 'No'}'),
                                            const SizedBox(height: 12),
                                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: isSelf
                                                    ? null
                                                    : () {
                                                        Navigator.of(ctx).pop();
                                                        _confirmDelete(context, ref, user);
                                                      },
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                child: const Text('Delete user'),
                                              ),
                                            ])
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: PremiumCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: theme.colorScheme.primary.withAlpha((0.14 * 255).round()),
                                          child: Text(
                                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      user.fullName,
                                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (user.role == 'admin') ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme.primary.withAlpha((0.14 * 255).round()),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        'ADMIN',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          color: theme.colorScheme.primary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                user.email,
                                                style: theme.textTheme.bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        isDeleting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : IconButton(
                                                icon: const Icon(Icons.more_vert),
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (_) => Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            leading: const Icon(Icons.visibility),
                                                            title: const Text('View details'),
                                                            onTap: () {
                                                              Navigator.of(context).pop();
                                                              showDialog(
                                                                context: context,
                                                                builder: (ctx) => FormDialog(
                                                                  title: 'User details',
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text('Name: ${user.fullName}'),
                                                                      const SizedBox(height: 8),
                                                                      Text('Email: ${user.email}'),
                                                                      const SizedBox(height: 8),
                                                                      Text('Role: ${user.role}'),
                                                                      const SizedBox(height: 12),
                                                                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                                                                      ])
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                            title: const Text('Delete user'),
                                                            onTap: isSelf
                                                                ? null
                                                                : () {
                                                                    Navigator.of(context).pop();
                                                                    _confirmDelete(context, ref, user);
                                                                  },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: state.page > 1 && !state.isLoading
                                  ? () => ref.read(adminUsersProvider.notifier).fetchPage(state.page - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              label: const Text('Previous'),
                            ),
                            OutlinedButton.icon(
                              onPressed: state.page < state.totalPages && !state.isLoading
                                  ? () => ref.read(adminUsersProvider.notifier).fetchPage(state.page + 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              label: const Text('Next'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
