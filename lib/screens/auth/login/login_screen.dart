import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isAdminMode = false;
  late final AnimationController _shapeController;

  @override
  void initState() {
    super.initState();
    _shapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shapeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authNotifierProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (success) {
        if (mounted) {
          final user = ref.read(authNotifierProvider).user;
          if (_isAdminMode) {
            if (user?.role == 'admin') {
              context.go(AppRoutes.adminOverview);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account is not an administrator.')),
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
            SnackBar(content: Text(error)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: -48,
            child: AnimatedBuilder(
              animation: _shapeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 12 * _shapeController.value),
                  child: child,
                );
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.14 * 255).round()),
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 920 : double.infinity),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'app-logo',
                              child: Material(
                                color: Colors.white,
                                elevation: 8,
                                shape: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Icon(Icons.work_outline, size: 28, color: theme.colorScheme.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AI Resume Maker', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Premium career builder', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SectionHeader(title: 'Welcome Back', subtitle: 'Sign in to access your resume intelligence tools.'),
                        const SizedBox(height: 12),
                        PremiumCard(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PremiumTextField(
                                  controller: _emailController,
                                  label: 'Email address',
                                  hintText: 'you@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.validateEmail,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                PremiumTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Enter password',
                                  obscureText: !_showPassword,
                                  validator: Validators.validatePassword,
                                  autofillHints: const [AutofillHints.newPassword],
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _showPassword = !_showPassword),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.go(AppRoutes.forgotPassword),
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                PremiumButton(
                                  label: 'Login',
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                  onPressed: _handleLogin,
                                  isLoading: isLoading,
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Don’t have an account? '),
                                    TextButton(
                                      onPressed: () => context.go(AppRoutes.signup),
                                      child: const Text('Sign Up'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.12))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('OR', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                                    ),
                                    Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.12))),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.admin_panel_settings_outlined, color: theme.colorScheme.primary, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('ADMIN ACCESS', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                                          const SizedBox(height: 4),
                                          Text('Manage users, resumes & platform administration', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            onPressed: () => setState(() => _isAdminMode = !_isAdminMode),
                                            icon: Icon(_isAdminMode ? Icons.check_circle : Icons.shield),
                                            label: Text(_isAdminMode ? 'Admin mode active (tap to cancel)' : 'Login as Admin'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (isWide) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _LoginAccessory(label: 'Fingerprint', icon: Icons.fingerprint),
                                      _LoginAccessory(label: 'Fast access', icon: Icons.shield),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginAccessory extends StatelessWidget {
  const _LoginAccessory({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha((0.12 * 255).round()),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()))),
      ],
    );
  }
}
