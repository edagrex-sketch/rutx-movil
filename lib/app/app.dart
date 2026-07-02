import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/splash_page.dart';

class RutxApp extends StatelessWidget {
  const RutxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUTX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
}
