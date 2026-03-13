import 'dart:convert';

class ResumeModel {
  String id;
  String templateId;
  DateTime createdAt;
  DateTime updatedAt;

  PersonalInfo personalInfo;
  List<WorkExperience> workExperiences;
  List<Education> educations;
  List<String> skills;
  List<Project> projects;
  List<Certification> certifications;
  List<Language> languages;

  ResumeModel({
    required this.id,
    this.templateId = 'minimal',
    required this.createdAt,
    required this.updatedAt,
    required this.personalInfo,
    this.workExperiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.projects = const [],
    this.certifications = const [],
    this.languages = const [],
  });

  int get resumeScore {
    int score = 0;
    if (personalInfo.fullName.isNotEmpty) score += 10;
    if (personalInfo.professionalSummary.isNotEmpty) score += 15;
    if (personalInfo.email.isNotEmpty) score += 5;
    if (personalInfo.phone.isNotEmpty) score += 5;
    if (personalInfo.linkedIn.isNotEmpty) score += 5;
    if (workExperiences.isNotEmpty) score += 25;
    if (educations.isNotEmpty) score += 15;
    if (skills.length >= 5) score += 10;
    if (projects.isNotEmpty) score += 5;
    if (certifications.isNotEmpty) score += 5;
    return score.clamp(0, 100);
  }

  List<String> get scoreSuggestions {
    List<String> suggestions = [];
    if (personalInfo.professionalSummary.isEmpty) {
      suggestions.add('Add a professional summary to stand out');
    }
    if (workExperiences.isEmpty) {
      suggestions.add('Add work experience entries');
    }
    if (skills.length < 5) {
      suggestions.add('Add at least 5 skills for better ATS matching');
    }
    if (personalInfo.linkedIn.isEmpty) {
      suggestions.add('Include your LinkedIn profile URL');
    }
    if (projects.isEmpty) {
      suggestions.add('Add projects to showcase your work');
    }
    if (certifications.isEmpty) {
      suggestions.add('Add relevant certifications');
    }
    return suggestions;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'personalInfo': personalInfo.toJson(),
        'workExperiences': workExperiences.map((e) => e.toJson()).toList(),
        'educations': educations.map((e) => e.toJson()).toList(),
        'skills': skills,
        'projects': projects.map((e) => e.toJson()).toList(),
        'certifications': certifications.map((e) => e.toJson()).toList(),
        'languages': languages.map((e) => e.toJson()).toList(),
      };

  factory ResumeModel.fromJson(Map<String, dynamic> json) => ResumeModel(
        id: json['id'],
        templateId: json['templateId'] ?? 'minimal',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        personalInfo: PersonalInfo.fromJson(json['personalInfo']),
        workExperiences: (json['workExperiences'] as List)
            .map((e) => WorkExperience.fromJson(e))
            .toList(),
        educations: (json['educations'] as List)
            .map((e) => Education.fromJson(e))
            .toList(),
        skills: List<String>.from(json['skills']),
        projects: (json['projects'] as List)
            .map((e) => Project.fromJson(e))
            .toList(),
        certifications: (json['certifications'] as List)
            .map((e) => Certification.fromJson(e))
            .toList(),
        languages: (json['languages'] as List)
            .map((e) => Language.fromJson(e))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory ResumeModel.fromJsonString(String jsonStr) =>
      ResumeModel.fromJson(jsonDecode(jsonStr));

  ResumeModel copyWith({
    String? id,
    String? templateId,
    PersonalInfo? personalInfo,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<String>? skills,
    List<Project>? projects,
    List<Certification>? certifications,
    List<Language>? languages,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      personalInfo: personalInfo ?? this.personalInfo,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
    );
  }
}

class PersonalInfo {
  String fullName;
  String jobTitle;
  String phone;
  String email;
  String location;
  String linkedIn;
  String portfolio;
  String professionalSummary;

  PersonalInfo({
    this.fullName = '',
    this.jobTitle = '',
    this.phone = '',
    this.email = '',
    this.location = '',
    this.linkedIn = '',
    this.portfolio = '',
    this.professionalSummary = '',
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'jobTitle': jobTitle,
        'phone': phone,
        'email': email,
        'location': location,
        'linkedIn': linkedIn,
        'portfolio': portfolio,
        'professionalSummary': professionalSummary,
      };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
        fullName: json['fullName'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        location: json['location'] ?? '',
        linkedIn: json['linkedIn'] ?? '',
        portfolio: json['portfolio'] ?? '',
        professionalSummary: json['professionalSummary'] ?? '',
      );
}

class WorkExperience {
  String id;
  String jobTitle;
  String companyName;
  String location;
  String startDate;
  String endDate;
  bool isCurrent;
  String responsibilities;

