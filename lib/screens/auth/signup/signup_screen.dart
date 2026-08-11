import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/widgets/premium_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _acceptTerms = false;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(_passwordController.text);
    });
  }

  double _calculatePasswordStrength(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 8) score += 1;
    if (RegExp(r'(?=.*[A-Z])').hasMatch(value)) score += 1;
    if (RegExp(r'(?=.*[0-9])').hasMatch(value)) score += 1;
    if (RegExp(r'(?=.*[!@#\$&*~])').hasMatch(value)) score += 1;
    return score / 4;
  }

  String get _passwordStrengthLabel {
    if (_passwordStrength < 0.25) return 'Weak';
    if (_passwordStrength < 0.75) return 'Medium';
    return 'Strong';
  }

  Future<void> _handleCreateAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authNotifierProvider.notifier).register(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully. Please log in.')),
          );
          context.go(AppRoutes.login);
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

  String? _validatePasswordStrength(String? value) {
    final error = Validators.validatePassword(value);
    if (error != null) return error;
    if (value != null && !RegExp(r'(?=.*[A-Z])(?=.*[0-9])').hasMatch(value)) {
      return 'Use at least one uppercase letter and one digit';
    }
    return null;
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.colorScheme.surface, theme.colorScheme.surfaceContainerHighest],
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [theme.colorScheme.primary.withAlpha((0.28 * 255).round()), Colors.transparent],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create account', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Build your personalized resume workspace with built-in resume intelligence.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.78 * 255).round()), height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).round()),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PremiumTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hintText: 'Alex Johnson',
                            validator: Validators.validateName,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          const SizedBox(height: AppSpacing.md),
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
                            controller: _phoneController,
                            label: 'Mobile number',
                            hintText: '+91 98765 43210',
                            keyboardType: TextInputType.phone,
                            validator: Validators.validatePhone,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PremiumTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Enter password',
                            obscureText: !_showPassword,
                            validator: _validatePasswordStrength,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Strength: $_passwordStrengthLabel', style: theme.textTheme.bodySmall),
                              Text('${(_passwordStrength * 100).round()}%', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          LinearProgressIndicator(value: _passwordStrength, minHeight: 8),
                          const SizedBox(height: AppSpacing.md),
                          PremiumTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm password',
                            hintText: 'Re-enter password',
                            obscureText: !_showPassword,
                            validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CheckboxListTile(
                            value: _acceptTerms,
                            onChanged: (checked) => setState(() => _acceptTerms = checked ?? false),
                            title: const Text('I agree to the Terms & Conditions'),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PremiumButton(
                            label: 'Create account',
                            onPressed: _acceptTerms ? _handleCreateAccount : null,
                            isLoading: isLoading,
                            icon: const Icon(Icons.check_circle_outline),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text('Already have an account? Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
