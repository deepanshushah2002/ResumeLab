import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../providers/resume_provider.dart';
import '../models/resume_model.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGenerating = false;
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateAndDownload(ResumeModel resume) async {
    setState(() => _isGenerating = true);
    try {
      final pdfBytes = Uint8List.fromList(await PdfService.generatePdfBytes(resume));
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        final name = resume.personalInfo.fullName.isNotEmpty
            ? resume.personalInfo.fullName.replaceAll(' ', '_')
            : 'Resume';
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: '${name}_Resume.pdf',
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _printPdf(ResumeModel resume) async {
    await PdfService.printResume(resume);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final resume = provider.currentResume;
        if (resume == null) {
          return const Scaffold(body: Center(child: Text('No resume data')));
        }
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor(context),
          appBar: AppBar(
            title: const Text('Preview & Export'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textLightColor(context),
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(text: 'Preview'),
                Tab(text: 'Score'),
                Tab(text: 'Template'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PreviewTab(resume: resume),
                    _ScoreTab(resume: resume),
                    // BUG 3 FIX: _TemplateTab now uses Consumer internally
                    const _TemplateTab(),
                  ],
                ),
              ),
              _ExportBar(
                isGenerating: _isGenerating,
                onDownload: () => _generateAndDownload(resume),
                onPrint: () => _printPdf(resume),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── PREVIEW TAB ─────────────────────────────────────────────────────────────
class _PreviewTab extends StatelessWidget {
  final ResumeModel resume;
  const _PreviewTab({required this.resume});

  @override
  Widget build(BuildContext context) {
    final info = resume.personalInfo;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.fullName.isNotEmpty ? info.fullName : 'Your Name',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDarkColor(context)),
                ),
                if (info.jobTitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(info.jobTitle,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500)),
                ],
                const SizedBox(height: 10),
                Wrap(spacing: 12, runSpacing: 4, children: [
                  if (info.email.isNotEmpty)
                    _ContactChip(Icons.email_rounded, info.email),
                  if (info.phone.isNotEmpty)
                    _ContactChip(Icons.phone_rounded, info.phone),
                  if (info.location.isNotEmpty)
                    _ContactChip(Icons.location_on_rounded, info.location),
                  if (info.linkedIn.isNotEmpty)
                    _ContactChip(Icons.link_rounded, info.linkedIn),
                ]),
                const Divider(height: 24),

                if (info.professionalSummary.isNotEmpty) ...[
                  const _PreviewSectionTitle('PROFESSIONAL SUMMARY'),
                  const SizedBox(height: 6),
                  Text(info.professionalSummary,
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMediumColor(context),
                          height: 1.5)),
                  const SizedBox(height: 16),
                ],

                if (resume.workExperiences.isNotEmpty) ...[
                  const _PreviewSectionTitle('WORK EXPERIENCE'),
                  const SizedBox(height: 8),
                  ...resume.workExperiences.map((exp) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(exp.jobTitle,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.textDarkColor(context))),
                            ),
                            Text(
                                '${exp.startDate} – ${exp.isCurrent ? 'Present' : exp.endDate}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textLightColor(context))),
                          ],
                        ),
                        Text(exp.companyName,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontStyle: FontStyle.italic)),
                        if (exp.responsibilities.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(exp.responsibilities,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMediumColor(context),
                                  height: 1.4)),
                        ],
                      ],
                    ),
                  )),
                ],

                if (resume.educations.isNotEmpty) ...[
                  const _PreviewSectionTitle('EDUCATION'),
                  const SizedBox(height: 8),
                  ...resume.educations.map((edu) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${edu.degree} – ${edu.fieldOfStudy}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppTheme.textDarkColor(context))),
                              Text(edu.institution,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMediumColor(context))),
                            ],
                          ),
                        ),
                        Text('${edu.startYear}–${edu.endYear}',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLightColor(context))),
                      ],
                    ),
                  )),
                ],

                if (resume.skills.isNotEmpty) ...[
                  const _PreviewSectionTitle('SKILLS'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: resume.skills
                        .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.borderColor(context)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMediumColor(context))),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                if (resume.projects.isNotEmpty) ...[
                  const _PreviewSectionTitle('PROJECTS'),
                  const SizedBox(height: 8),
                  ...resume.projects.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textDarkColor(context))),
                        if (p.technologies.isNotEmpty)
                          Text(p.technologies,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.primary)),
                        if (p.description.isNotEmpty)
                          Text(p.description,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMediumColor(context))),
                      ],
                    ),
                  )),
                ],

                // BUG 1 FIX: Certifications section was missing from preview
                if (resume.certifications.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const _PreviewSectionTitle('CERTIFICATIONS'),
                  const SizedBox(height: 8),
                  ...resume.certifications.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppTheme.textDarkColor(context))),
                              Text(c.organization,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primary)),
                            ],
                          ),
                        ),
                        if (c.issueDate.isNotEmpty)
                          Text(c.issueDate,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLightColor(context))),
                      ],
                    ),
                  )),
                ],

                if (resume.languages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const _PreviewSectionTitle('LANGUAGES'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: resume.languages
                        .map((l) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.name,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDarkColor(context))),
                        const SizedBox(width: 4),
                        Text('· ${l.proficiency}',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMediumColor(context))),
                      ],
                    ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textLightColor(context)),
        const SizedBox(width: 3),
        Text(text,
            style:
            TextStyle(fontSize: 11, color: AppTheme.textMediumColor(context))),
      ],
    );
  }
}

