import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/resume_model.dart';
import '../pdf_layout_helpers.dart';

void buildModernTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF2F6FED);
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

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey500),
        ),
      ),
      build: (context) => [
        pw.Text(
          name.isEmpty ? 'Your Name' : name,
          style: pw.TextStyle(font: style.boldFont, fontSize: 26, color: accent),
        ),
        if (title.isNotEmpty) pw.SizedBox(height: 2),
        if (title.isNotEmpty)
          pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 13, color: PdfColors.grey700)),
        pw.SizedBox(height: 6),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Text(
            [email, phone].where((s) => s.isNotEmpty).join('   |   '),
            style: pw.TextStyle(font: style.regularFont, fontSize: 10, color: PdfColors.grey700),
          ),
        pw.SizedBox(height: 12),
        pw.Divider(color: accent, thickness: 1.2),
        pw.SizedBox(height: 8),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Professional Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10.5, lineSpacing: 1.6)),
          pw.SizedBox(height: 12),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}
