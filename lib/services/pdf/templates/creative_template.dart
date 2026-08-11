import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/resume_model.dart';
import '../pdf_layout_helpers.dart';

// Two-column feel via a bounded sidebar band (contact/skills/languages —
// naturally short content) alongside the header, with the longer sections
// (experience, education, projects, ...) flowing full-width below. A true
// full-height parallel sidebar isn't safe here: pw.Row doesn't paginate its
// children internally, so long sidebar content would clip instead of
// flowing to a new page. This keeps the distinct two-column look without
// that risk.
void buildCreativeTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF7C3AED);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
  );

  final personal = personalInfo(resume) ?? {};
  final name = field(personal, 'fullName');
  final title = field(personal, 'title');
  final email = field(personal, 'email');
  final phone = field(personal, 'phone');
  final summary = resume.summary.trim();
  final skills = skillLabels(resume);
  final languages = entriesForSection('languages', sectionItemData(resume, 'languages'));

  final bodyOrder = resumeSectionOrder.where((k) => k != 'skills' && k != 'languages').toList();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(0, 0, 0, 36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(right: 40),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey500),
          ),
        ),
      ),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 160,
              color: PdfColors.grey100,
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CONTACT', style: pw.TextStyle(font: style.boldFont, fontSize: 10, color: accent, letterSpacing: 1)),
                  pw.SizedBox(height: 6),
                  if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                  if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                  if (skills.isNotEmpty) ...[
                    pw.SizedBox(height: 16),
                    pw.Text('SKILLS', style: pw.TextStyle(font: style.boldFont, fontSize: 10, color: accent, letterSpacing: 1)),
                    pw.SizedBox(height: 6),
                    ...skills.map((s) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 3),
                          child: pw.Text(s, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                        )),
                  ],
                  if (languages.isNotEmpty) ...[
                    pw.SizedBox(height: 16),
                    pw.Text('LANGUAGES', style: pw.TextStyle(font: style.boldFont, fontSize: 10, color: accent, letterSpacing: 1)),
                    pw.SizedBox(height: 6),
                    ...languages.map((l) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 3),
                          child: pw.Text(l.title, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                        )),
                  ],
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(24, 24, 40, 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: accent)),
                    if (title.isNotEmpty)
                      pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey700)),
                    if (summary.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        // Each widget stays a separate top-level list item (padded
        // individually, not wrapped in one Column) so pw.MultiPage can still
        // break between them across pages for long resumes.
        ...bodyOrder
            .expand((key) => buildEntrySectionWidgets(key, resume, style))
            .map((w) => pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 40), child: w)),
      ],
    ),
  );
}