class _PreviewSectionTitle extends StatelessWidget {
  final String title;
  const _PreviewSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppTheme.primary)),
        const SizedBox(height: 4),
        Divider(height: 1, color: AppTheme.borderColor(context)),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── SCORE TAB ────────────────────────────────────────────────────────────────
class _ScoreTab extends StatelessWidget {
  final ResumeModel resume;
  const _ScoreTab({required this.resume});

  @override
  Widget build(BuildContext context) {
    final score = resume.resumeScore;
    final suggestions = resume.scoreSuggestions;
    final color = score >= 80
        ? AppTheme.success
        : score >= 50
        ? AppTheme.warning
        : AppTheme.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircularPercentIndicator(
              radius: 90,
              lineWidth: 12,
              percent: score / 100,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$score%',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  Text('ATS Score',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLightColor(context))),
                ],
              ),
              progressColor: color,
              backgroundColor: AppTheme.borderColor(context),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          const SizedBox(height: 24),
          Text('Score Breakdown',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          _ScoreItem('Full name', resume.personalInfo.fullName.isNotEmpty, 10),
          _ScoreItem('Professional summary',
              resume.personalInfo.professionalSummary.isNotEmpty, 15),
          _ScoreItem(
              'Work experience', resume.workExperiences.isNotEmpty, 25),
          _ScoreItem('Education', resume.educations.isNotEmpty, 15),
          _ScoreItem('5+ skills', resume.skills.length >= 5, 10),
          _ScoreItem('Email', resume.personalInfo.email.isNotEmpty, 5),
          _ScoreItem('Phone', resume.personalInfo.phone.isNotEmpty, 5),
          _ScoreItem('LinkedIn', resume.personalInfo.linkedIn.isNotEmpty, 5),
          _ScoreItem('Projects', resume.projects.isNotEmpty, 5),
          _ScoreItem('Certifications', resume.certifications.isNotEmpty, 5),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Improvements',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 16, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMediumColor(context)))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final bool completed;
  final int points;
  const _ScoreItem(this.label, this.completed, this.points);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: completed
                  ? AppTheme.success.withOpacity(0.12)
                  : AppTheme.borderColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.remove_rounded,
              size: 14,
              color:
              completed ? AppTheme.success : AppTheme.textLightColor(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: completed
                          ? AppTheme.textDarkColor(context)
                          : AppTheme.textLightColor(context)))),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: completed
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.borderColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('+$points pts',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: completed
                        ? AppTheme.success
                        : AppTheme.textLightColor(context))),
          ),
        ],
      ),
    );
  }
}

// ─── TEMPLATE TAB ────────────────────────────────────────────────────────
class _TemplateTab extends StatelessWidget {
  const _TemplateTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final resume = provider.currentResume;
        if (resume == null) return const SizedBox.shrink();

