import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

// Completes the flow started on ForgotPasswordScreen: the backend has
// already generated a reset code for this email (if it's registered); this
// screen is where the user enters that code plus a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the code you received';
    }
    return null;
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final message = await ref.read(authNotifierProvider.notifier).resetPassword(
          email: widget.email,
          otp: _otpController.text.trim(),
          password: _passwordController.text.trim(),
        );

    if (!mounted) return;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      context.go(AppRoutes.login);
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
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
                    Text('Reset your password', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter the code sent for ${widget.email} and choose a new password.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.78 * 255).round()), height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PremiumTextField(
                            controller: _otpController,
                            label: 'Reset code',
                            hintText: 'Enter the code',
                            keyboardType: TextInputType.number,
                            validator: _validateOtp,
                            prefixIcon: const Icon(Icons.pin_outlined),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PremiumTextField(
                            controller: _passwordController,
                            label: 'New password',
                            hintText: 'Enter new password',
                            obscureText: !_showPassword,
                            validator: Validators.validatePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PremiumTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm new password',
                            hintText: 'Re-enter new password',
                            obscureText: !_showPassword,
                            validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumButton(
                            label: 'Reset Password',
                            onPressed: _handleReset,
                            isLoading: isLoading,
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
