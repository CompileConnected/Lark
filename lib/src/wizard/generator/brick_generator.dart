import 'package:mustache_template/mustache_template.dart';
import '../config/wizard_config.dart';
import 'brick_templates.g.dart';

/// Converts a [WizardConfig] into the mustache variable map used by the
/// lark_note_app brick (mirrors pre_gen.dart logic from lark_template).
Map<String, dynamic> wizardConfigToBrickVars(WizardConfig config) {
  final vars = <String, dynamic>{};

  // === Project Setup ===
  vars['project_name'] = config.projectName;
  vars['org_name'] = config.orgName;
  vars['dart_package_name'] = config.dartPackageName;
  // Pre-compute case variants (Mason lambdas: snakeCase, pascalCase, camelCase)
  vars['project_name_snake'] = config.dartPackageName;
  vars['project_name_pascal'] = _pascalCase(config.projectName);
  vars['project_name_camel'] = _camelCase(config.projectName);

  // Platforms
  vars['has_android'] = config.platforms.contains(Platform.android);
  vars['has_ios'] = config.platforms.contains(Platform.ios);
  vars['has_web'] = config.platforms.contains(Platform.web);
  vars['has_windows'] = config.platforms.contains(Platform.windows);
  vars['has_macos'] = config.platforms.contains(Platform.macos);
  vars['has_linux'] = config.platforms.contains(Platform.linux);

  vars['platform_android'] = vars['has_android'];
  vars['platform_ios'] = vars['has_ios'];
  vars['platform_web'] = vars['has_web'];
  vars['platform_windows'] = vars['has_windows'];
  vars['platform_macos'] = vars['has_macos'];
  vars['platform_linux'] = vars['has_linux'];

  // === State Management ===
  final sm = config.stateManagement;
  vars['state_management_none'] = sm == StateManagement.none;
  vars['state_management_provider'] = sm == StateManagement.provider;
  vars['state_management_riverpod'] = sm == StateManagement.riverpod;
  vars['state_management_bloc'] = sm == StateManagement.bloc;
  vars['state_management_getx'] = sm == StateManagement.getx;
  vars['state_management_mobx'] = sm == StateManagement.mobx;
  vars['state_management_signals'] = sm == StateManagement.signals;

  final diHidden = sm == StateManagement.provider ||
      sm == StateManagement.riverpod ||
      sm == StateManagement.getx;
  vars['di_hidden'] = diHidden;

  // === UI Toolkit ===
  vars['ui_toolkit_material'] = config.uiToolkit == UiToolkit.material;
  vars['ui_toolkit_shadcn'] = config.uiToolkit == UiToolkit.shadcn;

  // === Network Client ===
  final nc = config.effectiveNetworkClient;
  vars['network_none'] = nc == NetworkClient.none;
  vars['network_http'] = nc == NetworkClient.http;
  vars['network_dio'] = nc == NetworkClient.dio;
  vars['network_rhttp'] = nc == NetworkClient.rhttp;

  // === API Generation ===
  vars['api_openapi'] = config.isOpenApiEnabled;

  final og = config.openApiClientGenerator;
  vars['openapi_dart'] = og == OpenApiClientGenerator.dart;
  vars['openapi_dio'] = og == OpenApiClientGenerator.dio;
  vars['openapi_dio_alt'] = og == OpenApiClientGenerator.dioAlt;

  vars['openapi_spec_url'] = config.openApiSpecUrl;

  // === Local Storage ===
  final ls = config.localStorage;
  vars['storage_none'] = ls == LocalStorage.none;
  vars['storage_shared_preferences'] = ls == LocalStorage.sharedPreferences;
  vars['storage_hive_ce'] = ls == LocalStorage.hiveCe;
  vars['storage_isar_community'] = ls == LocalStorage.isarCommunity;
  vars['storage_drift'] = ls == LocalStorage.drift;

  // === Environment Config ===
  final env = config.envConfig;
  vars['env_none'] = env == EnvConfig.none;
  vars['env_flutter_dotenv'] = env == EnvConfig.flutterDotenv;
  vars['env_dotenv'] = env == EnvConfig.dotenv;

  // === Dependency Injection (effective) ===
  final di = config.effectiveDI;
  vars['di_none'] = di == DependencyInjection.none;
  vars['di_get_it'] = di == DependencyInjection.getIt;
  vars['di_injectable'] = di == DependencyInjection.injectable;

  // === Logging ===
  final log = config.logging;
  vars['logging_none'] = log == Logging.none;
  vars['logging_logging'] = log == Logging.logging;
  vars['logging_logger'] = log == Logging.logger;

  // Attach logger to HTTP
  final canAttach = config.canAttachLoggerToHttp;
  vars['attach_logger_to_http'] = canAttach && config.attachLoggerToHttp;
  vars['attach_logger_to_http_dio'] =
      canAttach && config.attachLoggerToHttp && nc == NetworkClient.dio;

  // === DB Debugger ===
  final db = config.dbDebugger;
  vars['db_debugger_none'] = db == DbDebugger.none;
  vars['db_debugger_drift_db_viewer'] =
      db == DbDebugger.driftDbViewer && ls == LocalStorage.drift;

  // === Linting ===
  vars['linting_flutter_lints'] = config.linting == Linting.flutterLints;
  vars['linting_very_good_analysis'] = config.linting == Linting.veryGoodAnalysis;

  // === Computed flags ===
  vars['needs_code_generation'] = config.needsCodeGeneration;
  vars['needs_freezed'] = config.needsFreezed;
  vars['has_network'] = nc != NetworkClient.none;
  vars['has_storage'] = ls != LocalStorage.none;
  // Provider uses NotesNotifier
  vars['uses_notes_notifier'] = sm == StateManagement.provider;

  return vars;
}

