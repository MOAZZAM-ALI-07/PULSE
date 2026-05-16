import 'package:dio/dio.dart';
import '../models/analysis_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, or localhost for iOS simulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Map<String, dynamic>> ingest(String text, String domain, {String? runId}) async {
    final response = await _dio.post('/ingest', data: {
      'text': text,
      'domain': domain,
      if (runId != null) 'run_id': runId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> insights(String text, String domain, String runId) async {
    final response = await _dio.post('/insights', data: {
      'text': text,
      'domain': domain,
      'run_id': runId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> impact(String text, String domain, String runId) async {
    final response = await _dio.post('/impact', data: {
      'text': text,
      'domain': domain,
      'run_id': runId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> actions(String text, String domain, String runId) async {
    final response = await _dio.post('/actions', data: {
      'text': text,
      'domain': domain,
      'run_id': runId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> execute(String text, String domain, String runId) async {
    final response = await _dio.post('/execute', data: {
      'text': text,
      'domain': domain,
      'run_id': runId,
    });
    return response.data;
  }

  Future<List<AnalysisModel>> getHistory() async {
    try {
      final response = await _dio.get('/feedback/analyses');
      final data = response.data['analyses'] as List;
      return data.map((e) => AnalysisModel.fromJson(e)).toList();
    } catch (e) {
      return []; // Return empty list on failure for now
    }
  }

  Future<AnalysisModel?> getAnalysis(String runId) async {
    try {
      final response = await _dio.get('/feedback/analyses/$runId');
      return AnalysisModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> submitFeedback(String runId, int insightIndex, String rating) async {
    await _dio.post('/feedback/feedback', data: {
      'run_id': runId,
      'insight_index': insightIndex,
      'rating': rating,
    });
  }

  Future<void> toggleBookmark(String runId, {int? insightIndex}) async {
    await _dio.post('/feedback/bookmark', data: {
      'run_id': runId,
      if (insightIndex != null) 'insight_index': insightIndex,
    });
  }
}
