import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/resume_model.dart';
import '../pdf_layout_helpers.dart';

// Deliberately colorless and graphics-free: maximum parseability by ATS
// software that strips styling and reads raw text top-to-bottom.
void buildMinimalAtsTemplate(pw.Document doc, ResumeModel resume) {
  final style = PdfSectionStyle(
    accent: PdfColors.black,
    mutedText: PdfColors.grey700,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    uppercaseHeaders: true,
    headerUnderline: false,
    headerFontSize: 11,
    bodyFontSize: 10,
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
      margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 40),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 18)),
        if (title.isNotEmpty) pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 11)),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Text(
            [email, phone].where((s) => s.isNotEmpty).join(' | '),
            style: pw.TextStyle(font: style.regularFont, fontSize: 10),
          ),
        pw.SizedBox(height: 12),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.4)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style, skillsAsChips: false),
      ],
    ),
  );
}
