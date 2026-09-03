# 💬 NexaTalk — Modern Real-Time Messaging Platform

> **Connect simply. Chat naturally.**

[![GitHub](https://img.shields.io/badge/GitHub-Sifat221%2Fnexatalk-181717?logo=github)](https://github.com/Sifat221/nexatalk)
[![Firebase Hosting](https://img.shields.io/badge/Live_Demo-nexa--talk--169ff.web.app-FFA611?logo=firebase)](https://nexa-talk-169ff.web.app)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 🌐 Live Demo & Repository Links

* **Live Web App**: [https://nexa-talk-169ff.web.app](https://nexa-talk-169ff.web.app)
* **Alternative Domain**: [https://nexa-talk-169ff.firebaseapp.com](https://nexa-talk-169ff.firebaseapp.com)
* **GitHub Repository**: [https://github.com/Sifat221/nexatalk](https://github.com/Sifat221/nexatalk)

---

## 📖 Project Overview

NexaTalk is a responsive, dark-first real-time messaging application built with **Flutter** and backed entirely by **Google Firebase** (Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging). The application operates serverlessly under the **Firebase Spark (Free) plan**, delivering multi-user direct messaging, group conversations, live typing indicators, read receipts, emoji reactions, and user directory search without requiring external servers or custom database infrastructure.

---

## 🏛️ System Architecture

NexaTalk connects Flutter clients (Android, iOS, Web, Desktop) directly to Firebase managed services. No custom backend runtime, Docker daemon, or relational database is required to run the active application.

```text
┌──────────────────────────────────────────────────────────────┐
│                    NexaTalk Flutter Client                   │
│             (Android • iOS • Web • Windows/macOS)            │
└──────────────────────────────┬───────────────────────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            │                  │                  │
            ▼                  ▼                  ▼
  ┌──────────────────┐ ┌───────────────┐ ┌──────────────────┐
  │     Firebase     │ │ Cloud Firestore│ │  Firebase Cloud  │
  │  Authentication  │ │  (Real-Time)   │ │ Messaging (FCM)  │
  └──────────────────┘ └───────────────┘ └──────────────────┘
```

> **Note on Legacy Backend**: The `backend/` and `docker/` directories contain reference implementations and API archives from an earlier self-hosted prototype (Node.js/PostgreSQL/Prisma/Socket.IO). They are preserved strictly for historical reference and are **not** part of the active runtime.

---

## ✨ Key Features

### 🔐 Authentication
* **Email & Password**: Real Firebase Authentication sign-up and sign-in with automatic Firestore user profile synchronization.
* **Session Persistence**: Persistent local auth tokens backed by `SharedPreferences`.
* **Password Reset**: Automated password reset emails delivered via Firebase Auth.
* **Friendly Error Handling**: Maps Firebase error codes (`invalid-credential`, `email-already-in-use`, `weak-password`, `too-many-requests`) into user-friendly notifications.
* **One-Tap Demo Login**: Instant test authentication for local development and review.
* **Phone & Google Sign-In Status**: Code interfaces are implemented in `lib/services/firebase_auth_service.dart`. Google Sign-In and Phone OTP require valid SHA-1 certificate fingerprints added in the Firebase Console (the Android client includes the generated OAuth client configuration).

### 💬 Real-Time Messaging
* **Direct 1-on-1 Chat**: Low-latency message synchronization using Firestore snapshot listeners (`snapshots()`).
* **Multi-User Group Chats**: Create group conversations with custom titles and multi-contact member selection.
* **Live Typing Indicators**: Real-time typing indicators with client-side debouncing to optimize Firestore write quotas on the Spark plan.
* **Read Receipts & Unread Counters**: Atomically tracks per-user unread counts and marks conversations read upon opening.
* **Message Reactions**: Real-time emoji reactions (❤️, 👍, 🔥, 😂, 😮, ✨) persisted via atomic `FieldValue.arrayUnion` / `arrayRemove`.
* **Conversation Management**: Pin priority conversations to the top and mute notifications.

### 👤 User Profiles & Directory
* **Real-Time Profile Sync**: Display names, bios, usernames, and contact info stored and synced live in `users/{uid}`.
* **Personalized Radiant Avatars**: 4 vibrant, customizable gradient theme presets with initials fallback.
* **User Search**: Instant search querying Firestore by user display names, `@usernames`, or tags.

### 🔔 Push Notifications
* **FCM Registration**: Automatic device token registration and token refresh listener in `users/{uid}.fcmTokens`.

---

## ⚡ Current Spark Plan Notice & Media Uploads

NexaTalk is architected to run on the **Firebase Spark (Free) plan** without requiring Blaze billing or credit card activation:

* **Text Messaging, Reactions, Typing & Profiles**: 100% functional via Cloud Firestore and Firebase Auth.
* **Media Attachment Uploads (Photos, Videos, Documents, Voice Notes)**: **Disabled by design**. In Google Cloud / Firebase, Cloud Storage bucket provisioning requires the pay-as-you-go Blaze plan. Tapping attachment options displays an informative in-app banner explaining that media storage requires a Blaze plan, ensuring the application never crashes, fails unexpectedly, or incurs surprise billing.

---

## 🗄️ Firestore Data Structure

```text
users/ (collection)
  └── {userId} (document)
        ├── id: string
        ├── name: string
        ├── displayName: string
        ├── email: string
        ├── username: string
        ├── bio: string
        ├── phone: string
        ├── avatarColor: string ("1", "2", "3", "4")
        ├── avatarUrl: string | null
        ├── isOnline: boolean
        ├── lastActive: timestamp
        ├── fcmTokens: array<string>
        └── createdAt: timestamp

conversations/ (collection)
  └── {conversationId} (document)
        ├── id: string
        ├── isGroup: boolean
        ├── title: string
        ├── participantIds: array<string> [uid1, uid2, ...]
        ├── participantMap: map<string, map> { uid: { name, email, roleOrTag, isOnline } }
        ├── lastMessage: map { id, senderId, senderName, text, timestamp, status }
        ├── unreadCounts: map<string, int> { uid1: 0, uid2: 1 }
        ├── pinned: map<string, bool> { uid1: false, uid2: false }
        ├── muted: map<string, bool> { uid1: false, uid2: false }
        ├── typing: map<string, boolean> { uid1: false, uid2: true }
        ├── updatedAt: timestamp
        ├── createdAt: timestamp
        │
        └── messages/ (subcollection)
              └── {messageId} (document)
                    ├── id: string
                    ├── conversationId: string
                    ├── senderId: string
                    ├── senderName: string
                    ├── text: string
                    ├── timestamp: timestamp
                    ├── status: string ("sent", "delivered", "read")
                    ├── attachmentType: string ("none", "image", "document", "voiceNote")
                    ├── attachmentData: string | null
                    ├── reactions: array<string>
                    └── readBy: array<string>
```

---

## 🛡️ Security Rules

Firestore security is enforced via declarative rules in `firestore.rules`:

* **Unauthenticated Access Blocked**: All read and write requests require valid `request.auth`.
* **Profile Protection**: Users can only create or update their own user document (`request.auth.uid == userId`). Arbitrary profile deletion is disabled.
* **Conversation Privacy**: Only users whose UID is listed in `participantIds` can read, create, or update conversation documents.
* **Message Integrity**: Messages in `conversations/{id}/messages` can only be read and created by verified conversation participants, with mandatory validation that `request.resource.data.senderId == request.auth.uid`. Deletions are restricted to the message sender.

---

## 📱 Screenshots

| Chats & Online Tray | Real-Time Conversation | Profile & Themes |
|:---:|:---:|:---:|
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.24.0`)
* Dart SDK (`>= 3.5.0`)
* A Firebase project created at [Firebase Console](https://console.firebase.google.com/)

### 1. Clone the Repository
```bash
git clone https://github.com/Sifat221/nexatalk.git
cd nexatalk
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
The repository includes sample client configurations configured for `nexa-talk-169ff`:
* Android: `android/app/google-services.json`
* Multi-platform Dart options: `lib/core/config/firebase_options.dart`

To connect your own Firebase project:
1. Enable **Email/Password** under Firebase Console > **Authentication** > **Sign-in method**.
2. Create a **Cloud Firestore** database in test/production mode.
3. Publish the rules from `firestore.rules` in the Firebase Console **Rules** tab.
4. Run `flutterfire configure` to generate your project's `firebase_options.dart`.

---

## 💻 Running the App

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android
* **Physical Device**: Connect phone via USB with Developer Options & USB Debugging enabled:
  ```bash
  flutter run -d android
  ```
* **Emulator**: Ensure hardware virtualization (Hyper-V / Windows Hypervisor Platform) is enabled, start your AVD, and run:
  ```bash
  flutter run -d android
  ```

### Windows Desktop
```bash
flutter run -d windows
```

---

## 🌐 Deploying to Firebase Hosting

To build and deploy the Flutter Web application to Firebase Hosting:

```bash
# 1. Build the production Web bundle
flutter build web

# 2. Deploy only Firebase Hosting
firebase deploy --only hosting
```

Your web app will be live at:
* `https://<your-project-id>.web.app`
* `https://<your-project-id>.firebaseapp.com`

---

## 🧪 Testing & Verification

Run the full automated test suite and static analysis:

```bash
# Static analysis
flutter analyze

# Unit and widget test suite (25 tests)
flutter test
```

### Building for Production

```bash
# Build Web bundle (outputs to build/web)
flutter build web

# Build Android Release APK (outputs to build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release
```

---

## 📂 Project Structure

```text
lib/
├── controllers/          # State controllers (Auth, Chat, Contacts, Settings)
├── core/
│   ├── config/           # Firebase options and app runtime config
│   ├── constants/        # Theme colors, typography tokens, radius, strings
│   ├── theme/            # Material 3 Dark & OLED themes
│   └── utils/            # Date and text formatters
├── models/               # UserModel, ConversationModel, MessageModel, ContactModel
├── screens/
│   ├── auth/             # Sign-in, Sign-up, Forgot Password, OTP screens
│   ├── chat/             # Real-time chat screen, attachment modal, reactions
│   ├── home/             # Main chats list, online tray, navigation
│   ├── new_chat/         # Contact picker and New Group creation dialog
│   ├── profile/          # Profile details, avatar style customizer
│   ├── settings/         # OLED toggle, notification settings, logout
│   └── splash/           # Animated splash and session restore
├── services/             # FirebaseAuthService, FirestoreChatService, NotificationService
└── widgets/              # Reusable UI (CustomAvatar, MessageBubble, TypingIndicator, etc.)
```

---

## ⚠️ Known Limitations

1. **Firebase Storage / Media Uploads**: Media uploads (photos, videos, documents, audio messages) require upgrading to the Google Cloud / Firebase Blaze plan. On the free Spark plan, media upload triggers an informative banner while text chat remains fully operational.
2. **Apple & Phone Authentication**: The client code interfaces for Apple Sign-In and Phone OTP are implemented; live production use requires configuring Apple Developer Team credentials and enabling SMS verification quotas in Firebase Console.
3. **Web Push (FCM)**: Web push notifications require a custom VAPID key configured in the Firebase Console.

---

## 🛠️ Technologies Used

* **Framework**: Flutter 3 (Dart 3)
* **Backend as a Service**: Firebase (Authentication, Cloud Firestore, Cloud Messaging)
* **Hosting**: Firebase Hosting
* **State Management**: Provider
* **Storage & Persistence**: SharedPreferences
* **UI Design**: Material 3, Dark & OLED Mode, Custom Glassmorphic Gradients

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
