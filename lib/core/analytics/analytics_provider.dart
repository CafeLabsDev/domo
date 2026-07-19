import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'analytics_service.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService();
}
