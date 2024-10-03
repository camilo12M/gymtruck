import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtrack/config/router/app_router.dart';
import 'package:gymtrack/config/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymtrack/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme().themeData,
      localizationsDelegates: const [
        // Define los delegados de localización
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        // Define los locales que tu app soporta
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español
        // Añade otros idiomas aquí
      ],
    );
  }
}