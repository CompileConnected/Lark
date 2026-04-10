import '../../config/wizard_config.dart';

String generateAnalysisOptions(WizardConfig config) {
  final include = config.linting == Linting.veryGoodAnalysis
      ? 'package:very_good_analysis/analysis_options.yaml'
      : 'package:flutter_lints/flutter.yaml';

  final buffer = StringBuffer();
  buffer.writeln('include: $include');
  buffer.writeln();
  buffer.writeln('analyzer:');
  buffer.writeln('  exclude:');
  buffer.writeln('    - "**/*.g.dart"');
  buffer.writeln('    - "**/*.freezed.dart"');

  if (config.needsCodeGeneration) {
    buffer.writeln('  errors:');
    buffer.writeln('    invalid_annotation_target: ignore');
  }

  return buffer.toString();
}
