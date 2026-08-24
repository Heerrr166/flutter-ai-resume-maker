import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../models/resume_template.dart';

class TemplatePickerScreen extends StatefulWidget {
  final String currentTemplateId;

  const TemplatePickerScreen({super.key, required this.currentTemplateId});

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  late String _selectedTemplateId;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'All',
    'Modern',
    'ATS',
    'Tech',
    'Professional',
    'Executive',
    'Creative',
    'Corporate',
    'Student',
    'Academic',
    'Finance',
    'Minimal',
    'Bold',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTemplateId = widget.currentTemplateId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ResumeTemplateType> get _filteredTemplates {
    return ResumeTemplateType.values.where((template) {
      final matchesCategory = _selectedCategory == 'All' || template.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          template.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          template.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = _filteredTemplates;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Resume Template Marketplace'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 10),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Template',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ResumeTemplateType.fromId(_selectedTemplateId).label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(_selectedTemplateId),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Use This Template', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search Bar Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Box
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: TextStyle(fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Search templates by style, role, or feature...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Pills
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      final count = category == 'All'
                          ? ResumeTemplateType.values.length
                          : ResumeTemplateType.values.where((t) => t.category == category).length;

                      return InkWell(
                        onTap: () => setState(() => _selectedCategory = category),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white24 : (isDark ? Colors.white10 : Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),

          // Template Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.style_outlined, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(height: 12),
                        Text(
                          'No templates found in this category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try clearing search or choosing "All Categories".',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final int crossAxisCount = width >= 1200
                          ? 4
                          : (width >= 860 ? 3 : (width >= 540 ? 2 : 1));

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: crossAxisCount == 1 ? 1.05 : 0.62,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final template = filtered[index];
                          final isSelected = template.id == _selectedTemplateId;

                          return _TemplateCard(
                            template: template,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _selectedTemplateId = template.id);
                            },
                            onUseInstantly: () {
                              Navigator.of(context).pop(template.id);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ResumeTemplateType template;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onUseInstantly;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.onUseInstantly,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(template.primaryColorValue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.accent.withAlpha(isDark ? 60 : 35)
                  : Colors.black.withAlpha(isDark ? 25 : 6),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Preview Container
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _TemplateMockup(template: template),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        template.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Title & Category Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Short Description
            Text(
              template.description,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HIGH-FIDELITY LIGHTWEIGHT MOCKUPS FOR ALL 16 TEMPLATES
// ============================================================================
class _TemplateMockup extends StatelessWidget {
  final ResumeTemplateType template;

  const _TemplateMockup({required this.template});

  Widget _bar(double width, {double height = 5, Color color = const Color(0xFFCBD5E1)}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(8),
        child: switch (template) {
          ResumeTemplateType.modern => _modernMockup(),
          ResumeTemplateType.minimalAts => _minimalAtsMockup(),
          ResumeTemplateType.professional => _professionalMockup(),
          ResumeTemplateType.creative => _creativeMockup(),
          ResumeTemplateType.executive => _executiveMockup(),
          ResumeTemplateType.techDeveloper => _techDeveloperMockup(),
          ResumeTemplateType.dataAnalytics => _dataAnalyticsMockup(),
          ResumeTemplateType.corporate => _corporateMockup(),
          ResumeTemplateType.studentFresher => _studentFresherMockup(),
          ResumeTemplateType.academic => _academicMockup(),
          ResumeTemplateType.marketing => _marketingMockup(),
          ResumeTemplateType.finance => _financeMockup(),
          ResumeTemplateType.elegantMonochrome => _elegantMonochromeMockup(),
          ResumeTemplateType.boldHeader => _boldHeaderMockup(),
          ResumeTemplateType.cleanTwoColumn => _cleanTwoColumnMockup(),
          ResumeTemplateType.compactAts => _compactAtsMockup(),
        },
      ),
    );
  }

  Widget _modernMockup() {
    const accent = Color(0xFF2563EB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(65, height: 9, color: accent),
        const SizedBox(height: 3),
        _bar(45, height: 5, color: const Color(0xFF64748B)),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 1.5, color: accent),
        const SizedBox(height: 8),
        _bar(40, height: 5, color: accent),
        const SizedBox(height: 3),
        _bar(double.infinity, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 2),
        _bar(double.infinity, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 8),
        _bar(40, height: 5, color: accent),
        const SizedBox(height: 3),
        Row(
          children: [
            _bar(24, height: 8, color: const Color(0xFFDBEAFE)),
            const SizedBox(width: 4),
            _bar(28, height: 8, color: const Color(0xFFDBEAFE)),
            const SizedBox(width: 4),
            _bar(22, height: 8, color: const Color(0xFFDBEAFE)),
          ],
        ),
      ],
    );
  }

  Widget _minimalAtsMockup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(70, height: 8, color: Colors.black87),
        const SizedBox(height: 3),
        _bar(90, height: 4, color: Colors.black45),
        const SizedBox(height: 8),
        _bar(35, height: 4.5, color: Colors.black87),
        const SizedBox(height: 3),
        _bar(double.infinity, color: Colors.black26),
        const SizedBox(height: 2),
        _bar(double.infinity, color: Colors.black26),
        const SizedBox(height: 8),
        _bar(35, height: 4.5, color: Colors.black87),
        const SizedBox(height: 3),
        _bar(double.infinity, color: Colors.black26),
        const SizedBox(height: 2),
        _bar(double.infinity, color: Colors.black26),
      ],
    );
  }

  Widget _professionalMockup() {
    const navy = Color(0xFF1E3A8A);
    return Column(
      children: [
        _bar(70, height: 8, color: navy),
        const SizedBox(height: 3),
        _bar(50, height: 4, color: const Color(0xFF64748B)),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 1, color: Colors.black38),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: _bar(45, height: 5, color: navy)),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 2),
        _bar(double.infinity),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: _bar(45, height: 5, color: navy)),
        const SizedBox(height: 3),
        _bar(double.infinity),
      ],
    );
  }

  Widget _creativeMockup() {
    const accent = Color(0xFF7C3AED);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(20, height: 4, color: accent),
              const SizedBox(height: 4),
              _bar(20, height: 3),
              const SizedBox(height: 8),
              _bar(20, height: 4, color: accent),
              const SizedBox(height: 3),
              _bar(20, height: 3),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(55, height: 8, color: accent),
              const SizedBox(height: 3),
              _bar(40, height: 4),
              const SizedBox(height: 8),
              _bar(35, height: 4.5, color: accent),
              const SizedBox(height: 3),
              _bar(double.infinity),
              const SizedBox(height: 2),
              _bar(double.infinity),
            ],
          ),
        ),
      ],
    );
  }

  Widget _executiveMockup() {
    const darkNavy = Color(0xFF0F172A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: darkNavy,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(55, height: 7, color: Colors.white),
              const SizedBox(height: 2),
              _bar(40, height: 3.5, color: Colors.white70),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _bar(40, height: 4.5, color: darkNavy),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 2),
        _bar(double.infinity),
        const SizedBox(height: 8),
        _bar(40, height: 4.5, color: darkNavy),
        const SizedBox(height: 3),
        _bar(double.infinity),
      ],
    );
  }

  Widget _techDeveloperMockup() {
    const teal = Color(0xFF0D9488);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bar(50, height: 8, color: teal),
            _bar(30, height: 4, color: const Color(0xFF64748B)),
          ],
        ),
        const SizedBox(height: 4),
        Container(width: double.infinity, height: 1.5, color: teal),
        const SizedBox(height: 8),
        _bar(45, height: 5, color: teal),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 6),
        _bar(35, height: 5, color: teal),
        const SizedBox(height: 3),
        Row(
          children: [
            _bar(20, height: 7, color: const Color(0xFFCCFBF1)),
            const SizedBox(width: 3),
            _bar(24, height: 7, color: const Color(0xFFCCFBF1)),
            const SizedBox(width: 3),
            _bar(20, height: 7, color: const Color(0xFFCCFBF1)),
          ],
        ),
      ],
    );
  }

  Widget _dataAnalyticsMockup() {
    const sky = Color(0xFF0284C7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(55, height: 8, color: sky),
                  const SizedBox(height: 2),
                  _bar(40, height: 4),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(3)),
              child: _bar(24, height: 10, color: sky),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 1, color: sky),
        const SizedBox(height: 6),
        _bar(40, height: 4.5, color: sky),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 2),
        _bar(double.infinity),
      ],
    );
  }

  Widget _corporateMockup() {
    const slate = Color(0xFF334155);
    return Column(
      children: [
        _bar(65, height: 8, color: slate),
        const SizedBox(height: 3),
        _bar(45, height: 3.5),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 0.8, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 2, height: 25, color: slate),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(40, height: 4, color: slate),
                  const SizedBox(height: 3),
                  _bar(double.infinity),
                  const SizedBox(height: 2),
                  _bar(double.infinity),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _studentFresherMockup() {
    const green = Color(0xFF10B981);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bar(45, height: 7, color: green),
              _bar(30, height: 4),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _bar(45, height: 4.5, color: green),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 6),
        _bar(40, height: 4.5, color: green),
        const SizedBox(height: 3),
        _bar(double.infinity),
      ],
    );
  }

  Widget _academicMockup() {
    const bronze = Color(0xFF854D0E);
    return Column(
      children: [
        _bar(65, height: 8, color: bronze),
        const SizedBox(height: 3),
        _bar(50, height: 4, color: const Color(0xFF713F12)),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 0.8, color: bronze),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerLeft, child: _bar(45, height: 4.5, color: bronze)),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 2),
        _bar(double.infinity),
      ],
    );
  }

  Widget _marketingMockup() {
    const coral = Color(0xFFEA580C);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(60, height: 8, color: coral),
        const SizedBox(height: 3),
        _bar(40, height: 4),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 2.5, color: coral),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFFFEDD5), borderRadius: BorderRadius.circular(3)),
          child: _bar(double.infinity, height: 4, color: coral),
        ),
        const SizedBox(height: 6),
        _bar(40, height: 4.5, color: coral),
        const SizedBox(height: 3),
        _bar(double.infinity),
      ],
    );
  }

  Widget _financeMockup() {
    const forest = Color(0xFF065F46);
    return Column(
      children: [
        _bar(65, height: 8, color: forest),
        const SizedBox(height: 3),
        _bar(45, height: 4),
        const SizedBox(height: 6),
        Container(width: double.infinity, height: 1, color: forest),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerLeft, child: _bar(45, height: 4.5, color: forest)),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 2),
        _bar(double.infinity),
      ],
    );
  }

  Widget _elegantMonochromeMockup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(55, height: 8, color: Colors.black),
        const SizedBox(height: 2),
        _bar(35, height: 3.5, color: Colors.black54),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 0.5, color: Colors.black26),
        const SizedBox(height: 8),
        _bar(30, height: 4, color: Colors.black87),
        const SizedBox(height: 3),
        _bar(double.infinity, color: Colors.black38),
        const SizedBox(height: 2),
        _bar(double.infinity, color: Colors.black26),
      ],
    );
  }

  Widget _boldHeaderMockup() {
    const emerald = Color(0xFF059669);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: emerald,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(55, height: 7, color: Colors.white),
              const SizedBox(height: 2),
              _bar(35, height: 3.5, color: const Color(0xFFA7F3D0)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _bar(40, height: 4.5, color: emerald),
        const SizedBox(height: 3),
        _bar(double.infinity),
        const SizedBox(height: 2),
        _bar(double.infinity),
      ],
    );
  }

  Widget _cleanTwoColumnMockup() {
    const indigo = Color(0xFF4F46E5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bar(50, height: 7, color: indigo),
            _bar(30, height: 4),
          ],
        ),
        const SizedBox(height: 4),
        Container(width: double.infinity, height: 1, color: indigo),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(25, height: 4, color: indigo),
                  const SizedBox(height: 2),
                  _bar(double.infinity),
                  const SizedBox(height: 5),
                  _bar(25, height: 4, color: indigo),
                  const SizedBox(height: 2),
                  _bar(double.infinity),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(35, height: 4, color: indigo),
                  const SizedBox(height: 2),
                  _bar(double.infinity),
                  const SizedBox(height: 2),
                  _bar(double.infinity),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _compactAtsMockup() {
    const grey = Color(0xFF374151);
    return Column(
      children: [
        _bar(65, height: 7, color: grey),
        const SizedBox(height: 2),
        _bar(50, height: 3.5),
        const SizedBox(height: 4),
        Container(width: double.infinity, height: 0.8, color: grey),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: _bar(35, height: 4, color: grey)),
        const SizedBox(height: 2),
        _bar(double.infinity),
        const SizedBox(height: 1.5),
        _bar(double.infinity),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: _bar(35, height: 4, color: grey)),
        const SizedBox(height: 2),
        _bar(double.infinity),
      ],
    );
  }
}
