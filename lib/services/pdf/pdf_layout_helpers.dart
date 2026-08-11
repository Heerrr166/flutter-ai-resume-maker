import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/resume_model.dart';

// Canonical render order for resume sections. Personal info and summary are
// rendered separately by each template (they're headers, not list sections).
const List<String> resumeSectionOrder = [
  'education',
  'experience',
  'projects',
  'skills',
  'certifications',
  'languages',
  'achievements',
  'references',
];

const Map<String, String> resumeSectionTitles = {
  'education': 'Education',
  'experience': 'Experience',
  'projects': 'Projects',
  'skills': 'Skills',
  'certifications': 'Certifications',
  'languages': 'Languages',
  'achievements': 'Achievements',
  'references': 'References',
};

ResumeSection? findSection(ResumeModel resume, String key) {
  final matches = resume.sections.where((s) => s.key == key);
  return matches.isEmpty ? null : matches.first;
}

List<Map<String, dynamic>> sectionItemData(ResumeModel resume, String key) {
  final section = findSection(resume, key);
  if (section == null) return [];
  return section.items.map((it) => it.data).toList();
}

Map<String, dynamic>? personalInfo(ResumeModel resume) {
  final items = sectionItemData(resume, 'personal');
  return items.isEmpty ? null : items.first;
}

String field(Map<String, dynamic> data, String key) => (data[key] ?? '').toString().trim();

List<String> fieldList(Map<String, dynamic> data, String key) {
  final v = data[key];
  if (v is List) return v.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  return [];
}

String dateRange(Map<String, dynamic> data) {
  final start = field(data, 'start');
  final isCurrent = data['current'] == true;
  final end = isCurrent ? 'Present' : field(data, 'end');
  if (start.isEmpty && end.isEmpty) return '';
  if (start.isEmpty) return end;
  if (end.isEmpty) return start;
  return '$start - $end';
}

// A generic (title / subtitle / meta / bullets) shape every template renders
// the same way, regardless of which section it came from. Keeps the 5
// template files from each re-deriving section-specific field mappings.
class ResumeEntry {
  final String title;
  final String subtitle;
  final String meta;
  final List<String> bullets;

  ResumeEntry({required this.title, this.subtitle = '', this.meta = '', this.bullets = const []});
}

List<ResumeEntry> entriesForSection(String key, List<Map<String, dynamic>> items) {
  switch (key) {
    case 'experience':
      return items.map((d) {
        final location = field(d, 'location');
        final meta = [dateRange(d), if (location.isNotEmpty) location].where((s) => s.isNotEmpty).join(' | ');
        return ResumeEntry(
          title: field(d, 'position'),
          subtitle: field(d, 'company'),
          meta: meta,
          bullets: fieldList(d, 'responsibilities'),
        );
      }).toList();
    case 'education':
      return items
          .map((d) => ResumeEntry(title: field(d, 'degree'), subtitle: field(d, 'institution'), meta: dateRange(d)))
          .toList();
    case 'projects':
      return items.map((d) {
        final tech = fieldList(d, 'technologies').join(', ');
        final description = field(d, 'description');
        return ResumeEntry(
          title: field(d, 'name'),
          subtitle: tech,
          meta: field(d, 'role'),
          bullets: description.isEmpty ? [] : [description],
        );
      }).toList();
    case 'certifications':
      return items.map((d) {
        final issueDate = field(d, 'issueDate');
        final expiryDate = field(d, 'expiryDate');
        final meta = [
          if (issueDate.isNotEmpty) 'Issued $issueDate',
          if (expiryDate.isNotEmpty) 'Expires $expiryDate',
        ].join(' | ');
        return ResumeEntry(title: field(d, 'name'), subtitle: field(d, 'issuer'), meta: meta);
      }).toList();
    case 'languages':
      return items.map((d) {
        final proficiency = [
          'Read: ${field(d, 'read')}',
          'Write: ${field(d, 'write')}',
          'Speak: ${field(d, 'speak')}',
        ].join(' | ');
        return ResumeEntry(title: field(d, 'language'), subtitle: proficiency);
      }).toList();
    case 'achievements':
      return items.map((d) => ResumeEntry(title: field(d, 'title'), meta: field(d, 'date'))).toList();
    case 'references':
      return items.map((d) {
        final subtitle = [field(d, 'designation'), field(d, 'company')].where((s) => s.isNotEmpty).join(', ');
        final contact = [field(d, 'email'), field(d, 'phone')].where((s) => s.isNotEmpty).join(' | ');
        return ResumeEntry(title: field(d, 'name'), subtitle: subtitle, meta: contact);
      }).toList();
    default:
      return [];
  }
}

