import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/resume_model.dart';
import '../pdf_layout_helpers.dart';

// Bold full-width header banner, suited to senior/leadership roles where a
// strong first impression on the name and title matters most.
void buildExecutiveTemplate(pw.Document doc, ResumeModel resume) {
  final navy = PdfColor.fromInt(0xFF0F2A4A);
  final style = PdfSectionStyle(
    accent: navy,
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

  // Body sections must be spread as separate top-level items (not nested
  // inside one Column) so pw.MultiPage can break between them across pages
  // instead of clipping when the resume is long. Only the banner is a single
  // bounded item — it's inherently short and never needs to split.
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 20, 40, 36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey500),
        ),
      ),
      build: (context) => [
        pw.Container(
          margin: const pw.EdgeInsets.only(left: -40, right: -40, top: -20, bottom: 20),
          width: double.infinity,
          color: navy,
          padding: const pw.EdgeInsets.fromLTRB(40, 32, 40, 24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 28, color: PdfColors.white)),
              if (title.isNotEmpty)
                pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 13, color: PdfColors.grey300)),
              pw.SizedBox(height: 6),
              if (email.isNotEmpty || phone.isNotEmpty)
                pw.Text(
                  [email, phone].where((s) => s.isNotEmpty).join('   |   '),
                  style: pw.TextStyle(font: style.regularFont, fontSize: 10, color: PdfColors.grey300),
                ),
            ],
          ),
        ),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Executive Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10.5, lineSpacing: 1.6)),
          pw.SizedBox(height: 12),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}
