/// Auto-generated from lark_note_app brick templates.
/// DO NOT EDIT MANUALLY - regenerate with: dart run tools/sync_brick.dart
final Map<String, String> brickTemplates = {
  r'.fvmrc': r'''{
  "flutter": "3.29.3"
}
''',
  r'.gitignore': r'''# Miscellaneous
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

# Environment
.env
''',
  r'README.md': r'''# {{project_name}}

A note-taking Flutter application.
''',
  r'analysis_options.yaml': r'''{{#linting_flutter_lints}}include: package:flutter_lints/flutter.yaml{{/linting_flutter_lints}}{{#linting_very_good_analysis}}include: package:very_good_analysis/analysis_options.yaml{{/linting_very_good_analysis}}

linter:
  rules:
{{#linting_very_good_analysis}}
    public_member_api_docs: false
{{/linting_very_good_analysis}}
''',
  r'android/.gitkeep': r'''
''',
  r'env.tpl': r'''# Environment Variables
API_BASE_URL=https://api.example.com
''',
  r'ios/.gitkeep': r'''
''',
  r'lib/main.dart': r'''{{#ui_toolkit_material}}import 'package:flutter/material.dart';{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}import 'package:shadcn_flutter/shadcn_flutter.dart';{{/ui_toolkit_shadcn}}
{{#state_management_riverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';{{/state_management_riverpod}}
{{#state_management_provider}}import 'package:provider/provider.dart';{{/state_management_provider}}
{{#state_management_bloc}}import 'package:flutter_bloc/flutter_bloc.dart';{{/state_management_bloc}}
{{#state_management_getx}}import 'package:get/get.dart';{{/state_management_getx}}
{{#state_management_mobx}}import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';{{/state_management_mobx}}
{{#state_management_signals}}import 'package:signals_flutter/signals_flutter.dart';{{/state_management_signals}}
import 'package:go_router/go_router.dart';
{{#di_get_it}}import 'package:get_it/get_it.dart';{{/di_get_it}}
{{#di_injectable}}import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';{{/di_injectable}}
{{#env_flutter_dotenv}}import 'package:flutter_dotenv/flutter_dotenv.dart';{{/env_flutter_dotenv}}
{{#env_dotenv}}import 'package:dotenv/dotenv.dart';{{/env_dotenv}}
{{#logging_logging}}import 'package:logging/logging.dart';{{/logging_logging}}
{{#logging_logger}}import 'package:logger/logger.dart';{{/logging_logger}}
{{#db_debugger_drift_db_viewer}}import 'package:drift_db_viewer/drift_db_viewer.dart';{{/db_debugger_drift_db_viewer}}

import 'src/core/router/app_router.dart';
{{#di_get_it}}import 'src/core/di/injection.dart';{{/di_get_it}}
{{#di_injectable}}import 'src/core/di/injection.config.dart';{{/di_injectable}}
import 'src/features/notes/presentation/pages/notes_page.dart';
{{#state_management_provider}}import 'src/features/notes/presentation/notifiers/notes_notifier.dart';
import 'src/features/notes/domain/repositories/note_repository_impl.dart';
import 'src/features/notes/data/datasources/note_remote_source.dart';
import 'src/features/notes/data/datasources/note_local_source.dart';
{{#has_network}}import 'src/core/network/api_client.dart';
import 'src/core/env/app_env.dart';{{/has_network}}{{/state_management_provider}}

{{#logging_logging}}final _log = Logger('{{project_name.pascalCase()}}');{{/logging_logging}}
{{#logging_logger}}final logger = Logger();{{/logging_logger}}

{{#state_management_riverpod}}
class {{project_name.pascalCase()}} extends ConsumerWidget {
  const {{project_name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    {{#ui_toolkit_material}}return MaterialApp.router(
      title: '{{project_name}}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: appRouter,
    );{{/ui_toolkit_material}}
    {{#ui_toolkit_shadcn}}return ShadcnApp.router(
      title: '{{project_name}}',
      routerConfig: appRouter,
    );{{/ui_toolkit_shadcn}}
  }
}
{{/state_management_riverpod}}
{{^state_management_riverpod}}
{{#state_management_getx}}
class {{project_name.pascalCase()}} extends StatelessWidget {
  const {{project_name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: '{{project_name}}',
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
    );
  }
}
{{/state_management_getx}}
{{^state_management_getx}}
{{#state_management_provider}}
class {{project_name.pascalCase()}} extends StatelessWidget {
  const {{project_name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NotesNotifier(
            repository: NoteRepositoryImpl(
              remoteSource: NoteRemoteSourceImpl({{#has_network}}apiClient: ApiClient(baseUrl: AppEnv.apiBaseUrl){{/has_network}}),
              localSource: NoteLocalSourceImpl(),
            ),
          ),
        ),
      ],
      child: _buildApp(),
    );
  }

  Widget _buildApp() {
    {{#ui_toolkit_material}}return MaterialApp.router(
      title: '{{project_name}}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: appRouter,
    );{{/ui_toolkit_material}}
    {{#ui_toolkit_shadcn}}return ShadcnApp.router(
      title: '{{project_name}}',
      routerConfig: appRouter,
    );{{/ui_toolkit_shadcn}}
  }
}
{{/state_management_provider}}
{{^state_management_provider}}
class {{project_name.pascalCase()}} extends StatelessWidget {
  const {{project_name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context) {
    {{#ui_toolkit_material}}return MaterialApp.router(
      title: '{{project_name}}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: appRouter,
    );{{/ui_toolkit_material}}
    {{#ui_toolkit_shadcn}}return ShadcnApp.router(
      title: '{{project_name}}',
      routerConfig: appRouter,
    );{{/ui_toolkit_shadcn}}
  }
}
{{/state_management_provider}}
{{/state_management_getx}}
{{/state_management_riverpod}}

void main() {
  {{#logging_logging}}Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });{{/logging_logging}}
  {{#logging_logger}}logger.i('Starting {{project_name}}');{{/logging_logger}}

  {{#di_get_it}}setupInjection();{{/di_get_it}}
  {{#di_injectable}}configureDependencies(environment: Environment.prod);{{/di_injectable}}

  {{#env_flutter_dotenv}}dotenv.load(fileName: '.env');{{/env_flutter_dotenv}}
  {{#env_dotenv}}load();{{/env_dotenv}}

  {{#network_rhttp}}// Note: rhttp requires async init:
  // void main() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Rhttp.init();
  //   ...
  //   runApp(const {{project_name.pascalCase()}}());
  // }{{/network_rhttp}}

  runApp(const {{project_name.pascalCase()}}());
}
''',
  r'lib/openapi_config.dart': r'''{{#api_openapi}}import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: {{#openapi_dio}}DioProperties(pubName: '{{project_name.snakeCase()}}', pubAuthor: '{{org_name}}'){{/openapi_dio}}{{^openapi_dio}}AdditionalProperties(pubName: '{{project_name.snakeCase()}}', pubAuthor: '{{org_name}}'){{/openapi_dio}},
  inputSpec: {{#openapi_spec_url}}RemoteSpec(path: '{{openapi_spec_url}}'){{/openapi_spec_url}}{{^openapi_spec_url}}InputSpec(path: 'openapi/spec.json'){{/openapi_spec_url}},
  generatorName: Generator.{{#openapi_dart}}dart{{/openapi_dart}}{{#openapi_dio}}dartDio{{/openapi_dio}}{{#openapi_dio_alt}}dartOpenapiMaven{{/openapi_dio_alt}},
  runSourceGenOnOutput: {{#openapi_dio}}true{{/openapi_dio}}{{^openapi_dio}}false{{/openapi_dio}},
  outputDirectory: 'lib/src/api',
)
class OpenApiConfig {}
{{/api_openapi}}
''',
  r'lib/src/core/di/injection.config.dart': r'''{{#di_injectable}}// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run build_runner build
// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final _getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
)
Future<void> configureDependencies({String environment = Environment.prod}) async {
  await _getIt.init(environment: environment);
}
{{/di_injectable}}
''',
  r'lib/src/core/di/injection.dart': r'''{{#di_get_it}}import 'package:get_it/get_it.dart';
{{#network_http}}import '../../core/network/api_client.dart';{{/network_http}}
{{#network_dio}}import '../../core/network/api_client.dart';{{/network_dio}}
{{#network_rhttp}}import '../../core/network/api_client.dart';{{/network_rhttp}}
{{#has_network}}import '../../core/env/app_env.dart';{{/has_network}}
import '../../features/notes/data/datasources/note_local_source.dart';
import '../../features/notes/data/datasources/note_remote_source.dart';
import '../../features/notes/domain/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart';

final getIt = GetIt.instance;

void setupInjection() {
  {{#network_http}}// Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: AppEnv.apiBaseUrl),
  );{{/network_http}}
  {{#network_dio}}// Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: AppEnv.apiBaseUrl),
  );{{/network_dio}}
  {{#network_rhttp}}// Network
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: AppEnv.apiBaseUrl),
  );{{/network_rhttp}}

  // Data sources
  getIt.registerLazySingleton<NoteRemoteSource>(
    () => NoteRemoteSourceImpl({{#network_http}}apiClient: getIt<ApiClient>(){{/network_http}}{{#network_dio}}apiClient: getIt<ApiClient>(){{/network_dio}}{{#network_rhttp}}apiClient: getIt<ApiClient>(){{/network_rhttp}}),
  );
  getIt.registerLazySingleton<NoteLocalSource>(
    () => NoteLocalSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      remoteSource: getIt<NoteRemoteSource>(),
      localSource: getIt<NoteLocalSource>(),
    ),
  );
}{{/di_get_it}}{{#di_injectable}}import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({String environment = Environment.prod}) async {
  await getIt.init(environment: environment);
}{{/di_injectable}}
''',
  r'lib/src/core/env/app_env.dart': r'''{{#env_flutter_dotenv}}import 'package:flutter_dotenv/flutter_dotenv.dart';{{/env_flutter_dotenv}}
{{#env_dotenv}}import 'package:dotenv/dotenv.dart';{{/env_dotenv}}

/// App-wide read-only environment configuration.
/// Always available regardless of env backend selection.
/// Provides a unified interface to environment variables throughout the app.
abstract final class AppEnv {
  /// The base URL for the API.
  /// Reads [API_BASE_URL] from .env when an env backend is configured,
  /// otherwise returns the default placeholder.
  static String get apiBaseUrl {
    {{#env_flutter_dotenv}}return dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';{{/env_flutter_dotenv}}
    {{#env_dotenv}}return env['API_BASE_URL'] ?? 'https://api.example.com';{{/env_dotenv}}
    {{^env_flutter_dotenv}}{{^env_dotenv}}return 'https://api.example.com';{{/env_dotenv}}{{/env_flutter_dotenv}}
  }
}

''',
  r'lib/src/core/env/env_config.dart': r'''{{#env_flutter_dotenv}}import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  static String get(String key, {String defaultValue = ''}) =>
      dotenv.env[key] ?? defaultValue;
}{{/env_flutter_dotenv}}{{#env_dotenv}}import 'package:dotenv/dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl => env['API_BASE_URL'] ?? 'https://api.example.com';
  static String get(String key, {String defaultValue = ''}) =>
      env[key] ?? defaultValue;
}{{/env_dotenv}}
''',
  r'lib/src/core/logging/app_logger.dart': r'''{{#logging_logging}}import 'package:logging/logging.dart';

class AppLogger {
  AppLogger._();

  static final _loggers = <String, Logger>{};

  static Logger get(String name) {
    return _loggers.putIfAbsent(name, () => Logger(name));
  }

  static void info(String name, String message) => get(name).info(message);
  static void warning(String name, String message) => get(name).warning(message);
  static void severe(String name, String message) => get(name).severe(message);
  static void fine(String name, String message) => get(name).fine(message);
}{{/logging_logging}}{{#logging_logger}}import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final _logger = Logger();

  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [Object? error, StackTrace? st]) =>
      _logger.e(message, error: error, stackTrace: st);
  static void debug(String message) => _logger.d(message);
}{{/logging_logger}}
''',
  r'lib/src/core/network/api_client.dart': r'''{{#network_http}}import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    return _client.get(
      Uri.parse('$baseUrl$path'),
      headers: {...?headers},
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: body,
    );
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _client.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: body,
    );
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) {
    return _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: {...?headers},
    );
  }
}{{/network_http}}{{#network_dio}}import 'package:dio/dio.dart';
{{#attach_logger_to_http_dio}}import 'package:dio_logger_plus/dio_logger_plus.dart';{{/attach_logger_to_http_dio}}

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    {{#attach_logger_to_http_dio}}_dio.interceptors.add(DioLoggerPlus());{{/attach_logger_to_http_dio}}
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, options: options);
  }
}{{/network_dio}}{{#network_rhttp}}import 'package:rhttp/rhttp.dart';

class ApiClient {
  final Client _client;
  final String baseUrl;

  ApiClient({required this.baseUrl}) : _client = Client();

  Future<HttpResponse> get(String path, {Map<String, String>? headers}) {
    return _client.get(
      '$baseUrl$path',
      headers: HttpHeaders.fromMap(headers ?? {}),
    );
  }

  Future<HttpResponse> post(String path, {String? body, Map<String, String>? headers}) {
    return _client.post(
      '$baseUrl$path',
      headers: HttpHeaders.fromMap(headers ?? {}),
      body: HttpBody.text(body ?? ''),
    );
  }

  Future<HttpResponse> put(String path, {String? body, Map<String, String>? headers}) {
    return _client.put(
      '$baseUrl$path',
      headers: HttpHeaders.fromMap(headers ?? {}),
      body: HttpBody.text(body ?? ''),
    );
  }

  Future<HttpResponse> delete(String path, {Map<String, String>? headers}) {
    return _client.delete(
      '$baseUrl$path',
      headers: HttpHeaders.fromMap(headers ?? {}),
    );
  }
}{{/network_rhttp}}
''',
  r'lib/src/core/router/app_router.dart': r'''import 'package:go_router/go_router.dart';

import '../../features/notes/presentation/pages/notes_page.dart';
{{#db_debugger_drift_db_viewer}}import '../../features/notes/presentation/pages/db_viewer_page.dart';{{/db_debugger_drift_db_viewer}}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
    ),
    {{#db_debugger_drift_db_viewer}}GoRoute(
      path: '/db-viewer',
      builder: (context, state) => const DbViewerPage(),
    ),{{/db_debugger_drift_db_viewer}}
  ],
);
''',
  r'lib/src/core/storage/local_storage_service.dart': r'''{{#storage_shared_preferences}}import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static LocalStorageService? _instance;

  static Future<LocalStorageService> get instance async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService._internal(prefs);
    return _instance!;
  }

  late final SharedPreferences _prefs;

  LocalStorageService._internal(this._prefs);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  bool containsKey(String key) => _prefs.containsKey(key);

  Future<bool> clear() => _prefs.clear();
}{{/storage_shared_preferences}}{{#storage_hive_ce}}import 'package:hive_ce_flutter/hive_flutter.dart';

class LocalStorageService {
  LocalStorageService._();
  static LocalStorageService? _instance;

  static Future<LocalStorageService> get instance async {
    if (_instance != null) return _instance!;
    await Hive.initFlutter();
    _instance = LocalStorageService._();
    return _instance!;
  }

  late final Box<String> _box;

  Future<void> openBox(String name) async {
    _box = await Hive.openBox<String>(name);
  }

  Future<void> set(String key, String value) => _box.put(key, value);
  String? get(String key) => _box.get(key);

  Future<void> delete(String key) => _box.delete(key);
  bool containsKey(String key) => _box.containsKey(key);

  Future<void> clear() => _box.clear();
}{{/storage_hive_ce}}{{#storage_drift}}import 'package:drift/drift.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'local_storage_service.g.dart';

@DriftDatabase(tables: [NoteEntities])
class LocalStorageService extends _$LocalStorageService {
  LocalStorageService() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final db = await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      return NativeDatabase.createInBackground(db);
    });
  }

  // Notes queries
  Future<List<NoteEntity>> getAllNotes() => select(noteEntities).get();
  Stream<List<NoteEntity>> watchAllNotes() => select(noteEntities).watch();

  Future<int> insertNote(NoteEntitiesCompanion entry) =>
      into(noteEntities).insert(entry);

  Future<bool> updateNote(NoteEntitiesCompanion entry) =>
      update(noteEntities).replace(entry);

  Future<int> deleteNote(int id) =>
      (delete(noteEntities)..where((t) => t.id.equals(id))).go();
}

@DataClassName('NoteEntity')
class NoteEntities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}{{/storage_drift}}{{#storage_isar_community}}import 'package:isar_community/isar_community.dart';
{{#state_management_riverpod}}import 'package:freezed_annotation/freezed_annotation.dart';{{/state_management_riverpod}}
{{#state_management_bloc}}import 'package:freezed_annotation/freezed_annotation.dart';{{/state_management_bloc}}
part 'local_storage_service.g.dart';

@collection
class NoteEntity {
  Id id = Isar.autoIncrement;

  late String title;
  late String content;

  late DateTime createdAt;
  late DateTime updatedAt;
}{{/storage_isar_community}}
''',
  r'lib/src/core/theme/app_theme.dart': r'''{{#ui_toolkit_material}}import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppTheme {
  AppTheme._();

  static ThemeDataData get light => ThemeDataData(
        colorScheme: ColorSchemes.defaultColorScheme,
        brightness: Brightness.light,
      );

  static ThemeDataData get dark => ThemeDataData(
        colorScheme: ColorSchemes.defaultColorScheme,
        brightness: Brightness.dark,
      );
}{{/ui_toolkit_shadcn}}
''',
  r'lib/src/features/notes/data/datasources/note_local_source.dart': r'''import '../models/note_model.dart';
{{#storage_shared_preferences}}import '../../../../core/storage/local_storage_service.dart';{{/storage_shared_preferences}}
{{#storage_hive_ce}}import '../../../../core/storage/local_storage_service.dart';{{/storage_hive_ce}}
{{#storage_drift}}import '../../../../core/storage/local_storage_service.dart';{{/storage_drift}}
{{#storage_isar_community}}import '../../../../core/storage/local_storage_service.dart';{{/storage_isar_community}}

abstract class NoteLocalSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel?> getNoteById(String id);
  Future<void> saveNote(NoteModel note);
  Future<void> saveNotes(List<NoteModel> notes);
  Future<void> deleteNote(String id);
  {{#storage_drift}}Stream<List<NoteModel>> watchNotes();{{/storage_drift}}
}

class NoteLocalSourceImpl implements NoteLocalSource {
  {{#storage_drift}}final LocalStorageService _db;
  NoteLocalSourceImpl({LocalStorageService? db}) : _db = db ?? LocalStorageService();{{/storage_drift}}
  {{#storage_isar_community}}NoteLocalSourceImpl();{{/storage_isar_community}}
  {{#storage_shared_preferences}}NoteLocalSourceImpl();{{/storage_shared_preferences}}
  {{#storage_hive_ce}}NoteLocalSourceImpl();{{/storage_hive_ce}}
  {{^storage_drift}}{{^storage_isar_community}}{{^storage_shared_preferences}}{{^storage_hive_ce}}NoteLocalSourceImpl();{{/storage_hive_ce}}{{/storage_shared_preferences}}{{/storage_isar_community}}{{/storage_drift}}

  @override
  Future<List<NoteModel>> getNotes() async {
    {{#storage_drift}}final rows = await _db.getAllNotes();
    return rows.map((row) => NoteModel(
      id: row.id.toString(),
      title: row.title,
      content: row.content,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    )).toList();{{/storage_drift}}
    {{#storage_isar_community}}final isar = await Isar.getInstance();
    final notes = await isar?.noteEntitys.where().findAll() ?? [];
    return notes.map((e) => NoteModel(
      id: e.id.toString(),
      title: e.title,
      content: e.content,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    )).toList();{{/storage_isar_community}}
    {{#storage_hive_ce}}final storage = await LocalStorageService.instance;
    await storage.openBox('notes');
    final keys = storage._box.keys;
    return keys.map((key) {
      final json = storage.get(key.toString());
      if (json == null) return null;
      return NoteModel.fromJson({});
    }).whereType<NoteModel>().toList();{{/storage_hive_ce}}
    {{#storage_shared_preferences}}final storage = await LocalStorageService.instance;
    // Simple key-value: store notes as JSON string
    final notesJson = storage.getString('notes_list');
    if (notesJson == null) return [];
    return [];{{/storage_shared_preferences}}
    {{^storage_drift}}{{^storage_isar_community}}{{^storage_shared_preferences}}{{^storage_hive_ce}}// No local storage configured - return empty list
    return [];{{/storage_hive_ce}}{{/storage_shared_preferences}}{{/storage_isar_community}}{{/storage_drift}}
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    {{#storage_drift}}final notes = await getNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }{{/storage_drift}}
    {{#storage_isar_community}}final isar = await Isar.getInstance();
    final entity = await isar?.noteEntitys.get(int.parse(id));
    if (entity == null) return null;
    return NoteModel(
      id: entity.id.toString(),
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );{{/storage_isar_community}}
    {{#storage_hive_ce}}final storage = await LocalStorageService.instance;
    await storage.openBox('notes');
    return null;{{/storage_hive_ce}}
    {{#storage_shared_preferences}}final notes = await getNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }{{/storage_shared_preferences}}
    {{^storage_drift}}{{^storage_isar_community}}{{^storage_shared_preferences}}{{^storage_hive_ce}}return null;{{/storage_hive_ce}}{{/storage_shared_preferences}}{{/storage_isar_community}}{{/storage_drift}}
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    {{#storage_drift}}await _db.insertNote(NoteEntitiesCompanion.insert(
      title: note.title,
      content: note.content,
    ));{{/storage_drift}}
    {{#storage_isar_community}}final isar = await Isar.getInstance();
    final entity = NoteEntity()
      ..title = note.title
      ..content = note.content
      ..createdAt = note.createdAt
      ..updatedAt = note.updatedAt;
    await isar?.noteEntitys.put(entity);{{/storage_isar_community}}
    {{#storage_hive_ce}}final storage = await LocalStorageService.instance;
    await storage.openBox('notes');
    await storage.set(note.id, note.toJson().toString());{{/storage_hive_ce}}
    {{#storage_shared_preferences}}final storage = await LocalStorageService.instance;
    // Save via shared_preferences
    await storage.setString('note_${note.id}', note.toJson().toString());{{/storage_shared_preferences}}
    {{^storage_drift}}{{^storage_isar_community}}{{^storage_shared_preferences}}{{^storage_hive_ce}}// No local storage configured{{/storage_hive_ce}}{{/storage_shared_preferences}}{{/storage_isar_community}}{{/storage_drift}}
  }

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    for (final note in notes) {
      await saveNote(note);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    {{#storage_drift}}await _db.deleteNote(int.parse(id));{{/storage_drift}}
    {{#storage_isar_community}}final isar = await Isar.getInstance();
    await isar?.noteEntitys.delete(int.parse(id));{{/storage_isar_community}}
    {{#storage_hive_ce}}final storage = await LocalStorageService.instance;
    await storage.openBox('notes');
    await storage.delete(id);{{/storage_hive_ce}}
    {{#storage_shared_preferences}}final storage = await LocalStorageService.instance;
    await storage.remove('note_$id');{{/storage_shared_preferences}}
    {{^storage_drift}}{{^storage_isar_community}}{{^storage_shared_preferences}}{{^storage_hive_ce}}// No local storage configured{{/storage_hive_ce}}{{/storage_shared_preferences}}{{/storage_isar_community}}{{/storage_drift}}
  }

  {{#storage_drift}}@override
  Stream<List<NoteModel>> watchNotes() {
    return _db.watchAllNotes().map((rows) => rows.map((row) => NoteModel(
      id: row.id.toString(),
      title: row.title,
      content: row.content,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    )).toList());
  }{{/storage_drift}}
}
''',
  r'lib/src/features/notes/data/datasources/note_remote_source.dart': r'''import '../models/note_model.dart';
{{#network_http}}import '../../../../core/network/api_client.dart';{{/network_http}}
{{#network_dio}}import '../../../../core/network/api_client.dart';{{/network_dio}}
{{#network_rhttp}}import '../../../../core/network/api_client.dart';{{/network_rhttp}}
{{#logging_logging}}import '../../../../core/logging/app_logger.dart';{{/logging_logging}}
{{#logging_logger}}import '../../../../core/logging/app_logger.dart';{{/logging_logger}}

abstract class NoteRemoteSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(String id);
  Future<NoteModel> createNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
}

class NoteRemoteSourceImpl implements NoteRemoteSource {
  {{#network_http}}final ApiClient apiClient;
  NoteRemoteSourceImpl({required this.apiClient});{{/network_http}}
  {{#network_dio}}final ApiClient apiClient;
  NoteRemoteSourceImpl({required this.apiClient});{{/network_dio}}
  {{#network_rhttp}}final ApiClient apiClient;
  NoteRemoteSourceImpl({required this.apiClient});{{/network_rhttp}}
  {{^network_http}}{{^network_dio}}{{^network_rhttp}}NoteRemoteSourceImpl();{{/network_rhttp}}{{/network_dio}}{{/network_http}}

  @override
  Future<List<NoteModel>> getNotes() async {
    {{#network_http}}{{#logging_logging}}AppLogger.info('NoteRemoteSource', 'Fetching notes from API');{{/logging_logging}}{{#logging_logger}}AppLogger.info('Fetching notes from API');{{/logging_logger}}
    final response = await apiClient.get('/notes');
    final List<dynamic> jsonList = [];
    // Parse response body
    return jsonList.map((json) => NoteModel.fromJson(json as Map<String, dynamic>)).toList();{{/network_http}}
    {{#network_dio}}{{#logging_logging}}AppLogger.info('NoteRemoteSource', 'Fetching notes from API');{{/logging_logging}}{{#logging_logger}}AppLogger.info('Fetching notes from API');{{/logging_logger}}
    final response = await apiClient.get<List<dynamic>>('/notes');
    return (response.data ?? [])
        .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
        .toList();{{/network_dio}}
    {{#network_rhttp}}{{#logging_logging}}AppLogger.info('NoteRemoteSource', 'Fetching notes from API');{{/logging_logging}}{{#logging_logger}}AppLogger.info('Fetching notes from API');{{/logging_logger}}
    final response = await apiClient.get('/notes');
    final List<dynamic> jsonList = [];
    return jsonList.map((json) => NoteModel.fromJson(json as Map<String, dynamic>)).toList();{{/network_rhttp}}
    {{^network_http}}{{^network_dio}}{{^network_rhttp}}// No network client configured - return empty list
    return [];{{/network_rhttp}}{{/network_dio}}{{/network_http}}
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    {{#network_http}}final response = await apiClient.get('/notes/$id');
    return NoteModel.fromJson({});{{/network_http}}
    {{#network_dio}}final response = await apiClient.get<Map<String, dynamic>>('/notes/$id');
    return NoteModel.fromJson(response.data ?? {});{{/network_dio}}
    {{#network_rhttp}}final response = await apiClient.get('/notes/$id');
    return NoteModel.fromJson({});{{/network_rhttp}}
    {{^network_http}}{{^network_dio}}{{^network_rhttp}}throw UnimplementedError('No network client configured');{{/network_rhttp}}{{/network_dio}}{{/network_http}}
  }

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    {{#network_http}}final response = await apiClient.post('/notes', body: note.toJson());
    return NoteModel.fromJson({});{{/network_http}}
    {{#network_dio}}final response = await apiClient.post<Map<String, dynamic>>(
      '/notes',
      data: note.toJson(),
    );
    return NoteModel.fromJson(response.data ?? {});{{/network_dio}}
    {{#network_rhttp}}final response = await apiClient.post('/notes', body: note.toJson().toString());
    return NoteModel.fromJson({});{{/network_rhttp}}
    {{^network_http}}{{^network_dio}}{{^network_rhttp}}throw UnimplementedError('No network client configured');{{/network_rhttp}}{{/network_dio}}{{/network_http}}
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    {{#network_http}}final response = await apiClient.put('/notes/${note.id}', body: note.toJson());
    return NoteModel.fromJson({});{{/network_http}}
    {{#network_dio}}final response = await apiClient.put<Map<String, dynamic>>(
      '/notes/${note.id}',
      data: note.toJson(),
    );
    return NoteModel.fromJson(response.data ?? {});{{/network_dio}}
    {{#network_rhttp}}final response = await apiClient.put('/notes/${note.id}', body: note.toJson().toString());
    return NoteModel.fromJson({});{{/network_rhttp}}
    {{^network_http}}{{^network_dio}}{{^network_rhttp}}throw UnimplementedError('No network client configured');{{/network_rhttp}}{{/network_dio}}{{/network_http}}
  }

  @override
  Future<void> deleteNote(String id) async {
    {{#network_http}}await apiClient.delete('/notes/$id');{{/network_http}}
    {{#network_dio}}await apiClient.delete('/notes/$id');{{/network_dio}}
    {{#network_rhttp}}await apiClient.delete('/notes/$id');{{/network_rhttp}}
    {{^network_http}}{{^network_dio}}{{^network_rhttp}}throw UnimplementedError('No network client configured');{{/network_rhttp}}{{/network_dio}}{{/network_http}}
  }
}
''',
  r'lib/src/features/notes/data/models/note_model.dart': r'''import '../../domain/entities/note.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Note toEntity() => Note(
        id: id,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static NoteModel fromEntity(Note note) => NoteModel(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
      );
}
''',
  r'lib/src/features/notes/domain/entities/note.dart': r'''class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
''',
  r'lib/src/features/notes/domain/repositories/note_repository.dart': r'''import '../entities/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<Note> getNoteById(String id);
  Future<Note> createNote(Note note);
  Future<Note> updateNote(Note note);
  Future<void> deleteNote(String id);
  {{#storage_drift}}Stream<List<Note>> watchNotes();{{/storage_drift}}
}
''',
  r'lib/src/features/notes/domain/repositories/note_repository_impl.dart': r'''import '../entities/note.dart';
import 'note_repository.dart';
import '../../data/datasources/note_local_source.dart';
import '../../data/datasources/note_remote_source.dart';
import '../../data/models/note_model.dart';
{{#logging_logging}}import '../../../../core/logging/app_logger.dart';{{/logging_logging}}
{{#logging_logger}}import '../../../../core/logging/app_logger.dart';{{/logging_logger}}

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteSource remoteSource;
  final NoteLocalSource localSource;

  NoteRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
  });

  @override
  Future<List<Note>> getNotes() async {
    try {
      {{#logging_logging}}AppLogger.info('NoteRepository', 'Fetching notes');{{/logging_logging}}{{#logging_logger}}AppLogger.info('Fetching notes');{{/logging_logger}}
      final remoteNotes = await remoteSource.getNotes();
      await localSource.saveNotes(remoteNotes);
      return remoteNotes.map((model) => model.toEntity()).toList();
    } catch (e) {
      {{#logging_logging}}AppLogger.warning('NoteRepository', 'Remote fetch failed, falling back to local: $e');{{/logging_logging}}{{#logging_logger}}AppLogger.warning('Remote fetch failed, falling back to local: $e');{{/logging_logger}}
      final localNotes = await localSource.getNotes();
      return localNotes.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<Note> getNoteById(String id) async {
    try {
      final model = await remoteSource.getNoteById(id);
      return model.toEntity();
    } catch (_) {
      final model = await localSource.getNoteById(id);
      if (model == null) throw Exception('Note not found: $id');
      return model.toEntity();
    }
  }

  @override
  Future<Note> createNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    final created = await remoteSource.createNote(model);
    await localSource.saveNote(created);
    return created.toEntity();
  }

  @override
  Future<Note> updateNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    final updated = await remoteSource.updateNote(model);
    await localSource.saveNote(updated);
    return updated.toEntity();
  }

  @override
  Future<void> deleteNote(String id) async {
    await remoteSource.deleteNote(id);
    await localSource.deleteNote(id);
  }

  {{#storage_drift}}@override
  Stream<List<Note>> watchNotes() {
    return localSource.watchNotes().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }{{/storage_drift}}
}
''',
  r'lib/src/features/notes/presentation/bloc/notes_bloc.dart': r'''{{#state_management_bloc}}import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

// Events
sealed class NotesEvent {}

class LoadNotes extends NotesEvent {}

class CreateNote extends NotesEvent {
  final Note note;
  CreateNote(this.note);
}

class UpdateNote extends NotesEvent {
  final Note note;
  UpdateNote(this.note);
}

class DeleteNote extends NotesEvent {
  final String id;
  DeleteNote(this.id);
}

// State
class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository repository;

  NotesBloc({required this.repository}) : super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final notes = await repository.getNotes();
      emit(state.copyWith(notes: notes, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NotesState> emit) async {
    try {
      final note = await repository.createNote(event.note);
      emit(state.copyWith(notes: [...state.notes, note]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      final updated = await repository.updateNote(event.note);
      final notes = state.notes.map((n) => n.id == updated.id ? updated : n).toList();
      emit(state.copyWith(notes: notes));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await repository.deleteNote(event.id);
      final notes = state.notes.where((n) => n.id != event.id).toList();
      emit(state.copyWith(notes: notes));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}{{/state_management_bloc}}
''',
  r'lib/src/features/notes/presentation/controllers/notes_controller.dart': r'''{{#state_management_getx}}import 'package:get/get.dart';
{{#di_get_it}}import '../../../../core/di/injection.dart';{{/di_get_it}}

import '../../data/datasources/note_local_source.dart';
import '../../data/datasources/note_remote_source.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/note_repository_impl.dart';

class NotesController extends GetxController {
  {{#di_get_it}}final NoteRepository _repository = getIt<NoteRepository>();{{/di_get_it}}
  {{^di_get_it}}final NoteRepository _repository = NoteRepositoryImpl(
    remoteSource: NoteRemoteSourceImpl(),
    localSource: NoteLocalSourceImpl(),
  );{{/di_get_it}}

  final notes = <Note>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _repository.getNotes();
      notes.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNote(Note note) async {
    try {
      final created = await _repository.createNote(note);
      notes.add(created);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updated = await _repository.updateNote(note);
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) notes[index] = updated;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      notes.removeWhere((n) => n.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }
}{{/state_management_getx}}
''',
  r'lib/src/features/notes/presentation/notifiers/notes_notifier.dart': r'''{{#uses_notes_notifier}}import 'package:flutter/foundation.dart';
{{#di_get_it}}import '../../../../core/di/injection.dart';{{/di_get_it}}
{{#di_injectable}}import '../../../../core/di/injection.dart';{{/di_injectable}}

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

class NotesNotifier extends ChangeNotifier {
  {{#di_get_it}}final NoteRepository _repository = getIt<NoteRepository>();{{/di_get_it}}
  {{#di_injectable}}final NoteRepository _repository = getIt<NoteRepository>();{{/di_injectable}}
  {{^di_get_it}}{{^di_injectable}}final NoteRepository _repository;{{/di_injectable}}{{/di_get_it}}
  {{^di_get_it}}{{^di_injectable}}NotesNotifier({required NoteRepository repository}) : _repository = repository;{{/di_injectable}}{{/di_get_it}}

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _repository.getNotes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createNote(Note note) async {
    try {
      final created = await _repository.createNote(note);
      _notes.add(created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updated = await _repository.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      _notes.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}{{/uses_notes_notifier}}
''',
  r'lib/src/features/notes/presentation/pages/db_viewer_page.dart': r'''{{#db_debugger_drift_db_viewer}}{{#ui_toolkit_material}}import 'package:flutter/material.dart';{{/ui_toolkit_material}}
{{#ui_toolkit_shadcn}}import 'package:shadcn_flutter/shadcn_flutter.dart';{{/ui_toolkit_shadcn}}
import 'package:drift_db_viewer/drift_db_viewer.dart';
{{#di_get_it}}import '../../../../core/di/injection.dart';{{/di_get_it}}
import '../../../../core/storage/local_storage_service.dart';

class DbViewerPage extends StatelessWidget {
  const DbViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    {{#di_get_it}}final db = getIt<LocalStorageService>();{{/di_get_it}}
    {{^di_get_it}}final db = LocalStorageService();{{/di_get_it}}
    return Scaffold(
      appBar: AppBar(title: const Text('Database Viewer')),
      body: DriftDbViewer(db: db),
    );
  }
}
{{/db_debugger_drift_db_viewer}}
''',
  r'lib/src/features/notes/presentation/pages/note_detail_page.dart': r'''{{#ui_toolkit_material}}import 'package:flutter/material.dart';{{/ui_toolkit_material}}
{{#ui_toolkit_shadcn}}import 'package:shadcn_flutter/shadcn_flutter.dart';{{/ui_toolkit_shadcn}}
{{#state_management_riverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';{{/state_management_riverpod}}
{{#state_management_bloc}}import 'package:flutter_bloc/flutter_bloc.dart';{{/state_management_bloc}}
{{#state_management_getx}}import 'package:get/get.dart';{{/state_management_getx}}
{{#di_get_it}}import '../../../../core/di/injection.dart';{{/di_get_it}}
{{#di_injectable}}import '../../../../core/di/injection.dart';{{/di_injectable}}

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/note_repository_impl.dart';
import '../../data/datasources/note_local_source.dart';
import '../../data/datasources/note_remote_source.dart';
{{#state_management_riverpod}}import '../providers/notes_provider.dart';{{/state_management_riverpod}}
{{#state_management_bloc}}import '../bloc/notes_bloc.dart';{{/state_management_bloc}}

class NoteDetailPage extends StatefulWidget {
  final Note? note;

  const NoteDetailPage({super.key, this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  {{#state_management_riverpod}}
  void _save(WidgetRef ref) async {
    final repository = ref.read(noteRepositoryProvider);
    final note = widget.note?.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    ) ?? Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.note != null) {
      await repository.updateNote(note);
    } else {
      await repository.createNote(note);
    }
    if (mounted) {
      ref.invalidate(notesProvider);
      context.pop();
    }
  }
  {{/state_management_riverpod}}

  {{^state_management_riverpod}}
  Future<void> _save() async {
    {{#di_get_it}}final repository = getIt<NoteRepository>();{{/di_get_it}}
    {{#di_injectable}}final repository = getIt<NoteRepository>();{{/di_injectable}}
    {{^di_get_it}}{{^di_injectable}}final repository = NoteRepositoryImpl(
      remoteSource: NoteRemoteSourceImpl(),
      localSource: NoteLocalSourceImpl(),
    );{{/di_injectable}}{{/di_get_it}}

    final note = widget.note?.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    ) ?? Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.note != null) {
      await repository.updateNote(note);
    } else {
      await repository.createNote(note);
    }
    if (mounted) {
      {{#state_management_getx}}Get.back();{{/state_management_getx}}
      {{^state_management_getx}}Navigator.of(context).pop();{{/state_management_getx}}
    }
  }
  {{/state_management_riverpod}}

  {{#state_management_bloc}}
  void _saveWithBloc() {
    final bloc = context.read<NotesBloc>();
    final note = widget.note?.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    ) ?? Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.note != null) {
      bloc.add(UpdateNote(note));
    } else {
      bloc.add(CreateNote(note));
    }
    Navigator.of(context).pop();
  }
  {{/state_management_bloc}}

  @override
  Widget build(BuildContext context) {
    {{#state_management_riverpod}}
    return Consumer(builder: (context, ref, _) {
      return _buildScaffold(() => _save(ref));
    });
    {{/state_management_riverpod}}
    {{^state_management_riverpod}}
    {{#state_management_bloc}}
    return _buildScaffold(_saveWithBloc);
    {{/state_management_bloc}}
    {{^state_management_bloc}}
    return _buildScaffold(_save);
    {{/state_management_bloc}}
    {{/state_management_riverpod}}
  }

  Widget _buildScaffold(VoidCallback onSave) {
    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: onSave,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: onSave,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );{{/ui_toolkit_shadcn}}
  }
}
''',
  r'lib/src/features/notes/presentation/pages/notes_notifier.dart': r'''{{#state_management_none}}import '../../domain/entities/note.dart';

class NotesNotifier {
  List<Note> notes = [];
  bool isLoading = false;
  String? error;
}{{/state_management_none}}
''',
  r'lib/src/features/notes/presentation/pages/notes_page.dart': r'''{{#ui_toolkit_material}}import 'package:flutter/material.dart';{{/ui_toolkit_material}}
{{#ui_toolkit_shadcn}}import 'package:shadcn_flutter/shadcn_flutter.dart';{{/ui_toolkit_shadcn}}
{{#state_management_riverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';{{/state_management_riverpod}}
{{#state_management_provider}}import 'package:provider/provider.dart';{{/state_management_provider}}
{{#state_management_bloc}}import 'package:flutter_bloc/flutter_bloc.dart';{{/state_management_bloc}}
{{#state_management_getx}}import 'package:get/get.dart';{{/state_management_getx}}
{{#state_management_mobx}}import 'package:flutter_mobx/flutter_mobx.dart';{{/state_management_mobx}}
{{#state_management_signals}}import 'package:signals_flutter/signals_flutter.dart';{{/state_management_signals}}
{{#di_get_it}}import '../../../../core/di/injection.dart';{{/di_get_it}}
{{#di_injectable}}import '../../../../core/di/injection.dart';{{/di_injectable}}

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/note_repository_impl.dart';
import '../../data/datasources/note_local_source.dart';
import '../../data/datasources/note_remote_source.dart';
import '../widgets/note_card.dart';
{{#state_management_none}}import 'notes_notifier.dart';{{/state_management_none}}
{{#state_management_provider}}import '../notifiers/notes_notifier.dart';{{/state_management_provider}}
{{#state_management_riverpod}}import '../providers/notes_provider.dart';{{/state_management_riverpod}}
{{#state_management_bloc}}import '../bloc/notes_bloc.dart';{{/state_management_bloc}}
{{#state_management_getx}}import '../controllers/notes_controller.dart';{{/state_management_getx}}
{{#state_management_mobx}}import '../stores/notes_store.dart';{{/state_management_mobx}}
{{#state_management_signals}}import '../signals/notes_signal.dart';{{/state_management_signals}}
import 'note_detail_page.dart';

{{#state_management_riverpod}}
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('No notes yet'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) => NoteCard(
                  note: notes[index],
                  onTap: () => _navigateToDetail(context, note: notes[index]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('No notes yet'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) => NoteCard(
                  note: notes[index],
                  onTap: () => _navigateToDetail(context, note: notes[index]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );{{/ui_toolkit_shadcn}}
  }

  void _navigateToDetail(BuildContext context, {Note? note}) {
    context.push('/detail${note != null ? '/${note.id}' : ''}');
  }
}
{{/state_management_riverpod}}

{{#state_management_bloc}}
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc({{#di_get_it}}repository: getIt<NoteRepository>(){{/di_get_it}}{{#di_injectable}}repository: getIt<NoteRepository>(){{/di_injectable}}{{^di_get_it}}{{^di_injectable}}repository: NoteRepositoryImpl(
        remoteSource: NoteRemoteSourceImpl(),
        localSource: NoteLocalSourceImpl(),
      ){{/di_injectable}}{{/di_get_it}})..add(LoadNotes()),
      child: {{#ui_toolkit_material}}Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToDetail(context),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }
            final notes = state.notes;
            if (notes.isEmpty) {
              return const Center(child: Text('No notes yet'));
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) => NoteCard(
                note: notes[index],
                onTap: () => _navigateToDetail(context, note: notes[index]),
              ),
            );
          },
        ),
      ){{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToDetail(context),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }
            final notes = state.notes;
            if (notes.isEmpty) {
              return const Center(child: Text('No notes yet'));
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) => NoteCard(
                note: notes[index],
                onTap: () => _navigateToDetail(context, note: notes[index]),
              ),
            );
          },
        ),
      ){{/ui_toolkit_shadcn}},
    );
  }

  void _navigateToDetail(BuildContext context, {Note? note}) {
    context.push('/detail${note != null ? '/${note.id}' : ''}');
  }
}
{{/state_management_bloc}}

{{#state_management_provider}}
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<NotesNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notifier.error != null) {
            return Center(child: Text('Error: ${notifier.error}'));
          }
          final notes = notifier.notes;
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) => NoteCard(
              note: notes[index],
              onTap: () => _navigateToDetail(context, note: notes[index]),
            ),
          );
        },
      ),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<NotesNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notifier.error != null) {
            return Center(child: Text('Error: ${notifier.error}'));
          }
          final notes = notifier.notes;
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) => NoteCard(
              note: notes[index],
              onTap: () => _navigateToDetail(context, note: notes[index]),
            ),
          );
        },
      ),
    );{{/ui_toolkit_shadcn}}
  }

  void _navigateToDetail(BuildContext context, {Note? note}) {
    context.push('/detail${note != null ? '/${note.id}' : ''}');
  }
}
{{/state_management_provider}}

{{#state_management_getx}}
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());

    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NoteDetailPage()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(child: Text('Error: ${controller.error.value}'));
        }
        final notes = controller.notes;
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteCard(
            note: notes[index],
            onTap: () => Get.to(() => NoteDetailPage(note: notes[index])),
          ),
        );
      }),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NoteDetailPage()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(child: Text('Error: ${controller.error.value}'));
        }
        final notes = controller.notes;
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteCard(
            note: notes[index],
            onTap: () => Get.to(() => NoteDetailPage(note: notes[index])),
          ),
        );
      }),
    );{{/ui_toolkit_shadcn}}
  }
}
{{/state_management_getx}}

{{#state_management_mobx}}
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _store = NotesStore();

  @override
  void initState() {
    super.initState();
    _store.loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: Observer(builder: (_) {
        if (_store.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_store.error != null) {
          return Center(child: Text('Error: ${_store.error}'));
        }
        final notes = _store.notes;
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteCard(
            note: notes[index],
            onTap: () => _navigateToDetail(context, note: notes[index]),
          ),
        );
      }),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: Observer(builder: (_) {
        if (_store.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_store.error != null) {
          return Center(child: Text('Error: ${_store.error}'));
        }
        final notes = _store.notes;
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteCard(
            note: notes[index],
            onTap: () => _navigateToDetail(context, note: notes[index]),
          ),
        );
      }),
    );{{/ui_toolkit_shadcn}}
  }

  void _navigateToDetail(BuildContext context, {Note? note}) {
    context.push('/detail${note != null ? '/${note.id}' : ''}');
  }
}
{{/state_management_mobx}}

{{#state_management_signals}}
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: Watch((context) {
        if (notesLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notesError.value != null) {
          return Center(child: Text('Error: ${notesError.value}'));
        }
        final notes = notesList.value;
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteCard(
            note: notes[index],
            onTap: () => _navigateToDetail(context, note: notes[index]),
          ),
        );
      }),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(context),
        child: const Icon(Icons.add),
      ),
      body: Watch((context) {
        if (notesLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notesError.value != null) {
          return Center(child: Text('Error: ${notesError.value}'));
        }
        final notes = notesList.value;
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => NoteCard(
            note: notes[index],
            onTap: () => _navigateToDetail(context, note: notes[index]),
          ),
        );
      }),
    );{{/ui_toolkit_shadcn}}
  }

  void _navigateToDetail(BuildContext context, {Note? note}) {
    context.push('/detail${note != null ? '/${note.id}' : ''}');
  }
}
{{/state_management_signals}}

{{#state_management_none}}
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _notifier = NotesNotifier();
  final _repository = NoteRepositoryImpl(
    remoteSource: NoteRemoteSourceImpl(),
    localSource: NoteLocalSourceImpl(),
  );

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _notifier.isLoading = true);
    try {
      final notes = await _repository.getNotes();
      setState(() {
        _notifier.notes = notes;
        _notifier.isLoading = false;
      });
    } catch (e) {
      setState(() {
        _notifier.error = e.toString();
        _notifier.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return {{#ui_toolkit_material}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NoteDetailPage()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
      body: _notifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifier.error != null
              ? Center(child: Text('Error: ${_notifier.error}'))
              : _notifier.notes.isEmpty
                  ? const Center(child: Text('No notes yet'))
                  : RefreshIndicator(
                      onRefresh: _loadNotes,
                      child: ListView.builder(
                        itemCount: _notifier.notes.length,
                        itemBuilder: (context, index) => NoteCard(
                          note: _notifier.notes[index],
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NoteDetailPage(note: _notifier.notes[index]),
                              ),
                            );
                            _loadNotes();
                          },
                        ),
                      ),
                    ),
    );{{/ui_toolkit_material}}{{#ui_toolkit_shadcn}}Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NoteDetailPage()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
      body: _notifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifier.error != null
              ? Center(child: Text('Error: ${_notifier.error}'))
              : _notifier.notes.isEmpty
                  ? const Center(child: Text('No notes yet'))
                  : ListView.builder(
                      itemCount: _notifier.notes.length,
                      itemBuilder: (context, index) => NoteCard(
                        note: _notifier.notes[index],
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteDetailPage(note: _notifier.notes[index]),
                            ),
                          );
                          _loadNotes();
                        },
                      ),
                    ),
    );{{/ui_toolkit_shadcn}}
  }
}
{{/state_management_none}}


''',
  r'lib/src/features/notes/presentation/providers/notes_provider.dart': r'''{{#state_management_riverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';
{{#di_get_it}}import '../../../../core/di/injection.dart';{{/di_get_it}}

import '../../data/datasources/note_local_source.dart';
import '../../data/datasources/note_remote_source.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/note_repository_impl.dart';

{{#di_get_it}}final noteRepositoryProvider = Provider<NoteRepository>((ref) => getIt<NoteRepository>());{{/di_get_it}}
{{^di_get_it}}final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepositoryImpl(
  remoteSource: NoteRemoteSourceImpl(),
  localSource: NoteLocalSourceImpl(),
));{{/di_get_it}}

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNotes();
});{{/state_management_riverpod}}
''',
  r'lib/src/features/notes/presentation/signals/notes_signal.dart': r'''{{#state_management_signals}}import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

final notesList = signal<List<Note>>([]);
final notesLoading = signal<bool>(false);
final notesError = signal<String?>(null);

late NoteRepository _notesRepository;

void initNotesSignals(NoteRepository repository) {
  _notesRepository = repository;
}

Future<void> loadNotes() async {
  notesLoading.value = true;
  notesError.value = null;
  try {
    notesList.value = await _notesRepository.getNotes();
  } catch (e) {
    notesError.value = e.toString();
  } finally {
    notesLoading.value = false;
  }
}

Future<void> createNote(Note note) async {
  try {
    final created = await _notesRepository.createNote(note);
    notesList.value = [...notesList.value, created];
  } catch (e) {
    notesError.value = e.toString();
  }
}

Future<void> updateNote(Note note) async {
  try {
    final updated = await _notesRepository.updateNote(note);
    notesList.value = notesList.value.map((n) => n.id == updated.id ? updated : n).toList();
  } catch (e) {
    notesError.value = e.toString();
  }
}

Future<void> deleteNoteSignal(String id) async {
  try {
    await _notesRepository.deleteNote(id);
    notesList.value = notesList.value.where((n) => n.id != id).toList();
  } catch (e) {
    notesError.value = e.toString();
  }
}{{/state_management_signals}}
''',
  r'lib/src/features/notes/presentation/stores/notes_store.dart': r'''{{#state_management_mobx}}import 'package:mobx/mobx.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

// part of 'notes_store.g.dart'; // Uncomment after running build_runner

class NotesStore = NotesStoreBase with _\$NotesStore;

abstract class NotesStoreBase with Store {
  final NoteRepository _repository;

  NotesStoreBase({required NoteRepository repository}) : _repository = repository;

  @observable
  List<Note> notes = [];

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @action
  Future<void> loadNotes() async {
    isLoading = true;
    error = null;
    try {
      notes = await _repository.getNotes();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> createNote(Note note) async {
    try {
      final created = await _repository.createNote(note);
      notes = [...notes, created];
    } catch (e) {
      error = e.toString();
    }
  }

  @action
  Future<void> updateNote(Note note) async {
    try {
      final updated = await _repository.updateNote(note);
      notes = notes.map((n) => n.id == updated.id ? updated : n).toList();
    } catch (e) {
      error = e.toString();
    }
  }

  @action
  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      notes = notes.where((n) => n.id != id).toList();
    } catch (e) {
      error = e.toString();
    }
  }
}{{/state_management_mobx}}
''',
  r'lib/src/features/notes/presentation/widgets/note_card.dart': r'''{{#ui_toolkit_material}}import 'package:flutter/material.dart';{{/ui_toolkit_material}}
{{#ui_toolkit_shadcn}}import 'package:shadcn_flutter/shadcn_flutter.dart';{{/ui_toolkit_shadcn}}

import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    {{#ui_toolkit_material}}return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(
          '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );{{/ui_toolkit_material}}
    {{#ui_toolkit_shadcn}}return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(
          '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );{{/ui_toolkit_shadcn}}
  }
}
''',
  r'linux/.gitkeep': r'''
''',
  r'macos/.gitkeep': r'''
''',
  r'openapi/spec.json': r'''{{#api_openapi}}{
  "openapi": "3.0.0",
  "info": {
    "title": "{{project_name}} API",
    "version": "1.0.0"
  },
  "paths": {}
}
{{/api_openapi}}
''',
  r'pubspec.yaml': r'''name: {{project_name.snakeCase()}}
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.7.2

dependencies:
  flutter:
    sdk: flutter
{{#ui_toolkit_material}}
  cupertino_icons: ^1.0.8
{{/ui_toolkit_material}}
{{#state_management_provider}}
  provider: ^6.1.0
{{/state_management_provider}}
{{#state_management_riverpod}}
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.3.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
{{/state_management_riverpod}}
{{#state_management_bloc}}
  flutter_bloc: ^9.0.0
  bloc: ^9.0.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
{{/state_management_bloc}}
{{#state_management_getx}}
  get: ^4.6.0
{{/state_management_getx}}
{{#state_management_mobx}}
  mobx: ^2.3.0
  flutter_mobx: ^2.2.0
{{/state_management_mobx}}
{{#state_management_signals}}
  signals_flutter: ^5.5.0
{{/state_management_signals}}
  go_router: ^14.6.0
{{#di_get_it}}
  get_it: ^8.0.0
{{/di_get_it}}
{{#di_injectable}}
  get_it: ^8.0.0
  injectable: ^2.4.0
{{/di_injectable}}
{{#network_http}}
  http: ^1.2.0
{{/network_http}}
{{#network_dio}}
  dio: ^5.7.0
{{/network_dio}}
{{#network_rhttp}}
  rhttp: ^0.16.0
{{/network_rhttp}}
{{#storage_shared_preferences}}
  shared_preferences: ^2.3.0
{{/storage_shared_preferences}}
{{#storage_hive_ce}}
  hive_ce: ^2.10.0
  hive_ce_flutter: ^2.3.0
{{/storage_hive_ce}}
{{#storage_isar_community}}
  isar_community: ^3.3.0
  isar_community_flutter_libs: ^3.3.0
{{/storage_isar_community}}
{{#storage_drift}}
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.0
{{/storage_drift}}
{{#ui_toolkit_shadcn}}
  shadcn_flutter: ^0.0.52
{{/ui_toolkit_shadcn}}
{{#env_flutter_dotenv}}
  flutter_dotenv: ^6.0.0
{{/env_flutter_dotenv}}
{{#env_dotenv}}
  dotenv: ^4.2.0
{{/env_dotenv}}
{{#logging_logging}}
  logging: ^1.3.0
{{/logging_logging}}
{{#logging_logger}}
  logger: ^2.5.0
{{/logging_logger}}
{{#attach_logger_to_http_dio}}
  dio_logger_plus: ^1.0.0
{{/attach_logger_to_http_dio}}
{{#db_debugger_drift_db_viewer}}
  drift_db_viewer: ^2.0.0
{{/db_debugger_drift_db_viewer}}
{{#api_openapi}}
  openapi_generator_annotations: ^6.1.0
  json_annotation: ^4.9.0
{{#openapi_dart}}
  http: ^1.2.0
{{/openapi_dart}}
{{#openapi_dio}}
  dio: ^5.7.0
{{/openapi_dio}}
{{#openapi_dio_alt}}
  dio: ^5.7.0
{{/openapi_dio_alt}}
{{/api_openapi}}

dev_dependencies:
  flutter_test:
    sdk: flutter
{{#linting_flutter_lints}}
  flutter_lints: ^5.0.0
{{/linting_flutter_lints}}
{{#linting_very_good_analysis}}
  very_good_analysis: ^6.0.0
{{/linting_very_good_analysis}}
{{#state_management_riverpod}}
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
{{/state_management_riverpod}}
{{#state_management_bloc}}
  bloc_test: ^9.0.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
{{/state_management_bloc}}
{{#state_management_mobx}}
  mobx_codegen: ^2.6.0
  build_runner: ^2.4.0
{{/state_management_mobx}}
{{#di_injectable}}
  injectable_generator: ^2.6.0
  build_runner: ^2.4.0
{{/di_injectable}}
{{#storage_isar_community}}
  isar_community_generator: ^3.3.0
  build_runner: ^2.4.0
{{/storage_isar_community}}
{{#storage_drift}}
  drift_dev: ^2.22.0
  build_runner: ^2.4.0
{{/storage_drift}}
{{#api_openapi}}
  openapi_generator: ^6.1.0
{{#openapi_dio}}
  build_runner: ^2.4.0
{{/openapi_dio}}
{{/api_openapi}}

flutter:
  uses-material-design: true
{{#env_flutter_dotenv}}
  assets:
    - .env
{{/env_flutter_dotenv}}
''',
  r'test/widget_test.dart': r'''import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test', () {
    expect(1 + 1, equals(2));
  });
}
''',
  r'web/index.html': r'''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{project_name}}</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
''',
  r'windows/.gitkeep': r'''
''',
};
