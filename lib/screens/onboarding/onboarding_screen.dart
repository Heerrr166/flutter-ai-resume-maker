import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/widgets/premium_card.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    const _OnboardingPageData(
      title: 'Welcome to AI Resume Maker',
      subtitle: 'Build resumes in minutes with intelligent layouts and career-focused highlights.',
      icon: Icons.auto_stories_outlined,
      accentColor: Color(0xFF3B82FF),
      backgroundColor: Color(0xFFE0EEFF),
    ),
    const _OnboardingPageData(
      title: 'AI-Powered Career Tools',
      subtitle: 'Get a Smart Resume Score, job-match analysis, tailored suggestions, and AI writing help built in.',
      icon: Icons.insights_outlined,
      accentColor: Color(0xFF8B5CF6),
      backgroundColor: Color(0xFFF2E5FF),
    ),
    const _OnboardingPageData(
      title: 'Export with Confidence',
      subtitle: 'Save ATS-friendly PDFs and share professional resumes instantly.',
      icon: Icons.picture_as_pdf_outlined,
      accentColor: Color(0xFF10B981),
      backgroundColor: Color(0xFFE9F7EF),
    ),
  ];

  void _goToLogin() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'app-logo',
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.work_outline, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text('Skip', style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PremiumCard(
                          padding: const EdgeInsets.all(26),
                          gradient: LinearGradient(
                            colors: [page.backgroundColor, page.accentColor.withAlpha((0.18 * 255).round())],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [page.accentColor, page.accentColor.withAlpha((0.7 * 255).round())],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(page.icon, size: 56, color: Colors.white),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(page.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: AppSpacing.md),
                              Text(page.subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha((0.74 * 255).round()), height: 1.6), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha((0.24 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  PremiumButton(
                    label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _goToLogin();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
                      }
                    },
                  ),
                  if (_currentPage == _pages.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: TextButton(
                        onPressed: _goToLogin,
                        child: const Text('Already have an account? Login'),
                      ),
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

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}
