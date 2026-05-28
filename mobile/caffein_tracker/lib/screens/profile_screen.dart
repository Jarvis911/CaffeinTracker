import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../services/personalization_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;
  static final _personalization = PersonalizationService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final p = controller.profile;
        if (p == null) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Your profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: p.displayName),
              onSubmitted: (v) => _save(p.copyWith(displayName: v)),
            ),
            const SizedBox(height: 16),
            Text('Daily caffeine limit: ${p.dailyCaffeineLimitMg} mg'),
            Slider(
              min: 100,
              max: 600,
              divisions: 20,
              value: p.dailyCaffeineLimitMg.toDouble(),
              onChanged: (v) => _save(
                UserProfile(
                  id: p.id,
                  displayName: p.displayName,
                  dailyCaffeineLimitMg: v.round(),
                  sugarSensitivity: p.sugarSensitivity,
                  preferredDrinkIds: p.preferredDrinkIds,
                ),
              ),
            ),
            const Text('Sugar sensitivity'),
            const SizedBox(height: 8),
            SegmentedButton<SugarSensitivity>(
              segments: const [
                ButtonSegment(value: SugarSensitivity.low, label: Text('Low')),
                ButtonSegment(
                    value: SugarSensitivity.medium, label: Text('Medium')),
                ButtonSegment(
                    value: SugarSensitivity.high, label: Text('High')),
              ],
              selected: {p.sugarSensitivity},
              onSelectionChanged: (s) => _save(
                UserProfile(
                  id: p.id,
                  displayName: p.displayName,
                  dailyCaffeineLimitMg: p.dailyCaffeineLimitMg,
                  sugarSensitivity: s.first,
                  preferredDrinkIds: p.preferredDrinkIds,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sugar guidance cap: ~${_personalization.getDailySugarCap(p.sugarSensitivity)}g',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            if (!controller.useOfflineDemo) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => controller.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ],
        );
      },
    );
  }

  void _save(UserProfile updated) => controller.updateProfile(updated);
}

extension on UserProfile {
  UserProfile copyWith({String? displayName}) => UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        dailyCaffeineLimitMg: dailyCaffeineLimitMg,
        sugarSensitivity: sugarSensitivity,
        preferredDrinkIds: preferredDrinkIds,
      );
}
