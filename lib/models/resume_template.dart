enum ResumeTemplateType {
  modern,
  minimalAts,
  professional,
  creative,
  executive,
  techDeveloper,
  dataAnalytics,
  corporate,
  studentFresher,
  academic,
  marketing,
  finance,
  elegantMonochrome,
  boldHeader,
  cleanTwoColumn,
  compactAts;

  static ResumeTemplateType fromId(String id) {
    return ResumeTemplateType.values.firstWhere(
      (t) => t.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ResumeTemplateType.modern,
    );
  }

  String get id {
    switch (this) {
      case ResumeTemplateType.modern:
        return 'modern';
      case ResumeTemplateType.minimalAts:
        return 'minimalAts';
      case ResumeTemplateType.professional:
        return 'professional';
      case ResumeTemplateType.creative:
        return 'creative';
      case ResumeTemplateType.executive:
        return 'executive';
      case ResumeTemplateType.techDeveloper:
        return 'techDeveloper';
      case ResumeTemplateType.dataAnalytics:
        return 'dataAnalytics';
      case ResumeTemplateType.corporate:
        return 'corporate';
      case ResumeTemplateType.studentFresher:
        return 'studentFresher';
      case ResumeTemplateType.academic:
        return 'academic';
      case ResumeTemplateType.marketing:
        return 'marketing';
      case ResumeTemplateType.finance:
        return 'finance';
      case ResumeTemplateType.elegantMonochrome:
        return 'elegantMonochrome';
      case ResumeTemplateType.boldHeader:
        return 'boldHeader';
      case ResumeTemplateType.cleanTwoColumn:
        return 'cleanTwoColumn';
      case ResumeTemplateType.compactAts:
        return 'compactAts';
    }
  }

  String get label {
    switch (this) {
      case ResumeTemplateType.modern:
        return 'Modern Blue';
      case ResumeTemplateType.minimalAts:
        return 'Minimal ATS';
      case ResumeTemplateType.professional:
        return 'Corporate Serif';
      case ResumeTemplateType.creative:
        return 'Creative Purple';
      case ResumeTemplateType.executive:
        return 'Executive Navy';
      case ResumeTemplateType.techDeveloper:
        return 'Tech Developer';
      case ResumeTemplateType.dataAnalytics:
        return 'Data & Analytics';
      case ResumeTemplateType.corporate:
        return 'Corporate Clean';
      case ResumeTemplateType.studentFresher:
        return 'Student & Fresher';
      case ResumeTemplateType.academic:
        return 'Academic CV';
      case ResumeTemplateType.marketing:
        return 'Marketing & Growth';
      case ResumeTemplateType.finance:
        return 'Finance & Banking';
      case ResumeTemplateType.elegantMonochrome:
        return 'Elegant Monochrome';
      case ResumeTemplateType.boldHeader:
        return 'Bold Emerald';
      case ResumeTemplateType.cleanTwoColumn:
        return 'Clean Two-Column';
      case ResumeTemplateType.compactAts:
        return 'Compact ATS Pro';
    }
  }

  String get category {
    switch (this) {
      case ResumeTemplateType.modern:
        return 'Modern';
      case ResumeTemplateType.minimalAts:
        return 'ATS';
      case ResumeTemplateType.professional:
        return 'Professional';
      case ResumeTemplateType.creative:
        return 'Creative';
      case ResumeTemplateType.executive:
        return 'Executive';
      case ResumeTemplateType.techDeveloper:
        return 'Tech';
      case ResumeTemplateType.dataAnalytics:
        return 'Tech';
      case ResumeTemplateType.corporate:
        return 'Corporate';
      case ResumeTemplateType.studentFresher:
        return 'Student';
      case ResumeTemplateType.academic:
        return 'Academic';
      case ResumeTemplateType.marketing:
        return 'Creative';
      case ResumeTemplateType.finance:
        return 'Finance';
      case ResumeTemplateType.elegantMonochrome:
        return 'Minimal';
      case ResumeTemplateType.boldHeader:
        return 'Bold';
      case ResumeTemplateType.cleanTwoColumn:
        return 'Modern';
      case ResumeTemplateType.compactAts:
        return 'ATS';
    }
  }

  String get description {
    switch (this) {
      case ResumeTemplateType.modern:
        return 'Clean single-column layout with a bold blue accent color and skill badges.';
      case ResumeTemplateType.minimalAts:
        return 'Plain, 100% ATS-parseable layout with strict hierarchy and zero graphics.';
      case ResumeTemplateType.professional:
        return 'Traditional serif typography and horizontal dividers suited for formal roles.';
      case ResumeTemplateType.creative:
        return 'Two-column layout with a shaded sidebar for skills, links, and contact.';
      case ResumeTemplateType.executive:
        return 'High-impact dark navy title banner suited for directors and senior leaders.';
      case ResumeTemplateType.techDeveloper:
        return 'Clean technical layout emphasizing stack technologies, repos, and code impact.';
      case ResumeTemplateType.dataAnalytics:
        return 'Metrics-oriented structured format highlighting analytical tools and KPI achievements.';
      case ResumeTemplateType.corporate:
        return 'Authoritative corporate template with left accent indicators and clean structure.';
      case ResumeTemplateType.studentFresher:
        return 'Fresh layout placing education, coursework, and projects ahead of work experience.';
      case ResumeTemplateType.academic:
        return 'Exhaustive curriculum vitae layout tailored for research, academia, and publications.';
      case ResumeTemplateType.marketing:
        return 'Dynamic high-energy layout with vibrant coral accents for brand and growth roles.';
      case ResumeTemplateType.finance:
        return 'Conservative dark emerald and slate design favored by banking and advisory firms.';
      case ResumeTemplateType.elegantMonochrome:
        return 'Understated minimalist aesthetic with wide letter-spacing and luxury typography.';
      case ResumeTemplateType.boldHeader:
        return 'Standout emerald ribbon header with dual-tone text contrast for modern impact.';
      case ResumeTemplateType.cleanTwoColumn:
        return 'Balanced 30/70 split column format maximizing space efficiency for detailed resumes.';
      case ResumeTemplateType.compactAts:
        return 'High-density ATS layout designed to fit comprehensive multi-year experience into 1 page.';
    }
  }

  int get primaryColorValue {
    switch (this) {
      case ResumeTemplateType.modern:
        return 0xFF2563EB;
      case ResumeTemplateType.minimalAts:
        return 0xFF1E293B;
      case ResumeTemplateType.professional:
        return 0xFF1E3A8A;
      case ResumeTemplateType.creative:
        return 0xFF7C3AED;
      case ResumeTemplateType.executive:
        return 0xFF0F172A;
      case ResumeTemplateType.techDeveloper:
        return 0xFF0D9488;
      case ResumeTemplateType.dataAnalytics:
        return 0xFF0284C7;
      case ResumeTemplateType.corporate:
        return 0xFF334155;
      case ResumeTemplateType.studentFresher:
        return 0xFF10B981;
      case ResumeTemplateType.academic:
        return 0xFF854D0E;
      case ResumeTemplateType.marketing:
        return 0xFFEA580C;
      case ResumeTemplateType.finance:
        return 0xFF065F46;
      case ResumeTemplateType.elegantMonochrome:
        return 0xFF18181B;
      case ResumeTemplateType.boldHeader:
        return 0xFF059669;
      case ResumeTemplateType.cleanTwoColumn:
        return 0xFF4F46E5;
      case ResumeTemplateType.compactAts:
        return 0xFF374151;
    }
  }
}