List<String> skillLabels(ResumeModel resume) {
  return sectionItemData(resume, 'skills').map((d) => field(d, 'name')).where((s) => s.isNotEmpty).toList();
}

// Shared visual language every template configures rather than reimplements —
// this is what lets a 6th template be added later as a new small file instead
// of a full rewrite of the rendering logic.
class PdfSectionStyle {
  final PdfColor accent;
  final PdfColor mutedText;
  final bool uppercaseHeaders;
  final bool headerUnderline;
  final pw.Font regularFont;
  final pw.Font boldFont;
  final double headerFontSize;
  final double bodyFontSize;

  const PdfSectionStyle({
    required this.accent,
    required this.mutedText,
    required this.regularFont,
    required this.boldFont,
    this.uppercaseHeaders = true,
    this.headerUnderline = true,
    this.headerFontSize = 11.5,
    this.bodyFontSize = 10,
  });
}

pw.Widget buildSectionHeader(String title, PdfSectionStyle style) {
  final label = style.uppercaseHeaders ? title.toUpperCase() : title;
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6, top: 4),
    padding: style.headerUnderline ? const pw.EdgeInsets.only(bottom: 3) : pw.EdgeInsets.zero,
    decoration: style.headerUnderline
        ? pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: style.accent, width: 1.1)))
        : null,
    child: pw.Text(
      label,
      style: pw.TextStyle(
        font: style.boldFont,
        fontSize: style.headerFontSize,
        color: style.accent,
        letterSpacing: style.uppercaseHeaders ? 1.1 : 0,
      ),
    ),
  );
}

List<pw.Widget> buildSkillsWidgets(ResumeModel resume, PdfSectionStyle style, {bool asChips = true}) {
  final skills = skillLabels(resume);
  if (skills.isEmpty) return [];
  final body = asChips
      ? pw.Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills
              .map((s) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(s, style: pw.TextStyle(font: style.regularFont, fontSize: style.bodyFontSize - 0.5)),
                  ))
              .toList(),
        )
      : pw.Text(skills.join('   |   '), style: pw.TextStyle(font: style.regularFont, fontSize: style.bodyFontSize));

  return [
    buildSectionHeader(resumeSectionTitles['skills']!, style),
    body,
    pw.SizedBox(height: 12),
  ];
}

List<pw.Widget> buildEntrySectionWidgets(String key, ResumeModel resume, PdfSectionStyle style) {
  final entries = entriesForSection(key, sectionItemData(resume, key));
  if (entries.isEmpty) return [];

  return [
    buildSectionHeader(resumeSectionTitles[key]!, style),
    ...entries.map(
      (e) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    e.title.isEmpty ? '(Untitled)' : e.title,
                    style: pw.TextStyle(font: style.boldFont, fontSize: style.bodyFontSize + 1),
                  ),
                ),
                if (e.meta.isNotEmpty)
                  pw.Text(e.meta, style: pw.TextStyle(font: style.regularFont, fontSize: style.bodyFontSize - 1.5, color: style.mutedText)),
              ],
            ),
            if (e.subtitle.isNotEmpty)
              pw.Text(e.subtitle, style: pw.TextStyle(font: style.regularFont, fontSize: style.bodyFontSize, color: style.accent)),
            ...e.bullets.map(
              (b) => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3, left: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('-  ', style: pw.TextStyle(font: style.boldFont, fontSize: style.bodyFontSize - 0.5)),
                    pw.Expanded(
                      child: pw.Text(b, style: pw.TextStyle(font: style.regularFont, fontSize: style.bodyFontSize - 0.5, lineSpacing: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}

// Renders every section in canonical order using the given style, skipping
// any section with no data. This is the single place that decides "what
// counts as resume content" — templates never hand-pick which sections exist.
List<pw.Widget> buildAllSections(ResumeModel resume, PdfSectionStyle style, {bool skillsAsChips = true}) {
  final widgets = <pw.Widget>[];
  for (final key in resumeSectionOrder) {
    if (key == 'skills') {
      widgets.addAll(buildSkillsWidgets(resume, style, asChips: skillsAsChips));
    } else {
      widgets.addAll(buildEntrySectionWidgets(key, resume, style));
    }
  }
  return widgets;
}