        final templates = [
          _TemplateInfo(id: 'minimal',         name: 'Minimal Pro',   tag: 'ATS Best',   accentColor: const Color(0xFF1B4FE4), style: _TplStyle.minimal),
          _TemplateInfo(id: 'modern',           name: 'Modern Clean',  tag: 'Popular',    accentColor: const Color(0xFF4B75F0), style: _TplStyle.modern),
          _TemplateInfo(id: 'compact',          name: 'Compact Dark',  tag: 'Compact',    accentColor: const Color(0xFF0D1B3E), style: _TplStyle.compact),
          _TemplateInfo(id: 'executive',        name: 'Executive',     tag: 'Senior',     accentColor: const Color(0xFF1a1a2e), style: _TplStyle.executive),
          _TemplateInfo(id: 'teal',             name: 'Teal Accent',   tag: 'Fresh',      accentColor: const Color(0xFF00C7BE), style: _TplStyle.teal),
          _TemplateInfo(id: 'minimal_two_col',  name: 'Two Column',    tag: 'Organized',  accentColor: const Color(0xFF6366F1), style: _TplStyle.twoCol),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Template', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('All templates are 90%+ ATS compatible', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
                children: templates.map((t) {
                  final isSelected = resume.templateId == t.id;
                  return GestureDetector(
                    onTap: () => provider.updateTemplate(t.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.borderColor(context),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(color: AppTheme.primary.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4)),
                        ] : [],
                      ),
                      child: Column(
                        children: [
                          // Template preview drawing
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                              child: CustomPaint(
                                size: const Size(double.infinity, double.infinity),
                                painter: _TemplatePainter(t.style, t.accentColor),
                              ),
                            ),
                          ),
                          // Label row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor(context),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.name,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? AppTheme.primary : AppTheme.textDarkColor(context))),
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: t.accentColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(t.tag,
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: t.accentColor)),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  size: 18,
                                  color: isSelected ? AppTheme.primary : AppTheme.textLightColor(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Select a template then tap Download PDF to generate.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMediumColor(context))),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _TplStyle { minimal, modern, compact, executive, teal, twoCol }

class _TemplateInfo {
  final String id, name, tag;
  final Color accentColor;
  final _TplStyle style;
  const _TemplateInfo({required this.id, required this.name, required this.tag, required this.accentColor, required this.style});
}

// Draws a tiny resume preview for each template style
class _TemplatePainter extends CustomPainter {
  final _TplStyle style;
  final Color accent;
  const _TemplatePainter(this.style, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bg = const Color(0xFFFFFFFF);
    final lineColor = const Color(0xFFE2E8F0);
    final darkText = const Color(0xFF1a1a2e);
    final midText = const Color(0xFF9099AA);

    // White background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bg);

    switch (style) {
      case _TplStyle.minimal:
        _drawMinimal(canvas, w, h, accent, darkText, midText, lineColor);
        break;
      case _TplStyle.modern:
        _drawModern(canvas, w, h, accent, darkText, midText);
        break;
      case _TplStyle.compact:
        _drawCompact(canvas, w, h, accent, darkText, midText);
        break;
      case _TplStyle.executive:
        _drawExecutive(canvas, w, h, accent, darkText, midText, lineColor);
        break;
      case _TplStyle.teal:
        _drawTeal(canvas, w, h, accent, darkText, midText);
        break;
      case _TplStyle.twoCol:
        _drawTwoCol(canvas, w, h, accent, darkText, midText);
        break;
    }
  }

