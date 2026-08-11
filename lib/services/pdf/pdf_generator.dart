import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../models/resume_model.dart';
import '../../models/resume_template.dart';
import 'templates/creative_template.dart';
import 'templates/executive_template.dart';
import 'templates/minimal_ats_template.dart';
import 'templates/modern_template.dart';
import 'templates/professional_template.dart';

// Single entry point for both the live preview (via printing's PdfPreview)
// and the actual export/share — both use this exact function, so what the
// user previews is byte-for-byte what gets shared.
class PdfGenerator {
  static Future<Uint8List> generate(ResumeModel resume) async {
    final type = ResumeTemplateType.fromId(resume.template);
    final doc = pw.Document(title: resume.title.isEmpty ? 'Resume' : resume.title);

    switch (type) {
      case ResumeTemplateType.modern:
        buildModernTemplate(doc, resume);
        break;
      case ResumeTemplateType.minimalAts:
        buildMinimalAtsTemplate(doc, resume);
        break;
      case ResumeTemplateType.professional:
        buildProfessionalTemplate(doc, resume);
        break;
      case ResumeTemplateType.creative:
        buildCreativeTemplate(doc, resume);
        break;
      case ResumeTemplateType.executive:
        buildExecutiveTemplate(doc, resume);
        break;
    }

    return doc.save();
  }
}
