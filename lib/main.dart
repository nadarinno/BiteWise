

import 'package:bitewise/services/auth_wrapper.dart';
import 'package:bitewise/viewmodel/auth_view_model.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/viewmodel/plan_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme/app_theme.dart';
import 'viewmodel/theme_view_model.dart';
import 'viewmodel/nutrition_view_model.dart';
import 'viewmodel/chat_view_model.dart';
import 'viewmodel/meal_view_model.dart';
import 'viewmodel/setting_view_model.dart';
import 'viewmodel/profile_view_model.dart';
import 'viewmodel/language_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  final languageViewModel = LanguageViewModel();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageViewModel),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => NutritionViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => MealViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => PlanViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();
    final languageVm = context.watch<LanguageViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeVm.themeMode,

      locale: languageVm.locale,

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        return Directionality(
          textDirection: languageVm.isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      home: const AuthWrapper(),
    );
  }
}