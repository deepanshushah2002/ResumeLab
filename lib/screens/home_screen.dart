import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/resume_provider.dart';
import '../providers/theme_provider.dart';
import '../models/resume_model.dart';
import '../theme/app_theme.dart';
import 'create_resume_screen.dart';
import 'preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeProvider>().loadResumes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor(context),
      body: SafeArea(
        child: Consumer<ResumeProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                _buildHeader(context),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.resumes.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _ResumeCard(
                          resume: provider.resumes[index],
                          onEdit: () => _editResume(context, provider.resumes[index]),
                          onPreview: () =>
                              _previewResume(context, provider.resumes[index]),
                          onDelete: () =>
                              _deleteResume(context, provider, provider.resumes[index].id),
                        ),
                        childCount: provider.resumes.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createResume(context),
        icon: const Icon(Icons.add),
        label: const Text('New Resume'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.description_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('ResumeLab',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                          color: AppTheme.textDarkColor(context))),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return GestureDetector(
                      onTap: () => _showThemeSheet(context, themeProvider),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          themeProvider.isDark
                              ? Icons.dark_mode_rounded
                              : themeProvider.isLight
                              ? Icons.light_mode_rounded
                              : Icons.brightness_auto_rounded,
                          color: AppTheme.textMediumColor(context),
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text('ATS-Optimized',
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Build resumes that\nget you hired',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        height: 1.2,
                      )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBadge(label: '90%+', sublabel: 'ATS Pass Rate'),
                      const SizedBox(width: 12),
                      _StatBadge(label: '3', sublabel: 'Templates'),
                      const SizedBox(width: 12),
                      _StatBadge(label: 'PDF', sublabel: 'Export'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Consumer<ResumeProvider>(
              builder: (context, provider, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Resumes (${provider.resumes.length})',
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined,
                size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text('No resumes yet',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Create your first ATS-optimized resume\nand land your dream job',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _createResume(context),
            icon: Icon(Icons.add),
            label: const Text('Create Resume'),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Appearance',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Light',
              selected: themeProvider.isLight,
              onTap: () {
                themeProvider.setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Dark',
              selected: themeProvider.isDark,
              onTap: () {
                themeProvider.setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _ThemeOption(
              icon: Icons.brightness_auto_rounded,
              label: 'System default',
              selected: themeProvider.isSystem,
              onTap: () {
                themeProvider.setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createResume(BuildContext context) {
    context.read<ResumeProvider>().createNewResume();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateResumeScreen()),
    ).then((_) => context.read<ResumeProvider>().loadResumes());
  }

  void _editResume(BuildContext context, ResumeModel resume) {
    context.read<ResumeProvider>().editResume(resume);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateResumeScreen()),
    ).then((_) => context.read<ResumeProvider>().loadResumes());
  }

  void _previewResume(BuildContext context, ResumeModel resume) {
    context.read<ResumeProvider>().editResume(resume);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PreviewScreen()),
    );
  }

  void _deleteResume(
      BuildContext context, ResumeProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Resume'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteResume(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String sublabel;
  const _StatBadge({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          Text(sublabel,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final ResumeModel resume;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  const _ResumeCard({
    required this.resume,
    required this.onEdit,
    required this.onPreview,
    required this.onDelete,
  });

  Color get scoreColor {
    final s = resume.resumeScore;
    if (s >= 80) return AppTheme.success;
    if (s >= 50) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final name = resume.personalInfo.fullName.isNotEmpty
        ? resume.personalInfo.fullName
        : 'Untitled Resume';
    final role = resume.personalInfo.jobTitle;
    final date = DateFormat('MMM d, yyyy').format(resume.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_rounded,
                      color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 15)),
                      if (role.isNotEmpty)
                        Text(role,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ),
                // Score badge
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${resume.resumeScore}%',
                      style: TextStyle(
                          color: scoreColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: AppTheme.textLightColor(context)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('Updated $date',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                    icon: Icons.remove_red_eye_rounded,
                    label: 'Preview',
                    onTap: onPreview),
                const SizedBox(width: 6),
                _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    onTap: onEdit,
                    filled: true),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppTheme.error),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14,
                color: filled ? Colors.white : AppTheme.primary),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  color: filled ? Colors.white : AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.08)
              : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.borderColor(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withOpacity(0.12)
                    : AppTheme.borderColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 20,
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textMediumColor(context)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    color: selected
                        ? AppTheme.primary
                        : AppTheme.textDarkColor(context),
                  )),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}