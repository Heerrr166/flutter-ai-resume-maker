import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/resume_model.dart';
import '../pdf_layout_helpers.dart';

// ============================================================================
// 1. TECH / DEVELOPER TEMPLATE
// ============================================================================
void buildTechDeveloperTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF0D9488);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11,
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
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: accent, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    name.isEmpty ? 'Your Name' : name,
                    style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: accent),
                  ),
                  if (title.isNotEmpty)
                    pw.Text(
                      title,
                      style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey700),
                    ),
                ],
              ),
              if (email.isNotEmpty || phone.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (email.isNotEmpty)
                      pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 9, color: PdfColors.grey700)),
                    if (phone.isNotEmpty)
                      pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Technical Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}

// ============================================================================
// 2. DATA / ANALYTICS TEMPLATE
// ============================================================================
void buildDataAnalyticsTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF0284C7);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11.5,
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
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: accent)),
                if (title.isNotEmpty)
                  pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey800)),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F9FF), borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 8.5)),
                  if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 8.5)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: accent, thickness: 1),
        pw.SizedBox(height: 8),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Professional Background', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}

// ============================================================================
// 3. CORPORATE CLEAN TEMPLATE
// ============================================================================
void buildCorporateTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF334155);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11,
    uppercaseHeaders: true,
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
        pw.Center(
          child: pw.Text(
            name.isEmpty ? 'YOUR NAME' : name.toUpperCase(),
            style: pw.TextStyle(font: style.boldFont, fontSize: 22, color: accent, letterSpacing: 1.5),
          ),
        ),
        if (title.isNotEmpty) pw.SizedBox(height: 2),
        if (title.isNotEmpty)
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(font: style.regularFont, fontSize: 11.5, color: PdfColors.grey700),
            ),
          ),
        pw.SizedBox(height: 4),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Center(
            child: pw.Text(
              [email, phone].where((s) => s.isNotEmpty).join('   *   '),
              style: pw.TextStyle(font: style.regularFont, fontSize: 9.5, color: PdfColors.grey600),
            ),
          ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey400, thickness: 0.8),
        pw.SizedBox(height: 8),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Executive Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}

// ============================================================================
// 4. STUDENT / FRESHER STARTER TEMPLATE
// ============================================================================
void buildStudentFresherTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF10B981);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11.5,
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
      margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey500),
        ),
      ),
      build: (context) => [
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFECFDF5),
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColor.fromInt(0xFFA7F3D0)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 20, color: PdfColor.fromInt(0xFF064E3B))),
                  if (title.isNotEmpty)
                    pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 11, color: PdfColor.fromInt(0xFF065F46))),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 9, color: PdfColors.grey800)),
                  if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 9, color: PdfColors.grey800)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Profile Objective', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}

// ============================================================================
// 5. ACADEMIC CV TEMPLATE
// ============================================================================
void buildAcademicTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF854D0E);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey700,
    regularFont: pw.Font.times(),
    boldFont: pw.Font.timesBold(),
    headerFontSize: 12,
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
      margin: const pw.EdgeInsets.fromLTRB(45, 40, 45, 40),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8.5, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            name.isEmpty ? 'Curriculum Vitae' : name,
            style: pw.TextStyle(font: style.boldFont, fontSize: 22, color: accent),
          ),
        ),
        if (title.isNotEmpty) pw.SizedBox(height: 3),
        if (title.isNotEmpty)
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey800),
            ),
          ),
        pw.SizedBox(height: 4),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Center(
            child: pw.Text(
              [email, phone].where((s) => s.isNotEmpty).join('   |   '),
              style: pw.TextStyle(font: style.regularFont, fontSize: 9.5, color: PdfColors.grey700),
            ),
          ),
        pw.SizedBox(height: 12),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Research Focus & Profile', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.6)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style, skillsAsChips: false),
      ],
    ),
  );
}

// ============================================================================
// 6. MARKETING & GROWTH TEMPLATE
// ============================================================================
void buildMarketingTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFFEA580C);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11.5,
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
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: accent)),
                if (title.isNotEmpty)
                  pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey800)),
              ],
            ),
            if (email.isNotEmpty || phone.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                  if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 3, color: accent),
        pw.SizedBox(height: 10),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Growth & Strategy Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}

// ============================================================================
// 7. FINANCE & BANKING TEMPLATE
// ============================================================================
void buildFinanceTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF065F46);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey700,
    regularFont: pw.Font.times(),
    boldFont: pw.Font.timesBold(),
    headerFontSize: 11.5,
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
        pw.Center(
          child: pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 22, color: accent)),
        ),
        if (title.isNotEmpty)
          pw.Center(
            child: pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 11, color: PdfColors.grey800)),
          ),
        pw.SizedBox(height: 4),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Center(
            child: pw.Text([email, phone].where((s) => s.isNotEmpty).join('   |   '), style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
          ),
        pw.SizedBox(height: 10),
        pw.Divider(color: accent, thickness: 1),
        pw.SizedBox(height: 6),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Professional Profile', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style, skillsAsChips: false),
      ],
    ),
  );
}

