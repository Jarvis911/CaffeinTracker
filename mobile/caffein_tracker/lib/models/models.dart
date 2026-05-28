enum SugarSensitivity { low, medium, high }

enum StressLevel { low, medium, high }

enum FitnessProvider {
  appleHealth('apple_health'),
  healthConnect('health_connect'),
  googleFit('google_fit'),
  fitbit('fitbit'),
  garmin('garmin'),
  samsungHealth('samsung_health'),
  manual('manual');

  const FitnessProvider(this.value);
  final String value;

  static FitnessProvider? fromValue(String? v) {
    if (v == null) return null;
    for (final e in FitnessProvider.values) {
      if (e.value == v) return e;
    }
    return null;
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.dailyCaffeineLimitMg,
    required this.sugarSensitivity,
    required this.preferredDrinkIds,
  });

  final String id;
  final String displayName;
  final int dailyCaffeineLimitMg;
  final SugarSensitivity sugarSensitivity;
  final List<String> preferredDrinkIds;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? 'Friend',
      dailyCaffeineLimitMg: json['daily_caffeine_limit_mg'] as int? ?? 400,
      sugarSensitivity: _parseSensitivity(json['sugar_sensitivity'] as String?),
      preferredDrinkIds: List<String>.from(
        json['preferred_drink_ids'] as List? ?? ['latte', 'matcha'],
      ),
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'display_name': displayName,
        'daily_caffeine_limit_mg': dailyCaffeineLimitMg,
        'sugar_sensitivity': sugarSensitivity.name,
        'preferred_drink_ids': preferredDrinkIds,
      };

  static SugarSensitivity _parseSensitivity(String? v) {
    return SugarSensitivity.values.firstWhere(
      (e) => e.name == v,
      orElse: () => SugarSensitivity.medium,
    );
  }
}

class DrinkTemplate {
  const DrinkTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.caffeineMg,
    required this.sugarG,
    required this.calories,
    required this.category,
  });

  final String id;
  final String name;
  final String emoji;
  final int caffeineMg;
  final double sugarG;
  final int calories;
  final String category;

  factory DrinkTemplate.fromJson(Map<String, dynamic> json) {
    return DrinkTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      caffeineMg: json['caffeine_mg'] as int,
      sugarG: (json['sugar_g'] as num).toDouble(),
      calories: json['calories'] as int,
      category: json['category'] as String,
    );
  }
}

class LoggedDrink {
  const LoggedDrink({
    required this.id,
    required this.drinkId,
    required this.loggedAt,
    this.amount = 1,
  });

  final String id;
  final String drinkId;
  final DateTime loggedAt;
  final double amount;

  factory LoggedDrink.fromJson(Map<String, dynamic> json) {
    return LoggedDrink(
      id: json['id'] as String,
      drinkId: json['drink_id'] as String,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 1,
    );
  }
}

class HealthSnapshot {
  const HealthSnapshot({
    required this.restingHeartRate,
    required this.sleepHours,
    required this.steps,
    required this.activeMinutes,
    required this.stressLevel,
    required this.hydrationMl,
    required this.source,
    this.recordedAt,
  });

  final int restingHeartRate;
  final double sleepHours;
  final int steps;
  final int activeMinutes;
  final StressLevel stressLevel;
  final int hydrationMl;
  final FitnessProvider source;
  final DateTime? recordedAt;

  Map<String, dynamic> toInsertJson(String userId) => {
        'user_id': userId,
        'resting_heart_rate': restingHeartRate,
        'sleep_hours': sleepHours,
        'steps': steps,
        'active_minutes': activeMinutes,
        'stress_level': stressLevel.name,
        'hydration_ml': hydrationMl,
        'source': source.value,
        'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
      };

  factory HealthSnapshot.fromJson(Map<String, dynamic> json) {
    return HealthSnapshot(
      restingHeartRate: json['resting_heart_rate'] as int,
      sleepHours: (json['sleep_hours'] as num).toDouble(),
      steps: json['steps'] as int,
      activeMinutes: json['active_minutes'] as int,
      stressLevel: StressLevel.values.firstWhere(
        (e) => e.name == json['stress_level'],
        orElse: () => StressLevel.medium,
      ),
      hydrationMl: json['hydration_ml'] as int,
      source: FitnessProvider.fromValue(json['source'] as String?) ??
          FitnessProvider.manual,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
    );
  }
}

class DrinkRecommendation {
  const DrinkRecommendation({
    required this.drink,
    required this.score,
    required this.reason,
    this.tweaks,
  });

  final DrinkTemplate drink;
  final int score;
  final String reason;
  final List<String>? tweaks;
}

class FitnessConnectionInfo {
  const FitnessConnectionInfo({
    required this.provider,
    required this.connected,
    this.lastSyncedAt,
  });

  final FitnessProvider provider;
  final bool connected;
  final DateTime? lastSyncedAt;
}
