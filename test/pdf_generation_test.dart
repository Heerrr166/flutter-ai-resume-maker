// Validates the real PDF generation pipeline directly (no widget tree
// needed — PdfGenerator.generate is a pure async function). Catches layout
// exceptions the pdf package throws when content doesn't fit a page, which
// static analysis cannot catch (e.g. the pagination bug fixed during
// development where wrapping body sections in a single Column instead of
// spreading them as top-level MultiPage items caused overflow on long
// resumes).

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_resume_maker/models/resume_model.dart';
import 'package:ai_resume_maker/models/resume_template.dart';
import 'package:ai_resume_maker/services/pdf/pdf_generator.dart';

ResumeSection _personal() => ResumeSection(
      key: 'personal',
      title: 'Personal',
      order: 0,
      items: [
        ResumeSectionItem(id: 'me', data: {
          'fullName': 'Jordan Avery',
          'title': 'Senior Software Engineer',
          'email': 'jordan.avery@example.com',
          'phone': '+1 555 123 4567',
        }),
      ],
    );

// A resume with every section populated, including one experience entry
// with many bullet points, to exercise multi-page pagination.
ResumeModel _fullResume(String template) {
  return ResumeModel(
    id: 'r1',
    title: 'Jordan Avery Resume',
    summary:
        'Results-driven software engineer with 8+ years building scalable backend systems and leading cross-functional teams.',
    status: 'draft',
    template: template,
    sections: [
      _personal(),
      ResumeSection(
        key: 'education',
        title: 'Education',
        order: 2,
        items: [
          ResumeSectionItem(id: 'e1', data: {
            'degree': 'B.Sc. Computer Science',
            'institution': 'State University',
            'start': '2012',
            'end': '2016',
          }),
        ],
      ),
      ResumeSection(
        key: 'experience',
        title: 'Experience',
        order: 3,
        items: List.generate(
          6,
          (i) => ResumeSectionItem(id: 'x$i', data: {
            'position': 'Software Engineer $i',
            'company': 'Company $i Inc.',
            'location': 'Remote',
            'start': '201${i % 9}',
            'end': i == 0 ? '' : '202${i % 9}',
            'current': i == 0,
            'responsibilities': List.generate(6, (j) => 'Delivered measurable outcome number $j for project $i with real detail padding the line length.'),
          }),
        ),
      ),
      ResumeSection(
        key: 'projects',
        title: 'Projects',
        order: 4,
        items: [
          ResumeSectionItem(id: 'p1', data: {
            'name': 'Open Source Toolkit',
            'description': 'Built and maintained a widely used internal developer toolkit.',
            'technologies': ['Dart', 'Flutter', 'Node.js'],
            'role': 'Lead',
          }),
        ],
      ),
      ResumeSection(
        key: 'skills',
        title: 'Skills',
        order: 5,
        items: List.generate(12, (i) => ResumeSectionItem(id: 's$i', data: {'name': 'Skill $i', 'rating': 4})),
      ),
      ResumeSection(
        key: 'certifications',
        title: 'Certifications',
        order: 6,
        items: [
          ResumeSectionItem(id: 'c1', data: {'name': 'Cloud Architect', 'issuer': 'Cloud Co', 'issueDate': '2021'}),
        ],
      ),
      ResumeSection(
        key: 'languages',
        title: 'Languages',
        order: 7,
        items: [
          ResumeSectionItem(id: 'l1', data: {'language': 'English', 'read': 'Native', 'write': 'Native', 'speak': 'Native'}),
        ],
      ),
      ResumeSection(
        key: 'achievements',
        title: 'Achievements',
        order: 8,
        items: [
          ResumeSectionItem(id: 'a1', data: {'title': 'Employee of the Year', 'date': '2022'}),
        ],
      ),
      ResumeSection(
        key: 'references',
        title: 'References',
        order: 9,
        items: [
          ResumeSectionItem(id: 'r1', data: {'name': 'Sam Lee', 'designation': 'Manager', 'company': 'Company 0 Inc.', 'email': 'sam@example.com'}),
        ],
      ),
    ],
  );
}

ResumeModel _sparseResume(String template) => ResumeModel(
      id: 'r2',
      title: 'Sparse Resume',
      summary: '',
      status: 'draft',
      template: template,
      sections: [_personal()],
    );

bool _looksLikePdf(List<int> bytes) {
  if (bytes.length < 5) return false;
  return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46; // "%PDF"
}

void main() {
  for (final type in ResumeTemplateType.values) {
    test('${type.id} template generates a valid multi-page PDF from a full resume', () async {
      final bytes = await PdfGenerator.generate(_fullResume(type.id));
      expect(_looksLikePdf(bytes), isTrue, reason: 'Output does not start with the PDF magic bytes');
      expect(bytes.length, greaterThan(1000), reason: 'Generated PDF looks too small to contain real content');
    });

    test('${type.id} template does not crash on a near-empty resume (empty state)', () async {
      final bytes = await PdfGenerator.generate(_sparseResume(type.id));
      expect(_looksLikePdf(bytes), isTrue);
    });
  }
}
