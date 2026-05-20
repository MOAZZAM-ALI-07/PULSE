import 'package:dio/dio.dart';
import '../models/analysis_model.dart';

class ApiService {
  static const String baseUrl = 'https://pulse-backend-124278038303.asia-south1.run.app';
  
  // Retry configuration
  static const int _maxRetries = 5;
  static const Duration _baseDelay = Duration(seconds: 4);

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    // CRITICAL: Treat server error status codes gracefully to capture logs and display them
    validateStatus: (status) => status != null && status < 600, 
  ));

  /// Sanitize error messages — never expose API keys or raw URLs to user
  String _sanitizeError(String raw) {
    // Remove API keys from error messages
    final keyPattern = RegExp(r'key=[A-Za-z0-9_-]+');
    String cleaned = raw.replaceAll(keyPattern, 'key=***');
    
    // Remove full URLs to keep it clean for user
    final urlPattern = RegExp(r'https?://[^\s\x27\x22]+');
    cleaned = cleaned.replaceAllMapped(urlPattern, (m) {
      final url = m.group(0)!;
      if (url.contains('generativelanguage.googleapis.com')) {
        return 'AI Service';
      }
      return url; // keep non-sensitive URLs
    });

    // Translate common HTTP errors to user-friendly messages
    if (cleaned.contains('429') || cleaned.toLowerCase().contains('too many requests')) {
      return 'AI service is busy. Retrying automatically...';
    }
    if (cleaned.contains('500') || cleaned.contains('502') || cleaned.contains('503')) {
      return 'Server is temporarily unavailable. Please try again.';
    }
    if (cleaned.contains('timeout') || cleaned.contains('Timeout')) {
      return 'Request timed out. The server may be overloaded.';
    }
    
    return cleaned;
  }

  /// Retry-enabled request handler with exponential backoff for 429/5xx
  Future<Map<String, dynamic>> _handleRequest(
    Future<Response> Function() requestFactory, 
    String errorMessage,
  ) async {
    int attempt = 0;
    String? lastError;

    while (attempt < _maxRetries) {
      try {
        final response = await requestFactory();
        
        // Handle rate limiting (429) with retry
        if (response.statusCode == 429) {
          attempt++;
          if (attempt < _maxRetries) {
            final delay = _baseDelay * (1 << (attempt - 1)); // Exponential backoff
            await Future.delayed(delay);
            continue;
          }
          return {
            'success': false,
            'error': 'AI service is busy right now. Please wait a moment and try again.',
          };
        }

        // Handle server errors (5xx) with retry
        if (response.statusCode != null && response.statusCode! >= 500) {
          attempt++;
          if (attempt < _maxRetries) {
            final delay = _baseDelay * (1 << (attempt - 1));
            await Future.delayed(delay);
            continue;
          }
          return {
            'success': false,
            'error': 'Server is temporarily unavailable. Please try again shortly.',
          };
        }
        
        // Handle other client errors (4xx) — no retry
        if (response.statusCode != null && response.statusCode! >= 400) {
          final errorDetail = response.data is Map && response.data['detail'] != null
              ? response.data['detail']
              : 'Request failed (${response.statusCode})';
          return {
            'success': false,
            'error': _sanitizeError(errorDetail.toString()),
          };
        }

        // Success
        return response.data is Map 
            ? Map<String, dynamic>.from(response.data) 
            : {'success': true, 'data': response.data};

      } on DioException catch (e) {
        attempt++;
        lastError = e.message ?? errorMessage;
        
        // Retry on timeout/connection errors
        if (attempt < _maxRetries && 
            (e.type == DioExceptionType.connectionTimeout || 
             e.type == DioExceptionType.receiveTimeout ||
             e.type == DioExceptionType.sendTimeout ||
             e.type == DioExceptionType.connectionError)) {
          final delay = _baseDelay * (1 << (attempt - 1));
          await Future.delayed(delay);
          continue;
        }
        
        return {'success': false, 'error': _sanitizeError(lastError ?? errorMessage)};
      } catch (e) {
        return {'success': false, 'error': _sanitizeError(e.toString())};
      }
    }

    return {'success': false, 'error': _sanitizeError(lastError ?? errorMessage)};
  }

  Future<Map<String, dynamic>> ingest(String text, String domain, {String? runId}) async {
    return _handleRequest(
      () => _dio.post('/api/ingest', data: {
        'text': text,
        'domain': domain,
        if (runId != null) 'run_id': runId,
      }),
      'Data ingestion failed. Please try again.',
    );
  }

  Future<Map<String, dynamic>> insights(String text, String domain, String runId) async {
    return _handleRequest(
      () => _dio.post('/api/insights', data: {
        'text': text,
        'domain': domain,
        'run_id': runId,
      }),
      'Insight generation failed. Please try again.',
    );
  }

  Future<Map<String, dynamic>> impact(String text, String domain, String runId) async {
    return _handleRequest(
      () => _dio.post('/api/impact', data: {
        'text': text,
        'domain': domain,
        'run_id': runId,
      }),
      'Impact assessment failed. Please try again.',
    );
  }

  Future<Map<String, dynamic>> actions(String text, String domain, String runId) async {
    return _handleRequest(
      () => _dio.post('/api/actions', data: {
        'text': text,
        'domain': domain,
        'run_id': runId,
      }),
      'Action planning failed. Please try again.',
    );
  }

  Future<Map<String, dynamic>> execute(String text, String domain, String runId) async {
    return _handleRequest(
      () => _dio.post('/api/execute', data: {
        'text': text,
        'domain': domain,
        'run_id': runId,
      }),
      'Simulation execution failed. Please try again.',
    );
  }

  Future<List<AnalysisModel>> getHistory() async {
    try {
      final response = await _dio.get('/api/analyses');
      if (response.statusCode == 200 && response.data['analyses'] != null) {
        final data = response.data['analyses'] as List;
        return data.map((e) => AnalysisModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) { 
      return []; 
    }
  }

  Future<AnalysisModel?> getAnalysis(String runId) async {
    try {
      final response = await _dio.get('/api/analyses/$runId');
      if (response.statusCode == 200) {
        return AnalysisModel.fromJson(response.data);
      }
      return null;
    } catch (_) { 
      return null; 
    }
  }

  Future<Map<String, dynamic>> submitFeedback(String runId, int insightIndex, String rating, {String? comment}) async {
    return _handleRequest(
      () => _dio.post('/api/feedback', data: {
        'run_id': runId,
        'insight_index': insightIndex,
        'rating': rating,
        if (comment != null) 'comment': comment,
      }),
      'Feedback submission failed',
    );
  }

  Future<Map<String, dynamic>> toggleBookmark(String runId, {int? insightIndex}) async {
    return _handleRequest(
      () => _dio.post('/api/bookmark', data: {
        'run_id': runId,
        if (insightIndex != null) 'insight_index': insightIndex,
      }),
      'Bookmark toggle failed',
    );
  }
}