import 'package:archive/archive.dart';
import 'package:openapi_generator/openapi_generator.dart';

import '../config/wizard_config.dart';
import './brick_generator.dart';

class ProjectGenerator {
  final WizardConfig config;

  /// Diagnostics from the last generation run (OpenAPI parse/generate steps).
  List<GenDiagnostic> lastDiagnostics = [];

  ProjectGenerator(this.config);

  /// Validate the OpenAPI spec without generating the full project.
  /// Returns diagnostics only.
  GenResult validateOpenApi() {
    if (!config.isOpenApiEnabled || !config.hasOpenApiSpec) {
      return const GenResult(success: true, diagnostics: []);
    }
    return DartGenerator.generateWithDiagnostics(
      config.openApiSpecContent,
      clientName: 'ApiClient',
    );
  }

  Map<String, String> generateFileMap() {
    lastDiagnostics = [];

    // 1. Convert WizardConfig → mustache vars (pre_gen logic)
    final vars = wizardConfigToBrickVars(config);

    // 2. Render all brick templates with mustache
    var files = renderBrickTemplates(config, vars);

    // 3. Apply post_gen cleanup (remove unselected option files)
    files = applyPostGenCleanup(config, vars, files);

    // 4. Inject OpenAPI generated code (if enabled)
    if (config.isOpenApiEnabled && config.hasOpenApiSpec) {
      final result = DartGenerator.generateWithDiagnostics(
        config.openApiSpecContent,
        clientName: 'ApiClient',
      );
      lastDiagnostics = result.diagnostics;

      if (result.success) {
        final prefix = config.projectName;
        for (final entry in result.files.entries) {
          files['$prefix/lib/src/api/${entry.key}'] = entry.value;
        }
      }

      // Override the openapi spec with the actual content
      files['${config.projectName}/openapi/spec.json'] =
          config.openApiSpecContent;
    }

    return files;
  }

  Archive generateZipArchive() {
    final archive = Archive();
    final files = generateFileMap();

    for (final entry in files.entries) {
      final data = entry.value.isEmpty ? <int>[] : entry.value.codeUnits;
      final file = ArchiveFile(entry.key, data.length, data);
      archive.addFile(file);
    }

    return archive;
  }
}
