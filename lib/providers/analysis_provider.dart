import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/analysis_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class HistoryNotifier extends StateNotifier<AsyncValue<List<AnalysisModel>>> {
  final ApiService _api;
  List<AnalysisModel> _fullHistory = [];
  String _searchQuery = '';
  
  HistoryNotifier(this._api) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      _fullHistory = await _api.getHistory();
      _applyFilters();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void deleteItem(String runId) {
    _fullHistory = _fullHistory.where((item) => item.runId != runId).toList();
    _applyFilters();
  }

  void clearAll() {
    _fullHistory = [];
    _applyFilters();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      state = AsyncValue.data([..._fullHistory]);
    } else {
      final filtered = _fullHistory.where((item) => 
        item.domain.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        item.severity.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      state = AsyncValue.data(filtered);
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<AnalysisModel>>>((ref) {
  return HistoryNotifier(ref.read(apiServiceProvider));
});

class CurrentAnalysisState {
  final String? runId;
  final String? text;
  final String? domain;
  final int step; // 0: Init, 1: Reading, 2: Analyzing, 3: Assessing, 4: Planning, 5: Executing, 6: Finalizing, 7: Done
  final Map<String, dynamic> logs;
  final bool isProcessing;
  final AnalysisModel? result;
  final String? errorMessage;

  CurrentAnalysisState({
    this.runId,
    this.text,
    this.domain,
    this.step = 0,
    this.logs = const {},
    this.isProcessing = false,
    this.result,
    this.errorMessage,
  });

  /// FIX: Added clearError flag so errorMessage can be explicitly set to null
  CurrentAnalysisState copyWith({
    String? runId,
    String? text,
    String? domain,
    int? step,
    Map<String, dynamic>? logs,
    bool? isProcessing,
    AnalysisModel? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CurrentAnalysisState(
      runId: runId ?? this.runId,
      text: text ?? this.text,
      domain: domain ?? this.domain,
      step: step ?? this.step,
      logs: logs ?? this.logs,
      isProcessing: isProcessing ?? this.isProcessing,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AnalysisNotifier extends StateNotifier<CurrentAnalysisState> {
  final ApiService _api;

  AnalysisNotifier(this._api) : super(CurrentAnalysisState());

  Future<void> runFullPipeline(String text, String domain) async {
    state = CurrentAnalysisState(
      text: text, 
      domain: domain, 
      step: 1, 
      isProcessing: true, 
      logs: {}, 
      errorMessage: null,
    );

    try {
      final logs = <String, dynamic>{};

      // 1. Ingest Agent Loop
      final ingestRes = await _api.ingest(text, domain);
      if (ingestRes['success'] == false || ingestRes['run_id'] == null) {
        throw Exception(ingestRes['error'] ?? 'Ingest step failed to respond.');
      }
      
      final runId = ingestRes['run_id'].toString();
      logs['Reading'] = 'Extracted ${ingestRes['signal_count'] ?? 0} signals.';
      state = state.copyWith(runId: runId, step: 2, logs: Map.from(logs), clearError: true);

      // Small delay between steps to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Insights Agent Loop
      final insightsRes = await _api.insights(text, domain, runId);
      if (insightsRes['success'] == false) {
        throw Exception(insightsRes['error'] ?? 'Insights loop broken.');
      }
      logs['Analyzing'] = 'Generated critical structured insights.';
      state = state.copyWith(step: 3, logs: Map.from(logs));

      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Impact Agent Loop
      final impactRes = await _api.impact(text, domain, runId);
      if (impactRes['success'] == false) {
        throw Exception(impactRes['error'] ?? 'Impact assessment pipeline failed.');
      }
      logs['Assessing'] = 'Assessed system domain consequences.';
      state = state.copyWith(step: 4, logs: Map.from(logs));

      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Actions Agent Loop
      final actionsRes = await _api.actions(text, domain, runId);
      if (actionsRes['success'] == false) {
        throw Exception(actionsRes['error'] ?? 'Action formulation loop failed.');
      }
      logs['Planning'] = 'Formulated targeted strategic actions.';
      state = state.copyWith(step: 5, logs: Map.from(logs));

      await Future.delayed(const Duration(milliseconds: 500));

      // 5. Execute Simulation Loop
      final executeRes = await _api.execute(text, domain, runId);
      if (executeRes['success'] == false) {
        throw Exception(executeRes['error'] ?? 'Simulation runner failed.');
      }
      logs['Executing'] = 'Simulated operational action updates.';
      state = state.copyWith(step: 6, logs: Map.from(logs));
      
      // 6. Fetch Complete Outcome Result
      final fullResult = await _api.getAnalysis(runId);
      state = state.copyWith(step: 7, isProcessing: false, logs: Map.from(logs), result: fullResult);

    } catch (e) {
      final logs = Map<String, dynamic>.from(state.logs);
      String cleanedError = e.toString().replaceAll('Exception: ', '');
      logs['Error'] = cleanedError;
      
      state = CurrentAnalysisState(
        runId: state.runId,
        text: state.text,
        domain: state.domain,
        step: state.step,
        logs: logs,
        isProcessing: false,
        result: state.result,
        errorMessage: cleanedError,
      );
    }
  }

  void reset() {
    state = CurrentAnalysisState();
  }

  Future<void> loadAnalysis(String runId) async {
    state = CurrentAnalysisState(
      isProcessing: true,
    );
    try {
      final result = await _api.getAnalysis(runId);
      if (result == null) {
        throw Exception("Analysis not found");
      }
      state = CurrentAnalysisState(
        runId: runId,
        result: result,
        isProcessing: false,
        step: 7,
      );
    } catch (e) {
      state = CurrentAnalysisState(
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, CurrentAnalysisState>((ref) {
  return AnalysisNotifier(ref.read(apiServiceProvider));
});