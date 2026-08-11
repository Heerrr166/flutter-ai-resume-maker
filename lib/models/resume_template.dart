enum ResumeTemplateType {
  modern,
  minimalAts,
  professional,
  creative,
  executive;

  static ResumeTemplateType fromId(String id) {
    return ResumeTemplateType.values.firstWhere((t) => t.id == id, orElse: () => ResumeTemplateType.modern);
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
    }
  }

  String get label {
    switch (this) {
      case ResumeTemplateType.modern:
        return 'Modern';
      case ResumeTemplateType.minimalAts:
        return 'Minimal / ATS';
      case ResumeTemplateType.professional:
        return 'Professional';
      case ResumeTemplateType.creative:
        return 'Creative';
      case ResumeTemplateType.executive:
        return 'Executive';
    }
  }

  String get description {
    switch (this) {
      case ResumeTemplateType.modern:
        return 'Clean single-column layout with a bold accent color.';
      case ResumeTemplateType.minimalAts:
        return 'Plain, maximally ATS-parseable layout with no color or graphics.';
      case ResumeTemplateType.professional:
        return 'Traditional serif layout suited to formal industries.';
      case ResumeTemplateType.creative:
        return 'Two-column layout with a sidebar for skills and contact info.';
      case ResumeTemplateType.executive:
        return 'Bold header banner suited to senior and leadership roles.';
    }
  }
}
