import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/greeting_utils.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/score_ring.dart';
import '../../core/widgets/user_navigation.dart';
import '../../models/resume_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_progress_provider.dart';
import '../../providers/resume_provider.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (_searchQuery != query) {
      setState(() {
        _searchQuery = query;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _showNotificationsSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                theme: theme,
                isDark: isDark,
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.accent,
                title: 'AI Resume Intelligence Ready',
                subtitle: 'Generate tailored summaries and ATS bullet points directly in the editor.',
              ),
              const SizedBox(height: 8),
              _buildNotificationItem(
                theme: theme,
                isDark: isDark,
                icon: Icons.cloud_done_outlined,
                iconColor: AppColors.success,
                title: 'Cloud Auto-Save Active',
                subtitle: 'Your drafts are synchronized automatically in the background.',
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHigh : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? Colors.white10 : theme.colorScheme.outline.withAlpha(25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(isDark ? 50 : 30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createResume() async {
    await ref.read(resumeNotifierProvider.notifier).createResume('Untitled Resume');
    final newest = ref.read(resumeNotifierProvider).value?.last;
    if (!mounted || newest == null) return;
    context.push(AppRoutes.resumeEditorPath(newest.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).user;
    final resumeState = ref.watch(resumeNotifierProvider);
    final greetingText = GreetingUtils.getPersonalizedGreeting(user?.fullName);
    final avatarLetter = (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      drawer: const UserNavigationDrawer(currentRoute: AppRoutes.dashboard),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 960;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header Sliver
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Responsive Dashboard Header
                        _buildResponsiveHeader(
                          context: context,
                          theme: theme,
                          isDark: isDark,
                          isDesktop: isDesktop,
                          greetingText: greetingText,
                          avatarLetter: avatarLetter,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Admin Portal Quick Bar (Only for authenticated Admins)
                        if (user?.role == 'admin') ...[
                          _buildAdminConsoleQuickBar(theme, isDark),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Search Bar with debounced query & clear action
                        _buildSearchBar(theme, isDark),
                        const SizedBox(height: AppSpacing.lg),

                        // Overview KPI Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Quick Statistics Grid (Real Live Data)
                        _buildQuickStats(resumeState, isDesktop, isTablet, theme, isDark),
                        const SizedBox(height: AppSpacing.xl),

                        // Workspace Actions Header
                        Text(
                          'Workspace Actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Quick Action Cards
                        _buildWorkspaceActions(isDesktop, isTablet, theme, isDark),
                        const SizedBox(height: AppSpacing.xl),

                        // Active Resume Progress Hero Card
                        _buildResumeProgressHero(resumeState, theme, isDark),
                        const SizedBox(height: AppSpacing.xl),

                        // Recent Resumes Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Resumes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.push(AppRoutes.resumeList),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                    ),
                  ),
                ),

                // Recent Resumes Horizontal List / Empty State Sliver
                SliverToBoxAdapter(
                  child: _buildRecentResumesSection(
                    resumeState: resumeState,
                    searchQuery: _searchQuery,
                    theme: theme,
                    isDark: isDark,
                    isDesktop: isDesktop,
                  ),
                ),

                // AI Suggestions & Daily Tip Sliver
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        _buildSmartSuggestionsCard(theme, isDark),
                        const SizedBox(height: AppSpacing.md),
                        _buildDailyTipCard(theme, isDark),
                        SizedBox(
                          height: isDesktop
                              ? 40.0
                              : (88.0 + MediaQuery.of(context).padding.bottom),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const UserBottomNavigation(selectedIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createResume,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Create Resume',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildResponsiveHeader({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required bool isDesktop,
    required String greetingText,
    required String avatarLetter,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Drawer Menu Trigger
        Builder(
          builder: (innerContext) => Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Navigation Menu',
              icon: Icon(
                Icons.menu_rounded,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                size: 22,
              ),
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            ),
          ),
        ),

        // Greeting & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingText,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: isDesktop ? 22 : 18,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                'Your AI career studio & intelligence tools are ready.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withAlpha((0.65 * 255).round())
                      : theme.colorScheme.onSurface.withAlpha((0.65 * 255).round()),
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Desktop quick CTA
        if (isDesktop) ...[
          ElevatedButton.icon(
            onPressed: _createResume,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],

        // Notification Bell Icon
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white12 : theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
            ),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotificationsSheet,
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? Colors.white70 : theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        // User Avatar
        GestureDetector(
          onTap: () => context.go(AppRoutes.profile),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.accent : theme.colorScheme.primary,
                width: 1.8,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminConsoleQuickBar(ThemeData theme, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.adminPrimary.withAlpha(isDark ? 90 : 60),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.adminPrimary.withAlpha(isDark ? 30 : 15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.adminPrimary.withAlpha(isDark ? 60 : 30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.adminPrimary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Admin Console Access',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.adminPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.adminPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage users, review platform resumes, and view analytics.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.adminPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        icon: const Icon(Icons.shield_outlined, size: 16),
                        label: const Text('Open Console'),
                        onPressed: () => context.go(AppRoutes.adminOverview),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.adminPrimary.withAlpha(isDark ? 60 : 30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppColors.adminPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Admin Console Access',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppColors.adminPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.adminPrimary,
                                  borderRadius: BorderRadius.circular(4),
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
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage users, review platform resumes, and view analytics.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminPrimary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                      onPressed: () => context.go(AppRoutes.adminOverview),
                      child: const Text('Open Console'),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(20)
              : theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: 14.5,
          color: isDark ? Colors.white : AppColors.nearBlack,
        ),
        decoration: InputDecoration(
          hintText: 'Search resumes by title, role, or keywords...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.accent : theme.colorScheme.primary,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    AsyncValue<List<ResumeModel>> resumeState,
    bool isDesktop,
    bool isTablet,
    ThemeData theme,
    bool isDark,
  ) {
    return resumeState.when(
      data: (resumes) {
        final total = resumes.length;
        final published = resumes.where((r) => r.status == 'published').length;
        final drafts = total - published;

        // Calculate average completeness
        var totalPercent = 0.0;
        for (final r in resumes) {
          final p = ref.watch(resumeProgressProvider(r));
          totalPercent += p.percent;
        }
        final avgPercent = total > 0 ? (totalPercent / total).round() : 0;

        final statCards = [
          _StatTile(
            label: 'Total Resumes',
            value: '$total',
            icon: Icons.description_outlined,
            color: theme.colorScheme.primary,
            isDark: isDark,
          ),
          _StatTile(
            label: 'Published',
            value: '$published',
            icon: Icons.verified_outlined,
            color: AppColors.success,
            isDark: isDark,
          ),
          _StatTile(
            label: 'Drafts',
            value: '$drafts',
            icon: Icons.edit_note_rounded,
            color: AppColors.warning,
            isDark: isDark,
          ),
          _StatTile(
            label: 'Avg Quality',
            value: '$avgPercent%',
            icon: Icons.auto_awesome_rounded,
            color: AppColors.accent,
            isDark: isDark,
          ),
        ];

        if (isDesktop) {
          return Row(
            children: statCards
                .map((card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: card,
                      ),
                    ))
                .toList(),
          );
        }

        // 2-column layout for tablet and mobile
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isTablet ? 2.4 : 1.75,
          children: statCards,
        );
      },
      loading: () => Container(
        height: 100,
        alignment: Alignment.center,
        child: const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildWorkspaceActions(
    bool isDesktop,
    bool isTablet,
    ThemeData theme,
    bool isDark,
  ) {
    final actions = [
      _WorkspaceActionCard(
        title: 'Create Resume',
        subtitle: 'Start a new AI-guided draft',
        icon: Icons.add_circle_outline_rounded,
        color: theme.colorScheme.primary,
        isDark: isDark,
        onTap: _createResume,
      ),
      _WorkspaceActionCard(
        title: 'Resume Intelligence',
        subtitle: 'Score & optimize keywords',
        icon: Icons.auto_awesome_rounded,
        color: AppColors.accent,
        isDark: isDark,
        onTap: () => context.push(AppRoutes.resume),
      ),
      _WorkspaceActionCard(
        title: 'ATS Templates',
        subtitle: 'Choose premium designs',
        icon: Icons.grid_view_rounded,
        color: AppColors.success,
        isDark: isDark,
        onTap: () => context.push(AppRoutes.resume),
      ),
      _WorkspaceActionCard(
        title: 'Resume Library',
        subtitle: 'Manage & export all resumes',
        icon: Icons.folder_open_rounded,
        color: AppColors.warning,
        isDark: isDark,
        onTap: () => context.push(AppRoutes.resumeList),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: actions
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: isTablet ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isTablet ? 1.4 : 1.2,
      children: actions,
    );
  }

  Widget _buildResumeProgressHero(
    AsyncValue<List<ResumeModel>> resumeState,
    ThemeData theme,
    bool isDark,
  ) {
    return resumeState.when(
      data: (resumes) {
        if (resumes.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDark ? Colors.white12 : theme.colorScheme.outline.withAlpha(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 35 : 10),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 50 : 20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.post_add_rounded,
                    color: isDark ? AppColors.accent : theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to build your first resume?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use AI bullet generation and ATS templates to land interviews.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _createResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text('Start Now', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        }

        final latest = resumes.first;
        final progress = ref.watch(resumeProgressProvider(latest));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF1E293B)]
                  : [AppColors.primary, const Color(0xFF2E3D8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(isDark ? 40 : 25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Active Resume Progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      latest.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${progress.percent}% overall completion • ATS quality ready',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.resumeEditorPath(latest.id)),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Continue Editing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ScoreRing(
                    value: progress.percent.toDouble(),
                    size: 82,
                    strokeWidth: 8,
                    valueColor: Colors.white,
                    trackColor: Colors.white24,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 140,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentResumesSection({
    required AsyncValue<List<ResumeModel>> resumeState,
    required String searchQuery,
    required ThemeData theme,
    required bool isDark,
    required bool isDesktop,
  }) {
    return resumeState.when(
      data: (resumes) {
        final filtered = searchQuery.isEmpty
            ? resumes
            : resumes.where((r) => r.title.toLowerCase().contains(searchQuery)).toList();

        if (filtered.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20),
            child: EmptyState(
              icon: searchQuery.isEmpty ? Icons.description_outlined : Icons.search_off_rounded,
              title: searchQuery.isEmpty ? 'No resumes created yet' : 'No resumes matching "$searchQuery"',
              subtitle: searchQuery.isEmpty
                  ? 'Tap Create Resume to build your first ATS-friendly resume.'
                  : 'Try searching with different keywords.',
              compact: true,
            ),
          );
        }

        final recent = filtered.take(6).toList();

        return SizedBox(
          height: 206,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final resume = recent[index];
              final progress = ref.watch(resumeProgressProvider(resume));

              return _RecentResumeItemCard(
                resume: resume,
                progressPercent: progress.percent.toDouble(),
                isDark: isDark,
                onTap: () => context.push(AppRoutes.resumeEditorPath(resume.id)),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: 120,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSmartSuggestionsCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white12 : theme.colorScheme.outline.withAlpha(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(isDark ? 50 : 25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Career Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push(AppRoutes.resume),
                child: const Text(
                  'Explore Tools →',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Open any resume in the builder to utilize AI-powered professional summary generation, action-verb suggestions, and keyword match analysis.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white12 : theme.colorScheme.outline.withAlpha(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Career Tip',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quantify your accomplishments using metrics (e.g. "Increased sales by 30%") to pass automated ATS screening filters effectively.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(isDark ? 50 : 25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.warning,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact, responsive Stat Tile widget for dashboard metrics
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white10 : theme.colorScheme.outline.withAlpha(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 50 : 20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: isDark ? Colors.white : AppColors.nearBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A clean, tactile Workspace Action Card widget
class _WorkspaceActionCard extends StatelessWidget {
  const _WorkspaceActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? Colors.white10 : theme.colorScheme.outline.withAlpha(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 25 : 6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 50 : 20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A modern horizontal card representing a single recent resume
class _RecentResumeItemCard extends StatelessWidget {
  const _RecentResumeItemCard({
    required this.resume,
    required this.progressPercent,
    required this.isDark,
    required this.onTap,
  });

  final ResumeModel resume;
  final double progressPercent;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPublished = resume.status == 'published';

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 14, bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDark ? Colors.white12 : theme.colorScheme.outline.withAlpha(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 35 : 8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(isDark ? 50 : 20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: isDark ? AppColors.accent : theme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPublished
                            ? AppColors.success.withAlpha(isDark ? 50 : 25)
                            : AppColors.warning.withAlpha(isDark ? 50 : 25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPublished ? 'PUBLISHED' : 'DRAFT',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isPublished ? AppColors.success : AppColors.warning,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Template: ${resume.template.isNotEmpty ? resume.template : "modern"}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completion',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${progressPercent.round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.accent : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progressPercent / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accent : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
