import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/resume_model.dart';
import '../pdf_layout_helpers.dart';

// Traditional serif layout with a centered header — suited to formal/legal/
// academic industries where a conservative look is expected.
void buildProfessionalTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF1F2937);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey700,
    regularFont: pw.Font.times(),
    boldFont: pw.Font.timesBold(),
    headerUnderline: true,
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
      margin: const pw.EdgeInsets.fromLTRB(46, 40, 46, 40),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 22)),
              if (title.isNotEmpty)
                pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              if (email.isNotEmpty || phone.isNotEmpty)
                pw.Text(
                  [email, phone].where((s) => s.isNotEmpty).join('  |  '),
                  style: pw.TextStyle(font: style.regularFont, fontSize: 10, color: PdfColors.grey700),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey400, thickness: 0.8),
        pw.SizedBox(height: 10),
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
