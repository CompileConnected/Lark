import 'wizard_config.dart';

class DepEntry {
  final String package;
  final String version;
  final bool isDev;

  const DepEntry(this.package, this.version, {this.isDev = false});

  @override
  String toString() => '$package: $version${isDev ? ' (dev)' : ''}';
}

List<DepEntry> resolveDependencies(WizardConfig config) {
  final Set<DepEntry> deps = {};
  final Set<DepEntry> devDeps = {};

  // State management
  switch (config.stateManagement) {
    case StateManagement.none:
    case StateManagement.changeNotifier:
      break;
    case StateManagement.provider:
      deps.add(const DepEntry('provider', '^6.1.0'));
    case StateManagement.riverpod:
      deps.add(const DepEntry('flutter_riverpod', '^2.6.0'));
      deps.add(const DepEntry('riverpod_annotation', '^2.3.0'));
      devDeps.add(const DepEntry('riverpod_generator', '^2.4.0', isDev: true));
    case StateManagement.bloc:
      deps.add(const DepEntry('flutter_bloc', '^9.0.0'));
      deps.add(const DepEntry('bloc', '^9.0.0'));
      devDeps.add(const DepEntry('bloc_test', '^9.0.0', isDev: true));
    case StateManagement.getx:
      deps.add(const DepEntry('get', '^4.6.0'));
    case StateManagement.mobx:
      deps.add(const DepEntry('mobx', '^2.3.0'));
      deps.add(const DepEntry('flutter_mobx', '^2.2.0'));
      devDeps.add(const DepEntry('mobx_codegen', '^2.6.0', isDev: true));
    case StateManagement.signals:
      deps.add(const DepEntry('signals_flutter', '^5.5.0'));
  }

  // Navigation (always GoRouter)
  deps.add(const DepEntry('go_router', '^14.6.0'));

  // Dependency injection
  final di = config.effectiveDI;
  switch (di) {
    case DependencyInjection.none:
      break;
    case DependencyInjection.getIt:
      deps.add(const DepEntry('get_it', '^8.0.0'));
    case DependencyInjection.injectable:
      deps.add(const DepEntry('get_it', '^8.0.0'));
      deps.add(const DepEntry('injectable', '^2.4.0'));
      devDeps.add(const DepEntry('injectable_generator', '^2.6.0', isDev: true));
  }

  // Network
  switch (config.networkClient) {
    case NetworkClient.none:
      break;
    case NetworkClient.http:
      deps.add(const DepEntry('http', '^1.2.0'));
    case NetworkClient.dio:
      deps.add(const DepEntry('dio', '^5.7.0'));
    case NetworkClient.rhttp:
      deps.add(const DepEntry('rhttp', '^0.16.0'));
  }

  // Local storage
  switch (config.localStorage) {
    case LocalStorage.none:
      break;
    case LocalStorage.sharedPreferences:
      deps.add(const DepEntry('shared_preferences', '^2.3.0'));
    case LocalStorage.hiveCe:
      deps.add(const DepEntry('hive_ce', '^2.10.0'));
      deps.add(const DepEntry('hive_ce_flutter', '^2.3.0'));
    case LocalStorage.isarCommunity:
      deps.add(const DepEntry('isar_community', '^3.3.0'));
      deps.add(const DepEntry('isar_community_flutter_libs', '^3.3.0'));
      devDeps.add(const DepEntry('isar_community_generator', '^3.3.0', isDev: true));
    case LocalStorage.drift:
      deps.add(const DepEntry('drift', '^2.22.0'));
      deps.add(const DepEntry('sqlite3_flutter_libs', '^0.5.0'));
      devDeps.add(const DepEntry('drift_dev', '^2.22.0', isDev: true));
  }

  // UI toolkit
  if (config.uiToolkit == UiToolkit.shadcn) {
    deps.add(const DepEntry('shadcn_flutter', '^0.0.52'));
  }

  // Env config
  switch (config.envConfig) {
    case EnvConfig.none:
      break;
    case EnvConfig.flutterDotenv:
      deps.add(const DepEntry('flutter_dotenv', '^6.0.0'));
    case EnvConfig.dotenv:
      deps.add(const DepEntry('dotenv', '^4.2.0'));
  }

  // Logging
  switch (config.logging) {
    case Logging.none:
      break;
    case Logging.logging:
      deps.add(const DepEntry('logging', '^1.3.0'));
    case Logging.logger:
      deps.add(const DepEntry('logger', '^2.5.0'));
  }

  // HTTP logging interceptor
  if (config.attachLoggerToHttp) {
    switch (config.networkClient) {
      case NetworkClient.dio:
        deps.add(const DepEntry('dio_logger_plus', '^1.0.0'));
      case NetworkClient.http:
      case NetworkClient.rhttp:
        break;
      case NetworkClient.none:
        break;
    }
  }

  // DB Debugger
  switch (config.dbDebugger) {
    case DbDebugger.none:
      break;
    case DbDebugger.driftDbViewer:
      deps.add(const DepEntry('drift_db_viewer', '^2.0.0'));
  }

  // OpenAPI generation
  if (config.isOpenApiEnabled) {
    deps.add(const DepEntry('openapi_generator_annotations', '^6.1.0'));
    deps.add(const DepEntry('json_annotation', '^4.9.0'));
    devDeps.add(const DepEntry('openapi_generator', '^6.1.0', isDev: true));
    // Generator-specific deps
    switch (config.openApiClientGenerator) {
      case OpenApiClientGenerator.dart:
        deps.add(const DepEntry('http', '^1.2.0'));
      case OpenApiClientGenerator.dio:
      case OpenApiClientGenerator.dioAlt:
        deps.add(const DepEntry('dio', '^5.7.0'));
    }
    if (config.openApiClientGenerator.needsSourceGen) {
      devDeps.add(const DepEntry('build_runner', '^2.4.0', isDev: true));
    }
  }

  // Code generation (auto-included when needed)
  if (config.needsCodeGeneration) {
    devDeps.add(const DepEntry('build_runner', '^2.4.0', isDev: true));
  }
  if (config.needsFreezed) {
    deps.add(const DepEntry('freezed_annotation', '^2.4.0'));
    devDeps.add(const DepEntry('freezed', '^2.5.0', isDev: true));
    deps.add(const DepEntry('json_annotation', '^4.9.0'));
    devDeps.add(const DepEntry('json_serializable', '^6.8.0', isDev: true));
  }

  // Linting
  if (config.linting == Linting.veryGoodAnalysis) {
    devDeps.add(const DepEntry('very_good_analysis', '^6.0.0', isDev: true));
  }

  return [...deps, ...devDeps];
}
