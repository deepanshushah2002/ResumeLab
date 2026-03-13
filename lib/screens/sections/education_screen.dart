import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';
import '../../theme/app_theme.dart';

const _uuid = Uuid();

// ─── EDUCATION ────────────────────────────────────────────────────────────────
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final educations = provider.currentResume?.educations ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.school_rounded, 'Education',
                  'Add your educational background'),
              const SizedBox(height: 20),
              ...educations.map((edu) => _EduCard(
                edu: edu,
                onEdit: () => _showForm(context, provider, edu: edu),
                onDelete: () => provider.deleteEducation(edu.id),
              )),
              _addButton(context, 'Add Education',
                      () => _showForm(context, provider)),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, ResumeProvider provider,
      {Education? edu}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EducationForm(
        education: edu,
        onSave: (e) {
          if (edu == null) provider.addEducation(e);
          else provider.updateEducation(e);
        },
      ),
    );
  }
}

class _EduCard extends StatelessWidget {
  final Education edu;
  final VoidCallback onEdit, onDelete;
  const _EduCard({required this.edu, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${edu.degree} in ${edu.fieldOfStudy}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
              Text(edu.institution,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
              Text('${edu.startYear} – ${edu.endYear}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            ]),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error)),
        ],
      ),
    );
  }
}

class _EducationForm extends StatefulWidget {
  final Education? education;
  final Function(Education) onSave;
  const _EducationForm({this.education, required this.onSave});

  @override
  State<_EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<_EducationForm> {
  final _degreeCtrl = TextEditingController();
  final _instCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.education;
    if (e != null) {
      _degreeCtrl.text = e.degree;
      _instCtrl.text = e.institution;
      _fieldCtrl.text = e.fieldOfStudy;
      _startCtrl.text = e.startYear;
      _endCtrl.text = e.endYear;
      _gpaCtrl.text = e.gpa;
    }
  }

  void _save() {
    widget.onSave(Education(
      id: widget.education?.id ?? _uuid.v4(),
      degree: _degreeCtrl.text,
      institution: _instCtrl.text,
      fieldOfStudy: _fieldCtrl.text,
      startYear: _startCtrl.text,
      endYear: _endCtrl.text,
      gpa: _gpaCtrl.text,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: widget.education == null ? 'Add Education' : 'Edit Education',
      onSave: _save,
      saveLabel: widget.education == null ? 'Add Education' : 'Save Changes',
      children: [
        _f(_degreeCtrl, "Degree *", "Bachelor's of Science"),
        _f(_instCtrl, 'Institution *', 'MIT'),
        _f(_fieldCtrl, 'Field of Study', 'Computer Science'),
        Row(children: [
          Expanded(child: _f(_startCtrl, 'Start Year', '2018')),
          const SizedBox(width: 12),
          Expanded(child: _f(_endCtrl, 'End Year', '2022')),
        ]),
        _f(_gpaCtrl, 'GPA (Optional)', '3.8/4.0'),
      ],
    );
  }

  Widget _f(TextEditingController c, String label, String hint) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(controller: c, decoration: InputDecoration(labelText: label, hintText: hint)),
      );
}

