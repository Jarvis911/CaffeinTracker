import 'dart:io';

import 'package:health/health.dart';

import '../models/models.dart';

/// Reads real health data from Apple Health (iOS) or Health Connect (Android).
class HealthService {
  HealthService() : _health = Health();

  final Health _health;

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WATER,
  ];

  FitnessProvider get nativeProvider =>
      Platform.isIOS ? FitnessProvider.appleHealth : FitnessProvider.healthConnect;

  String get platformLabel =>
      Platform.isIOS ? 'Apple Health' : 'Health Connect';

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      await _health.configure();
    }
    return _health.requestAuthorization(
      _types,
      permissions: List.filled(_types.length, HealthDataAccess.READ),
    );
  }

  Future<bool> hasPermissions() async {
    final result = await _health.hasPermissions(
      _types,
      permissions: List.filled(_types.length, HealthDataAccess.READ),
    );
    return result == true;
  }

  Future<HealthSnapshot?> fetchSnapshot() async {
    final granted = await hasPermissions();
    if (!granted) return null;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: start,
      endTime: now,
    );

    final steps = _sumNumeric(data, HealthDataType.STEPS).round();
    final heartRates = data
        .where((p) => p.type == HealthDataType.HEART_RATE)
        .map((p) => _numericValue(p))
        .whereType<double>()
        .toList();
    final restingHr = heartRates.isEmpty
        ? 68
        : heartRates.reduce((a, b) => a + b) ~/ heartRates.length;

    final sleepHours = _sleepHours(data);
    final activeMinutes = (_sumNumeric(data, HealthDataType.ACTIVE_ENERGY_BURNED) / 8)
        .round()
        .clamp(0, 300);
    final hydrationMl = _sumNumeric(data, HealthDataType.WATER).round();

    final stress = sleepHours < 6
        ? StressLevel.high
        : sleepHours < 7
            ? StressLevel.medium
            : StressLevel.low;

    return HealthSnapshot(
      restingHeartRate: restingHr.clamp(40, 120),
      sleepHours: sleepHours,
      steps: steps,
      activeMinutes: activeMinutes,
      stressLevel: stress,
      hydrationMl: hydrationMl > 0 ? hydrationMl : 1500,
      source: nativeProvider,
      recordedAt: now,
    );
  }

  double _sleepHours(List<HealthDataPoint> data) {
    var totalMinutes = 0.0;
    for (final type in [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED]) {
      for (final point in data.where((p) => p.type == type)) {
        totalMinutes += point.dateTo.difference(point.dateFrom).inMinutes;
      }
    }
    if (totalMinutes <= 0) return 7.0;
    return (totalMinutes / 60).clamp(0, 14);
  }

  double _sumNumeric(List<HealthDataPoint> data, HealthDataType type) {
    return data
        .where((p) => p.type == type)
        .map(_numericValue)
        .whereType<double>()
        .fold(0.0, (a, b) => a + b);
  }

  double? _numericValue(HealthDataPoint point) {
    final v = point.value;
    if (v is NumericHealthValue) return v.numericValue.toDouble();
    return null;
  }
}
