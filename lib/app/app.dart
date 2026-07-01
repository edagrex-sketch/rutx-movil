import 'package:flutter/material.dart';
import '../core/database/database_service.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';

class RutxApp extends StatelessWidget {
  final DatabaseService databaseService;

  const RutxApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUTX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: LoginPage(databaseService: databaseService),
    );
  }
}
