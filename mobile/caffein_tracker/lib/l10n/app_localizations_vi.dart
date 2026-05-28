// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Theo dõi Caffein';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get connectFitnessPrompt => 'Kết nối ứng dụng sức khỏe để nhận gợi ý.';

  @override
  String get connectFitnessBtn => 'Kết nối ứng dụng sức khỏe';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navLog => 'Nhật ký';

  @override
  String get navSync => 'Đồng bộ';

  @override
  String get navYou => 'Hồ sơ';

  @override
  String get profileTitle => 'Hồ sơ của bạn';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String caffeineLimit(int limit) {
    return 'Giới hạn caffeine hàng ngày: $limit mg';
  }

  @override
  String get sugarSensitivity => 'Mức độ nhạy cảm đường';

  @override
  String get sugarLow => 'Thấp';

  @override
  String get sugarMedium => 'Vừa';

  @override
  String get sugarHigh => 'Cao';

  @override
  String sugarGuidance(int cap) {
    return 'Gợi ý lượng đường tối đa hàng ngày: ~${cap}g';
  }

  @override
  String get language => 'Ngôn ngữ / Language';

  @override
  String get langEn => 'English';

  @override
  String get langVi => 'Tiếng Việt';

  @override
  String get signOut => 'Đăng xuất';
}
