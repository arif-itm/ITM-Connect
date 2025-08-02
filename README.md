# ITM Connect

ITM Connect is a cross‑platform Flutter application for institutes. It helps students and teachers stay informed and organized with:
- Notices and announcements
- Class routines/schedules
- Teacher directory and contact
- Feedback submission

An admin CMS (inside the app) enables authorized staff to manage notices, routines, teachers, and review feedback. The project is built with Flutter and Firebase (Firestore), and targets Android, iOS, Web, and Windows.

![Screenshot](/assets/images/admin-home.png)

## Table of Contents
- Overview
- Features
- Architecture
- Tech Stack
- Project Structure
- Getting Started
  - Prerequisites
  - Firebase Setup
  - Configure Platforms (Android/iOS/Web/Windows)
  - Run the App
- Environment & Configuration
- Development
  - Code Style
  - Linting
  - Testing
- Build & Release
- Deployment (Web)
- Security & Privacy
- Troubleshooting
- Roadmap
- Contributing
- License

## Overview

ITM Connect centralizes institute communications and schedules in one app:
- Students/teachers can view notices, routines, teacher profiles, and contact information.
- Users can submit feedback to the admin.
- Admins have a secure area to manage all content.

Primary goals:
- Simple, reliable access to academic info
- Minimal setup using Firebase Firestore
- Scalable feature structure and routing

## Features

User-facing
- Landing and onboarding
- Home dashboard
- Notice board with latest updates
- Class routine by day/department/section (configurable in code/data)
- Teacher directory (list and profile)
- Contact us page with institute contact details
- Feedback submission form

Admin-facing
- Admin login
- Dashboard for quick stats/shortcuts
- Manage Notices: create, edit, publish/unpublish, delete
- Manage Routines: create/modify scheduled classes
- Manage Teachers: add/update teacher info
- Manage Feedback: view and respond to user feedback
- Settings: admin contact details, app info

Cross-cutting
- Drawer-based navigation for user/admin roles
- Shared widgets (headers, buttons, layout scaffolds)
- Centralized Firestore service

## Architecture

- Pattern: Layered by features (admin, user, shared), with screens and shared widgets.
- Routing: lib/routes.dart defines named routes for screens, with a central app wrapper in lib/app/app.dart and entry in lib/main.dart.
- Data: lib/services/firestore_service.dart provides Firestore read/write helpers for notices, routines, teachers, feedback. Data models can be evolved as needed.
- UI: Feature-first directories under lib/features with clear separation between admin and user modules.
- Assets: Stored under assets/ (animations, images) and declared in pubspec.yaml.

High-level flow
- main.dart initializes Firebase (via generated firebase_options.dart) and runs App widget.
- routes.dart maps route names to screens.
- Screens use FirestoreService for CRUD operations on Firestore collections.
- Admin screens provide forms/tables to manage institute data.

## Tech Stack

- Flutter (stable) for cross-platform UI
- Firebase Firestore for data storage
- Dart language with static analysis (analysis_options.yaml)
- Platforms: Android, iOS, Web, Windows

Note: Defaults assume Firestore only. You can extend with Firebase Auth, Storage, or FCM later.

## Project Structure

Key paths (non-exhaustive):
- lib/
  - main.dart
  - routes.dart
  - app/app.dart
  - services/firestore_service.dart
  - features/
    - landing/landing_screen.dart
    - user/
      - home/user_home_screen.dart
      - notice/notice_board_screen.dart
      - class_routine/class_routine_screen.dart
      - teacher/
        - list/
        - profile/
      - contact/contact_us_screen.dart
      - feedback/feedback_screen.dart
      - drawer/user_drawer.dart
    - admin/
      - login/admin_login_screen.dart
      - dashboard/admin_dashboard_screen.dart
      - manage_notices/manage_notices_screen.dart
      - manage_routines/manage_routines_screen.dart
      - manage_teachers/manage_teachers_screen.dart
      - feedback/manage_feedback_screen.dart
      - settings/admin_contact_screen.dart
      - shared/admin_drawer.dart
  - widgets/
    - admin_app_layout.dart
    - app_layout.dart
    - universal_header.dart
    - universal_drawer.dart
    - side_menu.dart
    - custom_button.dart
    - itm_logo_header.dart
- assets/
  - animations/intro.json
  - images/app_icon.png, Itm_logo.png
- web/ (PWA metadata)
- android/, ios/, windows/ (platform projects)
- firebase.json, firestore.rules