  void _rect(Canvas c, double x, double y, double w, double h, Color color, {double r = 0}) {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), Paint()..color = color);
  }

  void _drawMinimal(Canvas c, double w, double h, Color accent, Color dark, Color mid, Color line) {
    final p = w * 0.08;
    // Name block
    _rect(c, p, p, w * 0.55, 6, dark);
    _rect(c, p, p + 9, w * 0.35, 3.5, accent);
    // Divider
    c.drawLine(Offset(p, p + 18), Offset(w - p, p + 18), Paint()..color = line..strokeWidth = 0.8);
    // Section label
    _rect(c, p, p + 24, w * 0.25, 2.5, accent);
    c.drawLine(Offset(p, p + 29), Offset(w - p, p + 29), Paint()..color = line..strokeWidth = 0.5);
    // Text lines
    for (var i = 0; i < 3; i++) {
      _rect(c, p, p + 33 + i * 6, w * (0.7 - i * 0.1), 2.5, mid);
    }
    // Section 2
    _rect(c, p, p + 57, w * 0.2, 2.5, accent);
    c.drawLine(Offset(p, p + 62), Offset(w - p, p + 62), Paint()..color = line..strokeWidth = 0.5);
    for (var i = 0; i < 4; i++) {
      _rect(c, p, p + 66 + i * 6, w * (0.65 - i * 0.08), 2.5, mid);
    }
    // Skills chips
    _rect(c, p, p + 94, w * 0.22, 6, const Color(0xFFEEF2FF), r: 2);
    _rect(c, p + w * 0.26, p + 94, w * 0.18, 6, const Color(0xFFEEF2FF), r: 2);
    _rect(c, p + w * 0.48, p + 94, w * 0.20, 6, const Color(0xFFEEF2FF), r: 2);
  }

  void _drawModern(Canvas c, double w, double h, Color accent, Color dark, Color mid) {
    final sideW = w * 0.32;
    // Sidebar bg
    _rect(c, 0, 0, sideW, h, accent);
    // Sidebar lines
    final sw = sideW * 0.7;
    final sx = sideW * 0.15;
    _rect(c, sx, 14, sw, 5, Colors.white.withOpacity(0.9));
    _rect(c, sx, 22, sw * 0.7, 3, Colors.white.withOpacity(0.5));
    for (var i = 0; i < 5; i++) {
      _rect(c, sx, 34 + i * 7, sw * (0.9 - i * 0.1), 2.5, Colors.white.withOpacity(0.4));
    }
    for (var i = 0; i < 3; i++) {
      _rect(c, sx, 78 + i * 6, sw * 0.7, 2.5, Colors.white.withOpacity(0.35));
    }
    // Main content
    final mx = sideW + 8;
    final mw = w - mx - 6;
    _rect(c, mx, 10, mw * 0.7, 5, dark);
    _rect(c, mx, 18, mw * 0.45, 3, accent);
    _rect(c, mx, 26, mw, 0.8, const Color(0xFFE2E8F0));
    for (var i = 0; i < 4; i++) {
      _rect(c, mx, 32 + i * 6, mw * (0.9 - i * 0.1), 2.5, const Color(0xFFBBBBCC));
    }
    _rect(c, mx, 60, mw, 0.8, const Color(0xFFE2E8F0));
    for (var i = 0; i < 3; i++) {
      _rect(c, mx, 66 + i * 6, mw * (0.85 - i * 0.12), 2.5, const Color(0xFFBBBBCC));
    }
  }

  void _drawCompact(Canvas c, double w, double h, Color accent, Color dark, Color mid) {
    // Dark header
    _rect(c, 0, 0, w, h * 0.26, dark);
    _rect(c, 8, 8, w * 0.5, 6, Colors.white.withOpacity(0.9));
    _rect(c, 8, 17, w * 0.3, 3.5, const Color(0xFF00C7BE));
    _rect(c, 8, 24, w * 0.7, 2, Colors.white.withOpacity(0.3));
    // Two columns below
    final colW = (w - 20) / 2;
    for (var i = 0; i < 5; i++) {
      _rect(c, 8, h * 0.3 + i * 8, colW * 0.9, 3, const Color(0xFFBBBBCC));
    }
    for (var i = 0; i < 4; i++) {
      _rect(c, 8 + colW + 4, h * 0.3 + i * 8, colW * 0.85, 3, const Color(0xFFBBBBCC));
    }
  }

  void _drawExecutive(Canvas c, double w, double h, Color accent, Color dark, Color mid, Color line) {
    final p = w * 0.08;
    // Centred name
    _rect(c, w * 0.2, p, w * 0.6, 6, dark);
    _rect(c, w * 0.3, p + 9, w * 0.4, 3.5, accent);
    _rect(c, w * 0.25, p + 16, w * 0.5, 2, mid);
    // Heavy accent line
    c.drawLine(Offset(p, p + 22), Offset(w - p, p + 22), Paint()..color = accent..strokeWidth = 2);
    // Section
    _rect(c, p, p + 28, w * 0.22, 3, accent);
    c.drawLine(Offset(p, p + 34), Offset(w - p, p + 34), Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 0.8);
    for (var i = 0; i < 3; i++) {
      _rect(c, p, p + 38 + i * 6, w * (0.75 - i * 0.1), 2.5, mid);
    }
    // Skill borders
    for (var i = 0; i < 3; i++) {
      final bx = p + i * (w * 0.25);
      _rect(c, bx, p + 64, 2, 10, accent);
      _rect(c, bx + 4, p + 66, w * 0.18, 2.5, mid);
    }
  }

  void _drawTeal(Canvas c, double w, double h, Color accent, Color dark, Color mid) {
    // Teal header
    _rect(c, 0, 0, w, h * 0.22, accent);
    _rect(c, 8, 7, w * 0.5, 5.5, Colors.white.withOpacity(0.95));
    _rect(c, 8, 15, w * 0.3, 3, Colors.white.withOpacity(0.65));
    // Teal contact strip
    _rect(c, 0, h * 0.22, w, h * 0.08, const Color(0xFFE6FFFE));
    _rect(c, 8, h * 0.24, w * 0.35, 2.5, const Color(0xFF00A099));
    _rect(c, w * 0.5, h * 0.24, w * 0.28, 2.5, const Color(0xFF00A099));
    // Teal section markers
    for (var s = 0; s < 2; s++) {
      final sy = h * 0.34 + s * 40;
      _rect(c, 6, sy, 3, 10, accent);
      _rect(c, 12, sy + 2, w * 0.22, 2.5, accent);
      c.drawLine(Offset(6, sy + 13), Offset(w - 6, sy + 13), Paint()..color = accent..strokeWidth = 0.6);
      for (var i = 0; i < 3; i++) {
        _rect(c, 8, sy + 17 + i * 6, w * (0.75 - i * 0.1), 2.5, mid);
      }
    }
    // Skill pills
    for (var i = 0; i < 3; i++) {
      _rect(c, 8 + i * (w * 0.3), h * 0.88, w * 0.24, 7, const Color(0xFFE6FFFE), r: 2);
    }
  }

  void _drawTwoCol(Canvas c, double w, double h, Color accent, Color dark, Color mid) {
    // Indigo header full width
    _rect(c, 0, 0, w, h * 0.2, accent);
    _rect(c, 8, 6, w * 0.5, 5.5, Colors.white.withOpacity(0.95));
    _rect(c, 8, 14, w * 0.3, 3, Colors.white.withOpacity(0.6));
    // Left sidebar
    final sW = w * 0.35;
    _rect(c, 0, h * 0.2, sW, h * 0.8, const Color(0xFFF4F4FF));
    for (var s = 0; s < 3; s++) {
      final sy = h * 0.24 + s * 26;
      _rect(c, 4, sy, sW * 0.55, 2.5, accent);
      c.drawLine(Offset(4, sy + 5), Offset(sW - 4, sy + 5), Paint()..color = accent..strokeWidth = 0.6);
      for (var i = 0; i < 2; i++) {
        _rect(c, 4, sy + 9 + i * 5, sW * (0.75 - i * 0.15), 2.2, mid);
      }
    }
    // Right main
    final mx = sW + 6;
    final mw = w - mx - 4;
    for (var s = 0; s < 2; s++) {
      final sy = h * 0.24 + s * 38;
      _rect(c, mx, sy, mw * 0.45, 2.5, accent);
      c.drawLine(Offset(mx, sy + 5), Offset(w - 4, sy + 5), Paint()..color = accent..strokeWidth = 0.6);
      for (var i = 0; i < 3; i++) {
        _rect(c, mx, sy + 9 + i * 6, mw * (0.9 - i * 0.15), 2.5, mid);
      }
    }
  }

  @override
  bool shouldRepaint(_TemplatePainter old) => old.style != style || old.accent != accent;
}

// ─── EXPORT BAR ───────────────────────────────────────────────────────────────
class _ExportBar extends StatelessWidget {
  final bool isGenerating;
  final VoidCallback onDownload;
  final VoidCallback onPrint;

  const _ExportBar({
    required this.isGenerating,
    required this.onDownload,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : onDownload,
              icon: isGenerating
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.download_rounded),
              label: Text(isGenerating ? 'Generating...' : 'Download PDF'),
            ),
          ),
          const SizedBox(width: 10),
          _IconBtn(
            icon: Icons.print_rounded,
            onTap: onPrint,
            color: AppTheme.textMediumColor(context),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _IconBtn(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}