/// Renders all brick mustache templates with the given [vars] and returns
/// a map of output file paths (prefixed with [projectName]/) to rendered content.
Map<String, String> renderBrickTemplates(
  WizardConfig config,
  Map<String, dynamic> vars,
) {
  final prefix = config.projectName;
  final files = <String, String>{};

  // Replace Mason lambda syntax: {{var.snakeCase()}} → {{var_snake}}
  // We pre-computed these as separate variables.
  final lambdaReplacements = <String, String>{
    'project_name.snakeCase()': 'project_name_snake',
    'project_name.pascalCase()': 'project_name_pascal',
    'project_name.camelCase()': 'project_name_camel',
    'org_name.snakeCase()': 'org_name',
  };

  for (final entry in brickTemplates.entries) {
    var template = entry.key;
    var content = entry.value;

    // Replace lambda syntax in template content
    for (final repl in lambdaReplacements.entries) {
      content = content.replaceAll('{{${repl.key}}}', '{{${repl.value}}}');
    }

    // Also replace in file path (e.g., pubspec name uses snakeCase)
    for (final repl in lambdaReplacements.entries) {
      template = template.replaceAll('{{${repl.key}}}', '{{${repl.value}}}');
    }

    // Render mustache template
    final mustache = Template(content, htmlEscapeValues: false);
    var rendered = mustache.renderString(vars);

    // Clean up excessive blank lines (3+ consecutive → 2) caused by mustache conditionals
    rendered = RegExp(r'\n{3,}').allMatches(rendered).fold<String>(
      rendered,
      (acc, match) => acc.replaceAll(match.group(0)!, '\n\n'),
    );

    // Render file path too
    final pathTemplate = Template(template, htmlEscapeValues: false);
    final renderedPath = pathTemplate.renderString(vars);

    files['$prefix/$renderedPath'] = rendered;
  }

  return files;
}

/// Applies post_gen cleanup logic: removes files for unselected options.
Map<String, String> applyPostGenCleanup(
  WizardConfig config,
  Map<String, dynamic> vars,
  Map<String, String> files,
) {
  final prefix = config.projectName;
  final result = Map<String, String>.from(files);

  // Files to delete when their option is NOT selected
  // (mirrors post_gen.dart from lark_template)
  final deletions = <String, bool>{
    // Network
    'lib/src/core/network/api_client.dart': vars['network_none'] == true,
    // Storage
    'lib/src/core/storage/local_storage_service.dart':
        vars['storage_none'] == true,
    // Env
    'lib/src/core/env/env_config.dart': vars['env_none'] == true,
    // Logging
    'lib/src/core/logging/app_logger.dart': vars['logging_none'] == true,
    // DI
    'lib/src/core/di/injection.dart': vars['di_none'] == true,
    'lib/src/core/di/injection.config.dart':
        vars['di_injectable'] != true,
    // OpenAPI
    'lib/openapi_config.dart': vars['api_openapi'] != true,
    'openapi/spec.json': vars['api_openapi'] != true,
    // State management - keep only the selected one
    'lib/src/features/notes/presentation/notifiers/notes_notifier.dart':
        vars['uses_notes_notifier'] != true,
    'lib/src/features/notes/presentation/pages/notes_notifier.dart':
        vars['state_management_none'] != true,
    'lib/src/features/notes/presentation/providers/notes_provider.dart':
        vars['state_management_riverpod'] != true,
    'lib/src/features/notes/presentation/bloc/notes_bloc.dart':
        vars['state_management_bloc'] != true,
    'lib/src/features/notes/presentation/controllers/notes_controller.dart':
        vars['state_management_getx'] != true,
    'lib/src/features/notes/presentation/stores/notes_store.dart':
        vars['state_management_mobx'] != true,
    'lib/src/features/notes/presentation/signals/notes_signal.dart':
        vars['state_management_signals'] != true,
    // DB debugger
    'lib/src/features/notes/presentation/pages/db_viewer_page.dart':
        vars['db_debugger_drift_db_viewer'] != true,
    // Platform directories
    'android/.gitkeep': !vars['has_android'],
    'ios/.gitkeep': !vars['has_ios'],
    'web/index.html': !vars['has_web'],
    'windows/.gitkeep': !vars['has_windows'],
    'macos/.gitkeep': !vars['has_macos'],
    'linux/.gitkeep': !vars['has_linux'],
  };

  for (final entry in deletions.entries) {
    if (entry.value) {
      final key = '$prefix/${entry.key}';
      result.remove(key);
    }
  }

  // Remove empty files (from falsy mustache conditionals that produced empty content)
  result.removeWhere((key, value) {
    if (value.trim().isEmpty) {
      // Keep .gitkeep files (they're intentionally empty)
      return !key.endsWith('.gitkeep');
    }
    return false;
  });

  // Handle .env file: include if flutter_dotenv is selected
  if (vars['env_flutter_dotenv'] == true) {
    final envContent = result['$prefix/env.tpl'] ?? '# Environment Variables\nAPI_BASE_URL=https://api.example.com\n';
    result['$prefix/.env'] = envContent;
    result.remove('$prefix/env.tpl');
  } else {
    result.remove('$prefix/env.tpl');
  }

  return result;
}

// === Case conversion helpers (mirrors Mason lambdas) ===

String _pascalCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(RegExp(r'[_\-\s]+'))
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
      .join();
}

String _camelCase(String input) {
  final pascal = _pascalCase(input);
  if (pascal.isEmpty) return pascal;
  return pascal[0].toLowerCase() + pascal.substring(1);
}
