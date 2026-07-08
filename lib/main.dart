import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/database/database_service.dart';
import 'core/network/sync_service.dart';
import 'core/network/notification_polling_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final databaseService = DatabaseService();
  await databaseService.initialize();

  SyncService().start();
  NotificationPollingService().start();

  runApp(const RutxApp());
}
