class ResumeSectionItem {
  final String id;
  final Map<String, dynamic> data;

  ResumeSectionItem({required this.id, required this.data});

  factory ResumeSectionItem.fromJson(Map<String, dynamic> json) {
    return ResumeSectionItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'data': data};
}

class ResumeSection {
  final String key;
  final String title;
  final List<ResumeSectionItem> items;
  final int order;

  ResumeSection({required this.key, required this.title, required this.items, required this.order});

  factory ResumeSection.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return ResumeSection(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      items: itemsJson.map((e) => ResumeSectionItem.fromJson(e as Map<String, dynamic>)).toList(),
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
        'order': order,
      };
}

class ResumeModel {
  final String id;
  final String title;
  final String summary;
  final List<ResumeSection> sections;
  final String status;
  final String template;
  final String coverLetter;

  ResumeModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
    required this.status,
    this.template = 'modern',
    this.coverLetter = '',
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    return ResumeModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      sections: sectionsJson.map((e) => ResumeSection.fromJson(e as Map<String, dynamic>)).toList(),
      status: json['status'] as String? ?? 'draft',
      template: json['template'] as String? ?? 'modern',
      coverLetter: json['coverLetter'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'sections': sections.map((s) => s.toJson()).toList(),
        'status': status,
        'template': template,
        'coverLetter': coverLetter,
      };

  ResumeModel copyWith({
    String? title,
    String? summary,
    List<ResumeSection>? sections,
    String? status,
    String? template,
    String? coverLetter,
  }) {
    return ResumeModel(
      id: id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      sections: sections ?? this.sections,
      status: status ?? this.status,
      template: template ?? this.template,
      coverLetter: coverLetter ?? this.coverLetter,
    );
  }
}
