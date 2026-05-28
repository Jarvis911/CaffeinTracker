import '../models/models.dart';

class PersonalizationService {
  int getDailySugarCap(SugarSensitivity sensitivity) {
    switch (sensitivity) {
      case SugarSensitivity.low:
        return 50;
      case SugarSensitivity.high:
        return 25;
      case SugarSensitivity.medium:
        return 35;
    }
  }

  ({int consumed, int limit, double percent}) getCaffeineStatus(
    UserProfile profile,
    List<LoggedDrink> logs,
    List<DrinkTemplate> catalog,
  ) {
    final consumed = _consumedToday(logs, catalog).caffeineMg;
    final limit = profile.dailyCaffeineLimitMg;
    final percent =
        limit > 0 ? (consumed / limit * 100).clamp(0, 100).toDouble() : 0.0;
    return (consumed: consumed, limit: limit, percent: percent);
  }

  List<DrinkRecommendation> getRecommendations({
    required HealthSnapshot health,
    required UserProfile profile,
    required List<LoggedDrink> logs,
    required List<DrinkTemplate> catalog,
  }) {
    final consumed = _consumedToday(logs, catalog);
    final remainingCaffeine =
        (profile.dailyCaffeineLimitMg - consumed.caffeineMg).clamp(0, 9999);
    final remainingSugar = (getDailySugarCap(profile.sugarSensitivity) -
            consumed.sugarG)
        .clamp(0, 999);
    final hour = DateTime.now().hour;
    final penalty = _healthPenalty(health);

    final results = catalog.map((drink) {
      final scored = _scoreDrink(
        drink: drink,
        health: health,
        profile: profile,
        remainingCaffeine: remainingCaffeine,
        remainingSugar: remainingSugar,
        hour: hour,
      );
      final adjusted =
          (scored.score - penalty * 0.15).round().clamp(0, 100);
      final topReason = scored.reasons.isNotEmpty
          ? scored.reasons.first
          : (adjusted > 70
              ? 'Looks like a cozy fit for today'
              : 'Okay in moderation today');

      return DrinkRecommendation(
        drink: drink,
        score: adjusted,
        reason: topReason,
        tweaks: scored.tweaks.isEmpty ? null : scored.tweaks,
      );
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return results.take(5).toList();
  }

  ({int caffeineMg, double sugarG}) _consumedToday(
    List<LoggedDrink> logs,
    List<DrinkTemplate> catalog,
  ) {
    final today = DateTime.now();
    var caffeineMg = 0;
    var sugarG = 0.0;

    for (final log in logs) {
      final logDate = log.loggedAt;
      if (logDate.year != today.year ||
          logDate.month != today.month ||
          logDate.day != today.day) {
        continue;
      }
      DrinkTemplate? drink;
      for (final d in catalog) {
        if (d.id == log.drinkId) {
          drink = d;
          break;
        }
      }
      if (drink == null) continue;
      caffeineMg += (drink.caffeineMg * log.amount).round();
      sugarG += drink.sugarG * log.amount;
    }
    return (caffeineMg: caffeineMg, sugarG: sugarG);
  }

  int _healthPenalty(HealthSnapshot health) {
    var penalty = 0;
    if (health.sleepHours < 6) {
      penalty += 25;
    } else if (health.sleepHours < 7) {
      penalty += 12;
    }
    if (health.restingHeartRate > 72) penalty += 15;
    if (health.stressLevel == StressLevel.high) penalty += 18;
    if (health.hydrationMl < 1200) penalty += 8;
    return penalty;
  }

  ({int score, List<String> reasons, List<String> tweaks}) _scoreDrink({
    required DrinkTemplate drink,
    required HealthSnapshot health,
    required UserProfile profile,
    required num remainingCaffeine,
    required num remainingSugar,
    required int hour,
  }) {
    var score = 100;
    final reasons = <String>[];
    final tweaks = <String>[];

    if (drink.caffeineMg > remainingCaffeine) {
      score -= 40;
      reasons.add('Would exceed your remaining caffeine budget');
    } else if (drink.caffeineMg <= remainingCaffeine * 0.5) {
      score += 8;
      reasons.add('Fits comfortably in today\'s caffeine budget');
    }

    if (drink.sugarG > remainingSugar) {
      score -= 35;
      reasons.add('High sugar for your sensitivity today');
    } else if (drink.sugarG == 0) {
      score += 6;
    }

    if (health.sleepHours < 6 && drink.caffeineMg > 80) {
      score -= 30;
      reasons.add('Short sleep — gentler caffeine is safer');
      tweaks.add('Try half-caf or a smaller size');
    }

    if (health.restingHeartRate > 72 && drink.caffeineMg > 100) {
      score -= 22;
      reasons.add('Elevated resting heart rate');
      tweaks.add('Consider decaf or green tea');
    }

    if (hour >= 15 && drink.caffeineMg > 50) {
      score -= 20;
      reasons.add('Afternoon — caffeine may affect tonight\'s sleep');
      tweaks.add('Switch to decaf or herbal after 2pm');
    }

    if (health.activeMinutes > 60 &&
        drink.caffeineMg >= 50 &&
        drink.caffeineMg <= 120) {
      score += 10;
      reasons.add('Good match after an active morning');
    }

    if (profile.preferredDrinkIds.contains(drink.id)) {
      score += 12;
      reasons.add('One of your favorites');
    }

    if (profile.sugarSensitivity == SugarSensitivity.high &&
        drink.sugarG > 15) {
      score -= 25;
      tweaks.add('Ask for less syrup or sugar-free milk');
    }

    return (
      score: score.clamp(0, 100),
      reasons: reasons,
      tweaks: tweaks,
    );
  }
}
