import 'dart:io';

import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({
    super.key,
    required this.controller,
    required this.healthService,
  });

  final AppController controller;
  final HealthService healthService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final native = healthService.nativeProvider;
        final nativeLabel = healthService.platformLabel;
        final nativeConnected = controller.connections
            .any((c) => c.provider == native && c.connected);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Fitness sync',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Grant access to read sleep, heart rate, steps & water — used only to personalize your drinks.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            _ProviderTile(
              emoji: Platform.isIOS ? '🍎' : '💚',
              title: nativeLabel,
              subtitle: Platform.isIOS
                  ? 'HealthKit on iPhone & Apple Watch'
                  : 'Health Connect on Android',
              connected: nativeConnected,
              loading: controller.loading,
              onConnect: () async {
                final ok = await controller.connectNativeHealth();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Synced from $nativeLabel'
                          : controller.error ?? 'Sync failed'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            _ProviderTile(
              emoji: '✏️',
              title: 'Refresh health data',
              subtitle: 'Pull latest metrics again',
              connected: controller.hasHealth,
              loading: controller.loading,
              onConnect: () async {
                await controller.syncHealth();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Health data refreshed')),
                  );
                }
              },
            ),
            if (controller.hasHealth) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Latest snapshot',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Sleep ${controller.health!.sleepHours.toStringAsFixed(1)}h · '
                        'HR ${controller.health!.restingHeartRate} · '
                        'Steps ${controller.health!.steps}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Fitbit, Garmin & Google Fit OAuth can be added via Supabase Edge Functions later.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        );
      },
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.connected,
    required this.loading,
    required this.onConnect,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool connected;
  final bool loading;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: connected
            ? const Icon(Icons.check_circle, color: AppColors.mintDeep)
            : FilledButton(
                onPressed: loading ? null : onConnect,
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Connect'),
              ),
      ),
    );
  }
}
