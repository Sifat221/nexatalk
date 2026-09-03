import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/contacts_controller.dart';
import 'controllers/settings_controller.dart';
import 'core/config/firebase_options.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_chat_service.dart';
import 'services/notification_service.dart';
import 'services/persistence_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase Core
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      print('Firebase.initializeApp note: $e');
    }
  }

  // 2. Initialize Local Persistence
  final persistenceService = await PersistenceService.init();

  // 3. Instantiate Real Firebase Services (with graceful fallback)
  final AuthService authService = isFirebaseInitialized
      ? FirebaseAuthService(persistence: persistenceService)
      : MockAuthService(persistenceService);

  final ChatService chatService = isFirebaseInitialized
      ? FirestoreChatService(persistence: persistenceService)
      : MockChatService(persistenceService);

  final storageService = StorageService();
  final notificationService = NotificationService();

  // 4. Initialize FCM Push Notifications (non-blocking for web)
  if (isFirebaseInitialized && !kIsWeb) {
    try {
      await notificationService.init(persistenceService.getSavedUser()?.id);
    } catch (_) {}
  }

  runApp(
    NexaTalkApp(
      persistenceService: persistenceService,
      authService: authService,
      chatService: chatService,
      storageService: storageService,
      notificationService: notificationService,
    ),
  );
}

/// Root Application Widget for NexaTalk.
class NexaTalkApp extends StatelessWidget {
  final PersistenceService persistenceService;
  final AuthService authService;
  final ChatService chatService;
  final StorageService? storageService;
  final NotificationService? notificationService;

  const NexaTalkApp({
    super.key,
    required this.persistenceService,
    required this.authService,
    required this.chatService,
    this.storageService,
    this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PersistenceService>.value(value: persistenceService),
        Provider<AuthService>.value(value: authService),
        Provider<ChatService>.value(value: chatService),
        if (storageService != null) Provider<StorageService>.value(value: storageService!),
        if (notificationService != null) Provider<NotificationService>.value(value: notificationService!),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(authService),
        ),
        ChangeNotifierProvider<ChatController>(
          create: (_) => ChatController(chatService),
        ),
        ChangeNotifierProvider<ContactsController>(
          create: (_) => ContactsController(chatService),
        ),
        ChangeNotifierProvider<SettingsController>(
          create: (_) => SettingsController(persistenceService),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsCtrl, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: settingsCtrl.oledMode ? AppTheme.oledTheme : AppTheme.darkTheme,
            darkTheme: settingsCtrl.oledMode ? AppTheme.oledTheme : AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
