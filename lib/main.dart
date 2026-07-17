import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'utils/app_theme.dart';
import 'utils/theme_provider.dart';
import 'views/dashboard/main_dashboard.dart';
import 'views/auth/login_screen.dart';

// Firebase configuration for QatarSale
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDoxWNaXedeQ6ayCo2F3H5A_s3PL18uMWM",
  authDomain: "qatar-sale.firebaseapp.com",
  databaseURL: "https://qatar-sale-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "qatar-sale",
  storageBucket: "qatar-sale.firebasestorage.app",
  messagingSenderId: "671530950257",
  appId: "1:671530950257:web:78db3c1394d32f83ed45d0",
  measurementId: "G-CDPV9TDN2V",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FnBMarketAdminApp(),
    ),
  );
}

class FnBMarketAdminApp extends StatelessWidget {
  const FnBMarketAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'FnB Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const MainDashboard();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