## Getting Started

### Prerequisites
- Flutter SDK installed (stable channel)
- A configured Firebase project
- Dart enabled in your IDE (VS Code or Android Studio)
- Platform SDKs as needed:
  - Android SDK/Android Studio
  - Xcode (iOS)
  - Chrome (Web)
  - Visual Studio C++ workload (Windows)

### Firebase Setup
1) Create a Firebase project in console.firebase.google.com.
2) Enable Firestore (Native mode).
3) Run FlutterFire CLI or add firebase_options.dart (already present):
   - If rotating keys or changing project:
     - dart pub global activate flutterfire_cli
     - flutterfire configure
     This regenerates lib/firebase_options.dart and adds platform config files.
4) Place platform config files (already included in repo):
   - Android: android/app/google-services.json
   - iOS: ios/Runner/GoogleService-Info.plist (managed by FlutterFire)
5) Update security rules (firestore.rules). For production, restrict writes to authorized admins.

### Configure Platforms

Android
- Ensure google-services plugin is applied (Kotlin Gradle scripts already configured).
- Min/target SDK defined in android/build files.

iOS
- Open ios/Runner.xcworkspace in Xcode for signing and capabilities.
- Ensure Firebase iOS config is present (via FlutterFire).

Web
- web/index.html and web/manifest.json are provided.
- Ensure Firebase web app credentials match firebase_options.dart.

Windows
- Requires Visual Studio with Desktop development with C++.
- Windows runner is scaffolded by Flutter.

### Run the App

From project root:
- flutter pub get
- flutter run
  - Select a device: Android emulator, iOS simulator, Chrome, or Windows.

To run on a specific platform:
- flutter run -d chrome
- flutter run -d windows
- flutter run -d emulator-5554

## Environment & Configuration

- Firebase options are stored in lib/firebase_options.dart (generated).
- Firestore rules: firestore.rules — update to enforce admin-only writes to admin collections.
- App assets are declared in pubspec.yaml under assets:.

Recommended environment separation
- Use separate Firebase projects for dev/staging/prod.
- Generate a firebase_options.dart per environment with flutterfire configure --project=...

## Development

Code Style
- Follow Flutter/Dart best practices (effective naming, small widgets, immutable models).
- Keep feature-first structure under lib/features.

Linting
- analysis_options.yaml configures lints.
- Run: dart analyze

Testing
- Widget test example at test/widget_test.dart.
- Add tests per feature where feasible.
- Run: flutter test

## Build & Release

Android
- Debug: flutter build apk
- Release:
  - Create keystore and configure signing in android/ as per Flutter docs.
  - flutter build appbundle
  - Upload AAB to Play Console.

iOS
- flutter build ios --release
- Archive and distribute with Xcode.

Web
- flutter build web
- Outputs to build/web.

Windows
- flutter build windows

## Deployment (Web)

- After flutter build web, host build/web/ on any static site hosting (Firebase Hosting, GitHub Pages, Nginx).
- For Firebase Hosting:
  - firebase init hosting
  - Set public directory to build/web
  - firebase deploy

## Security & Privacy

- Firestore security rules must restrict admin actions.
- Do not commit secrets beyond standard Firebase public web config.
- Validate and sanitize any user-submitted fields (feedback).
- Consider rate limiting and moderation for public content.

Example rule approach (pseudo):
- Only authenticated admin users can write to admin collections (notices, routines, teachers).
- All users can read published content.
Adjust firestore.rules accordingly.

## Troubleshooting

- Firebase initialization issues:
  - Ensure lib/firebase_options.dart matches the active Firebase project.
  - For web, confirm your app’s Firebase config is included via flutterfire configure.
- Permission errors:
  - Review firestore.rules to confirm read/write access per role.
- Build failures:
  - Run flutter clean & flutter pub get.
  - Confirm Gradle/Xcode versions and platform SDKs.
- Web blank screen:
  - Check browser console for Firebase initialization errors or CORS issues.

## Roadmap

- Optional Firebase Auth for role-based access (admin vs user)
- Push notifications (Firebase Cloud Messaging)
- Offline caching for schedules and notices
- Rich text notices and file attachments (requires Storage)
- Role-based navigation guards

## Contributing

- Fork the repo and create feature branches.
- Ensure dart analyze and tests pass.
- Open a pull request with a clear description and screenshots if UI changes are made.

## License

MIT License. See below.

---

Copyright (c) 2025 ITM Connect contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