// ─── SKILLS ──────────────────────────────────────────────────────────────────
class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _ctrl = TextEditingController();
  String _selectedRole = 'Flutter Developer';

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final skills = provider.currentResume?.skills ?? [];
        final suggestions = roleKeywords[_selectedRole] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.psychology_rounded, 'Skills',
                  'Add your technical and soft skills'),
              const SizedBox(height: 20),

              // Custom skill input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Type a skill and press Add',
                        prefixIcon: Icon(Icons.add_circle_outline_rounded,
                            size: 20, color: AppTheme.textLightColor(context)),
                      ),
                      onFieldSubmitted: (v) {
                        if (v.trim().isNotEmpty) {
                          provider.addSkill(v.trim());
                          _ctrl.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_ctrl.text.trim().isNotEmpty) {
                        provider.addSkill(_ctrl.text.trim());
                        _ctrl.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 52),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ],
              ),

              // Added skills
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Added Skills (${skills.length})',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => Chip(
                    label: Text(s),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => provider.removeSkill(s),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppTheme.primary),
                    deleteIconColor: AppTheme.primary,
                  ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 20),
              // Role-based suggestions
              Text('Suggested by Role',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                dropdownColor: AppTheme.cardColor(context),
                style: TextStyle(
                  color: AppTheme.textDarkColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(labelText: 'Job Role'),
                items: roleKeywords.keys
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role,
                      style: TextStyle(
                          color: AppTheme.textDarkColor(context))),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((s) {
                  final added = skills.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: added,
                    onSelected: (_) {
                      if (added) provider.removeSkill(s);
                      else provider.addSkill(s);
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                        color: added ? Colors.white : AppTheme.primary),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── PROJECTS ────────────────────────────────────────────────────────────────
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final projects = provider.currentResume?.projects ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.rocket_launch_rounded, 'Projects',
                  'Showcase your best work'),
              const SizedBox(height: 20),
              ...projects.map((p) => _ProjectCard(
                project: p,
                onEdit: () => _showForm(context, provider, project: p),
                onDelete: () => provider.deleteProject(p.id),
              )),
              _addButton(context, 'Add Project', () => _showForm(context, provider)),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, ResumeProvider provider, {Project? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectForm(
        project: project,
        onSave: (p) {
          if (project == null) provider.addProject(p);
          else provider.updateProject(p);
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit, onDelete;
  const _ProjectCard({required this.project, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(project.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15))),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error)),
        ]),
        if (project.technologies.isNotEmpty)
          Text(project.technologies,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary, fontSize: 12)),
        if (project.description.isNotEmpty)
          Text(project.description,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}

class _ProjectForm extends StatefulWidget {
  final Project? project;
  final Function(Project) onSave;
  const _ProjectForm({this.project, required this.onSave});

  @override
  State<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<_ProjectForm> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _liveCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    if (p != null) {
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _techCtrl.text = p.technologies;
      _githubCtrl.text = p.githubLink;
      _liveCtrl.text = p.liveLink;
    }
  }

  void _save() {
    widget.onSave(Project(
      id: widget.project?.id ?? _uuid.v4(),
      name: _nameCtrl.text,
      description: _descCtrl.text,
      technologies: _techCtrl.text,
      githubLink: _githubCtrl.text,
      liveLink: _liveCtrl.text,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: widget.project == null ? 'Add Project' : 'Edit Project',
      onSave: _save,
      saveLabel: widget.project == null ? 'Add Project' : 'Save Changes',
      children: [
        _f(_nameCtrl, 'Project Name *', 'My Awesome App'),
        _f(_techCtrl, 'Technologies Used', 'Flutter, Firebase, REST API'),
        _f(_descCtrl, 'Description', 'A brief overview of the project...', maxLines: 3),
        _f(_githubCtrl, 'GitHub Link', 'github.com/username/project'),
        _f(_liveCtrl, 'Live / Demo Link', 'myproject.app'),
      ],
    );
  }

  Widget _f(TextEditingController c, String label, String hint, {int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(controller: c, maxLines: maxLines,
            decoration: InputDecoration(labelText: label, hintText: hint)),
      );
}

// ─── CERTIFICATIONS ───────────────────────────────────────────────────────────
class CertificationsScreen extends StatelessWidget {
  const CertificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final certs = provider.currentResume?.certifications ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.verified_rounded, 'Certifications',
                  'Add professional certifications'),
              const SizedBox(height: 20),
              ...certs.map((c) => _CertCard(
                cert: c,
                onEdit: () => _showForm(context, provider, cert: c),
                onDelete: () => provider.deleteCertification(c.id),
              )),
              _addButton(context, 'Add Certification', () => _showForm(context, provider)),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, ResumeProvider provider, {Certification? cert}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CertForm(
        cert: cert,
        onSave: (c) {
          if (cert == null) provider.addCertification(c);
          else provider.updateCertification(c);
        },
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final Certification cert;
  final VoidCallback onEdit, onDelete;
  const _CertCard({required this.cert, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(children: [
        const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cert.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
          Text(cert.organization, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
          Text(cert.issueDate, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
        ])),
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary)),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error)),
      ]),
    );
  }
}

class _CertForm extends StatefulWidget {
  final Certification? cert;
  final Function(Certification) onSave;
  const _CertForm({this.cert, required this.onSave});

  @override
  State<_CertForm> createState() => _CertFormState();
}

