<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" />
<img src="https://img.shields.io/badge/ATS%20Pass%20Rate-90%25-success?style=for-the-badge" />

<br /><br />

# 📄 ResumeLab — ATS-Friendly Resume Maker

**A Flutter mobile app that helps job seekers build professional, ATS-optimized resumes and export them as PDF — in minutes.**

[Features](#-features) · [Screenshots](#-screenshots) · [Getting Started](#-getting-started) · [Architecture](#-architecture) · [Contributing](#-contributing)

</div>

---

## ✨ Features

| | Feature | Details |
|---|---|---|
| 🧑‍💼 | **7-Step Resume Builder** | Guided form across Personal Info, Experience, Education, Skills, Projects, Certifications, Languages |
| 📄 | **3 ATS-Safe PDF Templates** | Minimal Professional · Modern Clean · Compact Resume |
| 📊 | **Live ATS Score** | Real-time 0–100 compatibility score with improvement suggestions |
| 💡 | **Role-Based Keyword Suggestions** | Auto-suggest skills by job role (Flutter Dev, Data Analyst, etc.) |
| 📤 | **Export Anywhere** | Download PDF, share via email/WhatsApp, or print directly |
| 💾 | **Offline-First** | Full local storage — no internet required |
| 🎨 | **Live Template Switching** | Preview how your resume looks across all 3 templates instantly |
| ✅ | **Form Validation** | Helpful inline errors prevent incomplete submissions |

---

## 📱 Screenshots

> *All screens built with Material 3 + Google Fonts (DM Sans)*

| Splash | Home | Builder | Skills |
|--------|------|---------|--------|
| Animated gradient intro | Resume dashboard with score badges | 7-step guided form | Role-based keyword chips |

| PDF Preview | ATS Score | Template Picker | Add Experience |
|-------------|-----------|-----------------|----------------|
| Live resume layout | Circular score + breakdown | 3 templates with ATS notes | Bottom sheet form |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter 3.x](https://docs.flutter.dev/get-started/install)
- Dart 3.x
- Android Studio / VS Code
- A physical device or emulator

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/resume_lab.git
cd resume_lab

# 2. Install dependencies
flutter pub get

# 3. Run on your connected device or emulator
flutter run
```

### Build for release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## ⚙️ Platform Setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

Set minimum SDK in `android/app/build.gradle`:

```gradle
minSdkVersion 21
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save your resume PDF to Photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access Photos to save your resume</string>
```

---

## 🗂 Project Structure

```
lib/
├── main.dart                          # App entry + SplashScreen
│
├── theme/
│   └── app_theme.dart                 # Material 3 theme, colors, typography
│
├── models/
│   └── resume_model.dart              # Data models + ATS scoring logic + role keywords
│
├── providers/
│   └── resume_provider.dart           # ChangeNotifier state management
│
├── services/
│   └── pdf_service.dart               # PDF generation (3 templates via pdf package)
│
└── screens/
    ├── home_screen.dart               # Dashboard — list, score badges, CRUD
    ├── create_resume_screen.dart      # Stepper shell with progress indicator
    ├── preview_screen.dart            # Preview + Score + Template tabs + export bar
    │
    └── sections/
        ├── personal_info_screen.dart  # Step 1 — contact details + summary
        ├── work_experience_screen.dart # Step 2 — experience cards + bottom sheet form
        ├── education_screen.dart      # Steps 3–7 — edu, skills, projects, certs, langs
        ├── skills_screen.dart
        ├── projects_screen.dart
        ├── certifications_screen.dart
        └── languages_screen.dart
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| [`provider`](https://pub.dev/packages/provider) | ^6.1.1 | State management |
| [`pdf`](https://pub.dev/packages/pdf) | ^3.10.8 | PDF document generation |
| [`printing`](https://pub.dev/packages/printing) | ^5.12.0 | Print / share / download PDF |
| [`path_provider`](https://pub.dev/packages/path_provider) | ^2.1.2 | Local file system access |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | ^2.2.2 | Persistent local resume storage |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | ^6.2.1 | DM Sans typeface |
| [`share_plus`](https://pub.dev/packages/share_plus) | ^7.2.2 | System share sheet |
| [`uuid`](https://pub.dev/packages/uuid) | ^4.3.3 | Unique IDs for resume entries |
| [`percent_indicator`](https://pub.dev/packages/percent_indicator) | ^4.2.3 | Circular ATS score ring |
| [`intl`](https://pub.dev/packages/intl) | ^0.19.0 | Date formatting |

---

## 🎯 ATS Compliance

All 3 PDF templates are built around the following ATS best practices:

| Rule | Implementation |
|---|---|
| No tables or complex graphics | Single-column or simple 2-column layouts only |
| ATS-safe fonts | Lato (via `PdfGoogleFonts`) — universally parseable |
| Standard section headings | SUMMARY · EXPERIENCE · EDUCATION · SKILLS · PROJECTS · CERTIFICATIONS |
| No text in images | 100% selectable text throughout |
| Keyword density | Role-based keyword suggestions embedded directly in the form |
| Logical reading order | Linear document flow from top to bottom |

---

## 🏗 Architecture

```
UI (Screens)
    │
    ▼
ResumeProvider (ChangeNotifier)     ← single source of truth
    │
    ├─▶ ResumeModel                 ← plain Dart data classes
    │       ├── PersonalInfo
    │       ├── WorkExperience[]
    │       ├── Education[]
    │       ├── skills: List<String>
    │       ├── Project[]
    │       ├── Certification[]
    │       └── Language[]
    │
    ├─▶ SharedPreferences           ← JSON serialization for local persistence
    │
    └─▶ PdfService                  ← stateless, generates PDF from ResumeModel
            ├── Minimal template
            ├── Modern template
            └── Compact template
```

**State flow:** User fills forms → provider updates `currentResume` → `saveCurrentResume()` persists to `SharedPreferences` → `PdfService.generatePdf()` renders final document.

---

## 📊 ATS Score Breakdown

The score is calculated in real-time as the user fills in their resume:

| Section | Points |
|---|---|
| Full name present | +10 |
| Professional summary | +15 |
| Work experience | +25 |
| Education | +15 |
| 5+ skills added | +10 |
| Email address | +5 |
| Phone number | +5 |
| LinkedIn URL | +5 |
| Projects added | +5 |
| Certifications | +5 |
| **Max total** | **100** |

Scores ≥ 80 are considered **Excellent** ATS compatibility.

---

## 🔮 Roadmap

- [ ] Firebase Authentication + cloud sync
- [ ] AI-powered professional summary generator (Claude API)
- [ ] Cover letter generator
- [ ] LinkedIn profile import
- [ ] Resume analytics dashboard
- [ ] Job description keyword matcher
- [ ] Multi-language UI support
- [ ] Dark mode

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please make sure your code passes `flutter analyze` and is formatted with `dart format .` before submitting.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev) — UI framework
- [pdf](https://pub.dev/packages/pdf) — PDF generation
- [printing](https://pub.dev/packages/printing) — cross-platform print/share

---

<div align="center">

Made with ❤️ using Flutter

⭐ Star this repo if it helped you land your dream job!

</div>
#   R e s u m e L a b  
 