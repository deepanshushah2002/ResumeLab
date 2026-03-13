import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/resume_model.dart';

const _uuid = Uuid();

class ResumeProvider extends ChangeNotifier {
  List<ResumeModel> _resumes = [];
  ResumeModel? _currentResume;
  bool _isLoading = false;
  int _currentStep = 0;

  List<ResumeModel> get resumes => _resumes;
  ResumeModel? get currentResume => _currentResume;
  bool get isLoading => _isLoading;
  int get currentStep => _currentStep;

  final List<String> steps = [
    'Personal Info',
    'Experience',
    'Education',
    'Skills',
    'Projects',
    'Certifications',
    'Languages',
  ];

  Future<void> loadResumes() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final resumeListJson = prefs.getStringList('resumes') ?? [];

    _resumes = resumeListJson
        .map((json) => ResumeModel.fromJsonString(json))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveResumes() async {
    final prefs = await SharedPreferences.getInstance();
    final resumeListJson = _resumes.map((r) => r.toJsonString()).toList();
    await prefs.setStringList('resumes', resumeListJson);
  }

  void createNewResume() {
    _currentResume = ResumeModel(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      personalInfo: PersonalInfo(),
    );
    _currentStep = 0;
    notifyListeners();
  }

  void editResume(ResumeModel resume) {
    _currentResume = resume;
    _currentStep = 0;
    notifyListeners();
  }

  Future<void> saveCurrentResume() async {
    if (_currentResume == null) return;

    final idx = _resumes.indexWhere((r) => r.id == _currentResume!.id);
    if (idx >= 0) {
      _resumes[idx] = _currentResume!;
    } else {
      _resumes.insert(0, _currentResume!);
    }

    await _saveResumes();
    notifyListeners();
  }

  Future<void> deleteResume(String id) async {
    _resumes.removeWhere((r) => r.id == id);
    await _saveResumes();
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < steps.length - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Update personal info
  void updatePersonalInfo(PersonalInfo info) {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(personalInfo: info);
    notifyListeners();
  }

  // Work Experience
  void addWorkExperience(WorkExperience exp) {
    if (_currentResume == null) return;
    final list = [..._currentResume!.workExperiences, exp];
    _currentResume = _currentResume!.copyWith(workExperiences: list);
    notifyListeners();
  }

  void updateWorkExperience(WorkExperience exp) {
    if (_currentResume == null) return;
    final list = _currentResume!.workExperiences
        .map((e) => e.id == exp.id ? exp : e)
        .toList();
    _currentResume = _currentResume!.copyWith(workExperiences: list);
    notifyListeners();
  }

  void deleteWorkExperience(String id) {
    if (_currentResume == null) return;
    final list = _currentResume!.workExperiences
        .where((e) => e.id != id)
        .toList();
    _currentResume = _currentResume!.copyWith(workExperiences: list);
    notifyListeners();
  }

  // Education
  void addEducation(Education edu) {
    if (_currentResume == null) return;
    final list = [..._currentResume!.educations, edu];
    _currentResume = _currentResume!.copyWith(educations: list);
    notifyListeners();
  }

  void updateEducation(Education edu) {
    if (_currentResume == null) return;
    final list = _currentResume!.educations
        .map((e) => e.id == edu.id ? edu : e)
        .toList();
    _currentResume = _currentResume!.copyWith(educations: list);
    notifyListeners();
  }

  void deleteEducation(String id) {
    if (_currentResume == null) return;
    final list = _currentResume!.educations.where((e) => e.id != id).toList();
    _currentResume = _currentResume!.copyWith(educations: list);
    notifyListeners();
  }

  // Skills
  void addSkill(String skill) {
    if (_currentResume == null) return;
    if (_currentResume!.skills.contains(skill)) return;
    final list = [..._currentResume!.skills, skill];
    _currentResume = _currentResume!.copyWith(skills: list);
    notifyListeners();
  }

  void removeSkill(String skill) {
    if (_currentResume == null) return;
    final list = _currentResume!.skills.where((s) => s != skill).toList();
    _currentResume = _currentResume!.copyWith(skills: list);
    notifyListeners();
  }

  // Projects
  void addProject(Project project) {
    if (_currentResume == null) return;
    final list = [..._currentResume!.projects, project];
    _currentResume = _currentResume!.copyWith(projects: list);
    notifyListeners();
  }

  void updateProject(Project project) {
    if (_currentResume == null) return;
    final list = _currentResume!.projects
        .map((p) => p.id == project.id ? project : p)
        .toList();
    _currentResume = _currentResume!.copyWith(projects: list);
    notifyListeners();
  }

  void deleteProject(String id) {
    if (_currentResume == null) return;
    final list = _currentResume!.projects.where((p) => p.id != id).toList();
    _currentResume = _currentResume!.copyWith(projects: list);
    notifyListeners();
  }

  // Certifications
  void addCertification(Certification cert) {
    if (_currentResume == null) return;
    final list = [..._currentResume!.certifications, cert];
    _currentResume = _currentResume!.copyWith(certifications: list);
    notifyListeners();
  }

  void updateCertification(Certification cert) {
    if (_currentResume == null) return;
    final list = _currentResume!.certifications
        .map((c) => c.id == cert.id ? cert : c)
        .toList();
    _currentResume = _currentResume!.copyWith(certifications: list);
    notifyListeners();
  }

  void deleteCertification(String id) {
    if (_currentResume == null) return;
    final list =
        _currentResume!.certifications.where((c) => c.id != id).toList();
    _currentResume = _currentResume!.copyWith(certifications: list);
    notifyListeners();
  }

  // Languages
  void addLanguage(Language lang) {
    if (_currentResume == null) return;
    final list = [..._currentResume!.languages, lang];
    _currentResume = _currentResume!.copyWith(languages: list);
    notifyListeners();
  }

  void updateLanguage(Language lang) {
    if (_currentResume == null) return;
    final list = _currentResume!.languages
        .map((l) => l.id == lang.id ? lang : l)
        .toList();
    _currentResume = _currentResume!.copyWith(languages: list);
    notifyListeners();
  }

  void deleteLanguage(String id) {
    if (_currentResume == null) return;
    final list = _currentResume!.languages.where((l) => l.id != id).toList();
    _currentResume = _currentResume!.copyWith(languages: list);
    notifyListeners();
  }

  void updateTemplate(String templateId) {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(templateId: templateId);
    notifyListeners();
  }
}
