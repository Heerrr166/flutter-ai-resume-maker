import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/premium_card.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(adminUsersProvider);
    final currentUserId = ref.watch(authNotifierProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — Users'),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${state.total} total users', style: theme.textTheme.bodyMedium),
                            Text('Page ${state.page} of ${state.totalPages}', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Expanded(
                        child: state.users.isEmpty
                            ? const Center(child: Text('No users found'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.users.length,
                                itemBuilder: (context, index) {
                                  final user = state.users[index];
                                  final isSelf = user.id == currentUserId;
                                  final isDeleting = state.deletingIds.contains(user.id);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
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
                                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                  onPressed: isSelf ? null : () => _confirmDelete(context, ref, user),
                                                  tooltip: isSelf ? 'You cannot delete your own account' : 'Delete user',
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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
