import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/premium_card.dart';
import '../../core/constants/app_colors.dart';
import '../../models/resume_model.dart';
import '../../providers/resume_provider.dart';

class AdminResumesScreen extends ConsumerWidget {
  const AdminResumesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumes = ref.watch(resumeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.nearBlack,
        foregroundColor: Colors.white,
        title: const Text('ADMIN CONSOLE / RESUMES', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: resumes.when(
          data: (list) {
            if (list.isEmpty) return const Center(child: Text('No resumes found'));
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final ResumeModel r = list[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PremiumCard(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(r.title.isEmpty ? 'Untitled' : r.title),
                      subtitle: Text('${r.status} • ${r.template}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => Navigator.of(context).pushNamed('/resume/${r.id}/edit'),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Failed to load resumes')),
        ),
      ),
    );
  }
}
