abstract interface class UiOption {
  bool get hidden;
}

enum StateManagement implements UiOption {
  none('None (setState)', hidden: true),
  provider('Provider + ChangeNotifier'),
  riverpod('Riverpod'),
  bloc('Bloc / Cubit'),
  getx('GetX'),
  mobx('MobX'),
  signals('Signals');

  final String label;

  @override
  final bool hidden;

  const StateManagement(this.label, {this.hidden = false});
}

enum Navigation {
  goRouter('GoRouter');

  final String label;
  const Navigation(this.label);
}

enum DependencyInjection {
  none('None (manual)'),
  getIt('GetIt'),
  injectable('Injectable + GetIt');

  final String label;
  const DependencyInjection(this.label);
}

enum NetworkClient {
  none('None'),
  http('http'),
  dio('Dio'),
  rhttp('rhttp (Rust)');

  final String label;
  const NetworkClient(this.label);

  Set<Platform> get unsupportedPlatforms => switch (this) {
    none => {},
    http => {},
    dio => {},
    rhttp => {Platform.web},
  };
}

enum LocalStorage {
  none('None'),
  sharedPreferences('shared_preferences'),
  hiveCe('Hive CE (community)'),
  isarCommunity('Isar Community'),
  drift('Drift (SQLite)');

  final String label;
  const LocalStorage(this.label);

  Set<Platform> get unsupportedPlatforms => switch (this) {
    none => {},
    sharedPreferences => {},
    hiveCe => {},
    isarCommunity => {Platform.web},
    drift => {Platform.web},
  };

  bool get needsCodeGen => switch (this) {
    none => false,
    sharedPreferences => false,
    hiveCe => false,
    isarCommunity => true,
    drift => true,
  };
}

enum UiToolkit {
  material('Material (default)'),
  shadcn('shadcn_flutter');

  final String label;
  const UiToolkit(this.label);
}

enum EnvConfig {
  none('None'),
  flutterDotenv('flutter_dotenv'),
  dotenv('dotenv');

  final String label;
  const EnvConfig(this.label);

  /// flutter_dotenv works on all Flutter platforms; dotenv is Dart-only (CLI/server).
  Set<Platform> get unsupportedPlatforms => switch (this) {
    none => {},
    flutterDotenv => {},
    dotenv => {},
  };
}

enum Logging {
  none('None'),
  logging('logging (built-in)'),
  logger('logger');

  final String label;
  const Logging(this.label);
}

enum DbDebugger {
  none('None'),
  driftDbViewer('drift_db_viewer');

  final String label;
  const DbDebugger(this.label);
}

enum Linting {
  flutterLints('flutter_lints'),
  veryGoodAnalysis('very_good_analysis');

  final String label;
  const Linting(this.label);
}

enum ApiGeneration {
  none('None'),
  openApi('OpenAPI Generator');

  final String label;
  const ApiGeneration(this.label);
}

/// Maps to the Generator enum in openapi_generator_annotations.
/// - dart: uses the `http` package
/// - dio: uses the `dio` package (needs build_runner source gen)
/// - dioAlt: uses dart-openapi-maven (bluetrainsoftware) with `dio`
enum OpenApiClientGenerator {
  dart('http (dart)', 'dart'),
  dio('Dio (dart-dio)', 'dart-dio'),
  dioAlt('Dio Alt (dart-openapi-maven)', 'dart-openapi-maven');

  final String label;
  final String generatorName;
  const OpenApiClientGenerator(this.label, this.generatorName);

  /// Which NetworkClient this generator corresponds to.
  NetworkClient get networkClient => switch (this) {
    OpenApiClientGenerator.dart => NetworkClient.http,
    OpenApiClientGenerator.dio => NetworkClient.dio,
    OpenApiClientGenerator.dioAlt => NetworkClient.dio,
  };

  /// Whether the generated code needs build_runner source gen.
  bool get needsSourceGen => this == OpenApiClientGenerator.dio;
}

