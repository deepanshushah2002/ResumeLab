import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';
import '../../theme/app_theme.dart';
import '../sections/personal_info_screen.dart' show AtsHintCard;

const _uuid = Uuid();

class WorkExperienceScreen extends StatelessWidget {
  const WorkExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final experiences = provider.currentResume?.workExperiences ?? [];
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    if (experiences.isEmpty)
                      _buildEmptyState(context, provider)
                    else ...[
                      ...experiences.map((exp) => _ExperienceCard(
                        experience: exp,
                        onEdit: () =>
                            _showExpDialog(context, provider, exp: exp),
                        onDelete: () =>
                            provider.deleteWorkExperience(exp.id),
                      )),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showExpDialog(context, provider),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Another Experience'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AtsHintCard(tips: const [
                      'Use bullet points with action verbs (Led, Built, Improved)',
                      'Quantify achievements with numbers and percentages',
                      'Include relevant keywords from the job posting',
                      'List experience in reverse chronological order',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.work_rounded,
              color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Work Experience',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('Add your work history',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ResumeProvider provider) {
    return GestureDetector(
      onTap: () => _showExpDialog(context, provider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.2), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                size: 48, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text('Add Work Experience',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppTheme.primary)),
            const SizedBox(height: 4),
            Text('Tap to add your first job',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showExpDialog(BuildContext context, ResumeProvider provider,
      {WorkExperience? exp}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExperienceForm(
        experience: exp,
        onSave: (newExp) {
          if (exp == null) {
            provider.addWorkExperience(newExp);
          } else {
            provider.updateWorkExperience(newExp);
          }
        },
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final WorkExperience experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(experience.jobTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15, color: AppTheme.textDarkColor(context))),
                    Text(experience.companyName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.primary)),
                    Text(
                      '${experience.startDate} – ${experience.isCurrent ? 'Present' : experience.endDate}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded,
                    size: 18, color: AppTheme.primary),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppTheme.error),
              ),
            ],
          ),
          if (experience.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              experience.responsibilities,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceForm extends StatefulWidget {
  final WorkExperience? experience;
  final Function(WorkExperience) onSave;

  const _ExperienceForm({this.experience, required this.onSave});

  @override
  State<_ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<_ExperienceForm> {
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _respCtrl = TextEditingController();
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    if (exp != null) {
      _titleCtrl.text = exp.jobTitle;
      _companyCtrl.text = exp.companyName;
      _locationCtrl.text = exp.location;
      _startCtrl.text = exp.startDate;
      _endCtrl.text = exp.endDate;
      _respCtrl.text = exp.responsibilities;
      _isCurrent = exp.isCurrent;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _respCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final exp = WorkExperience(
      id: widget.experience?.id ?? _uuid.v4(),
      jobTitle: _titleCtrl.text,
      companyName: _companyCtrl.text,
      location: _locationCtrl.text,
      startDate: _startCtrl.text,
      endDate: _endCtrl.text,
      isCurrent: _isCurrent,
      responsibilities: _respCtrl.text,
    );
    widget.onSave(exp);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.experience == null ? 'Add Experience' : 'Edit Experience',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _field(_titleCtrl, 'Job Title *', 'Software Engineer'),
            _field(_companyCtrl, 'Company Name *', 'Acme Corp'),
            _field(_locationCtrl, 'Location', 'San Francisco, CA'),
            Row(children: [
              Expanded(child: _field(_startCtrl, 'Start Date', 'Jan 2022')),
              const SizedBox(width: 12),
              Expanded(
                child: _isCurrent
                    ? const SizedBox.shrink()
                    : _field(_endCtrl, 'End Date', 'Dec 2023'),
              ),
            ]),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Currently working here'),
              value: _isCurrent,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _isCurrent = v),
            ),
            TextFormField(
              controller: _respCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Responsibilities / Achievements',
                hintText:
                '• Led development of 3 major features\n• Improved app performance by 40%\n• Collaborated with cross-functional teams',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.experience == null ? 'Add Experience' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: ctrl,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}