  WorkExperience({
    required this.id,
    this.jobTitle = '',
    this.companyName = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.responsibilities = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'isCurrent': isCurrent,
        'responsibilities': responsibilities,
      };

  factory WorkExperience.fromJson(Map<String, dynamic> json) => WorkExperience(
        id: json['id'],
        jobTitle: json['jobTitle'] ?? '',
        companyName: json['companyName'] ?? '',
        location: json['location'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        isCurrent: json['isCurrent'] ?? false,
        responsibilities: json['responsibilities'] ?? '',
      );
}

class Education {
  String id;
  String degree;
  String institution;
  String fieldOfStudy;
  String startYear;
  String endYear;
  String gpa;

  Education({
    required this.id,
    this.degree = '',
    this.institution = '',
    this.fieldOfStudy = '',
    this.startYear = '',
    this.endYear = '',
    this.gpa = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'degree': degree,
        'institution': institution,
        'fieldOfStudy': fieldOfStudy,
        'startYear': startYear,
        'endYear': endYear,
        'gpa': gpa,
      };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        id: json['id'],
        degree: json['degree'] ?? '',
        institution: json['institution'] ?? '',
        fieldOfStudy: json['fieldOfStudy'] ?? '',
        startYear: json['startYear'] ?? '',
        endYear: json['endYear'] ?? '',
        gpa: json['gpa'] ?? '',
      );
}

class Project {
  String id;
  String name;
  String description;
  String technologies;
  String githubLink;
  String liveLink;

  Project({
    required this.id,
    this.name = '',
    this.description = '',
    this.technologies = '',
    this.githubLink = '',
    this.liveLink = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'technologies': technologies,
        'githubLink': githubLink,
        'liveLink': liveLink,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        technologies: json['technologies'] ?? '',
        githubLink: json['githubLink'] ?? '',
        liveLink: json['liveLink'] ?? '',
      );
}

class Certification {
  String id;
  String name;
  String organization;
  String issueDate;
  String credentialUrl;

  Certification({
    required this.id,
    this.name = '',
    this.organization = '',
    this.issueDate = '',
    this.credentialUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'organization': organization,
        'issueDate': issueDate,
        'credentialUrl': credentialUrl,
      };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        id: json['id'],
        name: json['name'] ?? '',
        organization: json['organization'] ?? '',
        issueDate: json['issueDate'] ?? '',
        credentialUrl: json['credentialUrl'] ?? '',
      );
}

class Language {
  String id;
  String name;
  String proficiency;

  Language({
    required this.id,
    this.name = '',
    this.proficiency = 'Intermediate',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'proficiency': proficiency,
      };

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json['id'],
        name: json['name'] ?? '',
        proficiency: json['proficiency'] ?? 'Intermediate',
      );
}

// Keyword suggestions by role
const Map<String, List<String>> roleKeywords = {
  'Flutter Developer': [
    'Dart', 'Flutter', 'REST API', 'Firebase', 'State Management',
    'Provider', 'BLoC', 'GetX', 'Widget', 'Material Design',
  ],
  'Software Engineer': [
    'Algorithms', 'Data Structures', 'OOP', 'Agile', 'Git',
    'CI/CD', 'Unit Testing', 'Design Patterns', 'API Development',
  ],
  'Data Analyst': [
    'Python', 'SQL', 'Excel', 'Power BI', 'Tableau',
    'Data Visualization', 'Statistics', 'Machine Learning', 'ETL',
  ],
  'UI/UX Designer': [
    'Figma', 'Wireframing', 'Prototyping', 'User Research',
    'Design Systems', 'Typography', 'Accessibility', 'Adobe XD',
  ],
  'Backend Developer': [
    'Node.js', 'Python', 'Java', 'REST API', 'GraphQL',
    'PostgreSQL', 'MongoDB', 'Docker', 'Microservices', 'AWS',
  ],
  'Frontend Developer': [
    'React', 'Vue.js', 'TypeScript', 'HTML5', 'CSS3',
    'Responsive Design', 'JavaScript', 'Webpack', 'Git',
  ],
};
