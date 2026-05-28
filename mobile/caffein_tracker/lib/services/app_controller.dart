import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../data/drink_catalog_fallback.dart';
import '../models/models.dart';
import 'health_service.dart';
import 'personalization_service.dart';
import 'supabase_repository.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.healthService,
    required this.personalization,
  });

  final HealthService healthService;
  final PersonalizationService personalization;

  SupabaseRepository? _repo;
  bool _loading = false;
  String? _error;

  UserProfile? profile;
  List<DrinkTemplate> catalog = kFallbackDrinkCatalog;
  List<LoggedDrink> logs = [];
  HealthSnapshot? health;
  List<FitnessConnectionInfo> connections = [];
  bool useOfflineDemo = false;

  bool get loading => _loading;
  String? get error => _error;
  bool get isSignedIn => _repo?.isSignedIn ?? false;
  bool get canEnterApp => isSignedIn || (useOfflineDemo && profile != null);
  bool get hasHealth => health != null;

  SupabaseRepository get repo {
    if (_repo == null) throw StateError('Not authenticated');
    return _repo!;
  }

  Future<void> init() async {
    if (!Env.isConfigured) {
      useOfflineDemo = true;
      _loadOfflineDemo();
      return;
    }
    _repo = SupabaseRepository(Supabase.instance.client);
    if (isSignedIn) {
      await refreshAll();
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await repo.signIn(email, password);
      await refreshAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      await repo.signUp(email, password, displayName: name);
      await repo.signIn(email, password);
      await refreshAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _repo?.signOut();
    profile = null;
    logs = [];
    health = null;
    connections = [];
    notifyListeners();
  }

  Future<void> refreshAll() async {
    if (useOfflineDemo) {
      _loadOfflineDemo();
      return;
    }
    _setLoading(true);
    try {
      profile = await repo.fetchProfile();
      catalog = await repo.fetchDrinkCatalog();
      logs = await repo.fetchTodayLogs();
      health = await repo.fetchLatestHealth();
      connections = await repo.fetchConnections();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> connectNativeHealth() async {
    _setLoading(true);
    try {
      final granted = await healthService.requestPermissions();
      if (!granted) {
        _error = 'Health permissions denied';
        return false;
      }

      final snapshot = await healthService.fetchSnapshot();
      if (snapshot == null) {
        _error = 'Could not read health data';
        return false;
      }

      health = snapshot;

      if (!useOfflineDemo) {
        await repo.saveHealthSnapshot(snapshot);
        await repo.upsertFitnessConnection(snapshot.source);
        connections = await repo.fetchConnections();
      } else {
        await _saveOfflineHealth(snapshot);
        _updateOfflineConnections(snapshot.source, true);
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncHealth() async {
    final granted = await healthService.hasPermissions();
    if (!granted) return;
    final snapshot = await healthService.fetchSnapshot();
    if (snapshot == null) return;
    health = snapshot;
    if (!useOfflineDemo) {
      await repo.saveHealthSnapshot(snapshot);
      await repo.upsertFitnessConnection(snapshot.source);
    } else {
      await _saveOfflineHealth(snapshot);
    }
    notifyListeners();
  }

  Future<void> logDrink(String drinkId) async {
    if (!useOfflineDemo) {
      await repo.logDrink(drinkId);
      logs = await repo.fetchTodayLogs();
    } else {
      logs = [
        LoggedDrink(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          drinkId: drinkId,
          loggedAt: DateTime.now(),
        ),
        ...logs,
      ];
      await _saveOfflineLogs();
    }
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    if (!useOfflineDemo) {
      await repo.updateProfile(updated);
    }
    profile = updated;
    if (useOfflineDemo) await _saveOfflineProfile(updated);
    notifyListeners();
  }

  List<DrinkRecommendation> get recommendations {
    if (profile == null || health == null) return [];
    return personalization.getRecommendations(
      health: health!,
      profile: profile!,
      logs: logs,
      catalog: catalog,
    );
  }

  ({int consumed, int limit, double percent}) get caffeineStatus {
    if (profile == null) return (consumed: 0, limit: 400, percent: 0);
    return personalization.getCaffeineStatus(profile!, logs, catalog);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _loadOfflineDemo() {
    profile = const UserProfile(
      id: 'offline',
      displayName: 'Friend',
      dailyCaffeineLimitMg: 400,
      sugarSensitivity: SugarSensitivity.medium,
      preferredDrinkIds: ['latte', 'matcha'],
    );
    catalog = kFallbackDrinkCatalog;
    connections = [
      FitnessConnectionInfo(
        provider: healthService.nativeProvider,
        connected: false,
      ),
      const FitnessConnectionInfo(
        provider: FitnessProvider.manual,
        connected: false,
      ),
    ];
    _loadOfflineFromPrefs();
    notifyListeners();
  }

  // Expose native provider for offline UI
  FitnessProvider get nativeProvider => healthService.nativeProvider;

  Future<void> _loadOfflineFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('profile_name');
    if (name != null && profile != null) {
      profile = UserProfile(
        id: profile!.id,
        displayName: name,
        dailyCaffeineLimitMg:
            prefs.getInt('caffeine_limit') ?? profile!.dailyCaffeineLimitMg,
        sugarSensitivity: SugarSensitivity.values.firstWhere(
          (e) => e.name == prefs.getString('sugar'),
          orElse: () => SugarSensitivity.medium,
        ),
        preferredDrinkIds: profile!.preferredDrinkIds,
      );
    }
    final healthJson = prefs.getString('health_json');
    if (healthJson != null) {
      // minimal restore not needed for demo - connect sets health
    }
  }

  Future<void> _saveOfflineProfile(UserProfile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', p.displayName);
    await prefs.setInt('caffeine_limit', p.dailyCaffeineLimitMg);
    await prefs.setString('sugar', p.sugarSensitivity.name);
  }

  Future<void> _saveOfflineLogs() async {
    // keep in memory for session
  }

  Future<void> _saveOfflineHealth(HealthSnapshot s) async {
    health = s;
  }

  void _updateOfflineConnections(FitnessProvider p, bool connected) {
    connections = connections
        .map((c) => c.provider == p
            ? FitnessConnectionInfo(
                provider: p,
                connected: connected,
                lastSyncedAt: DateTime.now(),
              )
            : c)
        .toList();
  }
}