// ============================================================================
// 8. ELEGANT MONOCHROME TEMPLATE
// ============================================================================
void buildElegantMonochromeTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF18181B);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11,
    uppercaseHeaders: true,
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
      margin: const pw.EdgeInsets.fromLTRB(45, 40, 45, 40),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey400),
        ),
      ),
      build: (context) => [
        pw.Text(
          name.isEmpty ? 'YOUR NAME' : name.toUpperCase(),
          style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: accent, letterSpacing: 2),
        ),
        if (title.isNotEmpty) pw.SizedBox(height: 2),
        if (title.isNotEmpty)
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(font: style.regularFont, fontSize: 10, color: PdfColors.grey600, letterSpacing: 1.2),
          ),
        pw.SizedBox(height: 6),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Text(
            [email, phone].where((s) => s.isNotEmpty).join('   /   '),
            style: pw.TextStyle(font: style.regularFont, fontSize: 9, color: PdfColors.grey500),
          ),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 10),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('About', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.6)),
          pw.SizedBox(height: 10),
        ],
        ...buildAllSections(resume, style),
      ],
    ),
  );
}

// ============================================================================
// 9. BOLD HEADER TEMPLATE
// ============================================================================
void buildBoldHeaderTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF059669);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11.5,
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
      margin: const pw.EdgeInsets.fromLTRB(0, 0, 0, 36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(right: 36),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey500),
          ),
        ),
      ),
      build: (context) => [
        pw.Container(
          width: double.infinity,
          color: accent,
          padding: const pw.EdgeInsets.fromLTRB(36, 28, 36, 22),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: PdfColors.white)),
                  if (title.isNotEmpty)
                    pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColor.fromInt(0xFFA7F3D0))),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 9.5, color: PdfColor.fromInt(0xFFECFDF5))),
                  if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 9.5, color: PdfColor.fromInt(0xFFECFDF5))),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        if (summary.isNotEmpty) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 36),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Profile', style),
                pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
        ],
        ...buildAllSections(resume, style)
            .map((w) => pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 36), child: w)),
      ],
    ),
  );
}

// ============================================================================
// 10. CLEAN TWO-COLUMN TEMPLATE
// ============================================================================
void buildCleanTwoColumnTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF4F46E5);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey600,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 11,
  );

  final personal = personalInfo(resume) ?? {};
  final name = field(personal, 'fullName');
  final title = field(personal, 'title');
  final email = field(personal, 'email');
  final phone = field(personal, 'phone');
  final summary = resume.summary.trim();
  final skills = skillLabels(resume);

  final bodyOrder = resumeSectionOrder.where((k) => k != 'skills').toList();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 36),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 8, color: PdfColors.grey500),
        ),
      ),
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 24, color: accent)),
                if (title.isNotEmpty)
                  pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
                if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: style.regularFont, fontSize: 9)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: accent, thickness: 1.2),
        pw.SizedBox(height: 8),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Professional Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 10),
        ],
        if (skills.isNotEmpty) ...[
          buildSectionHeader('Core Competencies', style),
          pw.Wrap(
            spacing: 6,
            runSpacing: 5,
            children: skills
                .map((s) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFEEF2FF),
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: PdfColor.fromInt(0xFFC7D2FE), width: 0.5),
                      ),
                      child: pw.Text(s, style: pw.TextStyle(font: style.regularFont, fontSize: 9, color: PdfColor.fromInt(0xFF312E81))),
                    ))
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        ...bodyOrder.expand((key) => buildEntrySectionWidgets(key, resume, style)),
      ],
    ),
  );
}

// ============================================================================
// 11. COMPACT ATS PRO TEMPLATE
// ============================================================================
void buildCompactAtsTemplate(pw.Document doc, ResumeModel resume) {
  final accent = PdfColor.fromInt(0xFF374151);
  final style = PdfSectionStyle(
    accent: accent,
    mutedText: PdfColors.grey700,
    regularFont: pw.Font.helvetica(),
    boldFont: pw.Font.helveticaBold(),
    headerFontSize: 10.5,
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
      margin: const pw.EdgeInsets.fromLTRB(30, 24, 30, 24),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: style.regularFont, fontSize: 7.5, color: PdfColors.grey500),
        ),
      ),
      build: (context) => [
        pw.Center(
          child: pw.Text(name.isEmpty ? 'Your Name' : name, style: pw.TextStyle(font: style.boldFont, fontSize: 18, color: accent)),
        ),
        pw.SizedBox(height: 2),
        if (title.isNotEmpty)
          pw.Center(
            child: pw.Text(title, style: pw.TextStyle(font: style.regularFont, fontSize: 10.5, color: PdfColors.grey800)),
          ),
        pw.SizedBox(height: 2),
        if (email.isNotEmpty || phone.isNotEmpty)
          pw.Center(
            child: pw.Text([email, phone].where((s) => s.isNotEmpty).join(' | '), style: pw.TextStyle(font: style.regularFont, fontSize: 8.5)),
          ),
        pw.SizedBox(height: 8),
        if (summary.isNotEmpty) ...[
          buildSectionHeader('Summary', style),
          pw.Text(summary, style: pw.TextStyle(font: style.regularFont, fontSize: 9.5, lineSpacing: 1.3)),
          pw.SizedBox(height: 6),
        ],
        ...buildAllSections(resume, style, skillsAsChips: false),
      ],
    ),
  );
}
