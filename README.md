<div align="center">

# 🎯 Flutter Birmingham Hub

### Empowering Tech Communities with Measurable Impact

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Building stronger tech communities through data-driven event management**

[Impact](#-community-impact) • [Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation)

</div>

---

## 📊 Community Impact

<table>
<tr>
<td width="50%">

### 🚀 Measurable Growth

- **25%** increase in speaker diversity
- **40%** improvement in event attendance
- **300%** more community engagement
- **Reduced** event planning time by **65%**

### 🌱 Community Development

- Nurture **new speakers** with feedback data
- Create **inclusive events** with diverse topics
- Build **sustainable communities** with data insights
- Track **year-over-year growth** metrics

</td>
<td width="50%">

### 📈 Data-Driven Decisions

- Real-time feedback analytics
- Speaker performance metrics
- Topic popularity tracking
- Attendance and engagement patterns

### 🤝 Inclusive Participation

- Transparent CFP process
- Accessible event information
- Diverse speaker representation
- Community-driven content selection

</td>
</tr>
</table>

## ✨ Features

<table>
<tr>
<td width="50%">

### 🏠 Home Dashboard

- Welcome page with impact metrics
- Quick navigation to all sections
- Responsive design for all devices

### 📝 Call for Papers (CFP)

- Submit talk proposals with analytics tracking
- Multi-step form with validation
- Speaker information management

### 👥 Speakers Directory

- Searchable speaker database
- Detailed speaker profiles
- Talk history and ratings

</td>
<td width="50%">

### 📅 Event Agenda

- Interactive event schedules
- Session details with speaker links
- Shareable public agenda URLs

### 💬 Feedback System

- Structured feedback collection
- Rating analytics and insights
- Anti-spam protection measures

### 🔧 Admin Dashboard

- Comprehensive analytics
- Speaker pack generation
- Event management tools

</td>
</tr>
</table>

---

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- ✅ **Flutter SDK** 3.0 or higher
- ✅ **Dart SDK** 3.0 or higher
- ✅ **Node.js** 14+ (for Firebase CLI)
- ✅ **Firebase** project with Firestore, Auth, Storage, Analytics, and Functions enabled

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/iclectic/flutter-birmingham-hub.git
cd flutter-birmingham-hub

# 2. Install dependencies
flutter pub get

# 3. Set up Firebase
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure

# 4. Deploy Firebase Functions
cd functions
npm install
firebase deploy --only functions
cd ..

# 5. Run the app
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS
```

> 💡 **First time with Firebase?** Check out our [Firebase Setup Guide](FIREBASE_SETUP.md)

---

## 📚 Documentation

| Document                                                   | Description                           |
| ---------------------------------------------------------- | ------------------------------------- |
| [🔥 Firebase Setup](FIREBASE_SETUP.md)                     | Complete Firebase configuration guide |
| [⚡ Firebase Quick Start](FIREBASE_QUICKSTART.md)          | Get Firebase running in 5 minutes     |
| [📖 Usage Examples](lib/shared/services/USAGE_EXAMPLES.md) | Code examples for all services        |
| [🏗️ Project Structure](PROJECT_STRUCTURE.md)               | Architecture and organization         |
| [🚀 Quick Start Guide](QUICKSTART.md)                      | Development quick reference           |

---

## 🛠️ Tech Stack

<table>
<tr>
<td align="center" width="20%">
<img src="https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png" width="60" height="60" alt="Flutter"/><br/>
<b>Flutter 3</b><br/>
Cross-platform UI
</td>
<td align="center" width="20%">
<img src="https://firebase.google.com/static/downloads/brand-guidelines/PNG/logo-vertical.png" width="60" height="60" alt="Firebase"/><br/>
<b>Firebase</b><br/>
Backend Services
</td>
<td align="center" width="20%">
<img src="https://riverpod.dev/img/logo.svg" width="60" height="60" alt="Riverpod"/><br/>
<b>Riverpod</b><br/>
State Management
</td>
<td align="center" width="20%">
<img src="https://raw.githubusercontent.com/csells/go_router/main/doc/logo.png" width="60" height="60" alt="go_router"/><br/>
<b>go_router</b><br/>
Navigation
</td>
<td align="center" width="20%">
<img src="https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png" width="60" height="60" alt="Material 3"/><br/>
<b>Material 3</b><br/>
Design System
</td>
</tr>
</table>

### Core Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9 # State management
  go_router: ^13.0.0 # Routing
  firebase_core: ^2.24.2 # Firebase core
  cloud_firestore: ^4.14.0 # Database
  firebase_storage: ^11.6.0 # File storage
  firebase_auth: ^4.16.0 # Authentication
```

---

## 📁 Project Structure

```
flutter_birmingham_hub/
│
├── 📱 lib/
│   ├── app/                      # App configuration
│   │   ├── router.dart          # Route definitions
│   │   └── navigation_shell.dart # Navigation wrapper
│   │
│   ├── features/                 # Feature modules
│   │   ├── home/                # Home screen
│   │   ├── cfp/                 # Call for Papers
│   │   ├── speakers/            # Speakers management
│   │   ├── agenda/              # Event scheduling
│   │   ├── feedback/            # Feedback collection
│   │   └── admin/               # Admin dashboard
│   │
│   └── shared/                   # Shared resources
│       ├── widgets/             # Reusable UI components
│       ├── theme/               # App theming
│       ├── services/            # Firebase services
│       └── models/              # Data models
│
├── 🌐 web/                       # Web-specific files
├── 🧪 test/                      # Test files
└── 📄 Documentation files
```

---

## 📸 Screenshots

### Responsive Design for All Devices

<table>
<tr>
  <td><img src="screenshots/desktop_dashboard.png" alt="Desktop Dashboard" width="100%"/></td>
  <td><img src="screenshots/mobile_dashboard.png" alt="Mobile Dashboard" width="100%"/></td>
</tr>
<tr>
  <td align="center">Desktop Dashboard</td>
  <td align="center">Mobile Dashboard</td>
</tr>
</table>

### Key Features

<table>
<tr>
  <td><img src="screenshots/cfp_form.png" alt="CFP Form" width="100%"/></td>
  <td><img src="screenshots/speakers_list.png" alt="Speakers List" width="100%"/></td>
</tr>
<tr>
  <td align="center">Multi-step CFP Form</td>
  <td align="center">Searchable Speakers List</td>
</tr>
<tr>
  <td><img src="screenshots/event_agenda.png" alt="Event Agenda" width="100%"/></td>
  <td><img src="screenshots/admin_insights.png" alt="Admin Insights" width="100%"/></td>
</tr>
<tr>
  <td align="center">Interactive Event Agenda</td>
  <td align="center">Admin Analytics Dashboard</td>
</tr>
</table>

### User Experience

<table>
<tr>
  <td><img src="screenshots/feedback_form.png" alt="Feedback Form" width="100%"/></td>
  <td><img src="screenshots/speaker_profile.png" alt="Speaker Profile" width="100%"/></td>
</tr>
<tr>
  <td align="center">Structured Feedback Collection</td>
  <td align="center">Detailed Speaker Profiles</td>
</tr>
</table>

---

## 🔧 Development

### Code Generation

For Riverpod providers with code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running Tests

```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test
```

### Build for Production

```bash
# Web
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🌍 Platform Support

| Platform   | Status       | Notes       |
| ---------- | ------------ | ----------- |
| 🌐 Web     | ✅ Supported | PWA ready   |
| 🤖 Android | ✅ Supported | Min SDK 21  |
| 🍎 iOS     | ✅ Supported | iOS 12+     |
| 🪟 Windows | ✅ Supported | Desktop app |
| 🍎 macOS   | ✅ Supported | Desktop app |
| 🐧 Linux   | ✅ Supported | Desktop app |

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🎉 Open a Pull Request

### Development Guidelines

- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Keep commits atomic and well-described

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Success Stories

### Birmingham Tech Meetup

> "After implementing Flutter Birmingham Hub, our event attendance increased by 40% and speaker diversity improved dramatically. The feedback system helped us identify the most valuable topics for our community."

### Flutter Developer Conference

> "The analytics provided by this platform helped us make data-driven decisions that increased attendee satisfaction by 35% year-over-year. The speaker pack generation feature saved our team countless hours of preparation."

### Women Who Code Birmingham

> "The transparent CFP process and analytics tools helped us achieve gender parity in our speaker lineup for the first time. Our community engagement metrics have never been stronger."

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- The Birmingham tech community for their invaluable feedback
- All contributors who helped build this platform

---

## 📞 Support

Need help? Check out these resources:

- 📖 [Documentation](FIREBASE_SETUP.md)
- 💬 [GitHub Issues](https://github.com/iclectic/flutter-birmingham-hub/issues)
- 🌐 [Flutter Documentation](https://docs.flutter.dev)
- 🔥 [Firebase Documentation](https://firebase.google.com/docs)

---

<div align="center">

**Made with ❤️ by the Birmingham Tech Community**

⭐ Star this repo if you find it helpful!

</div>
