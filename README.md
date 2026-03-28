<p align="center">
  <img src="assets/images/flutter.png" width="100%" alt="AutoTrack Banner">
</p>

# 🚗 AutoTrack - Smart Vehicle Management

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-v3.9.2-blue?logo=flutter&logoColor=white" alt="Flutter Badge">
  <img src="https://img.shields.io/badge/Firebase-Supported-orange?logo=firebase&logoColor=white" alt="Firebase Badge">
  <img src="https://img.shields.io/badge/Status-Beta-brightgreen" alt="Status Badge">
  <img src="https://img.shields.io/badge/License-MIT-purple" alt="License Badge">
</p>

**AutoTrack** is a modern, premium mobile application built with Flutter to help you manage your vehicles and track service history with ease. Never miss a maintenance schedule again with our smart reminder system.

---

## 📸 App Showcase

<p align="center">
  <img src="assets/images/mockup-mobile.png" width="80%" alt="AutoTrack App Mockup">
</p>

---

## ✨ Key Features

- **🏎 Complete Vehicle Management**: Track multiple vehicles, including cars and motorcycles.
- **🛠 Service History Logging**: Keep detailed records of every maintenance, including cost and description.
- **📅 Smart Reminders**: Automatically schedule and receive notifications for your next service.
- **☁️ Real-time Cloud Sync**: Your data is always safe and synchronized across devices via Firebase Firestore.
- **🔐 Secure Authentication**: Easy and secure login with Email or Google Sign-In.
- **🔔 Interactive Notifications**: Get timely alerts for service updates and reminders.

---

## 🛠 Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (Dart)
*   **Backend**: [Firebase](https://firebase.google.com) (Auth, Firestore, Messaging)
*   **Local Data**: SharedPreferences
*   **State Management**: Provider / StatefulWidgets
*   **Architecture**: MVVM-inspired clean structure

---

## 🚀 Getting Started

Follow these steps to set up the project on your local machine:

### 1. Prerequisites
Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started)
- Android Studio / VS Code with Flutter extension

### 2. Installation
Clone the repository:
```bash
git clone https://github.com/ibnuarip/autotrack.git
cd autotrack
```

Install dependencies:
```bash
flutter pub get
```

### 3. Setup Firebase
- Create a new Firebase project at [Firebase Console](https://console.firebase.google.com).
- Add Android/iOS apps and download `google-services.json` / `GoogleService-Info.plist`.
- Place them in the respective directories:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

### 4. Running the App
```bash
flutter run
```

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">Built with ❤️ by <a href="https://github.com/ibnuarip">Ibnu Arip</a></p>