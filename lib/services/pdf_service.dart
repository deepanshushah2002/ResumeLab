import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/resume_model.dart';

class PdfService {
  static Future<List<int>> generatePdfBytes(ResumeModel resume) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    _addTemplatePage(pdf, resume, fonts);
    return pdf.save();
  }

  static Future<File> generatePdf(ResumeModel resume) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    _addTemplatePage(pdf, resume, fonts);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/resume_${resume.personalInfo.fullName.replaceAll(" ", "_")}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static void _addTemplatePage(
      pw.Document pdf, ResumeModel resume, Map<String, pw.Font> fonts) {
    switch (resume.templateId) {
      case 'modern':
        pdf.addPage(_buildModernTemplate(resume, fonts));
        break;
      case 'compact':
        pdf.addPage(_buildCompactTemplate(resume, fonts));
        break;
      case 'executive':
        pdf.addPage(_buildExecutiveTemplate(resume, fonts));
        break;
      case 'teal':
        pdf.addPage(_buildTealTemplate(resume, fonts));
        break;
      case 'minimal_two_col':
        pdf.addPage(_buildTwoColumnTemplate(resume, fonts));
        break;
      default:
        pdf.addPage(_buildMinimalTemplate(resume, fonts));
    }
  }

  static Future<Map<String, pw.Font>> _loadFonts() async {
    return {
      'regular': await PdfGoogleFonts.latoRegular(),
      'bold': await PdfGoogleFonts.latoBold(),
      'italic': await PdfGoogleFonts.latoItalic(),
    };
  }

  // ─── MINIMAL TEMPLATE ────────────────────────────────────────────────────────
  static pw.Page _buildMinimalTemplate(
      ResumeModel resume, Map<String, pw.Font> fonts) {
    final info = resume.personalInfo;
    const black = PdfColors.black;
    const darkGrey = PdfColor.fromInt(0xFF1a1a2e);
    const midGrey = PdfColor.fromInt(0xFF555566);
    const lightGrey = PdfColor.fromInt(0xFFaaaaaa);
    const accentBlue = PdfColor.fromInt(0xFF1B4FE4);
    const borderGrey = PdfColor.fromInt(0xFFE2E8F0);

    pw.TextStyle heading(double size, {PdfColor? color}) => pw.TextStyle(
      font: fonts['bold'],
      fontSize: size,
      color: color ?? darkGrey,
    );

    pw.TextStyle body([PdfColor? color]) => pw.TextStyle(
      font: fonts['regular'],
      fontSize: 9.5,
      color: color ?? midGrey,
      lineSpacing: 1.2,
    );

    pw.Widget sectionTitle(String title) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 14),
        pw.Text(title.toUpperCase(),
            style: pw.TextStyle(
              font: fonts['bold'],
              fontSize: 8.5,
              letterSpacing: 1.5,
              color: accentBlue,
            )),
        pw.SizedBox(height: 4),
        pw.Divider(color: borderGrey, thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 40),
      build: (ctx) => [pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(info.fullName,
              style: pw.TextStyle(
                  font: fonts['bold'], fontSize: 26, color: darkGrey)),
          pw.SizedBox(height: 4),
          if (info.jobTitle.isNotEmpty)
            pw.Text(info.jobTitle, style: heading(12, color: accentBlue)),
          pw.SizedBox(height: 10),

          // Contact row
          pw.Wrap(
            spacing: 16,
            children: [
              if (info.email.isNotEmpty)
                _contactItem('Email: ${info.email}', fonts, lightGrey),
              if (info.phone.isNotEmpty)
                _contactItem('Tel: ${info.phone}', fonts, lightGrey),
              if (info.location.isNotEmpty)
                _contactItem('Loc: ${info.location}', fonts, lightGrey),
              if (info.linkedIn.isNotEmpty)
                _contactItem('LinkedIn: ${info.linkedIn}', fonts, lightGrey),
              if (info.portfolio.isNotEmpty)
                _contactItem('Portfolio: ${info.portfolio}', fonts, lightGrey),
            ],
          ),

          pw.Divider(color: borderGrey, thickness: 1.5),
          pw.SizedBox(height: 6),

          // Summary
          if (info.professionalSummary.isNotEmpty) ...[
            pw.Text(info.professionalSummary, style: body()),
            pw.SizedBox(height: 4),
          ],

          // Experience
          if (resume.workExperiences.isNotEmpty) ...[
            sectionTitle('Work Experience'),
            ...resume.workExperiences.map((exp) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(exp.jobTitle, style: heading(10.5)),
                    pw.Text(
                      '${exp.startDate} – ${exp.isCurrent ? 'Present' : exp.endDate}',
                      style: body(lightGrey),
                    ),
                  ],
                ),
                pw.Text(
                  '${exp.companyName}${exp.location.isNotEmpty ? '  ·  ${exp.location}' : ''}',
                  style: pw.TextStyle(
                      font: fonts['italic'], fontSize: 9.5, color: midGrey),
                ),
                pw.SizedBox(height: 4),
                if (exp.responsibilities.isNotEmpty)
                  pw.Text(exp.responsibilities, style: body()),
                pw.SizedBox(height: 10),
              ],
            )),
          ],

          // Education
          if (resume.educations.isNotEmpty) ...[
            sectionTitle('Education'),
            ...resume.educations.map((edu) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${edu.degree} in ${edu.fieldOfStudy}',
                        style: heading(10.5)),
                    pw.Text('${edu.startYear} – ${edu.endYear}',
                        style: body(lightGrey)),
                  ],
                ),
                pw.Text(edu.institution, style: body()),
                if (edu.gpa.isNotEmpty)
                  pw.Text('GPA: ${edu.gpa}', style: body()),
                pw.SizedBox(height: 8),
              ],
            )),
          ],

          // Skills
          if (resume.skills.isNotEmpty) ...[
            sectionTitle('Skills'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 6,
              children: resume.skills
                  .map((skill) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderGrey),
                  borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(skill, style: body(midGrey)),
              ))
                  .toList(),
            ),
          ],

          // Projects
          if (resume.projects.isNotEmpty) ...[
            sectionTitle('Projects'),
            ...resume.projects.map((p) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(p.name, style: heading(10.5)),
                if (p.technologies.isNotEmpty)
                  pw.Text('Tech: ${p.technologies}', style: body()),
                if (p.description.isNotEmpty)
                  pw.Text(p.description, style: body()),
                if (p.githubLink.isNotEmpty)
                  pw.Text('GitHub: ${p.githubLink}',
                      style: body(accentBlue)),
                pw.SizedBox(height: 8),
              ],
            )),
          ],

          // Certifications
          if (resume.certifications.isNotEmpty) ...[
            sectionTitle('Certifications'),
            ...resume.certifications.map((c) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(c.name, style: heading(10.5)),
                    pw.Text(c.issueDate, style: body(lightGrey)),
                  ],
                ),
                pw.Text(c.organization, style: body()),
                pw.SizedBox(height: 8),
              ],
            )),
          ],

          // Languages
          if (resume.languages.isNotEmpty) ...[
            sectionTitle('Languages'),
            pw.Wrap(
              spacing: 20,
              children: resume.languages
                  .map((l) => pw.Text('${l.name} – ${l.proficiency}',
                  style: body()))
                  .toList(),
            ),
          ],
        ],
      )],
    );
  }

  // ─── MODERN TEMPLATE ─────────────────────────────────────────────────────────
  static pw.Page _buildModernTemplate(
      ResumeModel resume, Map<String, pw.Font> fonts) {
    final info = resume.personalInfo;
    const sidebarBg = PdfColor.fromInt(0xFF1B4FE4);
    const bodyBg = PdfColors.white;
    const sidebarText = PdfColors.white;
    const bodyText = PdfColor.fromInt(0xFF1a1a2e);
    const mutedText = PdfColor.fromInt(0xFF555566);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Sidebar
          pw.Container(
            width: 190,
            constraints:
            const pw.BoxConstraints(minHeight: double.infinity),
            color: sidebarBg,
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 16),
                pw.Text(info.fullName,
                    style: pw.TextStyle(
                        font: fonts['bold'],
                        fontSize: 18,
                        color: sidebarText)),
                if (info.jobTitle.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(info.jobTitle,
                      style: pw.TextStyle(
                          font: fonts['regular'],
                          fontSize: 11,
                          color: PdfColor.fromInt(0xB3FFFFFF))),
                ],
                pw.SizedBox(height: 20),

                _sidebarSection('CONTACT', fonts, sidebarText),
                if (info.email.isNotEmpty) _sidebarItem('Email: ${info.email}', fonts),
                if (info.phone.isNotEmpty) _sidebarItem('Tel: ${info.phone}', fonts),
                if (info.location.isNotEmpty)
                  _sidebarItem('Loc: ${info.location}', fonts),
                if (info.linkedIn.isNotEmpty)
                  _sidebarItem('LinkedIn: ${info.linkedIn}', fonts),

                if (resume.skills.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  _sidebarSection('SKILLS', fonts, sidebarText),
                  ...resume.skills.map((s) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(children: [
                      pw.Container(
                        width: 4,
                        height: 4,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.white,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(s,
                          style: pw.TextStyle(
                              font: fonts['regular'],
                              fontSize: 9,
                              color: PdfColor.fromInt(0xB3FFFFFF))),
                    ]),
                  )),
                ],

                if (resume.languages.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  _sidebarSection('LANGUAGES', fonts, sidebarText),
                  ...resume.languages.map((l) => _sidebarItem(
                      '${l.name} · ${l.proficiency}', fonts)),
                ],
              ],
            ),
          ),

          // Main content
          pw.Expanded(
            child: pw.Container(
              color: bodyBg,
              padding: const pw.EdgeInsets.all(28),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (info.professionalSummary.isNotEmpty) ...[
                    _modernSectionTitle('PROFESSIONAL SUMMARY', fonts),
                    pw.Text(info.professionalSummary,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 9.5,
                            color: mutedText,
                            lineSpacing: 1.4)),
                    pw.SizedBox(height: 12),
                  ],
                  if (resume.workExperiences.isNotEmpty) ...[
                    _modernSectionTitle('EXPERIENCE', fonts),
                    ...resume.workExperiences.map((exp) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(exp.jobTitle,
                                style: pw.TextStyle(
                                    font: fonts['bold'],
                                    fontSize: 10.5,
                                    color: bodyText)),
                            pw.Text(
                                '${exp.startDate}–${exp.isCurrent ? 'Present' : exp.endDate}',
                                style: pw.TextStyle(
                                    font: fonts['regular'],
                                    fontSize: 9,
                                    color: mutedText)),
                          ],
                        ),
                        pw.Text(exp.companyName,
                            style: pw.TextStyle(
                                font: fonts['italic'],
                                fontSize: 9.5,
                                color: sidebarBg)),
                        pw.SizedBox(height: 4),
                        if (exp.responsibilities.isNotEmpty)
                          pw.Text(exp.responsibilities,
                              style: pw.TextStyle(
                                  font: fonts['regular'],
                                  fontSize: 9,
                                  color: mutedText)),
                        pw.SizedBox(height: 10),
                      ],
                    )),
                  ],
                  if (resume.educations.isNotEmpty) ...[
                    _modernSectionTitle('EDUCATION', fonts),
                    ...resume.educations.map((edu) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            '${edu.degree}${edu.fieldOfStudy.isNotEmpty ? ' – ${edu.fieldOfStudy}' : ''}',
                            style: pw.TextStyle(
                                font: fonts['bold'],
                                fontSize: 10,
                                color: bodyText)),
                        pw.Text(
                            '${edu.institution}  |  ${edu.startYear}–${edu.endYear}',
                            style: pw.TextStyle(
                                font: fonts['regular'],
                                fontSize: 9,
                                color: mutedText)),
                        pw.SizedBox(height: 8),
                      ],
                    )),
                  ],
                  if (resume.projects.isNotEmpty) ...[
                    _modernSectionTitle('PROJECTS', fonts),
                    ...resume.projects.map((p) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(p.name,
                            style: pw.TextStyle(
                                font: fonts['bold'],
                                fontSize: 10,
                                color: bodyText)),
                        if (p.technologies.isNotEmpty)
                          pw.Text('Stack: ${p.technologies}',
                              style: pw.TextStyle(
                                  font: fonts['italic'],
                                  fontSize: 9,
                                  color: sidebarBg)),
                        if (p.description.isNotEmpty)
                          pw.Text(p.description,
                              style: pw.TextStyle(
                                  font: fonts['regular'],
                                  fontSize: 9,
                                  color: mutedText)),
                        pw.SizedBox(height: 8),
                      ],
                    )),
                  ],
                  if (resume.certifications.isNotEmpty) ...[
                    _modernSectionTitle('CERTIFICATIONS', fonts),
                    ...resume.certifications.map((c) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(c.name,
                            style: pw.TextStyle(
                                font: fonts['bold'],
                                fontSize: 10,
                                color: bodyText)),
                        pw.Text(
                            '${c.organization}  ·  ${c.issueDate}',
                            style: pw.TextStyle(
                                font: fonts['regular'],
                                fontSize: 9,
                                color: mutedText)),
                        pw.SizedBox(height: 8),
                      ],
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── COMPACT TEMPLATE ────────────────────────────────────────────────────────
  static pw.Page _buildCompactTemplate(
      ResumeModel resume, Map<String, pw.Font> fonts) {
    final info = resume.personalInfo;
    const darkColor = PdfColor.fromInt(0xFF0D1B3E);
    const accentColor = PdfColor.fromInt(0xFF00C7BE);
    const mutedColor = PdfColor.fromInt(0xFF555566);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: darkColor,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(info.fullName,
                    style: pw.TextStyle(
                        font: fonts['bold'],
                        fontSize: 22,
                        color: PdfColors.white)),
                if (info.jobTitle.isNotEmpty)
                  pw.Text(info.jobTitle,
                      style: pw.TextStyle(
                          font: fonts['regular'],
                          fontSize: 11,
                          color: accentColor)),
                pw.SizedBox(height: 8),
                pw.Wrap(spacing: 12, children: [
                  if (info.email.isNotEmpty)
                    pw.Text(info.email,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 8.5,
                            color: PdfColor.fromInt(0xB3FFFFFF))),
                  if (info.phone.isNotEmpty)
                    pw.Text(info.phone,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 8.5,
                            color: PdfColor.fromInt(0xB3FFFFFF))),
                  if (info.location.isNotEmpty)
                    pw.Text(info.location,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 8.5,
                            color: PdfColor.fromInt(0xB3FFFFFF))),
                ]),
              ],
            ),
          ),

          pw.SizedBox(height: 12),
          if (info.professionalSummary.isNotEmpty) ...[
            pw.Text(info.professionalSummary,
                style: pw.TextStyle(
                    font: fonts['regular'],
                    fontSize: 9.5,
                    color: mutedColor,
                    lineSpacing: 1.3)),
            pw.SizedBox(height: 10),
          ],

          // Two column layout for skills + experience
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: Skills + Education
              pw.Container(
                width: 160,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (resume.skills.isNotEmpty) ...[
                      _compactSection('SKILLS', fonts, accentColor),
                      pw.SizedBox(height: 4),
                      pw.Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: resume.skills
                            .map((s) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: pw.BoxDecoration(
                            color: accentColor.shade(0.15),
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(3)),
                          ),
                          child: pw.Text(s,
                              style: pw.TextStyle(
                                  font: fonts['regular'],
                                  fontSize: 8,
                                  color: darkColor)),
                        ))
                            .toList(),
                      ),
                      pw.SizedBox(height: 10),
                    ],
                    if (resume.educations.isNotEmpty) ...[
                      _compactSection('EDUCATION', fonts, accentColor),
                      ...resume.educations.map((edu) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(edu.degree,
                                style: pw.TextStyle(
                                    font: fonts['bold'],
                                    fontSize: 9,
                                    color: darkColor)),
                            pw.Text(edu.institution,
                                style: pw.TextStyle(
                                    font: fonts['regular'],
                                    fontSize: 8.5,
                                    color: mutedColor)),
                            pw.Text('${edu.startYear}–${edu.endYear}',
                                style: pw.TextStyle(
                                    font: fonts['regular'],
                                    fontSize: 8,
                                    color: mutedColor)),
                          ],
                        ),
                      )),
                    ],
                    if (resume.languages.isNotEmpty) ...[
                      _compactSection('LANGUAGES', fonts, accentColor),
                      ...resume.languages.map((l) => pw.Text(
                        '${l.name}: ${l.proficiency}',
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 9,
                            color: mutedColor),
                      )),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(width: 16),

              // Right: Experience + Projects
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (resume.workExperiences.isNotEmpty) ...[
                      _compactSection('EXPERIENCE', fonts, accentColor),
                      ...resume.workExperiences.map((exp) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(exp.jobTitle,
                                    style: pw.TextStyle(
                                        font: fonts['bold'],
                                        fontSize: 9.5,
                                        color: darkColor)),
                                pw.Text(
                                    '${exp.startDate}–${exp.isCurrent ? 'Now' : exp.endDate}',
                                    style: pw.TextStyle(
                                        font: fonts['regular'],
                                        fontSize: 8,
                                        color: mutedColor)),
                              ],
                            ),
                            pw.Text(exp.companyName,
                                style: pw.TextStyle(
                                    font: fonts['italic'],
                                    fontSize: 9,
                                    color: accentColor)),
                            if (exp.responsibilities.isNotEmpty)
                              pw.Text(exp.responsibilities,
                                  style: pw.TextStyle(
                                      font: fonts['regular'],
                                      fontSize: 8.5,
                                      color: mutedColor,
                                      lineSpacing: 1.2)),
                          ],
                        ),
                      )),
                    ],
                    if (resume.projects.isNotEmpty) ...[
                      _compactSection('PROJECTS', fonts, accentColor),
                      ...resume.projects.map((p) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(p.name,
                                style: pw.TextStyle(
                                    font: fonts['bold'],
                                    fontSize: 9.5,
                                    color: darkColor)),
                            if (p.description.isNotEmpty)
                              pw.Text(p.description,
                                  style: pw.TextStyle(
                                      font: fonts['regular'],
                                      fontSize: 8.5,
                                      color: mutedColor)),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────
  static pw.Widget _contactItem(
      String text, Map<String, pw.Font> fonts, PdfColor color) =>
      pw.Text(text,
          style: pw.TextStyle(
              font: fonts['regular'], fontSize: 9, color: color));

  static pw.Widget _sidebarSection(
      String title, Map<String, pw.Font> fonts, PdfColor color) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title,
            style: pw.TextStyle(
                font: fonts['bold'],
                fontSize: 8,
                letterSpacing: 1.5,
                color: color)),
        pw.SizedBox(height: 6),
      ]);

  static pw.Widget _sidebarItem(String text, Map<String, pw.Font> fonts) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(text,
            style: pw.TextStyle(
                font: fonts['regular'],
                fontSize: 9,
                color: PdfColor.fromInt(0xB3FFFFFF))),
      );

  static pw.Widget _modernSectionTitle(
      String title, Map<String, pw.Font> fonts) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  font: fonts['bold'],
                  fontSize: 8,
                  letterSpacing: 1.5,
                  color: const PdfColor.fromInt(0xFF1B4FE4))),
          pw.SizedBox(height: 4),
          pw.Divider(
              color: const PdfColor.fromInt(0xFFE2E8F0), thickness: 1),
          pw.SizedBox(height: 8),
        ],
      );

  static pw.Widget _compactSection(
      String title, Map<String, pw.Font> fonts, PdfColor accent) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  font: fonts['bold'],
                  fontSize: 8,
                  letterSpacing: 1.5,
                  color: accent)),
          pw.SizedBox(height: 2),
          pw.Divider(color: accent, thickness: 0.8),
          pw.SizedBox(height: 6),
        ],
      );

  static Future<void> printResume(ResumeModel resume) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    _addTemplatePage(pdf, resume, fonts);
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // ─── EXECUTIVE TEMPLATE ──────────────────────────────────────────────────────
  static pw.Page _buildExecutiveTemplate(
      ResumeModel resume, Map<String, pw.Font> fonts) {
    final info = resume.personalInfo;
    const darkText = PdfColor.fromInt(0xFF1a1a2e);
    const midText  = PdfColor.fromInt(0xFF444455);
    const lightText= PdfColor.fromInt(0xFF888899);
    const accent   = PdfColor.fromInt(0xFF1B4FE4);
    const divLine  = PdfColor.fromInt(0xFFCCCCDD);

    pw.TextStyle bold(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['bold'], fontSize: sz, color: c ?? darkText);
    pw.TextStyle reg(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['regular'], fontSize: sz, color: c ?? midText, lineSpacing: 1.3);
    pw.TextStyle ital(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['italic'], fontSize: sz, color: c ?? accent);

    pw.Widget section(String title) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(title, style: bold(11, c: accent)),
        pw.Divider(color: accent, thickness: 0.8),
        pw.SizedBox(height: 6),
      ],
    );

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      build: (ctx) => [pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header — centred name block
          pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(info.fullName.toUpperCase(),
                    style: pw.TextStyle(
                        font: fonts['bold'],
                        fontSize: 22,
                        letterSpacing: 2.5,
                        color: darkText)),
                if (info.jobTitle.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(info.jobTitle, style: reg(11, c: accent)),
                ],
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 16,
                  children: [
                    if (info.email.isNotEmpty)
                      pw.Text(info.email, style: reg(9, c: lightText)),
                    if (info.phone.isNotEmpty)
                      pw.Text(info.phone, style: reg(9, c: lightText)),
                    if (info.location.isNotEmpty)
                      pw.Text(info.location, style: reg(9, c: lightText)),
                    if (info.linkedIn.isNotEmpty)
                      pw.Text(info.linkedIn, style: reg(9, c: lightText)),
                  ],
                ),
              ],
            ),
          ),
          pw.Divider(color: accent, thickness: 2),

          if (info.professionalSummary.isNotEmpty) ...[
            section('EXECUTIVE SUMMARY'),
            pw.Text(info.professionalSummary, style: reg(9.5)),
          ],

          if (resume.workExperiences.isNotEmpty) ...[
            section('PROFESSIONAL EXPERIENCE'),
            ...resume.workExperiences.map((exp) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(exp.jobTitle, style: bold(10.5)),
                      pw.Text(
                          '${exp.startDate} – ${exp.isCurrent ? 'Present' : exp.endDate}',
                          style: reg(9, c: lightText)),
                    ],
                  ),
                  pw.Text(exp.companyName, style: ital(9.5)),
                  if (exp.responsibilities.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text(exp.responsibilities, style: reg(9)),
                    ),
                ],
              ),
            )),
          ],

          if (resume.educations.isNotEmpty) ...[
            section('EDUCATION'),
            ...resume.educations.map((edu) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          '${edu.degree}${edu.fieldOfStudy.isNotEmpty ? ' in ${edu.fieldOfStudy}' : ''}',
                          style: bold(10)),
                      pw.Text(edu.institution, style: reg(9)),
                    ],
                  ),
                  pw.Text('${edu.startYear}–${edu.endYear}',
                      style: reg(9, c: lightText)),
                ],
              ),
            )),
          ],

          if (resume.skills.isNotEmpty) ...[
            section('CORE COMPETENCIES'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: resume.skills
                  .map((s) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  border: const pw.Border(
                    left: pw.BorderSide(color: accent, width: 2),
                  ),
                ),
                child: pw.Text(s, style: reg(9)),
              ))
                  .toList(),
            ),
          ],

          if (resume.certifications.isNotEmpty) ...[
            section('CERTIFICATIONS'),
            ...resume.certifications.map((c) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(c.name, style: bold(9.5)),
                    pw.Text(c.organization, style: reg(9, c: lightText)),
                  ]),
                  pw.Text(c.issueDate, style: reg(9, c: lightText)),
                ],
              ),
            )),
          ],
        ],
      )],
    );
  }

  // ─── TEAL ACCENT TEMPLATE ───────────────────────────────────────────────────
  static pw.Page _buildTealTemplate(
      ResumeModel resume, Map<String, pw.Font> fonts) {
    final info = resume.personalInfo;
    const teal    = PdfColor.fromInt(0xFF00C7BE);
    const darkText= PdfColor.fromInt(0xFF1a1a2e);
    const midText = PdfColor.fromInt(0xFF555566);
    const lightTxt= PdfColor.fromInt(0xFF999aaa);
    const tealBg  = PdfColor.fromInt(0xFFE6FFFE);

    pw.TextStyle bold(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['bold'], fontSize: sz, color: c ?? darkText);
    pw.TextStyle reg(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['regular'], fontSize: sz, color: c ?? midText, lineSpacing: 1.3);

    pw.Widget section(String title) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Row(children: [
          pw.Container(width: 4, height: 14,
              decoration: const pw.BoxDecoration(color: teal)),
          pw.SizedBox(width: 6),
          pw.Text(title,
              style: pw.TextStyle(
                  font: fonts['bold'],
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: teal)),
        ]),
        pw.SizedBox(height: 6),
      ],
    );

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => [pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Teal header bar
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const pw.BoxDecoration(color: teal),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(info.fullName,
                    style: pw.TextStyle(
                        font: fonts['bold'],
                        fontSize: 24,
                        color: PdfColors.white)),
                if (info.jobTitle.isNotEmpty)
                  pw.Text(info.jobTitle,
                      style: pw.TextStyle(
                          font: fonts['regular'],
                          fontSize: 11,
                          color: PdfColor.fromInt(0xCCFFFFFF))),
              ],
            ),
          ),
          // Contact strip
          pw.Container(
            color: tealBg,
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: pw.Wrap(spacing: 16, children: [
              if (info.email.isNotEmpty)
                pw.Text(info.email, style: reg(8.5, c: midText)),
              if (info.phone.isNotEmpty)
                pw.Text(info.phone, style: reg(8.5, c: midText)),
              if (info.location.isNotEmpty)
                pw.Text(info.location, style: reg(8.5, c: midText)),
              if (info.linkedIn.isNotEmpty)
                pw.Text(info.linkedIn, style: reg(8.5, c: midText)),
            ]),
          ),

          pw.SizedBox(height: 6),

          if (info.professionalSummary.isNotEmpty) ...[
            section('SUMMARY'),
            pw.Text(info.professionalSummary, style: reg(9.5)),
          ],

          if (resume.workExperiences.isNotEmpty) ...[
            section('EXPERIENCE'),
            ...resume.workExperiences.map((exp) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(exp.jobTitle, style: bold(10.5)),
                      pw.Text(
                          '${exp.startDate} – ${exp.isCurrent ? 'Present' : exp.endDate}',
                          style: reg(9, c: lightTxt)),
                    ],
                  ),
                  pw.Text(exp.companyName,
                      style: pw.TextStyle(
                          font: fonts['regular'],
                          fontSize: 9.5,
                          color: teal)),
                  if (exp.responsibilities.isNotEmpty)
                    pw.Text(exp.responsibilities, style: reg(9)),
                ],
              ),
            )),
          ],

          if (resume.educations.isNotEmpty) ...[
            section('EDUCATION'),
            ...resume.educations.map((edu) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      '${edu.degree} – ${edu.fieldOfStudy}  |  ${edu.institution}',
                      style: bold(9.5)),
                  pw.Text('${edu.startYear}–${edu.endYear}',
                      style: reg(9, c: lightTxt)),
                ],
              ),
            )),
          ],

          if (resume.skills.isNotEmpty) ...[
            section('SKILLS'),
            pw.Wrap(
              spacing: 6,
              runSpacing: 4,
              children: resume.skills
                  .map((s) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: tealBg,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(s, style: reg(8.5, c: midText)),
              ))
                  .toList(),
            ),
          ],

          if (resume.certifications.isNotEmpty) ...[
            section('CERTIFICATIONS'),
            ...resume.certifications.map((c) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${c.name}  ·  ${c.organization}',
                      style: bold(9.5)),
                  pw.Text(c.issueDate, style: reg(9, c: lightTxt)),
                ],
              ),
            )),
          ],

          if (resume.projects.isNotEmpty) ...[
            section('PROJECTS'),
            ...resume.projects.map((p) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(p.name, style: bold(10)),
                  if (p.technologies.isNotEmpty)
                    pw.Text('Stack: ${p.technologies}',
                        style: pw.TextStyle(
                            font: fonts['italic'],
                            fontSize: 9,
                            color: teal)),
                  if (p.description.isNotEmpty)
                    pw.Text(p.description, style: reg(9)),
                ],
              ),
            )),
          ],
        ],
      )],
    );
  }

  // ─── TWO-COLUMN TEMPLATE ────────────────────────────────────────────────────
  static pw.Page _buildTwoColumnTemplate(
      ResumeModel resume, Map<String, pw.Font> fonts) {
    final info = resume.personalInfo;
    const indigo  = PdfColor.fromInt(0xFF6366F1);
    const darkText= PdfColor.fromInt(0xFF1a1a2e);
    const midText = PdfColor.fromInt(0xFF555566);
    const lightTxt= PdfColor.fromInt(0xFF888899);
    const sideCol = PdfColor.fromInt(0xFFF4F4FF);

    pw.TextStyle bold(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['bold'], fontSize: sz, color: c ?? darkText);
    pw.TextStyle reg(double sz, {PdfColor? c}) => pw.TextStyle(
        font: fonts['regular'], fontSize: sz, color: c ?? midText, lineSpacing: 1.3);

    pw.Widget sideSection(String title, List<pw.Widget> items) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(title,
            style: pw.TextStyle(
                font: fonts['bold'],
                fontSize: 9,
                letterSpacing: 1.2,
                color: indigo)),
        pw.Divider(color: indigo, thickness: 0.8),
        pw.SizedBox(height: 5),
        ...items,
      ],
    );

    pw.Widget mainSection(String title, List<pw.Widget> items) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(title,
            style: pw.TextStyle(
                font: fonts['bold'],
                fontSize: 10,
                letterSpacing: 1.0,
                color: indigo)),
        pw.Divider(color: indigo, thickness: 0.8),
        pw.SizedBox(height: 5),
        ...items,
      ],
    );

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Full-width header
          pw.Container(
            width: double.infinity,
            color: indigo,
            padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(info.fullName,
                    style: pw.TextStyle(
                        font: fonts['bold'],
                        fontSize: 22,
                        color: PdfColors.white)),
                if (info.jobTitle.isNotEmpty)
                  pw.Text(info.jobTitle,
                      style: pw.TextStyle(
                          font: fonts['regular'],
                          fontSize: 11,
                          color: PdfColor.fromInt(0xCCFFFFFF))),
                pw.SizedBox(height: 6),
                pw.Wrap(spacing: 14, children: [
                  if (info.email.isNotEmpty)
                    pw.Text(info.email,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 8.5,
                            color: PdfColor.fromInt(0xB3FFFFFF))),
                  if (info.phone.isNotEmpty)
                    pw.Text(info.phone,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 8.5,
                            color: PdfColor.fromInt(0xB3FFFFFF))),
                  if (info.location.isNotEmpty)
                    pw.Text(info.location,
                        style: pw.TextStyle(
                            font: fonts['regular'],
                            fontSize: 8.5,
                            color: PdfColor.fromInt(0xB3FFFFFF))),
                ]),
              ],
            ),
          ),

          // Body: sidebar (30%) + main (70%)
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Left sidebar ──
                pw.Container(
                  width: 155,
                  color: sideCol,
                  padding: const pw.EdgeInsets.fromLTRB(16, 12, 14, 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (resume.skills.isNotEmpty)
                        sideSection('SKILLS', [
                          ...resume.skills.map((s) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 3),
                            child: pw.Row(children: [
                              pw.Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const pw.BoxDecoration(
                                      color: indigo,
                                      shape: pw.BoxShape.circle)),
                              pw.SizedBox(width: 5),
                              pw.Text(s, style: reg(8.5)),
                            ]),
                          )),
                        ]),

                      if (resume.educations.isNotEmpty)
                        sideSection('EDUCATION', [
                          ...resume.educations.map((edu) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(edu.degree, style: bold(8.5)),
                                pw.Text(edu.fieldOfStudy, style: reg(8)),
                                pw.Text(edu.institution,
                                    style: reg(8, c: lightTxt)),
                                pw.Text('${edu.startYear}–${edu.endYear}',
                                    style: reg(7.5, c: lightTxt)),
                              ],
                            ),
                          )),
                        ]),

                      if (resume.certifications.isNotEmpty)
                        sideSection('CERTIFICATIONS', [
                          ...resume.certifications.map((c) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 6),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(c.name, style: bold(8.5)),
                                pw.Text(c.organization,
                                    style: reg(8, c: lightTxt)),
                                if (c.issueDate.isNotEmpty)
                                  pw.Text(c.issueDate,
                                      style: reg(7.5, c: lightTxt)),
                              ],
                            ),
                          )),
                        ]),

                      if (resume.languages.isNotEmpty)
                        sideSection('LANGUAGES', [
                          ...resume.languages.map((l) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 3),
                            child: pw.Text('${l.name}: ${l.proficiency}',
                                style: reg(8.5)),
                          )),
                        ]),
                    ],
                  ),
                ),

                // ── Main content ──
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.fromLTRB(18, 12, 24, 16),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (info.professionalSummary.isNotEmpty) ...[
                          mainSection('SUMMARY', [
                            pw.Text(info.professionalSummary, style: reg(9.5)),
                          ]),
                        ],

                        if (resume.workExperiences.isNotEmpty)
                          mainSection('EXPERIENCE', [
                            ...resume.workExperiences.map((exp) => pw.Padding(
                              padding:
                              const pw.EdgeInsets.only(bottom: 10),
                              child: pw.Column(
                                crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(exp.jobTitle,
                                          style: bold(10.5)),
                                      pw.Text(
                                          '${exp.startDate}–${exp.isCurrent ? 'Present' : exp.endDate}',
                                          style: reg(8.5, c: lightTxt)),
                                    ],
                                  ),
                                  pw.Text(exp.companyName,
                                      style: pw.TextStyle(
                                          font: fonts['italic'],
                                          fontSize: 9.5,
                                          color: indigo)),
                                  if (exp.responsibilities.isNotEmpty)
                                    pw.Text(exp.responsibilities,
                                        style: reg(9)),
                                ],
                              ),
                            )),
                          ]),

                        if (resume.projects.isNotEmpty)
                          mainSection('PROJECTS', [
                            ...resume.projects.map((p) => pw.Padding(
                              padding:
                              const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Column(
                                crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(p.name, style: bold(10)),
                                  if (p.technologies.isNotEmpty)
                                    pw.Text('Stack: ${p.technologies}',
                                        style: pw.TextStyle(
                                            font: fonts['italic'],
                                            fontSize: 9,
                                            color: indigo)),
                                  if (p.description.isNotEmpty)
                                    pw.Text(p.description,
                                        style: reg(9)),
                                ],
                              ),
                            )),
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}