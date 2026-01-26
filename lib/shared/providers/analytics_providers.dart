import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/shared/services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
