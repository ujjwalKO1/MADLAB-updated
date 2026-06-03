import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDvryC5MQYPePdc_JnCoBaeGd_hkUvoP2E",
        authDomain: "evntnxt-e715a.firebaseapp.com",
        projectId: "evntnxt-a715a",
        storageBucket: "evntnxt-e715a.firebasestorage.app",
        messagingSenderId: "978311481913",
        appId: "1:978311481913:web:54cca57ccdd65d46511be8",
        measurementId: "G-Q5GZ5TDQVK",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surfaceWhite,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const EvntNxtApp());
}

class EvntNxtApp extends StatefulWidget {
  const EvntNxtApp({super.key});

  @override
  State<EvntNxtApp> createState() => _EvntNxtAppState();
}

class _EvntNxtAppState extends State<EvntNxtApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvntNxt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: OnboardingScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}
