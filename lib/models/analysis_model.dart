class AnalysisModel {
  final String runId;
  final String inputText;
  final String domain;
  final DateTime createdAt;
  final String severity;
  final double confidenceAvg;
  final bool bookmarked;

  final Map<String, dynamic>? ingestionData;
  final Map<String, dynamic>? insightsData;
  final Map<String, dynamic>? impactData;
  final Map<String, dynamic>? actionsData;
  final Map<String, dynamic>? executionData;

  AnalysisModel({
    required this.runId,
    required this.inputText,
    required this.domain,
    required this.createdAt,
    this.severity = 'Medium',
    this.confidenceAvg = 0.0,
    this.bookmarked = false,
    this.ingestionData,
    this.insightsData,
    this.impactData,
    this.actionsData,
    this.executionData,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    // 1. DateTime Parse Error Fix
    DateTime parsedDate;
    try {
      if (json['created_at'] != null) {
        parsedDate = DateTime.parse(json['created_at'].toString());
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now(); // Agar API se kharab date format aaye to crash nahi hoga
    }

    // 2. Double Type Casting Fix
    double parsedConfidence = 0.0;
    if (json['confidence_avg'] != null) {
      if (json['confidence_avg'] is num) {
        parsedConfidence = (json['confidence_avg'] as num).toDouble();
      }
    }

    return AnalysisModel(
      runId: json['run_id']?.toString() ?? '',
      inputText: json['input_text']?.toString() ?? '',
      domain: json['domain']?.toString() ?? 'Business',
      createdAt: parsedDate,
      severity: json['severity']?.toString() ?? 'Medium',
      confidenceAvg: parsedConfidence,
      bookmarked: json['bookmarked'] == 1 || json['bookmarked'] == true,
      
      // Map Type Safety Checks (Taaki UI me dynamic map crash na kare)
      ingestionData: json['ingestion_data'] is Map ? Map<String, dynamic>.from(json['ingestion_data']) : null,
      insightsData: json['insights_data'] is Map ? Map<String, dynamic>.from(json['insights_data']) : null,
      impactData: json['impact_data'] is Map ? Map<String, dynamic>.from(json['impact_data']) : null,
      actionsData: json['actions_data'] is Map ? Map<String, dynamic>.from(json['actions_data']) : null,
      executionData: json['execution_data'] is Map ? Map<String, dynamic>.from(json['execution_data']) : null,
    );
  }

  // Ek helper method taaki state update karte waqt aasani ho (Riverpod ke liye best practice)
  AnalysisModel copyWith({
    String? runId,
    String? inputText,
    String? domain,
    DateTime? createdAt,
    String? severity,
    double? confidenceAvg,
    bool? bookmarked,
    Map<String, dynamic>? ingestionData,
    Map<String, dynamic>? insightsData,
    Map<String, dynamic>? impactData,
    Map<String, dynamic>? actionsData,
    Map<String, dynamic>? executionData,
  }) {
    return AnalysisModel(
      runId: runId ?? this.runId,
      inputText: inputText ?? this.inputText,
      domain: domain ?? this.domain,
      createdAt: createdAt ?? this.createdAt,
      severity: severity ?? this.severity,
      confidenceAvg: confidenceAvg ?? this.confidenceAvg,
      bookmarked: bookmarked ?? this.bookmarked,
      ingestionData: ingestionData ?? this.ingestionData,
      insightsData: insightsData ?? this.insightsData,
      impactData: impactData ?? this.impactData,
      actionsData: actionsData ?? this.actionsData,
      executionData: executionData ?? this.executionData,
    );
  }
}