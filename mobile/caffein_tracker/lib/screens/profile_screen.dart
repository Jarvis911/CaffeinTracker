import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final p = controller.profile;
        if (p == null) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.profileTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.displayName,
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: p.displayName),
              onSubmitted: (v) => _save(p.copyWith(displayName: v)),
            ),
            const SizedBox(height: 16),
            Text(l10n.caffeineLimit(p.dailyCaffeineLimitMg)),
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
            Text(l10n.sugarSensitivity),
            const SizedBox(height: 8),
            SegmentedButton<SugarSensitivity>(
              segments: [
                ButtonSegment(value: SugarSensitivity.low, label: Text(l10n.sugarLow)),
                ButtonSegment(
                    value: SugarSensitivity.medium, label: Text(l10n.sugarMedium)),
                ButtonSegment(
                    value: SugarSensitivity.high, label: Text(l10n.sugarHigh)),
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
            const SizedBox(height: 16),
            Text(l10n.language),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.langEn)),
                ButtonSegment(value: 'vi', label: Text(l10n.langVi)),
              ],
              selected: {controller.locale?.languageCode ?? Localizations.localeOf(context).languageCode},
              onSelectionChanged: (s) => controller.setLocale(Locale(s.first)),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sugarGuidance(_personalization.getDailySugarCap(p.sugarSensitivity)),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            if (!controller.useOfflineDemo) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => controller.signOut(),
                child: Text(l10n.signOut),
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
