import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(authNotifierProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF101E4A), Color(0xFF0B1A2D), Color(0xFF162A5A)],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 34,
            child: Opacity(
              opacity: 0.16,
              child: Container(width: 96, height: 96, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 24,
            child: Opacity(
              opacity: 0.12,
              child: Container(width: 132, height: 132, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(scale: 0.94 + 0.06 * _controller.value, child: child);
                    },
                    child: Hero(
                      tag: 'app-logo',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF4C7CFF), Color(0xFF1558E0)]),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha((0.24 * 255).round()), blurRadius: 24, offset: const Offset(0, 14)),
                          ],
                        ),
                        child: const Icon(Icons.work_outline, size: 52, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('AI Resume Maker', style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: Text(
                      'Build a resume that gets noticed, with professional templates and instant export.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 120,
                    child: Column(
                      children: [
                        const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3),
                        const SizedBox(height: 16),
                        Text('Loading premium experience...', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ],
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
