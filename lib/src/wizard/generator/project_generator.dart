import 'package:archive/archive.dart';
import 'package:openapi_generator/openapi_generator.dart';

import '../config/wizard_config.dart';
import 'templates/pubspec_template.dart';
import 'templates/analysis_options_template.dart';
import 'templates/main_template.dart';

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
    final prefix = config.projectName;
    final files = <String, String>{};

    files['$prefix/pubspec.yaml'] = generatePubspec(config);
    files['$prefix/analysis_options.yaml'] = generateAnalysisOptions(config);
    files['$prefix/README.md'] = _generateReadme();
    files['$prefix/.gitignore'] = _generateGitignore();
    files['$prefix/.fvmrc'] = _generateFvmrc();
    files['$prefix/lib/main.dart'] = generateMain(config);
    files['$prefix/lib/src/counter/counter.dart'] = '';
    files['$prefix/lib/src/home/home_page.dart'] = '';
    files['$prefix/test/widget_test.dart'] = _generateWidgetTest();

    // OpenAPI generated code
    if (config.isOpenApiEnabled && config.hasOpenApiSpec) {
      final result = DartGenerator.generateWithDiagnostics(
        config.openApiSpecContent,
        clientName: 'ApiClient',
      );
      lastDiagnostics = result.diagnostics;

      if (result.success) {
        for (final entry in result.files.entries) {
          files['$prefix/lib/src/api/${entry.key}'] = entry.value;
        }
      }

      // Include the spec file
      files['$prefix/openapi/spec.json'] = config.openApiSpecContent;
      // Add the @Openapi() annotated class for build_runner
      files['$prefix/lib/openapi_config.dart'] = _generateOpenApiAnnotation();
    }

    if (config.platforms.contains(Platform.android)) {
      files['$prefix/android/.gitkeep'] = '';
    }
    if (config.platforms.contains(Platform.ios)) {
      files['$prefix/ios/.gitkeep'] = '';
    }
    if (config.platforms.contains(Platform.web)) {
      files['$prefix/web/index.html'] = _generateWebIndex();
    }
    if (config.platforms.contains(Platform.windows)) {
      files['$prefix/windows/.gitkeep'] = '';
    }
    if (config.platforms.contains(Platform.macos)) {
      files['$prefix/macos/.gitkeep'] = '';
    }
    if (config.platforms.contains(Platform.linux)) {
      files['$prefix/linux/.gitkeep'] = '';
    }

    return files;
  }

  Archive generateZipArchive() {
    final archive = Archive();
    final files = generateFileMap();

    for (final entry in files.entries) {
      final data = entry.value.isEmpty
          ? <int>[]
          : entry.value.codeUnits;
      final file = ArchiveFile(entry.key, data.length, data);
      archive.addFile(file);
    }

    return archive;
  }

  String _generateReadme() {
    return '# ${config.projectName}\n\nA new Flutter project.\n';
  }

  String _generateFvmrc() {
    return '{\n  "flutter": "3.29.3"\n}\n';
  }

  String _generateGitignore() {
    return '''# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/macos/Flutter/GeneratedPluginRegistrant.swift
**/windows/flutter/generated_plugin_registrant.cc
**/windows/flutter/generated_plugin_registrant.h
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Generated files
*.g.dart
*.freezed.dart
''';
  }

  String _generateWidgetTest() {
    return '''import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test', () {
    expect(1 + 1, equals(2));
  });
}
''';
  }

  String _generateWebIndex() {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${config.projectName}</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
''';
  }

  String _generateOpenApiAnnotation() {
    final gen = config.openApiClientGenerator;
    final inputSpecPath = config.openApiSpecUrl.isNotEmpty
        ? "RemoteSpec(path: '${config.openApiSpecUrl}')"
        : "InputSpec(path: 'openapi/spec.json')";
    final pubName = config.dartPackageName;

    final additionalProperties = gen == OpenApiClientGenerator.dio
        ? 'DioProperties(pubName: \'$pubName\', pubAuthor: \'${config.orgName}\')'
        : 'AdditionalProperties(pubName: \'$pubName\', pubAuthor: \'${config.orgName}\')';

    return """import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: $additionalProperties,
  inputSpec: $inputSpecPath,
  generatorName: Generator.${gen.name},
  runSourceGenOnOutput: ${gen.needsSourceGen},
  outputDirectory: 'lib/src/api',
)
class OpenApiConfig {}
""";
  }
}
