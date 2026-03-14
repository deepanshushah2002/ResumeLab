<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.38-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" />
<img src="https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge" />
<img src="https://img.shields.io/badge/ATS%20Pass%20Rate-90%25+-1B4FE4?style=for-the-badge" />

<br /><br />

<img src="https://img.shields.io/badge/Material_3-Design-1B4FE4?style=flat-square" />
<img src="https://img.shields.io/badge/Offline--First-✓-22C55E?style=flat-square" />
<img src="https://img.shields.io/badge/Dark%20Mode-✓-1a1a2e?style=flat-square" />
<img src="https://img.shields.io/badge/6%20PDF%20Templates-✓-F59E0B?style=flat-square" />

<br /><br />

# 📄 ResumeLab

### ATS-Optimized Resume Builder for Android & iOS

**Build professional, ATS-safe resumes in minutes. Export as PDF. Get hired faster.**

[Features](#-features) · [Getting Started](#-getting-started) · [Templates](#-pdf-templates) · [Architecture](#-architecture) · [ATS Score](#-ats-score-system) · [Roadmap](#-roadmap)

</div>

---

## ✨ Features

| | Feature | Description |
|---|---|---|
| 🧑‍💼 | **7-Step Guided Builder** | Personal Info → Experience → Education → Skills → Projects → Certifications → Languages |
| 📄 | **6 ATS-Safe PDF Templates** | Minimal Pro · Modern Clean · Compact Dark · Executive · Teal Accent · Two Column |
| 📊 | **Real-Time ATS Score** | Live 0–100 score with weighted breakdown and actionable improvement tips |
| 💡 | **Role-Based Keyword Chips** | Auto-suggests relevant skills for Flutter Dev, Data Analyst, UI/UX, Backend, Frontend & more |
| 🌙 | **Dark / Light / System Theme** | Full Material 3 dark mode with persistent theme preference |
| 📤 | **Native Share Sheet Export** | Save to Downloads, Google Drive, Files app, or share via WhatsApp/email |
| 💾 | **Offline-First** | All data stored locally with SharedPreferences — no internet required |
| 🎨 | **Visual Template Picker** | Live preview cards showing the actual layout of each template before selecting |
| ✅ | **Multi-Resume Support** | Create, edit, preview and manage multiple resumes from the home dashboard |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter 3.27+](https://docs.flutter.dev/get-started/install) (tested on 3.38.5)
- Dart 3.x
- Android Studio / VS Code
- Android emulator or physical device (minSdk 21) · iOS Simulator or device (iOS 13+)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/deepanshushah2002/ResumeLab.git
cd ResumeLab

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run
```

### Build for release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## ⚙️ Platform Setup

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Android — `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save your resume PDF to Photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access Photos to save your resume</string>
```

---

## 🎨 PDF Templates

All 6 templates output ATS-compliant PDFs using the **Lato** font (via `PdfGoogleFonts`). Content that doesn't fit on page 1 automatically flows to page 2 using `MultiPage`.

| ID | Name | Layout | Best For |
|---|---|---|---|
| `minimal` | **Minimal Pro** | Single-column, white, blue accents | Maximum ATS compatibility |
| `modern` | **Modern Clean** | Blue sidebar + white body | Tech & creative roles |
| `compact` | **Compact Dark** | Dark navy header, two-column body | Space-efficient, multiple roles |
| `executive` | **Executive** | Centred name, letter-spaced headings | Senior & leadership roles |
| `teal` | **Teal Accent** | Teal header bar + teal skill pills | Fresh graduates, design roles |
| `minimal_two_col` | **Two Column** | Indigo header, sidebar (skills/edu/certs) + main (exp/projects) | Organized, information-dense |

---

## 🗂 Project Structure

```
lib/
├── main.dart                          # Entry point + SplashScreen + MultiProvider setup
│
├── theme/
│   └── app_theme.dart                 # Material 3 light & dark themes, context-aware color helpers
│
├── models/
│   └── resume_model.dart              # Data models, ATS scoring, role keyword map, JSON serialization
│
├── providers/
│   ├── resume_provider.dart           # Resume CRUD, persistence via SharedPreferences
│   └── theme_provider.dart            # Light / Dark / System theme toggle with persistence
│
├── services/
│   └── pdf_service.dart               # 6 PDF template builders (MultiPage), generatePdfBytes, printResume
│
└── screens/
    ├── home_screen.dart               # Dashboard — resume cards, score badges, theme toggle
    ├── create_resume_screen.dart      # 7-step PageView with progress stepper
    ├── preview_screen.dart            # Preview tab + ATS Score tab + Template picker + Export bar
    │
    └── sections/
        ├── personal_info_screen.dart  # Step 1 — name, contact, summary
        ├── work_experience_screen.dart # Step 2 — experience cards + bottom sheet form
        ├── education_screen.dart      # Steps 3–7 — education, skills (with keyword chips), projects,
        ├── skills_screen.dart         #              certifications, languages
        ├── projects_screen.dart
        ├── certifications_screen.dart
        └── languages_screen.dart
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| [`provider`](https://pub.dev/packages/provider) | ^6.1.1 | State management (ChangeNotifier) |
| [`pdf`](https://pub.dev/packages/pdf) | ^3.10.8 | PDF document generation |
| [`printing`](https://pub.dev/packages/printing) | ^5.12.0 | Native share sheet PDF export & print |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | ^2.2.2 | Offline resume + theme persistence |
| [`path_provider`](https://pub.dev/packages/path_provider) | ^2.1.2 | Local filesystem access |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | ^6.2.1 | DM Sans UI font |
| [`share_plus`](https://pub.dev/packages/share_plus) | ^7.2.2 | System share sheet |
| [`uuid`](https://pub.dev/packages/uuid) | ^4.3.3 | Unique IDs for resume entries |
| [`percent_indicator`](https://pub.dev/packages/percent_indicator) | ^4.2.3 | Circular ATS score ring |
| [`intl`](https://pub.dev/packages/intl) | ^0.19.0 | Date formatting |
| [`flutter_animate`](https://pub.dev/packages/flutter_animate) | ^4.5.0 | UI animations |
| [`image_picker`](https://pub.dev/packages/image_picker) | ^1.0.7 | Profile photo (optional) |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────┐
│                  UI Layer                    │
│  HomeScreen → CreateResumeScreen            │
│            → PreviewScreen                  │
└───────────────────┬─────────────────────────┘
                    │ reads / writes
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐   ┌──────────▼────────┐
│ ResumeProvider │   │  ThemeProvider    │
│ (ChangeNotifier│   │ (ChangeNotifier)  │
└───────┬────────┘   └──────────┬────────┘
        │                       │
        ▼                       ▼
┌───────────────┐    ┌─────────────────────┐
│  ResumeModel  │    │  SharedPreferences  │
│  ├ PersonalInfo│   │  (JSON + theme key) │
│  ├ WorkExp[]  │    └─────────────────────┘
│  ├ Education[]│
│  ├ skills[]   │
│  ├ Project[]  │
│  ├ Cert[]     │
│  └ Language[] │
└───────┬───────┘
        │
        ▼
┌───────────────────────────────────┐
│           PdfService              │
│  generatePdfBytes() → Uint8List   │
│  printResume()                    │
│  ├ _buildMinimalTemplate          │
│  ├ _buildModernTemplate           │
│  ├ _buildCompactTemplate          │
│  ├ _buildExecutiveTemplate        │
│  ├ _buildTealTemplate             │
│  └ _buildTwoColumnTemplate        │
└───────────────────────────────────┘
```

**State flow:** User fills form → `ResumeProvider` updates `currentResume` → `saveCurrentResume()` serializes to `SharedPreferences` → `PdfService.generatePdfBytes()` builds PDF → `Printing.sharePdf()` opens native share sheet.

---

## 📊 ATS Score System

Score is calculated live in `ResumeModel.resumeScore` as sections are filled:

| Criteria | Points |
|---|---|
| Full name | +10 |
| Professional summary | +15 |
| Work experience | +25 |
| Education | +15 |
| 5 or more skills | +10 |
| Email address | +5 |
| Phone number | +5 |
| LinkedIn URL | +5 |
| Projects | +5 |
| Certifications | +5 |
| **Maximum** | **100** |

| Score Range | Rating |
|---|---|
| 80 – 100 | ✅ Excellent — strong ATS pass likelihood |
| 50 – 79 | ⚠️ Good — a few sections to complete |
| 0 – 49 | ❌ Needs work — key sections missing |

---

## 🔮 Roadmap

- [ ] Firebase Authentication + cloud backup
- [ ] AI-powered summary generator (Gemini / Claude API)
- [ ] Cover letter builder
- [ ] Job description keyword matcher
- [ ] LinkedIn profile import
- [ ] Resume analytics & view tracking
- [ ] Multi-language UI
- [ ] Play Store & App Store release

---

## 🤝 Contributing

Contributions are welcome!

```bash
# 1. Fork and clone
git checkout -b feature/your-feature-name

# 2. Make your changes, then
flutter analyze
dart format .

# 3. Push and open a PR
git push origin feature/your-feature-name
```

Please keep PRs focused on a single feature or fix. Include screenshots for UI changes.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

Built with ❤️ using Flutter by [Deepanshu Shah](https://github.com/deepanshushah2002)

**⭐ Star this repo if ResumeLab helped you land your next role!**

</div>
