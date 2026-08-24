import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/admin_stats_model.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import 'widgets/admin_scaffold.dart';

class AdminResumesScreen extends ConsumerStatefulWidget {
  const AdminResumesScreen({super.key});

  @override
  ConsumerState<AdminResumesScreen> createState() => _AdminResumesScreenState();
}

class _AdminResumesScreenState extends ConsumerState<AdminResumesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(adminResumesProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    ref.read(adminResumesProvider.notifier).setSearch(value);
  }

  void _confirmDeleteResume(BuildContext context, AdminResumeItem resume, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Delete Platform Resume'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${resume.title}" created by ${resume.ownerName}? This action cannot be undone.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(adminResumesProvider.notifier).deleteResume(resume.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Resume deleted successfully' : 'Failed to delete resume'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete Resume'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resumesState = ref.watch(adminResumesProvider);

    return AdminScaffold(
      title: 'Resume Database',
      currentRoute: AppRoutes.adminResumes,
      actions: [
        IconButton(
          tooltip: 'Refresh Resumes',
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: () => ref.read(adminResumesProvider.notifier).fetchPage(resumesState.page),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminResumesProvider.notifier).fetchPage(resumesState.page),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Search and Status Filters
            _buildSearchAndFilterCard(resumesState, isDark),
            const SizedBox(height: AppSpacing.lg),

            // Resume Count & List Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${resumesState.total} Platform Resumes Found',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (resumesState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Resumes List or Empty State
            if (resumesState.isLoading && resumesState.resumes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (resumesState.resumes.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.folder_off_rounded, size: 48, color: isDark ? Colors.white38 : Colors.black26),
                    const SizedBox(height: 12),
                    Text(
                      'No resumes found matching your search',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try changing the status filter or search keyword.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: resumesState.resumes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final resume = resumesState.resumes[index];
                  final isDeleting = resumesState.deletingIds.contains(resume.id);
                  final isPublished = resume.status == 'published';

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
                          color: Colors.black.withAlpha(isDark ? 20 : 5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(isDark ? 50 : 25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: Color(0xFF10B981),
                            size: 22,
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
                                      resume.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPublished
                                          ? AppColors.success.withAlpha(isDark ? 50 : 25)
                                          : AppColors.warning.withAlpha(isDark ? 50 : 25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isPublished ? 'PUBLISHED' : 'DRAFT',
                                      style: TextStyle(
                                        color: isPublished ? AppColors.success : AppColors.warning,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Owner: ${resume.ownerName} (${resume.ownerEmail.isNotEmpty ? resume.ownerEmail : "No email"}) • Template: ${resume.template} • Updated: ${resume.updatedAt.isNotEmpty ? resume.updatedAt.split('T').first : "Recently"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Open in Editor',
                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                          color: isDark ? AppColors.accent : const Color(0xFF6366F1),
                          onPressed: () => context.push(AppRoutes.resumeEditorPath(resume.id)),
                        ),
                        isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                tooltip: 'Delete Resume',
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                color: AppColors.error,
                                onPressed: () => _confirmDeleteResume(context, resume, isDark),
                              ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: AppSpacing.lg),

            // Pagination Controls
            _buildPaginationBar(resumesState, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterCard(AdminResumesState state, bool isDark) {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final searchField = TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmitted,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Search resumes by title or template...',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 13.5,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchSubmitted('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );

          final filterDropdown = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.statusFilter,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'published', child: Text('Published Only')),
                  DropdownMenuItem(value: 'draft', child: Text('Drafts Only')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(adminResumesProvider.notifier).setStatus(val);
                  }
                },
              ),
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                filterDropdown,
              ],
            );
          }

          return Column(
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Status: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  filterDropdown,
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaginationBar(AdminResumesState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${state.page} of ${state.totalPages}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: state.page > 1 && !state.isLoading
                    ? () => ref.read(adminResumesProvider.notifier).fetchPage(state.page - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 18),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: state.page < state.totalPages && !state.isLoading
                    ? () => ref.read(adminResumesProvider.notifier).fetchPage(state.page + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 18),
                label: const Text('Next'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
