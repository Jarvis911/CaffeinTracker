import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config/env.dart';
import 'screens/app_shell.dart';
import 'screens/auth_screen.dart';
import 'services/app_controller.dart';
import 'services/health_service.dart';
import 'services/personalization_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env optional — falls back to demo mode
  }

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  final controller = AppController(
    healthService: HealthService(),
    personalization: PersonalizationService(),
  );
  await controller.init();

  runApp(CaffeinTrackerApp(controller: controller));
}

class CaffeinTrackerApp extends StatefulWidget {
  const CaffeinTrackerApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<CaffeinTrackerApp> createState() => _CaffeinTrackerAppState();
}

class _CaffeinTrackerAppState extends State<CaffeinTrackerApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: c.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      theme: buildAppTheme(),
      home: c.canEnterApp
          ? AppShell(
              controller: c,
              healthService: c.healthService,
            )
          : AuthScreen(controller: c),
    );
  }
}
