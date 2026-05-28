// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Caffein Tracker';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get connectFitnessPrompt => 'Link fitness app for personalized picks.';

  @override
  String get connectFitnessBtn => 'Connect fitness apps';

  @override
  String get navHome => 'Home';

  @override
  String get navLog => 'Log';

  @override
  String get navSync => 'Sync';

  @override
  String get navYou => 'You';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get displayName => 'Display name';

  @override
  String caffeineLimit(int limit) {
    return 'Daily caffeine limit: $limit mg';
  }

  @override
  String get sugarSensitivity => 'Sugar sensitivity';

  @override
  String get sugarLow => 'Low';

  @override
  String get sugarMedium => 'Medium';

  @override
  String get sugarHigh => 'High';

  @override
  String sugarGuidance(int cap) {
    return 'Sugar guidance cap: ~${cap}g';
  }

  @override
  String get language => 'Language / Ngôn ngữ';

  @override
  String get langEn => 'English';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get signOut => 'Sign out';
}