class _CertFormState extends State<_CertForm> {
  final _nameCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.cert;
    if (c != null) {
      _nameCtrl.text = c.name;
      _orgCtrl.text = c.organization;
      _dateCtrl.text = c.issueDate;
      _urlCtrl.text = c.credentialUrl;
    }
  }

  void _save() {
    widget.onSave(Certification(
      id: widget.cert?.id ?? _uuid.v4(),
      name: _nameCtrl.text,
      organization: _orgCtrl.text,
      issueDate: _dateCtrl.text,
      credentialUrl: _urlCtrl.text,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: widget.cert == null ? 'Add Certification' : 'Edit Certification',
      onSave: _save,
      saveLabel: widget.cert == null ? 'Add Certification' : 'Save Changes',
      children: [
        _f(_nameCtrl, 'Certification Name *', 'AWS Solutions Architect'),
        _f(_orgCtrl, 'Issuing Organization *', 'Amazon Web Services'),
        _f(_dateCtrl, 'Issue Date', 'March 2024'),
        _f(_urlCtrl, 'Credential URL', 'credential.example.com/abc123'),
      ],
    );
  }

  Widget _f(TextEditingController c, String label, String hint) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(controller: c,
            decoration: InputDecoration(labelText: label, hintText: hint)),
      );
}

// ─── LANGUAGES ────────────────────────────────────────────────────────────────
class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  static const _proficiencies = [
    'Native', 'Fluent', 'Advanced', 'Intermediate', 'Basic'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final languages = provider.currentResume?.languages ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.language_rounded, 'Languages',
                  'Languages you speak'),
              const SizedBox(height: 20),
              ...languages.map((l) => _LangCard(
                lang: l,
                onEdit: () => _showForm(context, provider, lang: l),
                onDelete: () => provider.deleteLanguage(l.id),
              )),
              _addButton(context, 'Add Language', () => _showForm(context, provider)),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, ResumeProvider provider, {Language? lang}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LangForm(
        lang: lang,
        onSave: (l) {
          if (lang == null) provider.addLanguage(l);
          else provider.updateLanguage(l);
        },
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final Language lang;
  final VoidCallback onEdit, onDelete;
  const _LangCard({required this.lang, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(children: [
        const Icon(Icons.language_rounded, color: AppTheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lang.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
          Text(lang.proficiency, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontSize: 12)),
        ])),
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded, size: 18, color: AppTheme.primary)),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error)),
      ]),
    );
  }
}

class _LangForm extends StatefulWidget {
  final Language? lang;
  final Function(Language) onSave;
  const _LangForm({this.lang, required this.onSave});

  @override
  State<_LangForm> createState() => _LangFormState();
}

class _LangFormState extends State<_LangForm> {
  final _nameCtrl = TextEditingController();
  String _proficiency = 'Intermediate';

  @override
  void initState() {
    super.initState();
    if (widget.lang != null) {
      _nameCtrl.text = widget.lang!.name;
      _proficiency = widget.lang!.proficiency;
    }
  }

  void _save() {
    widget.onSave(Language(
      id: widget.lang?.id ?? _uuid.v4(),
      name: _nameCtrl.text,
      proficiency: _proficiency,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: widget.lang == null ? 'Add Language' : 'Edit Language',
      onSave: _save,
      saveLabel: widget.lang == null ? 'Add Language' : 'Save Changes',
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Language *', hintText: 'Spanish'),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _proficiency,
          dropdownColor: AppTheme.cardColor(context),
          style: TextStyle(
            color: AppTheme.textDarkColor(context),
            fontSize: 14,
          ),
          decoration: InputDecoration(labelText: 'Proficiency Level'),
          items: LanguagesScreen._proficiencies
              .map((p) => DropdownMenuItem(
            value: p,
            child: Text(p,
                style: TextStyle(color: AppTheme.textDarkColor(context))),
          ))
              .toList(),
          onChanged: (v) => setState(() => _proficiency = v!),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─── SHARED HELPERS ──────────────────────────────────────────────────────────
Widget _sectionHeader(
    BuildContext context, IconData icon, String title, String subtitle) {
  return Row(children: [
    Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 22),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
    ])),
  ]);
}

Widget _addButton(BuildContext context, String label, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
  );
}

class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final String saveLabel;
  final VoidCallback onSave;
  final List<Widget> children;

  const _BottomSheetWrapper({
    required this.title,
    required this.saveLabel,
    required this.onSave,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                IconButton(onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
            ElevatedButton(onPressed: onSave, child: Text(saveLabel)),
          ],
        ),
      ),
    );
  }
}