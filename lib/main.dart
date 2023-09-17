import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/chat.dart';
import 'utils/colors.dart';
import 'firebase_options.dart';
import 'pages/authentication/login.dart';
import 'pages/authentication/signup.dart';
import 'pages/conversations.dart';
import 'pages/contacts.dart';
import 'pages/profile.dart';
import 'pages/qr_scanner.dart';
import 'pages/user_profile.dart';
import 'provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDataProvider(),
      child: MaterialApp(
        title: 'Secure Messenger',
        theme: themeColors,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LogIn(),
          '/signup': (context) => SignUp(),
          '/contacts': (context) => const ContactPage(),
          '/chat-page': (context) => const ConversationPage(),
          '/chat': (context) => const Chat(),
          '/profile': (context) => const ProfilePage(),
          '/user-profile': (context) => const UserProfilePage(),
          '/scan-qr': (context) => QRScanPage(),
        },
      ),
    );
  }
}
