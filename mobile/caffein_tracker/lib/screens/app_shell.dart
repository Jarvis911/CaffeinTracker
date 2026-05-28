import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/app_controller.dart';
import '../services/health_service.dart';
import 'connect_screen.dart';
import 'home_screen.dart';
import 'log_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.controller,
    required this.healthService,
  });

  final AppController controller;
  final HealthService healthService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      HomeScreen(controller: widget.controller),
      LogScreen(controller: widget.controller),
      ConnectScreen(
        controller: widget.controller,
        healthService: widget.healthService,
      ),
      ProfileScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.coffee_outlined), label: l10n.navLog),
          NavigationDestination(icon: const Icon(Icons.favorite_outline), label: l10n.navSync),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.navYou),
        ],
      ),
    );
  }
}
