import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../theme/app_theme.dart';
import 'sections/personal_info_screen.dart';
import 'sections/work_experience_screen.dart';
import 'sections/education_screen.dart';
import 'sections/skills_screen.dart';
import 'sections/projects_screen.dart';
import 'sections/certifications_screen.dart';
import 'sections/languages_screen.dart';
import 'preview_screen.dart';

class CreateResumeScreen extends StatefulWidget {
  const CreateResumeScreen({super.key});

  @override
  State<CreateResumeScreen> createState() => _CreateResumeScreenState();
}

class _CreateResumeScreenState extends State<CreateResumeScreen> {
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    PersonalInfoScreen(),
    WorkExperienceScreen(),
    EducationScreen(),
    SkillsScreen(),
    ProjectsScreen(),
    CertificationsScreen(),
    LanguagesScreen(),
  ];

  final List<IconData> _icons = [
    Icons.person_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.psychology_rounded,
    Icons.rocket_launch_rounded,
    Icons.verified_rounded,
    Icons.language_rounded,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    final provider = context.read<ResumeProvider>();
    provider.setStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next(ResumeProvider provider) async {
    await provider.saveCurrentResume();
    if (provider.currentStep < provider.steps.length - 1) {
      provider.nextStep();
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PreviewScreen()),
      );
    }
  }

  void _prev(ResumeProvider provider) {
    if (provider.currentStep > 0) {
      provider.prevStep();
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final isLast = provider.currentStep == provider.steps.length - 1;

        return Scaffold(
          backgroundColor: AppTheme.surfaceColor(context),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => _prev(provider),
            ),
            title: Text(provider.steps[provider.currentStep]),
            actions: [
              TextButton(
                onPressed: () async {
                  await provider.saveCurrentResume();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save',
                    style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress stepper
              _StepperHeader(
                steps: provider.steps,
                icons: _icons,
                currentStep: provider.currentStep,
                onStepTap: _goToStep,
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _pages,
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    if (provider.currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _prev(provider),
                          child: const Text('Back'),
                        ),
                      ),
                    if (provider.currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _next(provider),
                        child: Text(isLast ? 'Preview Resume' : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepperHeader extends StatelessWidget {
  final List<String> steps;
  final List<IconData> icons;
  final int currentStep;
  final Function(int) onStepTap;

  const _StepperHeader({
    required this.steps,
    required this.icons,
    required this.currentStep,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor(context),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            backgroundColor: AppTheme.borderColor(context),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 3,
          ),

          // Step icons row
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: steps.length,
              itemBuilder: (context, i) {
                final isActive = i == currentStep;
                final isDone = i < currentStep;

                return GestureDetector(
                  onTap: () => onStepTap(i),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.primary
                                : isDone
                                ? AppTheme.success
                                : AppTheme.borderColor(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : icons[i],
                            size: 16,
                            color: (isActive || isDone)
                                ? Colors.white
                                : AppTheme.textLightColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive
                                ? AppTheme.primary
                                : isDone
                                ? AppTheme.success
                                : AppTheme.textLightColor(context),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}