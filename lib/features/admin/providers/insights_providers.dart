import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_birmingham_hub/features/admin/services/insights_service.dart';

// Insights service provider
final insightsServiceProvider = Provider<InsightsService>((ref) {
  return InsightsService();
});

// Insights data provider
final insightsDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final insightsService = ref.watch(insightsServiceProvider);
  return insightsService.getInsights();
});

// Individual insights providers
final totalSpeakersProvider = Provider<int>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) => data['totalSpeakers'] as int? ?? 0,
    orElse: () => 0,
  );
});

final totalTalksProvider = Provider<int>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) => data['totalTalks'] as int? ?? 0,
    orElse: () => 0,
  );
});

final acceptanceRateProvider = Provider<double>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) => (data['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
    orElse: () => 0.0,
  );
});

final averageRatingProvider = Provider<double>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) => (data['averageRating'] as num?)?.toDouble() ?? 0.0,
    orElse: () => 0.0,
  );
});

final topRatedTalksProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) {
      final topRatedTalks = data['topRatedTalks'] as List<dynamic>? ?? [];
      return topRatedTalks.map((talk) => talk as Map<String, dynamic>).toList();
    },
    orElse: () => <Map<String, dynamic>>[],
  );
});

final topTagsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) {
      final topTags = data['topTags'] as List<dynamic>? ?? [];
      return topTags.map((tag) => tag as Map<String, dynamic>).toList();
    },
    orElse: () => <Map<String, dynamic>>[],
  );
});

final submissionTrendProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final insightsDataAsync = ref.watch(insightsDataProvider);
  return insightsDataAsync.maybeWhen(
    data: (data) {
      final submissionTrend = data['submissionTrend'] as List<dynamic>? ?? [];
      return submissionTrend.map((item) => item as Map<String, dynamic>).toList();
    },
    orElse: () => <Map<String, dynamic>>[],
  );
});