enum Platform {
  android('Android', 'android'),
  ios('iOS', 'ios'),
  web('Web', 'web'),
  windows('Windows', 'windows'),
  macos('macOS', 'macos'),
  linux('Linux', 'linux');

  final String label;
  final String cliName;
  const Platform(this.label, this.cliName);
}

class WizardConfig {
  String projectName;
  String orgName;
  Set<Platform> platforms;
  StateManagement stateManagement;
  Navigation navigation;
  DependencyInjection dependencyInjection;
  NetworkClient networkClient;
  LocalStorage localStorage;
  UiToolkit uiToolkit;
  EnvConfig envConfig;
  Logging logging;
  bool attachLoggerToHttp;
  DbDebugger dbDebugger;
  Linting linting;
  ApiGeneration apiGeneration;
  OpenApiClientGenerator openApiClientGenerator;
  String openApiSpecUrl;
  String openApiSpecContent;

  WizardConfig({
    this.projectName = 'my_app',
    this.orgName = 'com.example',
    this.platforms = const {Platform.android, Platform.ios, Platform.web},
    this.stateManagement = StateManagement.provider,
    this.navigation = Navigation.goRouter,
    this.dependencyInjection = DependencyInjection.none,
    this.networkClient = NetworkClient.none,
    this.localStorage = LocalStorage.none,
    this.uiToolkit = UiToolkit.material,
    this.envConfig = EnvConfig.none,
    this.logging = Logging.none,
    this.attachLoggerToHttp = false,
    this.dbDebugger = DbDebugger.none,
    this.linting = Linting.flutterLints,
    this.apiGeneration = ApiGeneration.none,
    this.openApiClientGenerator = OpenApiClientGenerator.dio,
    this.openApiSpecUrl = '',
    this.openApiSpecContent = '',
  });

  DependencyInjection get effectiveDI {
    switch (stateManagement) {
      case StateManagement.provider:
      case StateManagement.riverpod:
      case StateManagement.getx:
        return DependencyInjection.none;
      case StateManagement.bloc:
      case StateManagement.mobx:
      case StateManagement.signals:
      case StateManagement.none:
        return dependencyInjection;
    }
  }

  bool get needsCodeGeneration {
    if (stateManagement == StateManagement.riverpod) return true;
    if (stateManagement == StateManagement.mobx) return true;
    if (dependencyInjection == DependencyInjection.injectable) return true;
    if (localStorage.needsCodeGen) return true;
    if (apiGeneration == ApiGeneration.openApi) return true;
    return false;
  }

  bool get needsFreezed =>
      stateManagement == StateManagement.riverpod ||
      stateManagement == StateManagement.bloc;

  bool get isRhttpSelected => networkClient == NetworkClient.rhttp;

  bool get isOpenApiEnabled => apiGeneration == ApiGeneration.openApi;

  bool get hasOpenApiSpec => openApiSpecContent.isNotEmpty;

  /// When OpenAPI is selected, force the network client to match the generator choice.
  NetworkClient get effectiveNetworkClient {
    if (isOpenApiEnabled) return openApiClientGenerator.networkClient;
    return networkClient == NetworkClient.none
        ? NetworkClient.none
        : networkClient;
  }

  bool get canAttachLoggerToHttp =>
      networkClient != NetworkClient.none && logging != Logging.none;

  bool get isDbDebuggerValid =>
      dbDebugger == DbDebugger.none ||
      (dbDebugger == DbDebugger.driftDbViewer &&
          localStorage == LocalStorage.drift);

  bool get hasPlatformConflict =>
      _networkPlatformConflict || _storagePlatformConflict;

  bool get _networkPlatformConflict =>
      networkClient.unsupportedPlatforms.intersection(platforms).isNotEmpty;

  bool get _storagePlatformConflict =>
      localStorage.unsupportedPlatforms.intersection(platforms).isNotEmpty;

  Set<Platform> get conflictingPlatforms => {
    ...networkClient.unsupportedPlatforms.intersection(platforms),
    ...localStorage.unsupportedPlatforms.intersection(platforms),
  };

  String get dartPackageName => projectName.replaceAll('-', '_');
}
