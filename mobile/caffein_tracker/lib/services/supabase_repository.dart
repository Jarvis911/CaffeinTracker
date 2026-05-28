import 'dart:io' show Platform;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/drink_catalog_fallback.dart';
import '../models/models.dart';

class SupabaseRepository {
  SupabaseRepository(this._client);

  final SupabaseClient _client;

  String? get userId => _client.auth.currentUser?.id;

  bool get isSignedIn => userId != null;

  Future<void> signUp(String email, String password, {String? displayName}) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<UserProfile> fetchProfile() async {
    final uid = userId!;
    final row = await _client.from('profiles').select().eq('id', uid).single();
    return UserProfile.fromJson(row);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _client
        .from('profiles')
        .update(profile.toUpdateJson())
        .eq('id', profile.id);
  }

  Future<List<DrinkTemplate>> fetchDrinkCatalog() async {
    try {
      final rows = await _client.from('drink_catalog').select().order('name');
      return (rows as List)
          .map((e) => DrinkTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return kFallbackDrinkCatalog;
    }
  }

  Future<List<LoggedDrink>> fetchTodayLogs() async {
    final uid = userId!;
    final start = DateTime.now();
    final dayStart = DateTime(start.year, start.month, start.day);
    final rows = await _client
        .from('drink_logs')
        .select()
        .eq('user_id', uid)
        .gte('logged_at', dayStart.toIso8601String())
        .order('logged_at', ascending: false);
    return (rows as List)
        .map((e) => LoggedDrink.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> logDrink(String drinkId, {double amount = 1}) async {
    await _client.from('drink_logs').insert({
      'user_id': userId,
      'drink_id': drinkId,
      'amount': amount,
    });
  }

  Future<HealthSnapshot?> fetchLatestHealth() async {
    final uid = userId!;
    final rows = await _client
        .from('health_snapshots')
        .select()
        .eq('user_id', uid)
        .order('recorded_at', ascending: false)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return HealthSnapshot.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> saveHealthSnapshot(HealthSnapshot snapshot) async {
    await _client.from('health_snapshots').insert(snapshot.toInsertJson(userId!));
  }

  Future<void> upsertFitnessConnection(FitnessProvider provider) async {
    await _client.from('fitness_connections').upsert({
      'user_id': userId,
      'provider': provider.value,
      'last_synced_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,provider');
  }

  Future<List<FitnessConnectionInfo>> fetchConnections() async {
    final uid = userId!;
    final rows =
        await _client.from('fitness_connections').select().eq('user_id', uid);
    final connected = <FitnessProvider>{};
    final syncMap = <FitnessProvider, DateTime?>{};

    for (final row in rows as List) {
      final p = FitnessProvider.fromValue(row['provider'] as String?);
      if (p == null) continue;
      connected.add(p);
      final synced = row['last_synced_at'];
      syncMap[p] =
          synced != null ? DateTime.tryParse(synced as String) : null;
    }

    return [
      if (Platform.isIOS) FitnessProvider.appleHealth else FitnessProvider.healthConnect,
      FitnessProvider.manual,
    ].map((p) => FitnessConnectionInfo(
          provider: p,
          connected: connected.contains(p),
          lastSyncedAt: syncMap[p],
        )).toList();
  }
}
