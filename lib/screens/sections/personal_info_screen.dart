import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';
import '../../theme/app_theme.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _linkedInCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final info = context.read<ResumeProvider>().currentResume?.personalInfo;
    if (info != null) {
      _nameCtrl.text = info.fullName;
      _titleCtrl.text = info.jobTitle;
      _phoneCtrl.text = info.phone;
      _emailCtrl.text = info.email;
      _locationCtrl.text = info.location;
      _linkedInCtrl.text = info.linkedIn;
      _portfolioCtrl.text = info.portfolio;
      _summaryCtrl.text = info.professionalSummary;
    }
    _addListeners();
  }

  void _addListeners() {
    for (final ctrl in [
      _nameCtrl, _titleCtrl, _phoneCtrl, _emailCtrl,
      _locationCtrl, _linkedInCtrl, _portfolioCtrl, _summaryCtrl
    ]) {
      ctrl.addListener(_onChanged);
    }
  }

  void _onChanged() {
    context.read<ResumeProvider>().updatePersonalInfo(PersonalInfo(
      fullName: _nameCtrl.text,
      jobTitle: _titleCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      location: _locationCtrl.text,
      linkedIn: _linkedInCtrl.text,
      portfolio: _portfolioCtrl.text,
      professionalSummary: _summaryCtrl.text,
    ));
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl, _titleCtrl, _phoneCtrl, _emailCtrl,
      _locationCtrl, _linkedInCtrl, _portfolioCtrl, _summaryCtrl
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.person_rounded,
            title: 'Personal Information',
            subtitle: 'Your basic contact details',
          ),
          const SizedBox(height: 20),

          _FormField(
            controller: _nameCtrl,
            label: 'Full Name *',
            hint: 'John Doe',
            icon: Icons.badge_rounded,
          ),
          _FormField(
            controller: _titleCtrl,
            label: 'Job Title',
            hint: 'Senior Flutter Developer',
            icon: Icons.work_rounded,
          ),
          Row(children: [
            Expanded(
              child: _FormField(
                controller: _phoneCtrl,
                label: 'Phone',
                hint: '+1 234 567 8900',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                controller: _emailCtrl,
                label: 'Email *',
                hint: 'john@email.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ]),
          _FormField(
            controller: _locationCtrl,
            label: 'Location',
            hint: 'New York, NY',
            icon: Icons.location_on_rounded,
          ),
          _FormField(
            controller: _linkedInCtrl,
            label: 'LinkedIn URL',
            hint: 'linkedin.com/in/johndoe',
            icon: Icons.link_rounded,
            keyboardType: TextInputType.url,
          ),
          _FormField(
            controller: _portfolioCtrl,
            label: 'Portfolio / Website',
            hint: 'johndoe.dev',
            icon: Icons.language_rounded,
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 8),
          _SectionHeader(
            icon: Icons.notes_rounded,
            title: 'Professional Summary',
            subtitle: 'A brief overview of your career (2-4 sentences)',
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _summaryCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
              'Results-driven Flutter developer with 3+ years of experience building high-performance mobile applications...',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 16),
          AtsHintCard(
            tips: const [
              'Write in first-person without using "I"',
              'Include years of experience and key skills',
              'Mention measurable achievements',
              'Keep it between 2-4 sentences',
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: AppTheme.textLightColor(context)),
        ),
      ),
    );
  }
}

class AtsHintCard extends StatelessWidget {
  final List<String> tips;
  const AtsHintCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 16, color: AppTheme.accent),
              const SizedBox(width: 6),
              Text('ATS Tips',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.accent,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tip,
                      style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppTheme.textMediumColor(context),
                      )),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}