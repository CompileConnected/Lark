import '../parser/openapi_spec.dart';
import '../parser/openapi_parser.dart';
import 'model_generator.dart';
import 'client_generator.dart';

/// A single diagnostic message from the generation pipeline.
class GenDiagnostic {
  final GenSeverity severity;
  final String phase;
  final String message;

  const GenDiagnostic(this.severity, this.phase, this.message);

  @override
  String toString() => '[$severity] $phase: $message';
}

enum GenSeverity { info, warning, error }

/// Result of the generation pipeline, including diagnostics.
class GenResult {
  final Map<String, String> files;
  final List<GenDiagnostic> diagnostics;
  final bool success;

  const GenResult({
    this.files = const {},
    this.diagnostics = const [],
    this.success = false,
  });

  List<GenDiagnostic> get errors => diagnostics.where((d) => d.severity == GenSeverity.error).toList();
  List<GenDiagnostic> get warnings => diagnostics.where((d) => d.severity == GenSeverity.warning).toList();
  List<GenDiagnostic> get infos => diagnostics.where((d) => d.severity == GenSeverity.info).toList();

  String get summary {
    if (success) {
      return 'Generated ${files.length} files'
          '${warnings.isNotEmpty ? ', ${warnings.length} warning(s)' : ''}'
          '${errors.isNotEmpty ? ', ${errors.length} error(s)' : ''}';
    }
    return 'Generation failed: ${errors.map((e) => e.message).join('; ')}';
  }
}

/// High-level generator that produces all Dart files from an OpenAPI spec.
class DartGenerator {
  /// Generate a complete API client package from an OpenAPI spec string.
  ///
  /// Returns a [GenResult] with files, diagnostics, and success status.
  static GenResult generateWithDiagnostics(String specContent, {String clientName = 'ApiClient'}) {
    final diagnostics = <GenDiagnostic>[];
    final files = <String, String>{};

    // Phase 1: Parse spec
    OpenApiSpec spec;
    try {
      final parser = OpenApiParser.parse(specContent);
      spec = parser.parse();
    } catch (e, st) {
      diagnostics.add(GenDiagnostic(
        GenSeverity.error,
        'Parse',
        'Failed to parse OpenAPI spec: $e',
      ));
      // Add first few lines of stack trace for debugging
      final traceLines = st.toString().split('\n').take(3);
      for (final line in traceLines) {
        diagnostics.add(GenDiagnostic(GenSeverity.info, 'Parse', line.trim()));
      }
      return GenResult(files: files, diagnostics: diagnostics, success: false);
    }

    // Validate parsed spec
    if (spec.schemas.isEmpty && spec.paths.isEmpty) {
      diagnostics.add(GenDiagnostic(
        GenSeverity.warning,
        'Validate',
        'Spec contains no schemas and no paths. Output will be minimal.',
      ));
    }

    diagnostics.add(GenDiagnostic(GenSeverity.info, 'Parse',
        'Parsed: ${spec.schemas.length} schema(s), ${spec.paths.length} path(s), ${spec.securitySchemes.length} security scheme(s)'));
    diagnostics.add(GenDiagnostic(GenSeverity.info, 'Parse',
        'API: ${spec.title ?? 'untitled'} v${spec.version ?? '?'} — ${spec.baseUrl ?? 'no base URL'}'));

    // Warn about unresolved refs
    final allRefs = <String>{};
    for (final schema in spec.schemas.values) {
      for (final field in schema.fields) {
        if (field.ref != null) allRefs.add(field.ref!);
      }
    }
    final missingRefs = allRefs.where((r) => !spec.schemas.containsKey(r)).toList();
    for (final ref in missingRefs) {
      diagnostics.add(GenDiagnostic(
        GenSeverity.warning,
        'Validate',
        'Unresolved $ref reference — referenced but not defined in components/schemas. Generated code may not compile.',
      ));
    }

    // Phase 2: Generate models
    try {
      final modelGen = ModelGenerator(spec);
      final modelFiles = modelGen.generate();
      for (final entry in modelFiles.entries) {
        files['models/${entry.key}'] = entry.value;
      }
      diagnostics.add(GenDiagnostic(GenSeverity.info, 'Models',
          'Generated ${modelFiles.length} model file(s): ${modelFiles.keys.join(', ')}'));
    } catch (e, st) {
      diagnostics.add(GenDiagnostic(
        GenSeverity.error,
        'Models',
        'Failed to generate models: $e',
      ));
      final traceLines = st.toString().split('\n').take(3);
      for (final line in traceLines) {
        diagnostics.add(GenDiagnostic(GenSeverity.info, 'Models', line.trim()));
      }
      return GenResult(files: files, diagnostics: diagnostics, success: false);
    }

    // Phase 3: Generate client
    try {
      final clientGen = ClientGenerator(spec, className: clientName);
      files['${_toSnakeCase(clientName)}.dart'] = clientGen.generate();
      diagnostics.add(GenDiagnostic(GenSeverity.info, 'Client',
          'Generated API client: ${_toSnakeCase(clientName)}.dart'));
    } catch (e, st) {
      diagnostics.add(GenDiagnostic(
        GenSeverity.error,
        'Client',
        'Failed to generate API client: $e',
      ));
      final traceLines = st.toString().split('\n').take(3);
      for (final line in traceLines) {
        diagnostics.add(GenDiagnostic(GenSeverity.info, 'Client', line.trim()));
      }
      return GenResult(files: files, diagnostics: diagnostics, success: false);
    }

    // Phase 4: Generate barrel export
    try {
      files['api.dart'] = _generateBarrel(clientName, spec);
      diagnostics.add(GenDiagnostic(GenSeverity.info, 'Export', 'Generated barrel export: api.dart'));
    } catch (e) {
      diagnostics.add(GenDiagnostic(
        GenSeverity.warning,
        'Export',
        'Failed to generate barrel export: $e',
      ));
      // Non-fatal, continue
    }

    diagnostics.add(GenDiagnostic(GenSeverity.info, 'Done',
        'Total: ${files.length} files generated'));

    return GenResult(files: files, diagnostics: diagnostics, success: true);
  }

  /// Simple generate that throws on failure (backward compatible).
  static Map<String, String> generate(String specContent, {String clientName = 'ApiClient'}) {
    final result = generateWithDiagnostics(specContent, clientName: clientName);
    if (!result.success) {
      throw Exception('OpenAPI generation failed:\n${result.errors.map((e) => e.toString()).join('\n')}');
    }
    return result.files;
  }

  static String _generateBarrel(String clientName, OpenApiSpec spec) {
    final buffer = StringBuffer();
    buffer.writeln("export '${_toSnakeCase(clientName)}.dart';");
    for (final schema in spec.schemas.keys) {
      buffer.writeln("export 'models/${_toSnakeCase(schema)}.dart';");
    }
    return buffer.toString();
  }

  static String _toSnakeCase(String input) {
    return input
        .replaceAll(RegExp(r'([A-Z])'), r'_$1')
        .toLowerCase()
        .replaceAll(RegExp(r'^_+'), '');
  }
}
