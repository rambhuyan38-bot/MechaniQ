enum DtcSeverity { critical, warning, advisory }

class DiagnosticTroubleCode {
  final String code;
  final String title;
  final String system;
  final DtcSeverity severity;
  final String description;
  final String aiAnalysis;
  final List<String> resolutionSteps;

  DiagnosticTroubleCode({
    required this.code,
    required this.title,
    required this.system,
    required this.severity,
    required this.description,
    required this.aiAnalysis,
    required this.resolutionSteps,
  });
}