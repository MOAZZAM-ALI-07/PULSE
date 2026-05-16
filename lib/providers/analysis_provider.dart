import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/analysis_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final historyProvider = FutureProvider<List<AnalysisModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getHistory();
});

class CurrentAnalysisState {
  final String? runId;
  final String? text;
  final String? domain;
  final int step; // 0: Init, 1: Reading, 2: Analyzing, 3: Assessing, 4: Planning, 5: Executing, 6: Done
  final Map<String, dynamic> logs;
  final bool isProcessing;
  final AnalysisModel? result;

  CurrentAnalysisState({
    this.runId,
    this.text,
    this.domain,
    this.step = 0,
    this.logs = const {},
    this.isProcessing = false,
    this.result,
  });

  CurrentAnalysisState copyWith({
    String? runId,
    String? text,
    String? domain,
    int? step,
    Map<String, dynamic>? logs,
    bool? isProcessing,
    AnalysisModel? result,
  }) {
    return CurrentAnalysisState(
      runId: runId ?? this.runId,
      text: text ?? this.text,
      domain: domain ?? this.domain,
      step: step ?? this.step,
      logs: logs ?? this.logs,
      isProcessing: isProcessing ?? this.isProcessing,
      result: result ?? this.result,
    );
  }
}

class AnalysisNotifier extends StateNotifier<CurrentAnalysisState> {
  final ApiService _api;

  AnalysisNotifier(this._api) : super(CurrentAnalysisState());

  Future<void> runFullPipeline(String text, String domain) async {
    state = state.copyWith(text: text, domain: domain, step: 1, isProcessing: true, logs: {});

    try {
      // 1. Ingest
      final ingestRes = await _api.ingest(text, domain);
      final runId = ingestRes['run_id'];
      final logs = Map<String, dynamic>.from(state.logs);
      logs['Reading'] = 'Extracted ${ingestRes['signal_count']} signals.';
      state = state.copyWith(runId: runId, step: 2, logs: logs);

      // 2. Insights
      await _api.insights(text, domain, runId);
      logs['Analyzing'] = 'Generated critical insights.';
      state = state.copyWith(step: 3, logs: logs);

      // 3. Impact
      await _api.impact(text, domain, runId);
      logs['Assessing'] = 'Assessed business consequences.';
      state = state.copyWith(step: 4, logs: logs);

      // 4. Actions
      await _api.actions(text, domain, runId);
      logs['Planning'] = 'Formulated strategic actions.';
      state = state.copyWith(step: 5, logs: logs);

      // 5. Execute
      await _api.execute(text, domain, runId);
      logs['Executing'] = 'Simulated business system updates.';
      
      // Fetch full result
      final fullResult = await _api.getAnalysis(runId);
      state = state.copyWith(step: 6, isProcessing: false, logs: logs, result: fullResult);

    } catch (e) {
      final logs = Map<String, dynamic>.from(state.logs);
      logs['Error'] = e.toString();
      state = state.copyWith(isProcessing: false, logs: logs);
    }
  }

  void reset() {
    state = CurrentAnalysisState();
  }
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, CurrentAnalysisState>((ref) {
  return AnalysisNotifier(ref.watch(apiServiceProvider));
});
