import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class InsightsService {
  final FirebaseFunctions _functions;

  InsightsService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Fetches insights data from the Cloud Function
  Future<Map<String, dynamic>> getInsights() async {
    try {
      // Call the Cloud Function
      final result = await _functions.httpsCallable('getInsights').call();
      
      // Return the insights data
      return result.data as Map<String, dynamic>;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error calling getInsights: ${e.message}');
      throw Exception('Failed to get insights: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }
}
