import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/caffeine_ring.dart';
import '../widgets/recommendation_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final c = controller;
        final profile = c.profile;
        final status = c.caffeineStatus;

        return RefreshIndicator(
          onRefresh: c.refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Hi, ${profile?.displayName ?? 'Friend'} 👋',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                c.hasHealth
                    ? 'Drinks tuned to your health today'
                    : 'Connect health for personalized picks',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CaffeineRing(
                      percent: status.percent,
                      consumed: status.consumed,
                      limit: status.limit,
                    ),
                  ),
                ),
              ),
              if (c.hasHealth) ...[
                const SizedBox(height: 16),
                const Text('Today\'s wellness',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('😴', '${c.health!.sleepHours.toStringAsFixed(1)}h sleep'),
                    _chip('💓', '${c.health!.restingHeartRate} bpm'),
                    _chip('👟', '${c.health!.steps} steps'),
                    _chip('💧', '${(c.health!.hydrationMl / 1000).toStringAsFixed(1)}L'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Picked for you',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...c.recommendations.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecommendationCard(
                      item: r,
                      onLog: () => c.logDrink(r.drink.id),
                    ),
                  ),
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Link Apple Health or Health Connect to unlock smart drink picks.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            // Parent shell switches tab via callback if provided
                          },
                          child: const Text('Connect health (Sync tab)'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String icon, String label) {
    return Chip(
      avatar: Text(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }
}
