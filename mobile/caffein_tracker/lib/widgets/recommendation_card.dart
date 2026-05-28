import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    required this.onLog,
  });

  final DrinkRecommendation item;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final scoreColor = item.score >= 75
        ? AppColors.mintDeep
        : item.score >= 50
            ? AppColors.accentDeep
            : Colors.pink.shade700;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.drink.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.drink.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.reason,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.score}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            if (item.tweaks != null) ...[
              const SizedBox(height: 8),
              ...item.tweaks!.map(
                (t) => Text('• $t',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onLog,
                child: const Text('Log this drink'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
