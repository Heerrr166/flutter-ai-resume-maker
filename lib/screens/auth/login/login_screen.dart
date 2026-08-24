import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _normalFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  // Distinct controllers and focus nodes for Normal User vs Administrator
  // to ensure credentials never cross-contaminate or leak between modes.
  final TextEditingController _normalEmailController = TextEditingController();
  final TextEditingController _normalPasswordController = TextEditingController();
  final FocusNode _normalEmailFocus = FocusNode();
  final FocusNode _normalPasswordFocus = FocusNode();

  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final FocusNode _adminEmailFocus = FocusNode();
  final FocusNode _adminPasswordFocus = FocusNode();

  bool _showPassword = false;
  bool _isAdminMode = false;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _normalEmailController.dispose();
    _normalPasswordController.dispose();
    _normalEmailFocus.dispose();
    _normalPasswordFocus.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _adminEmailFocus.dispose();
    _adminPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final activeFormKey = _isAdminMode ? _adminFormKey : _normalFormKey;
    final email = _isAdminMode ? _adminEmailController.text.trim() : _normalEmailController.text.trim();
    final password = _isAdminMode ? _adminPasswordController.text.trim() : _normalPasswordController.text.trim();

    if (activeFormKey.currentState?.validate() ?? false) {
      final success = await ref.read(authNotifierProvider.notifier).login(
            email: email,
            password: password,
          );
      if (success) {
        if (mounted) {
          final user = ref.read(authNotifierProvider).user;
          if (_isAdminMode) {
            if (user?.role == 'admin') {
              context.go(AppRoutes.adminOverview);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      Icon(Icons.gpp_bad_outlined, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Authenticated successfully, but this account does not have administrator privileges.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            context.go(AppRoutes.dashboard);
          }
        }
      } else {
        final error = ref.read(authNotifierProvider).errorMessage;
        if (mounted && error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(error)),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  void _onAdminCtaPressed() {
    setState(() {
      _isAdminMode = true;
      // If normal email was already typed and admin email is empty, carry forward the email identifier only
      if (_normalEmailController.text.trim().isNotEmpty && _adminEmailController.text.trim().isEmpty) {
        _adminEmailController.text = _normalEmailController.text.trim();
      }
    });

    if (_adminEmailController.text.trim().isNotEmpty && _adminPasswordController.text.trim().isNotEmpty) {
      _handleLogin();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: AppColors.adminPrimary,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admin Mode Enabled. Enter your administrator credentials to sign in.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
      if (_adminEmailController.text.trim().isEmpty) {
        _adminEmailFocus.requestFocus();
      } else {
        _adminPasswordFocus.requestFocus();
      }
    }
  }

  void _cancelAdminMode() {
    setState(() {
      _isAdminMode = false;
      // Always clear sensitive admin password on cancellation so it never leaks
      _adminPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Subtle ambient glow background decoration
          Positioned(
            top: -100,
            right: -80,
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.45 + (0.2 * _ambientController.value),
                  child: Transform.scale(
                    scale: 0.9 + (0.15 * _ambientController.value),
                    child: Container(
                      width: 380,
                      height: 380,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (isDark ? AppColors.adminGlow : theme.colorScheme.primary)
                                .withAlpha((0.25 * 255).round()),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.4 + (0.2 * (1.0 - _ambientController.value)),
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withAlpha((0.2 * 255).round()),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Scrollable Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Branding Hero Header
                      _buildHeroHeader(theme, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Card Container
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha((0.08 * 255).round())
                                : theme.colorScheme.outline.withAlpha((0.18 * 255).round()),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withAlpha((0.5 * 255).round())
                                  : AppColors.shadow.withAlpha((0.1 * 255).round()),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: _isAdminMode
                            ? _buildAdminForm(theme, isDark, isLoading)
                            : _buildNormalForm(theme, isDark, isLoading),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalForm(ThemeData theme, bool isDark, bool isLoading) {
    return AutofillGroup(
      key: const ValueKey('normal_user_auth_group'),
      child: Form(
        key: _normalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to access your resume workspace & AI tools',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? Colors.white.withAlpha((0.68 * 255).round())
                    : theme.colorScheme.onSurface.withAlpha((0.68 * 255).round()),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Email Field
            PremiumTextField(
              controller: _normalEmailController,
              label: 'Email Address',
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              autofillHints: const [AutofillHints.email, AutofillHints.username],
              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),

            // Password Field
            PremiumTextField(
              controller: _normalPasswordController,
              label: 'Password',
              hintText: 'Enter your password',
              obscureText: !_showPassword,
              validator: Validators.validatePassword,
              autofillHints: const [AutofillHints.password],
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withAlpha((0.65 * 255).round()),
                ),
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            const SizedBox(height: 6),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.primary,
                ),
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? AppColors.accent : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Primary Action Button
            PremiumButton(
              label: 'Sign In',
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              onPressed: _handleLogin,
              isLoading: isLoading,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withAlpha((0.9 * 255).round()),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Sign Up Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t have an account? ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withAlpha((0.7 * 255).round())
                        : theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  onPressed: () => context.go(AppRoutes.signup),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accent : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // OR Divider
            _buildOrDivider(theme, isDark),
            const SizedBox(height: AppSpacing.lg),

            // Redesigned ADMIN ACCESS Component
            _buildAdminAccessSection(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminForm(ThemeData theme, bool isDark, bool isLoading) {
    return AutofillGroup(
      key: const ValueKey('admin_auth_group'),
      child: Form(
        key: _adminFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Admin Portal',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Authenticate with administrator credentials',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? Colors.white.withAlpha((0.68 * 255).round())
                    : theme.colorScheme.onSurface.withAlpha((0.68 * 255).round()),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Admin Email Field
            PremiumTextField(
              controller: _adminEmailController,
              label: 'Admin Email',
              hintText: 'admin@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              autofillHints: const [AutofillHints.email, AutofillHints.username],
              prefixIcon: const Icon(Icons.shield_outlined, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),

            // Admin Password Field
            PremiumTextField(
              controller: _adminPasswordController,
              label: 'Admin Password',
              hintText: 'Enter admin password',
              obscureText: !_showPassword,
              validator: Validators.validatePassword,
              autofillHints: const [AutofillHints.password],
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withAlpha((0.65 * 255).round()),
                ),
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Sign In as Admin Button
            PremiumButton(
              label: 'Sign In as Administrator',
              icon: const Icon(Icons.shield_rounded, size: 18),
              onPressed: _handleLogin,
              isLoading: isLoading,
              gradient: const LinearGradient(
                colors: [AppColors.adminPrimary, AppColors.adminSecondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Admin active status banner & cancel action
            _AdminActiveStateBanner(
              onCancel: _cancelAdminMode,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrDivider(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark
                ? Colors.white.withAlpha((0.1 * 255).round())
                : theme.colorScheme.outline.withAlpha((0.16 * 255).round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark
                  ? Colors.white.withAlpha((0.45 * 255).round())
                  : theme.colorScheme.onSurface.withAlpha((0.45 * 255).round()),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark
                ? Colors.white.withAlpha((0.1 * 255).round())
                : theme.colorScheme.outline.withAlpha((0.16 * 255).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha((0.35 * 255).round()),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 26,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Resume Maker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Intelligent Career Studio',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.accent : theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminAccessSection(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceHigh.withAlpha((0.6 * 255).round())
            : const Color(0xFFF6F8FD),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha((0.08 * 255).round()) : theme.colorScheme.outline.withAlpha((0.18 * 255).round()),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withAlpha((0.75 * 255).round()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN ACCESS',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: isDark ? Colors.white70 : theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Manage users, resumes & platform administration',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withAlpha((0.68 * 255).round())
                            : theme.colorScheme.onSurface.withAlpha((0.68 * 255).round()),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AdminCtaButton(
            onPressed: _onAdminCtaPressed,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// A dedicated, premium Admin CTA button designed to look significantly
/// more elevated than standard buttons with subtle gradient accents,
/// shield branding, hover/pressed state, and forward arrow.
class _AdminCtaButton extends StatefulWidget {
  const _AdminCtaButton({
    required this.onPressed,
    required this.isDark,
  });

  final VoidCallback onPressed;
  final bool isDark;

  @override
  State<_AdminCtaButton> createState() => _AdminCtaButtonState();
}

class _AdminCtaButtonState extends State<_AdminCtaButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.985 : (_isHovered ? 1.01 : 1.0),
            _isPressed ? 0.985 : (_isHovered ? 1.01 : 1.0),
            1.0,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? (_isHovered
                      ? [const Color(0xFF312E81), const Color(0xFF3730A3)]
                      : [const Color(0xFF1E1B4B), const Color(0xFF312E81)])
                  : (_isHovered
                      ? [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)]
                      : [Colors.white, const Color(0xFFEEF2FF)]),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _isHovered
                  ? AppColors.adminPrimary
                  : (isDark ? AppColors.adminGlow.withAlpha((0.35 * 255).round()) : AppColors.adminPrimary.withAlpha((0.4 * 255).round())),
              width: _isHovered ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.adminPrimary.withAlpha((_isHovered ? 0.25 : 0.1) * 255 ~/ 1),
                blurRadius: _isHovered ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.adminGlow : AppColors.adminPrimary).withAlpha((0.15 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: isDark ? AppColors.adminGlow : AppColors.adminPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Login as Admin',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.adminPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                transform: Matrix4.translationValues(_isHovered ? 3.0 : 0.0, 0.0, 0.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: isDark ? AppColors.adminGlow : AppColors.adminPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A visually rich active banner shown when Admin Mode is enabled.
class _AdminActiveStateBanner extends StatelessWidget {
  const _AdminActiveStateBanner({
    required this.onCancel,
    required this.isDark,
  });

  final VoidCallback onCancel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withAlpha((0.35 * 255).round()) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: (isDark ? AppColors.adminGlow : AppColors.adminPrimary).withAlpha((0.35 * 255).round()),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.adminPrimary.withAlpha((0.2 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 17,
              color: AppColors.adminPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin mode enabled',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adminPrimary,
                  ),
                ),
                Text(
                  'Ready to sign in to Admin Console',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : AppColors.nearBlack.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              foregroundColor: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: onCancel,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close_rounded, size: 15),
                SizedBox(width: 4),
                Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
