import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'shared/services/local_storage_service.dart';
import 'shared/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.load();
  await Hive.initFlutter();
  await LocalStorageService.instance.initialize();
  await SupabaseService.instance.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GazaBuildApp());
}
