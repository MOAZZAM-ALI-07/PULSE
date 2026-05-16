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
    return AnalysisModel(
      runId: json['run_id'] ?? '',
      inputText: json['input_text'] ?? '',
      domain: json['domain'] ?? 'Business',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      severity: json['severity'] ?? 'Medium',
      confidenceAvg: (json['confidence_avg'] ?? 0.0).toDouble(),
      bookmarked: json['bookmarked'] == 1 || json['bookmarked'] == true,
      ingestionData: json['ingestion_data'],
      insightsData: json['insights_data'],
      impactData: json['impact_data'],
      actionsData: json['actions_data'],
      executionData: json['execution_data'],
    );
  }
}
