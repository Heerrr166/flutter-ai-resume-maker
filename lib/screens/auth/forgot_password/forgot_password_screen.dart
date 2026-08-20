import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Shows the backend's own response message rather than a hardcoded claim —
  // the backend deliberately never promises email delivery (no real email
  // provider is configured yet), so the UI must not promise it either.
  void _showSuccessDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Received'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.login);
              },
              child: const Text('Back to login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.resetPassword, extra: _emailController.text.trim());
              },
              child: const Text('Enter code'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSendLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await ref.read(authNotifierProvider.notifier).forgotPassword(
            email: _emailController.text.trim(),
          );
      if (result != null) {
        _showSuccessDialog(result);
      } else {
        final error = ref.read(authNotifierProvider).errorMessage;
        if (mounted && error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go(AppRoutes.login),
                          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(width: 8),
                        SectionHeader(title: 'Recover Account'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PremiumCard(
                      padding: const EdgeInsets.all(24),
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary.withAlpha((0.15 * 255).round()), theme.colorScheme.surface],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Forgot your password?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Enter the email associated with your account to request a password reset code.',
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.78 * 255).round()), height: 1.5),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Form(
                            key: _formKey,
                            child: PremiumTextField(
                              controller: _emailController,
                              label: 'Email address',
                              hintText: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumButton(
                            label: 'Send Reset OTP',
                            onPressed: _handleSendLink,
                            isLoading: isLoading,
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
